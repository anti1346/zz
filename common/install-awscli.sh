#!/bin/bash

# Amazon Linux 2
if [[ "$(uname -a)" == *"amzn2"* ]]; then
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

# Clean up
rm -rf awscliv2.zip
