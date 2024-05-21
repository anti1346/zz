#!/bin/bash

# 시스템 업데이트 및 필수 패키지 설치
sudo apt-get update
sudo apt-get install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring

# NGINX 아카이브 키 추가
curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
| sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

# NGINX 저장소 추가
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" \
| sudo tee /etc/apt/sources.list.d/nginx.list

# 패키지 목록 갱신 및 NGINX 설치
sudo apt-get update
sudo apt-get install -y nginx

# NGINX 서비스 활성화 및 시작
sudo systemctl enable --now nginx

echo "NGINX 설치 및 설정이 완료되었습니다."



### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/install_nginx.sh | bash
