#!/bin/bash

# 필요한 명령어 확인
sudo apt-get update
command -v curl >/dev/null 2>&1 || { echo >&2 "curl이 설치되어 있지 않습니다."; sudo apt-get install -y curl; }
command -v jq >/dev/null 2>&1 || { echo >&2 "jq가 설치되어 있지 않습니다."; sudo apt-get install -y jq; }

# 최신 cfssl 버전 가져오기
LATEST_VERSION=$(curl -fsSL "https://api.github.com/repos/cloudflare/cfssl/releases/latest" | jq -r '.tag_name' | sed 's/^v//')
if [ -z "$LATEST_VERSION" ]; then
    echo "최신 버전 정보를 가져오는 데 실패했습니다."
    exit 1
fi

# cfssl 다운로드 및 설치
curl -fsSL https://github.com/cloudflare/cfssl/releases/download/v${LATEST_VERSION}/cfssl_${LATEST_VERSION}_linux_amd64 -o /usr/local/bin/cfssl
chmod +x /usr/local/bin/cfssl

# cfssljson 다운로드 및 설치
curl -fsSL https://github.com/cloudflare/cfssl/releases/download/v${LATEST_VERSION}/cfssljson_${LATEST_VERSION}_linux_amd64 -o /usr/local/bin/cfssljson
chmod +x /usr/local/bin/cfssljson

# 버전 확인
cfssl version
cfssljson --version



### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/install_cfssl.sh | bash
