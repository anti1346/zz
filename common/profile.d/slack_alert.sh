#!/bin/bash

# Slack 웹훅 URL (YOUR_SLACK_WEBHOOK_URL에 본인의 URL을 입력하세요)
slack_webhook_url="YOUR_SLACK_WEBHOOK_URL에"

# 슬랙으로 알림 전송 함수
send_slack_alert() {
    local title="User Login Alert"
    local access_date=$(date -d "$ACCESS_DATE UTC" '+%Y-%m-%d %H:%M:%S KST')
    local message=$(cat <<-EOM

*DATE:* $access_date
*Client Account:* $USER
*Client IP Address:* $SSH_CLIENT
*Server Name:* $(hostname)
*Server IP Address:* $(hostname -I | cut -d' ' -f1)
EOM
    )

    local payload="{
        \"attachments\": [
            {
                \"color\": \"#36a64f\",
                \"title\": \"$title\",
                \"text\": \"$message\",
                \"mrkdwn_in\": [\"text\"]
            }
        ]
    }"

    curl -X POST -H "Content-type: application/json" --data "$payload" $slack_webhook_url
}

# 로그인 시 슬랙 알림 발생
if [ -n "$SSH_CLIENT" ]; then
    send_slack_alert
fi
