#!/bin/bash
# CentOS BIND Backup Script for ISMS

# 1. 설정 변수
BACKUP_ROOT="/backup/named"
HOSTNAME=$(hostname)
DATE=$(date +%Y%m%d)
BACKUP_NAME="${HOSTNAME}-${DATE}"
TARGET_DIR="${BACKUP_ROOT}/${BACKUP_NAME}"
LOG_FILE="${BACKUP_ROOT}/backup_named-${DATE}.log"

# 2. 디렉토리 초기화
mkdir -p "${TARGET_DIR}/sbin" "${TARGET_DIR}/etc"
echo "[$DATE] BIND 백업 시작 (OS: CentOS/RHEL)" >> "$LOG_FILE"

# 3. 백업 전 무결성 검사 (ISMS 대응)
if command -v named-checkconf >/dev/null 2>&1; then
    if ! named-checkconf /etc/named.conf >> "$LOG_FILE" 2>&1; then
        echo "[$DATE] [ERROR] BIND 설정 오류 발견. 백업을 중단합니다." >> "$LOG_FILE"
        exit 1
    fi
fi

# 4. 파일 복사 실행
echo "[$DATE] 데이터 복사 중..." >> "$LOG_FILE"

# 4-1. 설정 파일 (파일 존재 시에만 복사)
FILES=( "/etc/named.conf" "/etc/named.logging.conf" "/etc/named.root.key" "/etc/named.rfc1912.zones" "/etc/named.iscdlv.key" )
for file in "${FILES[@]}"; do
    [ -f "$file" ] && cp -pf "$file" "${TARGET_DIR}/etc/"
done
cp -pf /etc/rndc.* "${TARGET_DIR}/etc/" 2>/dev/null

# 4-2. 데이터 및 바이너리
[ -d "/var/named" ] && cp -rpf /var/named "${TARGET_DIR}/"
[ -f "/usr/sbin/named" ] && cp -pf /usr/sbin/named "${TARGET_DIR}/sbin/"
[ -d "/usr/local/named" ] && cp -rpf /usr/local/named "${TARGET_DIR}/"

# 5. 압축 및 로그 제외 처리
cd "${BACKUP_ROOT}"
# --exclude 위치를 tar 바로 뒤에 두어 안정성 확보
if tar --exclude="${BACKUP_NAME}/var/named/log/*" -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}" >> "$LOG_FILE" 2>&1; then
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