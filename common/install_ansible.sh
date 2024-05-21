#!/bin/bash

# Ansible이 이미 설치되어 있는지 확인합니다.
if [ -x "$(command -v ansible)" ]; then
  echo "Ansible is already installed. Exiting..."
  exit 0
fi

# 우분투에 Ansible을 설치합니다.
if command -v apt-get &> /dev/null; then
  # 패키지 목록 업데이트
  sudo apt-get update
  # 소프트웨어 소스 관리 도구 및 HTTPS 지원 패키지 설치
  sudo apt-get install -y software-properties-common apt-transport-https
  # Ansible의 공식 PPA 추가 및 패키지 목록 업데이트
  sudo apt-add-repository --yes --update ppa:ansible/ansible
  # Ansible 설치
  sudo apt-get install -y ansible
  # Ansible 버전 확인
  echo -e "Ansible 버전:\n\n$(ansible --version)"
else
  echo "Unsupported package manager. This script supports only systems with apt-get."
  exit 1
fi
