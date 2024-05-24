#!/bin/bash

# Check if aws-cli is already installed
if command -v aws &>/dev/null; then
    aws_version=$(aws --version | awk '{print $1}' | awk -F'/' '{print $2}')
    echo "aws is already installed."
    echo "aws-cli version: $aws_version"
    exit 0
fi

# Check the architecture
ARCH=$(uname -m)
if [[ ${ARCH} == "x86_64" ]]; then
  VAULT_ARCH="amd64"
elif [[ ${ARCH} == "aarch64" ]]; then
  VAULT_ARCH="arm64"
else
  echo "Unsupported architecture: ${ARCH}"
  exit 1
fi

# Determine the package manager
if [[ "$(command -v yum)" ]]; then
    PACKAGE_MANAGER="yum"
elif [[ "$(command -v apt-get)" ]]; then
    PACKAGE_MANAGER="apt-get"
else
    echo "Unsupported package manager."
    exit 1
fi

# Install unzip if necessary
if ! command -v unzip &>/dev/null; then
    sudo ${PACKAGE_MANAGER} update -qq
    sudo ${PACKAGE_MANAGER} install -qq -y unzip
fi

# Download and install aws-cli
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${VAULT_ARCH}.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install

# Get aws-cli version
aws_version=$(aws --version | awk '{print $1}' | awk -F'/' '{print $2}')
echo "aws-cli version: $aws_version"

# Clean up
rm -rf awscliv2.zip
