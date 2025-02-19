#!/bin/bash

# Slack Webhook URL (환경 변수에서 가져오거나 직접 입력)
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-"https://hooks.slack.com/services/Txxxxxxxx/Bxxxxxxxx/xxxxxxxxxxxxxxxxxxxxxxxx"}"

# 메시지 입력 확인
if [[ -z "$1" ]]; then
    echo "❌ [ERROR] 메시지를 입력해야 합니다." >&2
    exit 1
fi

# Slack 알림 함수
send_slack_alert() {
    local message="$1"

    if [[ -z "$SLACK_WEBHOOK_URL" ]]; then
        echo "❌ [ERROR] Slack Webhook URL이 설정되지 않았습니다." >&2
        exit 1
    fi

    response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-type: application/json" \
        --data "$(jq -n --arg text "$message" \
                --arg username "Web Monitor" \
                --arg icon_emoji ":warning:" \
                '{text: $text, username: $username, icon_emoji: $icon_emoji}')" \
        "$SLACK_WEBHOOK_URL")

    if [[ "$response" -ne 200 ]]; then
        echo "❌ [ERROR] Slack 메시지 전송 실패 (HTTP $response)" >&2
        exit 1
    fi
}

# Slack 메시지 전송 실행
send_slack_alert "$1"