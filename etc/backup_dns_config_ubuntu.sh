#!/bin/bash
# Ubuntu BIND Backup Script for ISMS

# 1. 설정 변수
BACKUP_ROOT="/backup/named"
HOSTNAME=$(hostname)
DATE=$(date +%Y%m%d)
BACKUP_NAME="${HOSTNAME}-${DATE}"
TARGET_DIR="${BACKUP_ROOT}/${BACKUP_NAME}"
LOG_FILE="${BACKUP_ROOT}/backup_named-${DATE}.log"

# 2. 디렉토리 초기화
mkdir -p "${TARGET_DIR}/sbin"
echo "[$DATE] BIND 백업 시작 (OS: Ubuntu/Debian)" >> "$LOG_FILE"

# 3. 백업 전 무결성 검사 (ISMS 대응)
if command -v named-checkconf >/dev/null 2>&1; then
    if ! named-checkconf /etc/bind/named.conf >> "$LOG_FILE" 2>&1; then
        echo "[$DATE] [ERROR] BIND 설정 오류 발견. 백업을 중단합니다." >> "$LOG_FILE"
        exit 1
    fi
fi

# 4. 파일 복사 실행
echo "[$DATE] 데이터 복사 중..." >> "$LOG_FILE"

# 4-1. 설정 및 Zone 파일
if [ -d "/etc/bind" ]; then
    cp -rpf /etc/bind "${TARGET_DIR}/"
else
    echo "[$DATE] [ERROR] /etc/bind 경로를 찾을 수 없습니다." >> "$LOG_FILE"
    exit 1
fi

# 4-2. 바이너리
[ -f "/usr/sbin/named" ] && cp -p /usr/sbin/named "${TARGET_DIR}/sbin/"

# 5. 압축 및 로그 제외 처리
cd "${BACKUP_ROOT}"
if tar --exclude="${BACKUP_NAME}/bind/logs/*" -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}" >> "$LOG_FILE" 2>&1; then
    chmod 600 "${BACKUP_NAME}.tar.gz"
    echo "[$DATE] 압축 및 보안 설정 완료" >> "$LOG_FILE"
else
    echo "[$DATE] [ERROR] 압축 실패" >> "$LOG_FILE"
    exit 1
fi

# 6. 정리 (임시 폴더 및 30일 경과 파일)
rm -rf "${BACKUP_NAME}"
find "${BACKUP_ROOT}" -name "${HOSTNAME}-*.tar.gz" -mtime +30 -delete
find "${BACKUP_ROOT}" -name "backup_named-*.log" -mtime +30 -delete

echo "[$DATE] BIND 백업 최종 완료" >> "$LOG_FILE"