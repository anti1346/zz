#!/bin/bash

# timedatectl 명령어가 설치되어 있는지 확인
if ! command -v timedatectl &> /dev/null; then
    echo "timedatectl 명령어를 찾을 수 없습니다."
    exit 1
fi

# 시간대를 Asia/Seoul로 설정
sudo timedatectl set-timezone Asia/Seoul

# 시스템 시간대 출력
echo "현재 시스템 시간대: $(timedatectl | grep "Time zone" | awk '{print $3}')"
