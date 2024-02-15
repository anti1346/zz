#!/bin/bash

# Check if packer is already installed
if [ -x "$(command -v ansible)" ]; then
  echo "Ansible is already installed. Exiting..."
  exit 0
fi

# 우분투 패키지 업데이트
sudo apt-get update

# 소프트웨어 소스 관리 도구 및 HTTPS 지원 패키지 설치
sudo apt-get install -y software-properties-common apt-transport-https

# Ansible 공식 저장소 추가 및 키 가져오기
sudo apt-add-repository --yes --update ppa:ansible/ansible

# 최신 버전의 Ansible 설치
sudo apt-get install -y ansible
