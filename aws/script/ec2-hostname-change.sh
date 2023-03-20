#!/bin/bash

if ! command -v jq &> /dev/null
then
    echo -e "\njq 패키지가 설치되어 있지 않습니다. 패키지를 설치합니다."
    if [[ $(cat /etc/os-release | grep "^ID=" | awk -F'=' '{print $2}' | tr -d '"') == "ubuntu" ]]; then
        sudo apt-get update
        sudo apt-get install -y jq
    elif [[ $(cat /etc/os-release | grep "^ID=" | awk -F'=' '{print $2}' | tr -d '"') == "centos" ]]; then
        sudo yum install -y epel-release
        sudo yum install -y jq
    elif [[ $(cat /etc/os-release | grep "^ID=" | awk -F'=' '{print $2}' | tr -d '"') == "amzn" ]]; then
        sudo amazon-linux-extras install -y epel
        sudo yum install -y jq
    else
        echo -e "\n지원하지 않는 운영체제입니다."
        exit 1
    fi
else
    echo -e "\njq 패키지가 이미 설치되어 있습니다."
fi

if ! [ -x "$(command -v aws)" ] || [ "$(aws --version | cut -d' ' -f1 | cut -d'/' -f2 | cut -c1)" != "1" ]; then
    echo -e "\nAWS CLI v2 패키지가 설치되어 있지 않거나 버전이 1이며 패키지를 재설치합니다."
    sudo rm -rf /usr/bin/aws
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    sudo aws --version
else
    echo -e "\nAWS CLI v2 패키지가 이미 설치되어 있습니다."
    sudo aws --version
fi

instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

hostname=$(aws --region ${region} ec2 describe-instances \
    --instance-ids ${instance_id} \
    --query "Reservations[].Instances[].Tags[?Key=='Name'].Value[]" \
    --output text)

sudo hostnamectl set-hostname ${hostname}

echo "Hostname set to ${hostname}"
