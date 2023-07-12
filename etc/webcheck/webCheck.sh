#!/bin/bash

# 도메인 리스트 파일 경로
domain_list_file="domain_list.txt"

# 결과를 저장할 파일
output_file="domain_check_results.txt"

# 결과 파일 초기화
> "$output_file"

# 결과 헤더 작성
printf "%-20s %-20s %-12s %-12s %-12s %-12s\n" "Domain" "IP" "Port 80" "Port 443" "http Port" "https Port">> "$output_file"

# 도메인 리스트 파일 읽기
while IFS= read -r line; do
    # 빈 줄이나 주석(#)인 경우 건너뛰기
    if [[ -z "$line" || "${line:0:1}" == "#" ]]; then
        continue
    fi

    # 도메인 가져오기
    domain=$(echo "$line" | awk -F ":" '{print $1}')

    # 포트 가져오기
    port=$(echo "$line" | awk -F ":" '{print $2}')
    echo $port

    # IP 주소 가져오기
    ip=$(dig +short "$domain" | tail -n1)

    if [[ -n "$port" ]]; then
        # HTTP 포트 체크
        http_code_other=$(curl -s --head --connect-timeout 5 -w "%{http_code}" "http://$domain:$port" -o /dev/null)
        if [[ "$http_code_other" == "200" || "$http_code_other" == "301" || "$http_code_other" == "302" ]]; then
            port_http_status="open ($http_code_other)"
        else
            port_http_status="closed ($http_code_other)"
        fi

        # HTTPS 포트 체크
        https_code_other=$(curl -s --head --connect-timeout 5 -w "%{http_code}" "https://$domain:$port" -o /dev/null)
        if [[ "$https_code_other" == "200" || "$https_code_other" == "301" || "$https_code_other" == "302" ]]; then
            port_https_status="open ($https_code_other)"
        else
            port_https_status="closed ($https_code_other)"
        fi
    else
        # 80번 포트 체크
        http_code_80=$(curl -s --head --connect-timeout 5 -w "%{http_code}" "http://$domain" -o /dev/null)
        if [[ "$http_code_80" == "200" || "$http_code_80" == "301" || "$http_code_80" == "302" ]]; then
            port_80_status="open ($http_code_80)"
        else
            port_80_status="closed ($http_code_80)"
        fi

        # 443번 포트 체크
        http_code_443=$(curl -s --head --connect-timeout 5 -w "%{http_code}" "https://$domain" -o /dev/null)
        if [[ "$http_code_443" == "200" || "$http_code_443" == "301" || "$http_code_443" == "302" ]]; then
            port_443_status="open ($http_code_443)"
        else
            port_443_status="closed ($http_code_443)"
        fi
    fi

    # 결과 파일에 기록
    printf "%-20s %-20s %-12s %-12s %-12s %-12s\n" "$domain" "$ip" "$port_80_status" "$port_443_status" "$port_http_status" "$port_https_status">> "$output_file"

done < "$domain_list_file"

echo "Domain check completed. Results saved in $output_file"