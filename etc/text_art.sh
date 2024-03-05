#!/bin/bash

# 다음 명령을 사용하여 OS 유형을 확인합니다.
if command -v apt &> /dev/null; then
    # Ubuntu
    sudo apt-get update
    sudo apt-get install -y lolcat figlet cowsay fortune
elif command -v yum &> /dev/null; then
    # CentOS
    sudo yum install -y epel-release
    sudo yum update
    sudo yum install -y lolcat figlet cowsay fortune-mod
else
    echo "Unsupported operating system."
    exit 1
fi



### Shell Execute Commands
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/text_art.sh | bash
#
