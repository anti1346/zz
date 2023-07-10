#!/bin/bash

# 출력을 위한 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 내부 IP 가져오기
INTERNAL_IP=$(hostname -I | awk '{print $1}')
# 외부 IP 가져오기
EXTERNAL_IP=$(curl -s --max-time 3 https://checkip.amazonaws.com)

echo -e "${RED}내부 IP: $INTERNAL_IP${NC}"
echo -e "${GREEN}외부 IP: $EXTERNAL_IP${NC}"
