#!/bin/bash

# Stop and remove codedeploy-agent service
sudo systemctl stop codedeploy-agent
sudo systemctl disable codedeploy-agent

# Uninstall codedeploy-agent
sudo yum erase -qq -y codedeploy-agent

# Remove existing codedeploy-agent files
sudo rm -rf /opt/codedeploy-agent

# Create codedeploy-agent directory
sudo mkdir -p /opt/codedeploy-agent

# Download and install codedeploy-agent
#wget -q https://aws-codedeploy-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/latest/install -O install
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
wget -q "https://aws-codedeploy-${REGION}.s3.${REGION}.amazonaws.com/latest/install" -O /tmp/install
chmod +x /tmp/install
sudo /tmp/install auto

# Update codedeploy-agent
sudo /opt/codedeploy-agent/bin/install auto

# Start and enable codedeploy-agent service
sudo systemctl --now enable codedeploy-agent

# Check the status of codedeploy-agent
sudo systemctl status codedeploy-agent
