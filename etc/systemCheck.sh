#!/bin/bash

# Slack Incoming Webhook URL 설정
SLACK_WEBHOOK_URL="YOUR_SLACK_WEBHOOK_URL_HERE"

# 인스턴스 메타데이터에서 region 및 instance-id 가져오기
region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# AWS 인증 정보 설정 (AWS CLI의 설정 파일과 연동)
export AWS_DEFAULT_REGION=$region

get_instance_metrics() {
    instance_id="$1"
    instance_info=$(aws ec2 describe-instances --instance-ids "$instance_id")
    instance_name=$(echo "$instance_info" | grep -o '"Value": "[^"]*' | cut -d'"' -f4)

    cpu_usage=$(ps -eo pcpu | awk 'NR>1' | awk '{sum+=$1} END {print int(sum)}')
    memory_usage=$(free | awk 'NR==2 {print int($3/$2 * 100)}')

    disk_usage=0
    volumes=$(echo "$instance_info" | grep -o '"VolumeSize": [0-9]*' | awk '{sum+=$2} END {print sum}')
    for volume in $volumes; do
        disk_usage=$((disk_usage + volume))
    done

    echo "$instance_name $INSTANCE_ID $cpu_usage $memory_usage $disk_usage"
}

send_slack_notification() {
    message="$1"
    payload="{\"text\": \"$message\"}"
    curl -s -X POST -H "Content-type: application/json" --data "$payload" "$SLACK_WEBHOOK_URL"
}

main() {
    instance_id="$INSTANCE_ID"
    instance_metrics=$(get_instance_metrics "$instance_id")
    instance_name=$(echo "$instance_metrics" | awk '{print $1}')
    cpu_usage=$(echo "$instance_metrics" | awk '{print $3}')
    memory_usage=$(echo "$instance_metrics" | awk '{print $4}')
    disk_usage=$(echo "$instance_metrics" | awk '{print $5}')

    if ((disk_usage >= 80)); then
        message="$instance_name($INSTANCE_ID) EC2 인스턴스의 디스크 사용량이 $disk_usage%로 10% 이상입니다."
        send_slack_notification "$message"
    fi

    if ((cpu_usage >= 80)); then
        message="$instance_name($INSTANCE_ID) EC2 인스턴스의 CPU 사용량이 $cpu_usage%로 10% 이상입니다."
        send_slack_notification "$message"
    fi

    if ((memory_usage >= 80)); then
        message="$instance_name($INSTANCE_ID) EC2 인스턴스의 메모리 사용량이 $memory_usage%로 10% 이상입니다."
        send_slack_notification "$message"
    fi
}

main
