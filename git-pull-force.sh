#!/bin/bash

# 첫 번째 git pull 시도
git pull

if [ $? -eq 0 ]; then
    echo "Git pull 성공!"
else
    echo "Git pull 실패, 리셋 후 다시 시도합니다."

    # 변경 사항을 초기화하고 다시 git pull 시도
    git reset --hard HEAD
    git pull
    if [ $? -eq 0 ]; then
        echo "Git pull (reset 후) 성공!"
    else
        echo "Git pull (reset 후) 실패! 문제 해결이 필요합니다."
        exit 1
    fi
fi
