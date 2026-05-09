#!/bin/bash

# 1. 설정 변수
BACKUP_ROOT="/backup/os_config"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/$DATE"
HOSTNAME=$(hostname)
LOG_FILE="$BACKUP_ROOT/backup_history.log"

# [수정 포인트] 사용자가 백업하고 싶은 추가 파일이나 디렉토리 경로를 여기에 적으세요.
# 예: "/home/user/my_script.sh" "/var/www/html/config.php" "/etc/nginx/conf.d"
CUSTOM_TARGETS=(
    "/root/scripts"
    "/usr/local/bin/custom_tool"
    "/etc/hosts.allow"
)

mkdir -p "$BACKUP_DIR"
echo "[$DATE] $HOSTNAME 백업 시작" >> "$LOG_FILE"

# 2. OS 및 버전 판별 (호환성 유지)
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
elif [ -f /etc/redhat-release ]; then
    OS_ID="centos"
fi

# 3. 기본 OS 설정 파일 목록
TARGET_FILES=(
    "/etc/passwd" "/etc/shadow" "/etc/group" "/etc/sudoers"
    "/etc/hosts" "/etc/fstab" "/etc/crontab"
    "/etc/ssh/sshd_config" "/etc/rsyslog.conf" "/etc/sysctl.conf"
    "/etc/teleport.yaml"
)

# 4. OS별 특화 경로 자동 추가
if [ "$OS_ID" == "ubuntu" ]; then
    TARGET_FILES+=("/etc/netplan" "/etc/network/interfaces")
elif [ "$OS_ID" == "centos" ]; then
    TARGET_FILES+=("/etc/sysconfig/network-scripts")
fi

# 5. 사용자 지정 경로(CUSTOM_TARGETS)를 전체 목록에 합치기
FINAL_TARGETS=("${TARGET_FILES[@]}" "${CUSTOM_TARGETS[@]}")

# 6. 파일 복사 실행 (호환성 높은 방식)
echo "지정된 파일 및 디렉토리 복사 중..."
for item in "${FINAL_TARGETS[@]}"; do
    if [ -e "$item" ]; then
        # 경로 구조를 그대로 복사하기 위해 디렉토리 먼저 생성
        dest_path="$BACKUP_DIR$(dirname "$item")"
        mkdir -p "$dest_path"
        cp -rp "$item" "$dest_path/" 2>/dev/null
    else
        echo "경고: $item 경로를 찾을 수 없어 건너뜁니다." >> "$LOG_FILE"
    fi
done

# 7. 시스템 정보 추출
command -v dpkg >/dev/null 2>&1 && dpkg -l > "$BACKUP_DIR/pkg_list.txt"
command -v rpm >/dev/null 2>&1 && rpm -qa > "$BACKUP_DIR/pkg_list.txt"
command -v iptables >/dev/null 2>&1 && iptables -S > "$BACKUP_DIR/firewall_rules.txt"

# 8. 압축 및 권한 설정
cd "$BACKUP_ROOT"
tar -czf "${HOSTNAME}_config_${DATE}.tar.gz" "$DATE"
rm -rf "$DATE"
chmod 600 "${HOSTNAME}_config_${DATE}.tar.gz"

# 9. 30일 경과분 삭제
find "$BACKUP_ROOT" -name "*.tar.gz" -mtime +30 -exec rm -f {} \;

echo "[$DATE] $HOSTNAME 백업 완료 (사용자 지정 항목 포함)" >> "$LOG_FILE"