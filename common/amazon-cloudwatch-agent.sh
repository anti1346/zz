#!/bin/bash

AWS_REGION=$(aws configure get region)

# CloudWatch 에이전트 설치 함수
install_cloudwatch_agent() {
  local os_platform="$1"
  local os_architecture="$2"
  local oslog_messages="$3"
  local oslog_secure="$4"
  local agent_url="https://amazoncloudwatch-agent-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/${os_platform}/${os_architecture}/latest/amazon-cloudwatch-agent.rpm"

  # Ubuntu의 경우 URL을 변경
  if [ "$os_platform" == "ubuntu" ]; then
    agent_url="https://amazoncloudwatch-agent-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/${os_platform}/${os_architecture}/latest/amazon-cloudwatch-agent.deb"
  fi

  # Ubuntu에서는 deb 파일을 사용하고 그 외에는 rpm 파일을 사용
  if [ "$os_platform" == "ubuntu" ]; then
    wget "$agent_url" -O /tmp/amazon-cloudwatch-agent.deb
    dpkg -i /tmp/amazon-cloudwatch-agent.deb
  else
    rpm -Uvh "$agent_url"
  fi

  # CloudWatch 에이전트 구성
  cat <<EOF | tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/${oslog_messages}",
            "log_group_name": "YourLogGroupName",
            "log_stream_name": "{instance_id}/messages",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/${oslog_secure}",
            "log_group_name": "YourLogGroupName",
            "log_stream_name": "{instance_id}/secure",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
EOF

  # CloudWatch 에이전트 서비스 시작 및 활성화
  systemctl --now enable amazon-cloudwatch-agent

  # CloudWatch 에이전트 구성 적용
  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

  # CloudWatch 에이전트 서비스 재시작
  systemctl restart amazon-cloudwatch-agent
}

# 운영체제 판별 및 CloudWatch 에이전트 설치
if [[ "$(uname -a)" == *"amzn2.x86_64"* ]]; then
  install_cloudwatch_agent "amazon_linux" "amd64" "messages" "secure"
elif [[ "$(uname -a)" == *"amzn2.aarch64"* ]]; then
  install_cloudwatch_agent "amazon_linux" "arm64" "messages" "secure"
elif [[ "$(uname -a)" == *"el7"* ]]; then
  install_cloudwatch_agent "centos" "amd64" "messages" "secure"
elif [[ "$(uname -a)" == *"Ubuntu"* ]]; then
  install_cloudwatch_agent "ubuntu" "amd64" "syslog" "auth.log"
else
  echo "지원되지 않는 운영체제입니다."
  exit 1
fi

