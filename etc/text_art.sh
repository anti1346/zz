#!/bin/bash

# 1. 관리자 권한 확인
if [[ $EUID -ne 0 ]]; then
   echo "이 스크립트는 sudo 권한으로 실행해야 합니다."
   exit 1
fi

echo "시스템 환경을 확인 중입니다..."

# 2. OS 유형 판별 및 설치
if command -v apt-get &> /dev/null; then
    # Ubuntu / Debian 계열
    echo "OS: Ubuntu/Debian 기반 시스템 감지"
    apt-get update -qq
    apt-get install -y lolcat figlet cowsay fortune-mod fortunes-min > /dev/null
    
elif command -v yum &> /dev/null; then
    # CentOS / RHEL 계열
    echo "OS: CentOS/RHEL 기반 시스템 감지"
    yum install -y -q epel-release
    yum install -y -q lolcat figlet cowsay fortune-mod > /dev/null
    
else
    echo "지원되지 않는 운영체제입니다."
    exit 1
fi

# 3. 설치 완료 확인 및 테스트
echo "----------------------------------------"
if command -v fortune &> /dev/null; then
    fortune | cowsay | lolcat
else
    echo "설치는 완료되었으나 일부 도구를 실행할 수 없습니다."
fi



### Shell Execute Commands
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/text_art.sh | bash
#
