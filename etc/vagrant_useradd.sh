#!/bin/bash

# 사용자 이름, 패스워드, uid, gid 설정
USER_NAME=${1:-vagrant}
USER_PASSWORD=${2:-vagrant}
USER_ID=${3:-2002}
GROUP_ID=${4:-2002}
KEYGEN=${5:-false} #true

# 입력 유효성 검사
if id "$USER_NAME" &>/dev/null; then
    echo "오류: '$USER_NAME' 사용자가 이미 존재합니다." >&2
    exit 1
fi

if [ "$USER_ID" -lt 1000 ]; then
    echo "경고: 1000 이상의 UID를 사용하는 것이 좋습니다." >&2
fi

# 그룹 생성 및 사용자 추가
groupadd -g "$GROUP_ID" "$USER_NAME"
useradd -m -c "deployment" -d "/home/$USER_NAME" -s /bin/bash -u "$USER_ID" -g "$GROUP_ID" "$USER_NAME"

# 사용자 비밀번호 설정
echo "$USER_NAME:$USER_PASSWORD" | chpasswd

# sudoers 파일 설정
# CentOS : echo -e '\n'$USER_NAME'\tALL=(ALL)\tNOPASSWD: ALL' >> /etc/sudoers
# Ubuntu : echo -e '\n'$USER_NAME'\tALL=(ALL:ALL)\tNOPASSWD: ALL' >> /etc/sudoers
if [ -x "$(command -v sudo)" ]; then
    echo "sudoers 파일을 수정 중입니다..."
    echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
    echo "sudoers 파일이 수정되었습니다."
else
    echo "경고: sudo를 사용할 수 없습니다. sudoers 파일을 직접 수정하세요." >&2
fi

# SSH 키 생성
if [ "$KEYGEN" == "true" ]; then
    su - $USER_NAME <<EOF
    ssh-keygen -t rsa -b 2048 -C "deployment" -f /home/$USER_NAME/.ssh/id_rsa -N ""
    #ssh-keygen -t rsa -b 2048 -C "deployment"
EOF
else
    echo "SSH 키 생성이 건너뜁니다."
fi


### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/vagrant_useradd.sh | bash
#
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/vagrant_useradd.sh | bash -s vagrant vagrant 2002 2002 true
