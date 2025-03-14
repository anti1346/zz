#!/bin/bash

# 삭제할 불필요한 계정 목록
UNUSED_USERS=(
    lp mail news uucp list irc polkitd uuidd
    games pollinate dhcpcd tss landscape fwupd-refresh usbmux
)

# 로그 파일 경로
LOG_FILE="/var/log/remove_unused_users.log"

# 로그 기록 함수
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

log "🔹 불필요한 계정 삭제 시작"

for user in "${UNUSED_USERS[@]}"; do
    if id "$user" &>/dev/null; then
        SHELL=$(getent passwd "$user" | cut -d: -f7)
        if [[ "$SHELL" == "/usr/sbin/nologin" || "$SHELL" == "/bin/false" ]]; then
            log "⚙️  계정 삭제 중: $user"
            userdel -r "$user" &>> "$LOG_FILE"
            if [[ $? -eq 0 ]]; then
                log "✅ 삭제 완료: $user"
            else
                log "❌ 삭제 실패: $user"
            fi
        else
            log "⏩ 삭제하지 않음 (로그인 가능 계정): $user"
        fi
    else
        log "🔹 존재하지 않는 계정: $user"
    fi
done

log "✅ 불필요한 계정 삭제 완료"