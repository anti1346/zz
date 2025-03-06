#!/bin/bash

# 현재 날짜와 시간을 커밋 메시지에 추가
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# 현재 브랜치 가져오기
CURRENT_BRANCH=$(git branch --show-current)

# 상태 출력
echo "현재 브랜치: $CURRENT_BRANCH"
echo "변경 사항을 스테이징합니다..."

# 변경 사항 스테이징
git add .
if [ $? -ne 0 ]; then
    echo "git add 실패. 스크립트를 종료합니다."
    exit 1
fi

# 커밋 생성
echo "커밋 메시지: '$DATE'"
git commit -m "commit update : $DATE"
if [ $? -ne 0 ]; then
    echo "git commit 실패. 스크립트를 종료합니다."
    exit 1
fi

# 변경 사항 푸시
echo "변경 사항을 원격 저장소로 푸시합니다..."
git push origin "$CURRENT_BRANCH"
if [ $? -ne 0 ]; then
    echo "git push 실패. 스크립트를 종료합니다."
    exit 1
fi

echo "작업이 완료되었습니다."
