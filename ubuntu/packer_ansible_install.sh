#!/bin/bash

# Check if packer is already installed
if [ -x "$(command -v packer)" ]; then
  echo "Packer is already installed. Exiting..."
  exit 0
fi

# Install hashicorp archive keyring
wget -q -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add hashicorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install packer
sudo apt update && sudo apt install packer

# Check if ansible is already installed
if [ -x "$(command -v ansible)" ]; then
  echo "Ansible is already installed. Exiting..."
  exit 0
fi

# Install ansible
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible-core
