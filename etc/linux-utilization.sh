#!/bin/bash

while true; do
    # 현재 시간을 가져옴
    current_time=$(date +"%Y-%m-%d %H:%M:%S")

    # CPU 사용량 확인
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

    # 메모리 사용량 확인
    total_memory=$(free -m | awk '/^Mem:/ {print $2}')
    used_memory=$(free -m | awk '/^Mem:/ {print $3}')
    memory_usage=$(awk "BEGIN {printf \"%.2f\", $used_memory/$total_memory*100}")

    # Disk I/O 사용량 확인
    disk_io=$(iostat -d -x 1 1 | awk '/^sda/ {print "Disk I/O: " $14 "%"}')

    # 결과 출력
    printf "%s | CPU utilization : %.2f%% | Memory utilization : %.2f%% | %s\n" "$current_time" "$cpu_usage" "$memory_usage" "$disk_io"

    # 1초 대기
    sleep 1
done

```
$ bash monitor.sh
2023-11-27 22:27:40 | CPU utilization : 1.50% | Memory utilization : 11.54% | Disk I/O: 0.00%
2023-11-27 22:27:42 | CPU utilization : 0.00% | Memory utilization : 11.54% | Disk I/O: 0.00%
2023-11-27 22:27:43 | CPU utilization : 1.60% | Memory utilization : 11.54% | Disk I/O: 0.00%
```
