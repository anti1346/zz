#!/bin/bash

# 삭제할 계정 목록
REMOVE_ACCOUNT_LIST="games lp news uucp gnats sync proxy backup list irc pollinate landscape fwupd-refresh lxd"

for account in $REMOVE_ACCOUNT_LIST; do
    # 계정이 존재하는지 확인
    if id -u $account >/dev/null 2>&1; then
        # 계정 삭제
        userdel -r $account
        echo "Account $account has been removed."
    else
        echo "Account $account does not exist."
    fi
done

# 삭제할 그룹 목록
REMOVE_GROUP_LIST="games lp news uucp gnats"

for group in $REMOVE_GROUP_LIST; do
    # 그룹이 존재하는지 확인
    if grep -q $group /etc/group; then
        # 그룹 삭제
        groupdel $group
        echo "Group $group has been removed."
    else
        echo "Group $group does not exist."
    fi
done
