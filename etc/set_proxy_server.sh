#!/bin/bash

# 제공된 인수 또는 기본값을 사용하여 프록시 서버 및 포트를 설정합니다.
proxy_server="${1:-192.168.0.100:8080}"
proxy_path="${2:-~/.bashrc}"

# 지정된 파일에 프록시 변수가 이미 설정되어 있는지 확인합니다.-
if ! grep -q 'http_proxy\|https_proxy' "$proxy_path"; then
    # 지정된 파일에 프록시 설정 추가
    cat <<EOF >> "$proxy_path"
### Proxy Server
export http_proxy=http://$proxy_server
export https_proxy=http://$proxy_server
EOF

    # Source the updated file to apply changes
    source "$proxy_path"

    echo "Proxy settings applied."
else
    echo "Proxy settings already exist in $proxy_path. No changes made."
fi
