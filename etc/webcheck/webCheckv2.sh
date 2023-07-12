#!/bin/bash

# 도메인 리스트 파일 경로
domain_list_file="domain_list.txt"

# 결과를 저장할 파일
output_file="domain_check_results.txt"

# 결과 파일 초기화
> "$output_file"

# 결과 헤더 작성
printf "%-20s %-20s %-15s %-15s %-15s\n" "Domain" "IP" "Port 80" "Port 443" "http Port" "https Port">> "$output_file"

# 도메인 리스트 파일 읽기
while read -r domain port; do
    # 빈 줄이나 주석(#)인 경우 건너뛰기
    if [[ -z "$domain" || "${domain:0:1}" == "#" ]]; then
        continue
    fi

    # IP 주소 가져오기
    ip=$(dig +short "$domain" | tail -n1)

    # HTTP/HTTPS 포트 상태 가져오기
    port_80_status=$(curl -s --head --connect-timeout 5 -w "%{http_code}" "http://$domain:$port" -o /dev/null | cut -d ' ' -f 1)
    port_443_status=$(curl -s --head --connect-timeout 5 -w "%{http_code}" "https://$domain:$port" -o /dev/null | cut -d ' ' -f 1)

    # 결과 파일에 기록
    printf "%-20s %-20s %-15s %-15s %-15s\n" "$domain" "$ip" "$port_80_status" "$port_443_status" "$port_80_status" "$port_443_status">> "$output_file"
done < "$domain_list_file"

echo "Domain check completed. Results saved in $output_file"
