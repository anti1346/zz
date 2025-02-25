#!/bin/bash

# 서버 목록 배열 선언 (IP 주소 및 호스트명)
declare -a server_list=(
    "192.168.10.1 serv1"
    "192.168.10.2 serv2"
    "192.168.10.3 serv3"
    "192.168.10.4 serv4"
    "192.168.10.5 serv5"
)

# Zabbix UserParameter 정의
# UserParameter=z_command[*],bash -c "$1"

# 서버 목록을 순회하며 Zabbix Agent에서 서버 정보 수집
for entry in "${server_list[@]}"; do
    # 공백을 기준으로 IP 주소와 호스트명 분리
    read -r server_ip server_name <<< "$entry"

    # 서버 모델 정보 가져오기 (Product Name: 제거)
    product_name=$(zabbix_get -s "$server_ip" -p 10500 -t 2 -k "z_command[
        dmidecode -t system | grep 'Product Name:' | sed 's/Product Name: //g'
    ]" | tr -d '\r\n')

    # 결과 출력 (탭 구분)
    echo -e "$server_name\t$server_ip\t$product_name"
done
