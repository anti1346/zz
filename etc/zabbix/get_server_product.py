import subprocess

# 서버 목록 (fetch_server_list.py로부터 데이터를 가져올 수도 있음)
server_list = [
    ("192.168.10.1", "serv1"),
    ("192.168.10.2", "serv2"),
    ("192.168.10.3", "serv3"),
    ("192.168.10.4", "serv4"),
    ("192.168.10.5", "serv5"),
]

# Zabbix Agent에서 서버 모델 정보를 가져오는 함수
def get_server_info(ip, hostname):
    try:
        command = f'zabbix_get -s {ip} -p 10500 -t 2 -k "z_command[dmidecode -t system | grep \'Product Name:\' | sed \'s/Product Name: //g\']"'
        result = subprocess.run(command, shell=True, capture_output=True, text=True)

        # 결과에서 개행 문자 제거 및 공백 정리
        product_name = result.stdout.strip()

        return f"{hostname}\t{ip}\t{product_name}"

    except Exception as e:
        return f"{hostname}\t{ip}\tError: {str(e)}"

if __name__ == "__main__":
    # 서버 목록을 순회하며 정보 가져오기
    for ip, hostname in server_list:
        print(get_server_info(ip, hostname))
