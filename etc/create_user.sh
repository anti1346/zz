#!/bin/bash

# 사용자 이름, 패스워드, uid, gid 설정
USERNAME=${1:-vagrant}
PASSWORD=${2:-vagrant}
UID=${3:-2002}
GID=${4:-2002}
KEYGEN=${5:-false} #true

# 입력 유효성 검사
if id "$USERNAME" &>/dev/null; then
    echo "오류: '$USERNAME' 사용자가 이미 존재합니다." >&2
    exit 1
fi

if [ "$UID" -lt 1000 ]; then
    echo "경고: 1000 이상의 UID를 사용하는 것이 좋습니다." >&2
fi

# 그룹 생성 및 사용자 추가
groupadd -g "$GID" "$USERNAME"
useradd -m -c "deployment" -d "/home/$USERNAME" -s /bin/bash -u "$UID" -g "$GID" "$USERNAME"

# 사용자 비밀번호 설정
echo "$USERNAME:$PASSWORD" | chpasswd

# sudoers 파일 설정
# CentOS : echo -e '\n'$USERNAME'\tALL=(ALL)\tNOPASSWD: ALL' >> /etc/sudoers
# Ubuntu : echo -e '\n'$USERNAME'\tALL=(ALL:ALL)\tNOPASSWD: ALL' >> /etc/sudoers
if [ -x "$(command -v visudo)" ]; then
    echo "sudoers 파일을 수정 중입니다..."
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" | sudo visudo -f /etc/sudoers.d/"$USERNAME"
    echo "sudoers 파일이 수정되었습니다."
else
    echo "경고: visudo를 사용할 수 없습니다. sudoers 파일을 직접 수정하세요." >&2
fi

# SSH 키 생성
if [ "$KEYGEN" == "true" ]; then
    su - $USERNAME <<EOF
    ssh-keygen -t rsa -b 2048 -C "deployment"
EOF
else
    echo "SSH 키 생성이 건너뜁니다."
fi


### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/create_user.sh | bash
