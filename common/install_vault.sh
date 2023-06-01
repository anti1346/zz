#!/bin/bash

# 아키텍처 확인
ARCH=$(uname -m)
if [[ ${ARCH} == "x86_64" ]]; then
  VAULT_ARCH="amd64"
elif [[ ${ARCH} == "aarch64" ]]; then
  VAULT_ARCH="arm64"
else
  echo "Unsupported architecture: ${ARCH}"
  exit 1
fi

# Vault 버전 및 다운로드 URL 설정
VAULT_VERSION="1.13.2"
VAULT_ZIP="vault_${VAULT_VERSION}_linux_${VAULT_ARCH}.zip"
VAULT_URL="https://releases.hashicorp.com/vault/${VAULT_VERSION}/${VAULT_ZIP}"

# Vault 다운로드 및 설치
curl -LO "${VAULT_URL}"
unzip "${VAULT_ZIP}"
sudo mv vault /usr/local/bin/

# Vault 삭제
rm -f "${VAULT_ZIP}"

# 설치 확인
vault --version

