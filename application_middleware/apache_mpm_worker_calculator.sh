#!/bin/bash

# 입력값 받기
read -p "Enter the number of CPU cores (default: auto-detect): " cpu_cores
read -p "Enter the total memory size in GB (default: auto-detect): " memory_size

# CPU 코어 수 가져오기
auto_cpu_cores=$(grep -c ^processor /proc/cpuinfo)
cpu_cores=${cpu_cores:-$auto_cpu_cores}

# 메모리 크기 가져오기
auto_memory_size=$(free -g | awk '/^Mem:/{print $2}')
memory_size=${memory_size:-$auto_memory_size}

# MPM Worker 모듈 매개변수 계산
start_servers=$cpu_cores
min_spare_threads=$cpu_cores
max_spare_threads=$((cpu_cores * 10))
threads_per_child=$((cpu_cores / 2))
max_request_workers=$((cpu_cores * 25))

# MaxConnectionsPerChild 계산
#max_connections_per_child=0 # 기본값인 무제한 사용
total_connections=$((threads_per_child * max_request_workers))
total_processes=$cpu_cores
max_connections_per_child=$((total_connections / total_processes))

# 결과 출력
echo ""
echo "StartServers: $start_servers"
echo "MinSpareThreads: $min_spare_threads"
echo "MaxSpareThreads: $max_spare_threads"
echo "ThreadsPerChild: $threads_per_child"
echo "MaxRequestWorkers: $max_request_workers"
echo "MaxConnectionsPerChild: $max_connections_per_child"
echo ""
