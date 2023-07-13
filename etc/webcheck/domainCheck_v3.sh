#!/bin/bash

# 도메인 리스트 파일 경로
domain_list_file="domain_list.txt"

# 결과를 저장할 파일
output_file="domain_check_results.txt"

# 결과 파일 초기화
> "$output_file"

# 결과 헤더 작성
printf "%-20s %-20s %-15s %-15s %-15s %-15s\n" "Domain" "IP" "Port 80" "Port 443" "http Port" "https Port" >> "$output_file"

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
    port=${port:-80,443}

    # IP 주소 가져오기
    ip=$(dig +short "$domain" | tail -n1)

    # 포트 체크
    ports=(${port//,/ })
    results=()
    for p in "${ports[@]}"; do
        http_code=$(curl -s --head --connect-timeout 5 -w "%{http_code}" "http://$domain:$p" -o /dev/null)
        if [[ "$http_code" == "200" || "$http_code" == "301" || "$http_code" == "302" ]]; then
            result="open ($http_code)"
        else
            result="closed ($http_code)"
        fi
        results+=("$result")
    done

    # 결과 파일에 기록
    printf "%-20s %-20s %-15s %-15s %-15s %-15s\n" "$domain" "$ip" "${results[0]}" "${results[1]}" "${results[0]}" "${results[1]}" >> "$output_file"

done < "$domain_list_file"

echo "Domain check completed. Results saved in $output_file"
