import requests
import socket

def check_connection(domain, port):
    http_status = "closed"
    https_status = "closed"

    try:
        # HTTP 연결 시도
        http_response = requests.get(f"http://{domain}:{port}", timeout=5)
        if http_response.status_code in [200, 301, 302]:
            http_status = "open"
    except requests.exceptions.RequestException:
        pass

    try:
        # HTTPS 연결 시도
        https_response = requests.get(f"https://{domain}:{port}", timeout=5, verify=True)
        if https_response.status_code in [200, 301, 302]:
            https_status = "open"
    except requests.exceptions.RequestException:
        pass

    return http_status, https_status

# 도메인 리스트 파일 경로
domain_file_path = "domain_list.txt"

# 파일에서 도메인 리스트 불러오기
with open(domain_file_path, "r") as file:
    domains = [line.strip() for line in file]

print("도메인:포트  IP  http  https")
for domain in domains:
    if ":" in domain:
        domain, port = domain.split(":")
    else:
        port = 80

    http_status, https_status = check_connection(domain, port)
    ip = socket.gethostbyname(domain)
    print(f"{domain}:{port}  {ip} {http_status}  {https_status}")
