#!/bin/bash

### 사용자 목록 출력
# cut -d: -f1 /etc/passwd
### 그룹 목록 출력
# cut -d: -f1 /etc/group

# 1. 관리자 권한 확인
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root." >&2
   exit 1
fi

# 2. 대상 목록 (운영 환경에 맞춰 신중히 선택)
# 시스템 계정은 삭제보다 잠금을 권장합니다.
USERS_TO_LOCK=("adm" "lp" "sync" "shutdown" "halt" "mail" "operator" "games" "ftp" "nfsnobody" "uucp" "news")
GROUPS_TO_DELETE=("cdrom" "floppy" "games" "audio" "dialout" "fax" "voice" "tape")

LOG_FILE="/var/log/account_cleanup_$(date +%Y%m%d).log"

echo "=== Account Cleanup Start: $(date) ===" | tee -a "$LOG_FILE"

# 3. 사용자 처리 (안전하게 잠금 및 쉘 변경)
for USER in "${USERS_TO_LOCK[@]}"; do
    if id "$USER" &>/dev/null; then
        echo "Processing user: $USER (Locking & Changing Shell)" | tee -a "$LOG_FILE"
        
        # 계정 잠금 (비밀번호 사용 불가)
        passwd -l "$USER" >> "$LOG_FILE" 2>&1
        
        # 쉘을 nologin으로 변경 (로그인 차단)
        if [ -f "/sbin/nologin" ]; then
            usermod -s /sbin/nologin "$USER" >> "$LOG_FILE" 2>&1
        else
            usermod -s /usr/sbin/nologin "$USER" >> "$LOG_FILE" 2>&1
        fi
    else
        echo "User not found: $USER (Skipping)" | tee -a "$LOG_FILE"
    fi
done

# 4. 그룹 삭제
for GROUP in "${GROUPS_TO_DELETE[@]}"; do
    if getent group "$GROUP" &>/dev/null; then
        echo "Deleting group: $GROUP" | tee -a "$LOG_FILE"
        groupdel "$GROUP" >> "$LOG_FILE" 2>&1
    else
        echo "Group not found: $GROUP (Skipping)" | tee -a "$LOG_FILE"
    fi
done

echo "=== Cleanup Completed. Details in $LOG_FILE ==="




### 실행 권한 여부
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/delete_accounts.sh -o delete_accounts.sh
# chmod +x delete_accounts.sh

# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/delete_accounts.sh | dos2unix | bash
