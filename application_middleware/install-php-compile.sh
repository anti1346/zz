#!/bin/bash

PHP_VERSION="${PHP_VERSION:-8.1.18}"
### Old Stable PHP 8.1.18
### Current Stable PHP 8.2.5

### Check if running on Ubuntu or CentOS
if [[ -x "$(command -v apt-get)" ]]; then
    OS="Ubuntu"
elif [[ -x "$(command -v yum)" ]]; then
    OS="CentOS"
else
    echo -e "\033[38;5;226m\n지원되지 않는 운영 체제입니다.\n\033[0m"
    exit 1
fi

# Check the OS and use the appropriate package manager
if [[ $OS == "Ubuntu" ]]; then
# if [ -f /etc/lsb-release ]; then
    # Ubuntu
    # 필요한 패키지 설치
    sudo apt-get update
    sudo apt-get install -y build-essential
    # 의존성 패키지 설치
    sudo apt-get install -y libxml2-dev libssl-dev libcurl4-openssl-dev libonig-dev libzip-dev
    echo -e "\033[38;5;226m\n패키지 설치 완료\n\033[0m"
elif [[ $OS == "CentOS" ]]; then
# elif [ -f /etc/redhat-release ]; then
    # CentOS
    sudo yum -y install epel-release
    # sudo yum -y install apache
    # sudo systemctl --now enable apache
    # sudo systemctl status apache
    echo -e "\033[38;5;226m\n패키지 설치 완료\n\033[0m"
else
    echo -e "\033[38;5;226m\nUnsupported operating system.\n\033[0m"
    exit 1
fi

# PHP 소스 다운로드
wget https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz
tar -xvzf php-${PHP_VERSION}.tar.gz
cd php-${PHP_VERSION}

# 컴파일 및 설치
./configure \
--prefix=/usr/local/php \
--with-apxs2=/usr/local/apache/bin/apxs \
--with-openssl \
--with-curl \
--with-zlib \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--enable-mbstring \
--enable-xml \
--enable-zip \
--enable-debug
make
sudo make install
echo -e "\033[38;5;226m\nPHP 소스 컴파일 완료\n\033[0m"