#!/bin/bash

# # Amazon Linux 2
# $ uname -a
# Linux node1 5.10.157-139.675.amzn2.x86_64 #1 SMP Thu Dec 8 01:29:11 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux

# # CentOS 7
# $ uname -a
# Linux node1 5.15.0-72-generic #79-Ubuntu SMP Wed Apr 19 08:22:18 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux

# # Ubuntu
# $ uname -a
# Linux node1 3.10.0-1160.76.1.el7.x86_64 #1 SMP Wed Aug 10 16:21:17 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux

# Amazon Linux 2
if [[ "$(uname -a)" == *"amzn2"* ]]; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
# CentOS 7
elif [[ "$(uname -a)" == *"el7"* ]]; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
# Ubuntu
elif [[ "$(uname -a)" == *"Ubuntu"* ]]; then
    sudo apt-get update -qq
    sudo apt-get install -qq -y unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
else
    echo "Unsupported operating system."
    exit 1
fi

# lsb_release 명령으로 운영체제 판단
# if command -v apt >/dev/null; then
#     echo "Linux Distribution : Debian"
#     apt update -qq -y >/dev/null 2>&1
#     apt install -qq -y lsb-release >/dev/null 2>&1
#     lsb_release -ds
# elif command -v yum >/dev/null; then
#     echo "Linux Distribution : RedHat"
#     yum install -q -y redhat-lsb-core >/dev/null 2>&1
#     lsb_release -ds | tr -d '"'
# else
#     echo "other OS"
# fi