#!/bin/bash

# Slack Webhook URL 및 메시지 관련 변수
slack_url="https://hooks.slack.com/services/TCT4/wkQM"
channel_name="#zabbix_bot"
username="ec2"
emoji=":white_check_mark:"
color='#0C7BDC'

# 현재 시간 및 EC2 인스턴스 메타데이터 관련 변수
current_date=$(date '+%Y-%m-%d, %H:%M:%S')
public_ipv4=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
local_ipv4=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
instance_type=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
hostname=$(aws --region ${region} ec2 describe-instances \
        --instance-ids ${instance_id} \
        --query "Reservations[].Instances[].Tags[?Key=='Name'].Value[]" \
        --output text)

# 메시지 생성
subject=$1
message="Instance id: $instance_id
Hostname: $hostname
Public ipv4: $public_ipv4
Local ipv4: $local_ipv4
Instance type: $instance_type
Date: $current_date"

# Payload 생성
payload="payload={\"channel\": \"${channel_name}\",  \
\"username\": \"${username}\", \
\"attachments\": [{\"fallback\": \"${subject//\"/\\\"}\", \"title\": \"${subject//\"/\\\"}\", \"text\": \"${message//\"/\\\"}\", \"color\": \"${color}\"}], \
\"icon_emoji\": \"${emoji}\"}"

# Slack에 메시지 전송
curl \
    -X POST \
    -H "Accept: application/json" \
    --data-urlencode "${payload}" \
    ${slack_url}
