#!/bin/bash
set -x

# Amazon Linux 2 PHP-FPM 8.1 설치 스크립트

# 패키지 업데이트
###sudo yum install -y epel-release
sudo amazon-linux-extras install -y epel

# PHP 저장소 추가 및 PHP 8.1 설치
sudo amazon-linux-extras install -y php8.1

# PHP-FPM 및 관련 패키지 설치
sudo yum install -y php-fpm php-cli php-common php-json php-xml php-mbstring php-gd php-curl 
#sudo yum install -y php-zip php-redis php-mongodb 

# PHP-FPM 서비스 시작 및 활성화
sudo systemctl --now enable php-fpm

# PHP-FPM 버전 확인
php-fpm --version

echo "PHP-FPM 8.1 설치가 완료되었습니다."
