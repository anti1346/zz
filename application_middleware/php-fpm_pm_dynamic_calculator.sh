#!/bin/bash

# CPU 개수 확인
cpu_count=$(nproc)

# 총 메모리 (MB 단위로 표시)
total_memory=$(free -m | awk '/^Mem:/{print $2}')

# 시스템에 사용할 메모리 (총 메모리의 80%)
system_memory=$((total_memory * 20 / 100))

# 사용자 입력으로 PHP-FPM 프로세스당 메모리 사용량을 입력받을 수 있게 추가
read -p "PHP-FPM 프로세스당 메모리 사용량(MB)을 입력하세요 (계산하려면 Enter): " user_php_memory

# PHP-FPM 평균 메모리 사용량 계산 (사용자 입력이 없을 경우 자동 계산)
if [ -z "$user_php_memory" ]; then
    php_memory=$(ps --no-headers -o "rss" $(pgrep php-fpm) | awk '{ sum+=$1 } END { if (NR > 0) printf ("%d\n", sum/NR/1024); else print 50 }')
else
    php_memory=$user_php_memory
fi

# max_children 계산: (총 메모리 - 시스템 메모리) / PHP-FPM 평균 메모리 사용량
max_children=$(( (total_memory - system_memory) / php_memory ))

# pm.min_spare_servers 계산: 일반적으로 max_children의 10% ~ 20% 설정
min_spare_servers=$(( max_children * 10 / 100 ))

# pm.max_spare_servers 계산: 일반적으로 min_spare_servers의 20% ~ 30% 추가
max_spare_servers=$(( min_spare_servers + (min_spare_servers * 20 / 100) ))

# pm.start_servers 계산: min_spare_servers + (max_spare_servers - min_spare_servers) / 2
start_servers=$(( min_spare_servers + (max_spare_servers - min_spare_servers) / 2 ))

# 결과 출력
echo "================ PHP-FPM 동적 풀 설정 ================="
echo "총 CPU 개수: $cpu_count"
echo "총 메모리: ${total_memory}MB"
echo "PHP-FPM 프로세스당 메모리 사용량: ${php_memory}MB"
echo "------------------------------------------------------"
echo "pm.max_children = $max_children"
echo "pm.start_servers = $start_servers"
echo "pm.min_spare_servers = $min_spare_servers"
echo "pm.max_spare_servers = $max_spare_servers"
echo "======================================================"