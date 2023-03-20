#!/bin/bash

# 운영체제 확인
if [[ $(cat /etc/os-release | grep "^ID=" | awk -F'=' '{print $2}') == "ubuntu" ]]; then
    PACKAGE_MANAGER="apt-get"
    SERVICE_NAME="chrony.service"
    CONFIG_FILE_PATH="/etc/chrony/chrony.conf"
    sudo $PACKAGE_MANAGER update
elif [[ $(cat /etc/os-release | grep "^ID=" | awk -F'=' '{print $2}') == "centos" || $(cat /etc/os-release | grep "^ID=" | awk -F'=' '{print $2}') == "amzn" ]]; then
    PACKAGE_MANAGER="yum"
    SERVICE_NAME="chronyd.service"
    CONFIG_FILE_PATH="/etc/chrony.conf"
else
    echo "지원하지 않는 운영체제입니다."
    exit 1
fi

# # chrony 설치
# sudo $PACKAGE_MANAGER install chrony -y

# # 기본 설정 파일 백업
# sudo cp $CONFIG_FILE_PATH $CONFIG_FILE_PATH.bak

# # 서버 설정 추가
# cat <<EOF > $CONFIG_FILE_PATH
# server 169.254.169.123 iburst
# server time.bora.net iburst
# server times.postech.ac.kr iburst

# driftfile /var/lib/chrony/drift

# makestep 1.0 3

# rtcsync

# logdir /var/log/chrony

# EOF

# # chrony 서비스 재시작
# sudo systemctl restart $SERVICE_NAME

# chronyc sourcestats -v

# chronyc sources -v

# chronyc tracking