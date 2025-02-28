#!/bin/bash

# FIO 설치 여부 확인
if ! command -v fio &>/dev/null; then
    echo "[ERROR] fio가 설치되어 있지 않습니다."
    read -p "fio를 설치하시겠습니까? (y/N): " answer
    case "$answer" in
        [Yy]*)
            echo "fio를 설치합니다..."
            if [[ -f /etc/debian_version ]]; then
                sudo apt update && sudo apt install -y fio
            elif [[ -f /etc/redhat-release ]]; then
                sudo yum install -y fio
            else
                echo "[ERROR] 지원되지 않는 운영체제입니다. fio를 수동으로 설치해주세요."
                exit 1
            fi
            ;;
        *)
            echo "fio가 필요합니다. 스크립트를 종료합니다."
            exit 1
            ;;
    esac
fi

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

    if [[ ! -e "$file" ]]; then
        echo "[ERROR] 결과 파일을 찾을 수 없습니다: $file"
        return
    fi

    local test_name=$(jq -r '.jobs[0].jobname' "$file")
    echo "--- $test_name ---"

    local read_iops=$(jq -r '.jobs[0].read.iops // "N/A"' "$file")
    local write_iops=$(jq -r '.jobs[0].write.iops // "N/A"' "$file")

    local read_bw=$(jq -r '.jobs[0].read.bw_bytes // 0' "$file" | awk '{printf "%.2f", $1/1024/1024}')
    local write_bw=$(jq -r '.jobs[0].write.bw_bytes // 0' "$file" | awk '{printf "%.2f", $1/1024/1024}')

    local read_lat=$(jq -r '.jobs[0].read.lat_ns.mean // 0' "$file" | awk '{printf "%.2f", $1/1000000}')
    local write_lat=$(jq -r '.jobs[0].write.lat_ns.mean // 0' "$file" | awk '{printf "%.2f", $1/1000000}')

    printf "%-15s : %s\n" "IOPS(Read)" "$read_iops"
    printf "%-15s : %s\n" "IOPS(Write)" "$write_iops"
    printf "%-15s : %s MB/s\n" "Bandwidth(Read)" "$read_bw"
    printf "%-15s : %s MB/s\n" "Bandwidth(Write)" "$write_bw"
    printf "%-15s : %s ms\n" "Latency(Read)" "$read_lat"
    printf "%-15s : %s ms\n" "Latency(Write)" "$write_lat"
    echo
}

# FIO 테스트 실행
run_fio_test "랜덤 읽기/쓰기 테스트 (4K 블록, 1GB 파일)" "randrw" "4k" 4 32 "randrw_result.json"
run_fio_test "순차 읽기 테스트 (1MB 블록, 1GB 파일)" "read" "1M" 1 32 "read_result.json"
run_fio_test "순차 쓰기 테스트 (1MB 블록, 1GB 파일)" "write" "1M" 1 32 "write_result.json"

# 결과 출력
echo "=== FIO 테스트 결과 ==="
for file in randrw_result.json read_result.json write_result.json; do
    parse_fio_result "$file"
done

rm -f testfile randrw_result.json read_result.json write_result.json;



### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/refs/heads/main/etc/disktest.sh | bash
