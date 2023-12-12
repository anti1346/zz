#!/bin/bash

### 사용자 목록 출력
# cut -d: -f1 /etc/passwd
### 그룹 목록 출력
# cut -d: -f1 /etc/group

# 삭제할 사용자 및 그룹 목록
USERS_TO_DELETE=("adm" "lp" "sync" "shutdown" "halt" "mail" "operator" "games" "ftp" "nfsnobody")
GROUPS_TO_DELETE=("cdrom" "floppy" "games" "audio")

# 사용자 삭제
for USER in "${USERS_TO_DELETE[@]}"; do
    if id "$USER" &>/dev/null; then
        echo "Deleting user: $USER"
        userdel -r "$USER"
    else
        echo "User not found: $USER"
    fi
done

# 그룹 삭제
for GROUP in "${GROUPS_TO_DELETE[@]}"; do
    if getent group "$GROUP" &>/dev/null; then
        echo "Deleting group: $GROUP"
        groupdel "$GROUP"
    else
        echo "Group not found: $GROUP"
    fi
done

echo "Script execution completed."

### 실행 권한 여부
# chmod +x delete_accounts.sh
