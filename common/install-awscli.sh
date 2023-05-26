#!/bin/bash

# Get aws-cli version
aws_version=$(aws --version | awk '{print $1}' | awk -F'/' '{print $2}')

if ! command -v aws >/dev/null; then
    echo "aws is already installed. Exiting..."
    echo "aws-cli version: $aws_version"
    exit 0
fi

# Download and install aws-cli based on the operating system
if [[ "$(uname -a)" == *"amzn2"* ]]; then
    # Amazon Linux 2
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    sudo unzip -q awscliv2.zip
    sudo ./aws/install
elif [[ "$(uname -a)" == *"el7"* ]]; then
    # CentOS 7
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    sudo unzip -q awscliv2.zip
    sudo ./aws/install
elif [[ "$(uname -a)" == *"Ubuntu"* ]]; then
    # Ubuntu
    sudo apt-get update -qq
    sudo apt-get install -qq -y unzip
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    sudo unzip -q awscliv2.zip
    sudo ./aws/install
else
    echo "Unsupported operating system."
    exit 1
fi

echo "aws-cli version: $aws_version"

# Clean up
rm -rf awscliv2.zip