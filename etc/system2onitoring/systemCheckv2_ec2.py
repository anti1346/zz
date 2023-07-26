import boto3
import psutil
import requests

# Slack Incoming Webhook URL 설정
SLACK_WEBHOOK_URL = 'YOUR_SLACK_WEBHOOK_URL_HERE'

# 인스턴스 메타데이터에서 region 및 instance-id 가져오기
try:
    response = requests.get('http://169.254.169.254/latest/dynamic/instance-identity/document', timeout=3)
    response.raise_for_status()  # 요청이 성공적으로 완료되지 않으면 예외 발생
    metadata = response.json()
    region = metadata['region']
    INSTANCE_ID = metadata['instanceId']
except requests.Timeout:
    print("타임아웃 발생: 인스턴스 메타데이터에 접근할 수 없습니다.")
    exit(1)
except requests.exceptions.RequestException as e:
    print(f"인스턴스 메타데이터 요청 실패: {e}")
    exit(1)

# AWS 인증 정보 설정 (AWS CLI의 설정 파일과 연동)
session = boto3.Session(region_name=region)

def get_instance_metrics(instance_id):
    ec2 = session.client('ec2')
    response = ec2.describe_instances(InstanceIds=[instance_id])
    instance = response['Reservations'][0]['Instances'][0]

    # 인스턴스 이름 가져오기 (태그 "Name"을 활용)
    instance_name = None
    for tag in instance.get('Tags', []):
        if tag['Key'] == 'Name':
            instance_name = tag['Value']
            break

    cpu_usage = psutil.cpu_percent()
    memory_usage = psutil.virtual_memory().percent

    # 디스크 사용량 추가
    disk_usage = 0
    for volume in instance.get('BlockDeviceMappings', []):
        if 'Ebs' in volume and 'VolumeSize' in volume['Ebs']:
            disk_usage += volume['Ebs']['VolumeSize']
    total_size_gb = disk_usage

    return instance_name, cpu_usage, memory_usage, total_size_gb

def send_slack_notification(message):
    payload = {
        'text': message
    }
    try:
        requests.post(SLACK_WEBHOOK_URL, json=payload, timeout=3)
    except requests.Timeout:
        print("타임아웃 발생: Slack 웹훅에 메시지를 전송할 수 없습니다.")
    except requests.exceptions.RequestException as e:
        print(f"Slack 웹훅 요청 실패: {e}")

if __name__ == '__main__':
    instance_id = INSTANCE_ID
    instance_name, cpu_usage, memory_usage, disk_usage = get_instance_metrics(instance_id)

    if disk_usage >= 10:
        message = f'{instance_name}({instance_id}) EC2 인스턴스의 디스크 사용량이 {disk_usage}GB로 10% 이상입니다.'
        send_slack_notification(message)

    if cpu_usage >= 10:
        message = f'{instance_name}({instance_id}) EC2 인스턴스의 CPU 사용량이 {cpu_usage:.2f}%로 10% 이상입니다.'
        send_slack_notification(message)

    if memory_usage >= 10:
        message = f'{instance_name}({instance_id}) EC2 인스턴스의 메모리 사용량이 {memory_usage:.2f}%로 10% 이상입니다.'
        send_slack_notification(message)
