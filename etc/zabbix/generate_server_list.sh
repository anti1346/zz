#!/bin/bash

# MySQL 접속 정보
DB_USER="zabbix"
DB_PASS="비밀번호"
DB_NAME="zabbix"

# 서버 목록 배열 선언
declare -a server_list=()

# MySQL에서 IP와 호스트명을 가져와 배열에 저장
while IFS= read -r line; do
    server_list+=("\"$line\"")
done < <(
    mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -N -e "
        SELECT CONCAT(i.ip, ' ', h.host)
        FROM hosts h
        JOIN interface i ON h.hostid = i.hostid
        WHERE h.status = 0 AND i.type = 1;
    "
)

# 배열 출력
echo "declare -a server_list=("
for entry in "${server_list[@]}"; do
    echo "    $entry"
done
echo ")"
