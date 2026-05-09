#!/bin/bash

# 1. 대상 디스크 자동 감지 (루트 파티션이 마운트된 장치)
DISK_NAME=$(lsblk -no pkname $(findmnt -nvo SOURCE /) | head -n1)
[ -z "$DISK_NAME" ] && DISK_NAME="sda" # 감지 실패 시 기본값

echo "Monitoring Start... (Device: $DISK_NAME)"
echo "--------------------------------------------------------------------------------"

while true; do
    # 현재 시간
    current_time=$(date +"%Y-%m-%d %H:%M:%S")

    # CPU 사용량 (vmstat 사용 - top보다 가벼움)
    # 2번째 라인의 id(idle) 값을 가져와서 100에서 뺌
    cpu_usage=$(vmstat 1 2 | tail -1 | awk '{print 100 - $15}')

    # 메모리 사용량 (free -m 결과를 awk 하나로 처리)
    memory_info=$(free -m | awk '/Mem:/ {printf "%.2f", $3/$2*100}')

    # Disk I/O (iostat 대신 가벼운 /proc/diskstats 또는 iostat 최적화 호출)
    # %util 값 추출
    disk_io=$(iostat -d -x 1 1 | grep "$DISK_NAME" | awk '{print $14}')
    [ -z "$disk_io" ] && disk_io="0.00"

    # 결과 출력 (printf로 정렬된 출력 유지)
    printf "%s | CPU: %5.2f%% | Mem: %5.2f%% | Disk(%s) Util: %s%%\n" \
           "$current_time" "$cpu_usage" "$memory_info" "$DISK_NAME" "$disk_io"

    # 1초 대기 (vmstat/iostat 내부 대기 시간을 고려하여 조정 가능)
    sleep 1
done

### Shell Execute Command
'''
$ ./monitor.sh | tee -a resource_monitor.log
2023-11-27 22:27:40 | CPU: 1.50% | Mem: 11.54% | Disk(sda) Util: 0.00%
2023-11-27 22:27:42 | CPU: 0.00% | Mem: 11.54% | Disk(sda) Util: 0.00%
2023-11-27 22:27:43 | CPU: 1.60% | Mem: 11.54% | Disk(sda) Util: 0.00%
'''
