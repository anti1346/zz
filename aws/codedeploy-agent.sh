#!/bin/bash

# 리눅스 배포판 확인
os_distribution=$(grep -oP '(?<=^PRETTY_NAME=")(.*)(?=")' /etc/os-release)

case "$os_distribution" in
  "Amazon Linux 2")
    package_manager="yum"
    sudo amazon-linux-extras install -y ruby3.0
    ;;
  "CentOS Linux"*)
    package_manager="yum"
    sudo yum install -y ruby
    ;;
  "Ubuntu"*)
    package_manager="apt"
    sudo apt-get install -y ruby
    ;;
  *)
    echo "지원되지 않는 운영 체제 배포판"
    exit 1
    ;;
esac

# 필수 패키지 설치
sudo $package_manager install -y curl jq

# AWS CodeDeploy 에이전트 서비스 중지 및 제거
sudo systemctl stop codedeploy-agent
#sudo systemctl disable codedeploy-agent
sudo $package_manager erase -y codedeploy-agent

# 기존 AWS CodeDeploy 에이전트 파일 제거
sudo rm -rf /opt/codedeploy-agent

# AWS CodeDeploy 에이전트 디렉토리 생성
sudo mkdir -p /opt/codedeploy-agent

# AWS CodeDeploy 에이전트 다운로드 및 설치
#wget -q https://aws-codedeploy-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/latest/install -O install
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
wget -q "https://aws-codedeploy-${REGION}.s3.${REGION}.amazonaws.com/latest/install" -O /tmp/install
chmod +x /tmp/install
sudo /tmp/install auto

# AWS CodeDeploy 에이전트 업데이트
sudo /opt/codedeploy-agent/bin/install auto

# AWS CodeDeploy 에이전트 서비스 시작 및 활성화
sudo systemctl --now enable codedeploy-agent

# AWS CodeDeploy 에이전트 상태 확인
sudo systemctl status codedeploy-agent
