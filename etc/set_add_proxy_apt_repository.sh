#!/bin/bash

# 사용 방법 표시
if [ "$#" -eq 0 ]; then
    echo "사용법: $0 [프록시서버IP:포트]"
    exit 1
fi

# 프록시 서버 IP와 포트를 변수에 저장
proxy_server="$1"

# 프록시 서버 IP와 포트 형식 확인
if ! [[ "$proxy_server" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$ ]]; then
    echo "오류: 올바른 프록시 서버 IP와 포트를 입력하세요. (예: 192.168.1.100:3128)"
    exit 1
fi

# 이미 파일이 존재하는지 확인
proxy_file="/etc/apt/apt.conf.d/00proxy"
if [ -e "$proxy_file" ]; then
    echo "경고: 이미 $proxy_file 파일이 존재합니다."
    echo "프록시 설정을 추가하려면 파일을 직접 편집하세요."
    exit 1
fi

# 프록시 설정 추가
cat <<EOF | sudo tee "$proxy_file" >/dev/null
### Proxy Server
Acquire::http::Proxy "http://$proxy_server";
Acquire::https::Proxy "http://$proxy_server";
EOF

echo "프록시 설정이 추가되었습니다."
