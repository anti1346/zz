#!/bin/bash

# 내부 IP 가져오기
INTERNAL_IP=$(hostname -I | awk '{print $1}')

# 외부 IP 가져오기
EXTERNAL_IP=$(curl -s https://checkip.amazonaws.com)

echo "내부 IP: $INTERNAL_IP"
echo "외부 IP: $EXTERNAL_IP"
