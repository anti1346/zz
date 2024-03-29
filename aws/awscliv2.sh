#!/bin/bash

# /var/run/yum.pid 파일이 존재하는지 확인
while [ -f /var/run/yum.pid ]; do
    echo "Waiting for another yum process to finish..."
    sleep 5
done

# Get the installed aws-cli version
#aws_version=$(aws --version | awk '{print $1}' | awk -F'/' '{print $2}')

# Check if AWS CLI version 1 is installed
if aws --version 2>&1 | grep -q "aws-cli/1"; then
    echo "AWS CLI version 1 is installed. Removing..."
    sudo yum -y remove awscli
    echo "AWS CLI version 1 has been removed."
fi

# Verify the installation
if aws --version 2>&1 | grep -q "aws-cli/2"; then
    echo "AWS CLI 버전 2가 설치되었습니다."
    exit 0
fi

# Determine the operating system and install aws-cli accordingly
if [[ "$(uname -a)" == *"amzn2.x86_64"* ]]; then
    # Install on Amazon Linux 2(x86_64)
    os_name="Amazon Linux 2"
    download_url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
elif [[ "$(uname -a)" == *"amzn2.aarch64"* ]]; then
    # Install on Amazon Linux 2(ARM)
    os_name="Amazon Linux 2"
    download_url="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
elif [[ "$(uname -a)" == *"el7"* ]]; then
    # Install on CentOS 7
    os_name="CentOS 7"
    download_url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
elif [[ "$(uname -a)" == *"Ubuntu"* ]]; then
    # Install on Ubuntu
    os_name="Ubuntu"
    sudo apt-get update -qq
    sudo apt-get install -qq -y unzip
    download_url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
else
    echo "Unsupported operating system."
    exit 1
fi

# Download and install aws-cli
curl -fsSL $download_url -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip
sudo /tmp/aws/install
sudo ln -s /usr/local/bin/aws /usr/bin/aws

echo "AWS CLI version: `aws --version`"

# Clean up
rm -rf /tmp/awscliv2.zip /tmp/aws

echo "AWS CLI 버전 2가 설치되었습니다."
