#!/bin/bash

# /var/run/yum.pid 파일이 존재하는지 확인
while [ -f /var/run/yum.pid ]; do
    echo "Waiting for another yum process to finish..."
    sleep 5
done

# 리눅스 배포판 확인
os_distribution=$(grep -oP '(?<=^PRETTY_NAME=")(.*)(?=")' /etc/os-release)

case "$os_distribution" in
  "Amazon Linux 2")
    package_manager="yum"
    ;;
  "CentOS Linux"*)
    package_manager="yum"
    ;;
  "Ubuntu"*)
    package_manager="apt"
    ;;
  *)
    echo "지원되지 않는 운영 체제 배포판"
    exit 1
    ;;
esac

# CloudWatch 에이전트 설치
if [ "$package_manager" = "yum" ]; then
  sudo rpm -Uvh https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
elif [ "$package_manager" = "apt" ]; then
  wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
  sudo dpkg -i amazon-cloudwatch-agent.deb
fi

# CloudWatch 에이전트 구성
cat <<EOF | tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "messagesLogs",
            "log_stream_name": "{instance_id}/messages",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/secure",
            "log_group_name": "secureLogs",
            "log_stream_name": "{instance_id}/secure",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
EOF

# CloudWatch 에이전트 구성 적용
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# CloudWatch 에이전트 서비스 시작 및 활성화
sudo systemctl start amazon-cloudwatch-agent
sudo systemctl enable amazon-cloudwatch-agent

# CloudWatch 에이전트 서비스 재시작
sudo systemctl restart amazon-cloudwatch-agent
