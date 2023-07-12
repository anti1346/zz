#!/usr/bin/env python3
import subprocess

# 도메인 리스트 파일 경로
domain_list_file = "domain_list.txt"

# 결과를 저장할 파일
output_file = "domain_check_results.txt"

# 결과 파일 초기화
with open(output_file, "w") as f:
    f.write("{:<40} {:<40} {:<15} {:<15}\n".format("Domain", "IP", "Port 80", "Port 443"))

# 도메인 리스트 파일 읽기
with open(domain_list_file, "r") as f:
    for line in f:
        # 빈 줄이나 주석(#)인 경우 건너뛰기
        if line.strip() == "" or line.strip().startswith("#"):
            continue

        # 도메인 가져오기
        domain = line.split()[0]

        # IP 주소 가져오기
        result = subprocess.run(["dig", "+short", domain], capture_output=True, text=True)
        ip = result.stdout.strip().split("\n")[-1]

        # 80번 포트 체크
        cmd_80 = ["curl", "-s", "--head", "--connect-timeout", "5", "-w", "%{http_code}", f"http://{domain}", "-o", "/dev/null"]
        result_80 = subprocess.run(cmd_80, capture_output=True, text=True)
        http_code_80 = result_80.stdout.strip()
        if http_code_80 in ("200", "301", "302"):
            port_80_status = f"open ({http_code_80})"
        else:
            port_80_status = f"closed ({http_code_80})"

        # 443번 포트 체크
        cmd_443 = ["curl", "-s", "--head", "--connect-timeout", "5", "-w", "%{http_code}", f"https://{domain}", "-o", "/dev/null"]
        result_443 = subprocess.run(cmd_443, capture_output=True, text=True)
        http_code_443 = result_443.stdout.strip()
        if http_code_443 in ("200", "301", "302"):
            port_443_status = f"open ({http_code_443})"
        else:
            port_443_status = f"closed ({http_code_443})"

        # 결과 파일에 기록
        with open(output_file, "a") as f:
            f.write("{:<40} {:<40} {:<15} {:<15}\n".format(domain, ip, port_80_status, port_443_status))

print("Domain check completed. Results saved in", output_file)
