#!/bin/bash

# 운영체제 확인
if [[ $(cat /etc/os-release | grep "^ID=" | awk -F'=' '{print $2}' | tr -d '"') == "ubuntu" ]]; then
    PACKAGE_MANAGER="apt-get"
    SERVICE_NAME="chrony.service"
    CONFIG_FILE_PATH="/etc/chrony/chrony.conf"
    sudo $PACKAGE_MANAGER update
elif [[ $(cat /etc/os-release | grep "^ID=" | awk -F'=' '{print $2}' | tr -d '"') == "centos" ]]; then
    PACKAGE_MANAGER="yum"
    SERVICE_NAME="chronyd.service"
    CONFIG_FILE_PATH="/etc/chrony.conf"
elif [[ $(cat /etc/os-release | grep "^ID=" | awk -F'=' '{print $2}' | tr -d '"') == "amzn" ]]; then
    PACKAGE_MANAGER="yum"
    SERVICE_NAME="chronyd.service"
    CONFIG_FILE_PATH="/etc/chrony.conf"
else
    echo "지원하지 않는 운영체제입니다."
    exit 1
fi

# chrony 설치
sudo $PACKAGE_MANAGER install -y chrony

# chrony 서비스 시작
sudo systemctl --now enable $SERVICE_NAME

# 기본 설정 파일 백업
sudo cp $CONFIG_FILE_PATH $CONFIG_FILE_PATH.bak

# 서버 설정 추가
cat <<EOF > $CONFIG_FILE_PATH
server 169.254.169.123 iburst
server time.bora.net iburst
server times.postech.ac.kr iburst

driftfile /var/lib/chrony/drift

makestep 1.0 3

rtcsync

logdir /var/log/chrony
EOF

# chrony 서비스 재시작
sudo systemctl restart $SERVICE_NAME

# 현재 chrony가 사용 중인 서버들의 상태
echo -e "\n### chronyc sourcestats -v"
chronyc sourcestats -v

# 현재 chrony가 사용 중인 시간 서버들의 상태
echo -e "\n### chronyc sources -v"
chronyc sources -v

# 현재 시스템의 시간 추적 정보를 출력
echo -e "\n### chronyc tracking"
chronyc tracking

echo -e "\n"
