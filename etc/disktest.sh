#!/bin/bash

# FIO 테스트 실행 함수
run_fio_test() {
    local name=$1
    local rw_mode=$2
    local block_size=$3
    local numjobs=$4
    local iodepth=$5
    local output_file=$6

    fio --name="$name" --filename=testfile --size=1G --rw="$rw_mode" --bs="$block_size" \
        --ioengine=libaio --direct=1 --numjobs="$numjobs" --iodepth="$iodepth" \
        --runtime=30 --time_based --group_reporting --output-format=json > "$output_file"
}

# 결과 출력 함수
parse_fio_result() {
    local file=$1

    # 파일 존재 여부 확인
    if [[ ! -e "$file" ]]; then
        echo "[ERROR] 결과 파일을 찾을 수 없습니다: $file"
        return
    fi

    # 테스트 이름 추출
    local test_name=$(jq -r '.jobs[0].jobname' "$file")
    echo "--- $test_name ---"

    # IOPS 추출
    local read_iops=$(jq -r '.jobs[0].read.iops // "N/A"' "$file")
    local write_iops=$(jq -r '.jobs[0].write.iops // "N/A"' "$file")

    # Bandwidth (MB/s) 추출
    local read_bw=$(jq -r '.jobs[0].read.bw_bytes // 0' "$file" | awk '{printf "%.2f", $1/1024/1024}')
    local write_bw=$(jq -r '.jobs[0].write.bw_bytes // 0' "$file" | awk '{printf "%.2f", $1/1024/1024}')

    # Latency (ms) 추출
    local read_lat=$(jq -r '.jobs[0].read.lat_ns.mean // 0' "$file" | awk '{printf "%.2f", $1/1000000}')
    local write_lat=$(jq -r '.jobs[0].write.lat_ns.mean // 0' "$file" | awk '{printf "%.2f", $1/1000000}')

    # 결과 출력 (정렬)
    printf "%-15s : %s\n" "IOPS(Read)" "$read_iops"
    printf "%-15s : %s\n" "IOPS(Write)" "$write_iops"
    printf "%-15s : %s MB/s\n" "BW(Read)" "$read_bw"
    printf "%-15s : %s MB/s\n" "BW(Write)" "$write_bw"
    printf "%-15s : %s ms\n" "Latency(Read)" "$read_lat"
    printf "%-15s : %s ms\n" "Latency(Write)" "$write_lat"
    echo
}

# FIO 테스트 실행
run_fio_test "randrw_test" "randrw" "4k" 4 32 "randrw_result.json"
run_fio_test "read_test" "read" "1M" 1 32 "read_result.json"
run_fio_test "write_test" "write" "1M" 1 32 "write_result.json"

# 결과 출력
echo "=== FIO 테스트 결과 ==="
for file in randrw_result.json read_result.json write_result.json; do
    parse_fio_result "$file"
done



### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/get_inet.sh | bash
