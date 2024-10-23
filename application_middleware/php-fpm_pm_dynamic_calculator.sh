#!/bin/bash

# CPU 개수 확인
cpu_count=$(nproc)

# 총 메모리 (GB 단위로 표시)
total_memory=$(free -g | awk '/^Mem:/{print $2}')

system_memory=$total_memory - $(( total_memory * 20 / 100 ))

# PHP-FPM 평균 메모리 사용량
php_memory=$(ps --no-headers -o "rss" $(pgrep php-fpm) | awk '{ sum+=$1 } END { if (NR > 0) printf ("%d%s\n", sum/NR/1024,"Mb"); else print "No php-fpm processes found." }')

# max_children 계산: 총 메모리 / PHP-FPM 평균 메모리 사용량
max_children=$(( (total_memory - system_memory * 1024) / php_memory ))

# pm.start_servers 계산: max_children의 20% ~ 30% 
start_servers=$(( max_children * 25 / 100 ))

# pm.min_spare_servers 계산: start_servers의 절반
min_spare_servers=$(( start_servers / 2 ))

# pm.max_spare_servers 계산: start_servers와 같거나 10% ~ 20% 추가
max_spare_servers=$(( start_servers + (start_servers * 15 / 100) ))

# 결과 출력
echo "================ PHP-FPM 동적 풀 설정 ================="
echo "총 CPU 개수: $cpu_count"
echo "총 메모리: ${total_memory}GB"
echo "PHP-FPM 프로세스당 메모리 사용량: ${php_memory}MB"
echo "------------------------------------------------------"
echo "pm.max_children = $max_children"
echo "pm.start_servers = $start_servers"
echo "pm.min_spare_servers = $min_spare_servers"
echo "pm.max_spare_servers = $max_spare_servers"
echo "======================================================"