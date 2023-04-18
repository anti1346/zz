#!/bin/bash

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
    # Install prerequisites
    sudo apt install -y curl gnupg2 ca-certificates lsb-release
    # Install apache2
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl --now enable apache2
    sudo systemctl status apache2
    echo -e "\033[38;5;226m\napache2 패키지 설치 완료\n\033[0m"
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
