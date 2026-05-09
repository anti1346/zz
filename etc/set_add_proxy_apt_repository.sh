#!/bin/bash

# cat <<EOF >> /etc/apt/apt.conf.d/00proxy
#
# ### Proxy Server
# Acquire::http::Proxy "http://ProxyServerIP:3128";
# Acquire::https::Proxy "http://ProxyServerIP:3128";
# EOF

# 1. 사용법 안내
if [ "$#" -eq 0 ]; then
    echo "사용법: $0 [프록시서버_주소:포트]"
    echo "예시: $0 192.168.1.100:3128 또는 $0 proxy.example.com:3128"
    exit 1
fi

# 2. 변수 설정
PROXY_SERVER="$1"
PROXY_FILE="/etc/apt/apt.conf.d/02proxy"

# 3. 주소 형식 확인 (IP 및 도메인 모두 지원하도록 개선)
# IP:포트 또는 도메인:포트 형식 검사
if ! [[ "$PROXY_SERVER" =~ ^([a-zA-Z0-9.-]+|[0-9.]+):[0-9]+$ ]]; then
    echo "오류: 올바른 프록시 주소 형식이 아닙니다. (예: 10.0.0.1:3128)" >&2
    exit 1
fi

# 4. 권한 및 파일 존재 확인
if [[ $EUID -ne 0 ]]; then
   echo "오류: 이 스크립트는 root 권한(sudo)으로 실행해야 합니다." >&2
   exit 1
fi

if [ -e "$PROXY_FILE" ]; then
    echo "경고: 이미 $PROXY_FILE 파일이 존재합니다."
    read -p "기존 파일을 백업하고 새로 설정하시겠습니까? (y/n): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        mv "$PROXY_FILE" "${PROXY_FILE}.bak_$(date +%Y%m%d)"
        echo "기존 파일이 ${PROXY_FILE}.bak_$(date +%Y%m%d)로 백업되었습니다."
    else
        echo "작업을 취소합니다."
        exit 0
    fi
fi

# 5. 프록시 설정 추가
echo "[$PROXY_FILE] 설정을 생성 중..."
cat <<EOF | tee "$PROXY_FILE" >/dev/null
# Proxy Server 설정 - $(date +%Y-%m-%d)
Acquire::http::Proxy "http://$PROXY_SERVER";
Acquire::https::Proxy "http://$PROXY_SERVER";
EOF

# 6. 보안 권한 설정 (644)
chmod 644 "$PROXY_FILE"

echo "프록시 설정이 성공적으로 완료되었습니다."
echo "확인: cat $PROXY_FILE"

ㄴ

### Shell Execute Command
#
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/set_add_proxy_apt_repository.sh | bash -s ProxyServerIP:3128
