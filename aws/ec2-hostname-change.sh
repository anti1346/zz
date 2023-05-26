#!/bin/bash

instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

hostname=$(aws --region ${region} ec2 describe-instances \
    --instance-ids ${instance_id} \
    --query "Reservations[].Instances[].Tags[?Key=='Name'].Value[]" \
    --output text)

sudo hostnamectl set-hostname ${hostname}

echo -e "\nHostname set to ${hostname}\n"
