#!/bin/bash

HTTP_VERSION="${HTTP_VERSION:-2.4.57}"

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
    sudo apt-get install -y libpcre3 libpcre3-dev libssl-dev
elif [[ $OS == "CentOS" ]]; then
# elif [ -f /etc/redhat-release ]; then
    # CentOS
    sudo yum -y install epel-release
    sudo yum -y install apache
    sudo systemctl --now enable apache
    sudo systemctl status apache
    echo -e "\033[38;5;226m\napache 패키지 설치 완료\n\033[0m"
else
    echo -e "\033[38;5;226m\nUnsupported operating system.\n\033[0m"
    exit 1
fi


cd /usr/local/src/
# APR 소스 다운로드
wget https://archive.apache.org/dist/apr/apr-1.7.0.tar.gz
tar -xvzf apr-1.7.0.tar.gz
cd apr-1.7.0

# APR 컴파일 및 설치
./configure
make
sudo make install

cd /usr/local/src/
# APR-util 소스 다운로드
wget https://archive.apache.org/dist/apr/apr-util-1.6.1.tar.gz
tar -xvzf apr-util-1.6.1.tar.gz
cd apr-util-1.6.1

# APR-util 컴파일 및 설치
./configure --with-apr=/usr/local/apr
make
sudo make install

cd /usr/local/src/
# Apache 소스 다운로드
wget https://downloads.apache.org/httpd/httpd-${HTTP_VERSION}.tar.gz
tar -xvzf httpd-${HTTP_VERSION}.tar.gz
cd httpd-${HTTP_VERSION}

# 컴파일 및 설치
./configure \
--prefix=/usr/local/apache \
--enable-mpms-shared=all \
--with-apr=/usr/local/apr/bin/apr-1-config \
--with-apr-util=/usr/local/apr/bin/apu-1-config \
--enable-ssl \
--enable-so \
--enable-rewrite \
--with-mpm=worker

make
sudo make install
echo -e "\033[38;5;226m\napache 소스 컴파일 완료\n\033[0m"