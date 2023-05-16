#!/bin/bash

# The default resolver settings
cat <<EOF > /etc/resolv.conf
# Generated by NetworkManager
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF

aws_resolver=$(aws ec2 describe-vpcs --query 'Vpcs[].CidrBlock' --output text | cut -d '.' -f 1,2 | awk '{print $0 ".0.2"}')

cat <<EOF > /etc/resolv.conf
# Generated by NetworkManager
nameserver $aws_resolver
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF

echo -e "\ncat /etc/resolv.conf"
