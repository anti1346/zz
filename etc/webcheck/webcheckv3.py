import requests
import socket

def check_connection(domain, port):
    http_status = "closed"
    https_status = "closed"

    try:
        # HTTP 연결 시도
        http_response = requests.get(f"http://{domain}:{port}", timeout=5)
        if http_response.status_code == 200:
            http_status = "open"
    except requests.exceptions.RequestException:
        pass

    try:
        # HTTPS 연결 시도
        https_response = requests.get(f"https://{domain}:{port}", timeout=5, verify=False)
        if https_response.status_code == 200:
            https_status = "open"
    except requests.exceptions.RequestException:
        pass

    return http_status, https_status

domains = [
    "naver.com",
    "www.daum.net",
    "google.com:443",
    "example.com:8443"
]

print("도메인:포트  IP  http  https")
for domain in domains:
    if ":" in domain:
        domain, port = domain.split(":")
    else:
        port = 80

    http_status, https_status = check_connection(domain, port)
    ip = socket.gethostbyname(domain)
    print(f"{domain}:{port}  {ip} {http_status}  {https_status}")
