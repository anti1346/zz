#!/bin/bash

# Vault 버전 및 다운로드 URL 설정
VAULT_VERSION="1.13.2"
VAULT_ZIP="vault_${VAULT_VERSION}_linux_amd64.zip"
VAULT_URL="https://releases.hashicorp.com/vault/${VAULT_VERSION}/${VAULT_ZIP}"

# Vault 다운로드 및 설치
curl -LO "${VAULT_URL}"
unzip "${VAULT_ZIP}"
sudo mv vault /usr/local/bin/

# 설치 확인
vault --version
