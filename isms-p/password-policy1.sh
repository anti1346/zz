#!/bin/bash

# Password Policy Settings
PW_MIN_LENGTH=8
PW_MIN_CLASSES=3

# Backup Settings
BACKUP_DATE="$(date +%Y%m%d-%H%M%S)"

# Determine Linux Distro and Install Required Packages
if [[ -f /etc/centos-release ]]; then
    DISTRO="CentOS"
    yum install -y libpwquality
elif [[ -f /etc/system-release && $(grep -c "Amazon Linux" /etc/system-release) -eq 1 ]]; then
    DISTRO="Amazon Linux"
    yum install -y libpwquality
elif [[ -f /etc/lsb-release && $(grep -c "DISTRIB_ID=Ubuntu" /etc/lsb-release) -eq 1 ]]; then
    DISTRO="Ubuntu"
    apt-get install -y libpam-pwquality
else
    echo "Unsupported Linux distribution."
    exit 1
fi

### login.defs 파일 수정
sudo cp /etc/login.defs /etc/login.defs.$BACKUP_DATE
sudo sed -i 's/PASS_MAX_DAYS\s*99999/PASS_MAX_DAYS\t90/g' /etc/login.defs
sudo sed -i 's/PASS_MIN_DAYS\s*0/PASS_MIN_DAYS\t1/g' /etc/login.defs
sudo sed -i 's/PASS_WARN_AGE\s*7/PASS_WARN_AGE\t7/g' /etc/login.defs
sudo sed -i 's/#PASS_MIN_LEN/PASS_MIN_LEN\t8/g' /etc/login.defs
