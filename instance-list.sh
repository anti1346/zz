#!/bin/bash

# Describe running EC2 instances
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].{
      Name: Tags[?Key==`Name`]|[0].Value,
      InstanceId: InstanceId,
      InstanceType: InstanceType,
      PrivateIpAddress: PrivateIpAddress,
      PublicIpAddress: PublicIpAddress,
      State: State.Name,
      LaunchTime: LaunchTime
    }' \
  --output table
  
# Name: 인스턴스 이름
# InstanceId: 인스턴스 ID
# InstanceType: 인스턴스 유형
# PrivateIpAddress: 프라이빗 IP 주소
# PublicIpAddress: 퍼블릭 IP 주소
# State: 인스턴스 상태
# LaunchTime: 인스턴스 시작 시간
