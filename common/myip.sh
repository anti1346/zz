#!/bin/bash

# 색상 정의
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly NC='\033[0m'

# 내부 IP 가져오기 (macOS/BSD 호환 방식)
# en0 인터페이스(Wi-Fi 또는 이더넷)의 IP를 가져옵니다.
INTERNAL_IP=$(ipconfig getifaddr en0)

# 외부 IP 가져오기
EXTERNAL_IP=$(curl -s --max-time 5 https://checkip.amazonaws.com)

# 출력 로직
echo -e "\n${RED}내부 IP: ${INTERNAL_IP:-알 수 없음}${NC}"

if [[ -n "$EXTERNAL_IP" ]]; then
    echo -e "${GREEN}외부 IP: $EXTERNAL_IP${NC}\n"
else
    echo -e "${RED}외부 IP: 가져오기 실패 (네트워크 연결 확인)${NC}\n"
fi