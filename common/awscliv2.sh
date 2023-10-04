#!/bin/bash

# Get the installed aws-cli version
aws_version=$(aws --version | awk '{print $1}' | awk -F'/' '{print $2}')

# Check if aws-cli is already installed
if command -v aws &>/dev/null; then
    echo "AWS CLI is already installed."
    echo "AWS CLI version: $aws_version"
    exit 0
fi

# Determine the operating system and install aws-cli accordingly
if [[ "$(uname -a)" == *"amzn2"* ]]; then
    # Install on Amazon Linux 2
    os_name="Amazon Linux 2"
    download_url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    home_dir="/home/ec2-user"
elif [[ "$(uname -a)" == *"el7"* ]]; then
    # Install on CentOS 7
    os_name="CentOS 7"
    download_url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    home_dir="/root"
elif [[ "$(uname -a)" == *"Ubuntu"* ]]; then
    # Install on Ubuntu
    os_name="Ubuntu"
    sudo apt-get update -qq
    sudo apt-get install -qq -y unzip
    download_url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    home_dir="/home/ubuntu"
else
    echo "Unsupported operating system."
    exit 1
fi

# Download and install aws-cli
curl -fsSL "$download_url" -o "$home_dir/awscliv2.zip"
unzip -q "$home_dir/awscliv2.zip"
sudo "$home_dir/aws/install"

echo "AWS CLI version: $aws_version"

# Clean up
rm -rf "$home_dir/awscliv2.zip" "$home_dir/aws"
