import subprocess
import socket

def check_connection(domain, port):
    http_status = "closed"
    https_status = "closed"

    try:
        # HTTP 연결 시도
        cmd_http = ["curl", "-s", "-o", "/dev/null", "--connect-timeout", "5", "-w", "%{http_code}", f"http://{domain}:{port}"]
        result_http = subprocess.run(cmd_http, capture_output=True, text=True)
        http_code = result_http.stdout.strip()
        if http_code in ("200", "301", "302"):
            http_status = "open"
    except subprocess.CalledProcessError:
        pass

    try:
        # HTTPS 연결 시도
        cmd_https = ["curl", "-s", "-o", "/dev/null", "--connect-timeout", "5", "-w", "%{http_code}", f"https://{domain}:{port}"]
        result_https = subprocess.run(cmd_https, capture_output=True, text=True)
        http_code = result_https.stdout.strip()
        if http_code in ("200", "301", "302"):
            https_status = "open"
    except subprocess.CalledProcessError:
        pass

    return http_status, https_status

# 도메인 리스트 파일 경로
domain_file_path = "domain_list.txt"

# 파일에서 도메인 리스트 불러오기
with open(domain_file_path, "r") as file:
    domains = [line.strip() for line in file]

# 결과 헤더 작성
print("{:<30} {:<10} {:<20} {:<12} {:<12}".format("Domain:Port", "IP", "HTTP(80)", "HTTPS(443)"))

for domain in domains:
    if ":" in domain:
        domain, port = domain.split(":")
    else:
        port = None

    http_status, https_status = check_connection(domain, port)
    
    if port:
        print("{:<30}:{:<10} {:<20} {:<12} {:<12}".format(f"{domain}:{port}", socket.gethostbyname(domain), http_status, https_status))
    else:
        print("{:<30}:{:<10} {:<20} {:<12} {:<12}".format(domain, socket.gethostbyname(domain), http_status, https_status))
