#!/bin/bash

# MySQL 접속 정보
DB_USER="zabbix"
DB_PASS="비밀번호"
DB_NAME="zabbix"

# server_list 배열 초기화
server_list=()

# SQL 실행 후 결과를 배열에 저장
while IFS= read -r line; do
    server_list+=("\"$line\"")
done < <(mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -N -e "
SELECT CONCAT(i.ip, ' ', h.host)
FROM hosts h
JOIN interface i ON h.hostid = i.hostid
WHERE h.status = 0 AND i.type = 1;
")

# 배열 출력
echo "server_list=("
for entry in "${server_list[@]}"; do
    echo "    $entry"
done
echo ")"
