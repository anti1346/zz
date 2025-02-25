import subprocess

SERVER_LIST_FILE = "server_list.txt"  # `server_list.py`가 생성한 파일

def load_server_list():
    """서버 목록 파일을 읽어와 리스트로 반환"""
    try:
        with open(SERVER_LIST_FILE, "r") as file:
            return [line.strip().split() for line in file.readlines()]  # (hostname, ip) 리스트 반환
    except FileNotFoundError:
        print(f"[ERROR] {SERVER_LIST_FILE} 파일을 찾을 수 없습니다. fetch_server_list.py를 실행하세요.")
        return []

def get_server_model(hostname: str, ip: str) -> str:
    """Zabbix에서 서버 모델 정보를 가져온 후 포맷팅하여 반환"""
    command = (
        f'zabbix_get -s {ip} -p 10500 -t 2 '
        f'-k "z_command[dmidecode -t system | grep \'Product Name:\' | sed \'s/Product Name: //g\']"'
    )

    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
        product_name = result.stdout.strip() or "Unknown"  # 결과가 없으면 Unknown 반환
        return f"{hostname}\t{ip}\t{product_name}"

    except subprocess.CalledProcessError:
        return f"{hostname}\t{ip}\tError: Failed to retrieve data"

    except Exception as e:
        return f"{hostname}\t{ip}\tError: {str(e)}"

if __name__ == "__main__":
    servers = load_server_list()

    if not servers:
        exit(1)  # 서버 목록이 없으면 종료

    for hostname, ip in servers:
        print(get_server_model(hostname, ip))
