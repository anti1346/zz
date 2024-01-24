#!/bin/bash

user_id=$(whoami)

# 제공된 인수 또는 기본값을 사용하여 프록시 서버 및 포트를 설정합니다.
proxy_server="${1:-ProxyServerIP:3128}"
proxy_path="${2:-/$user_id/.bashrc}"

# 지정된 파일에 프록시 변수가 이미 설정되어 있는지 확인합니다.
if [ -e "$proxy_path" ] && ! grep -q 'http_proxy\|https_proxy' "$proxy_path"; then
    # 지정된 파일에 프록시 설정 추가
    cat <<EOF >> "$proxy_path"

### Proxy Server
export http_proxy=http://$proxy_server
export https_proxy=http://$proxy_server
EOF

    # 업데이트된 파일을 소싱하여 변경 사항 적용
    source "$proxy_path"

    echo "Proxy settings applied."
elif [ ! -e "$proxy_path" ]; then
    echo "Error: The specified file $proxy_path does not exist."
else
    echo "Proxy settings already exist in $proxy_path. No changes made."
fi


### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/set_proxy_server.sh | bash
#
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/set_proxy_server.sh | bash -s proxy_server:8080 /tmp/bb
