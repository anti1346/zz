#!/bin/bash

#!/bin/bash

# 에러 발생 시 즉시 중단, 미선언 변수 사용 시 에러
set -e

# 1. 설정 변수 (기본값 설정)
USER_NAME=${1:-vagrant}
USER_PASSWORD=${2:-vagrant}
USER_ID=${3:-2002}
GROUP_ID=${4:-2002}
KEYGEN=${5:-false}

# 2. 실행 권한 및 유효성 검사
if [[ $EUID -ne 0 ]]; then
   echo "오류: 이 스크립트는 root 권한으로 실행해야 합니다." >&2
   exit 1
fi

if id "$USER_NAME" &>/dev/null; then
    echo "오류: '$USER_NAME' 사용자가 이미 존재합니다." >&2
    exit 1
fi

# 3. 그룹 생성 (GID 중복 체크)
if getent group "$GROUP_ID" &>/dev/null; then
    echo "경고: GID $GROUP_ID 를 사용하는 그룹이 이미 존재합니다. 기존 그룹을 사용합니다."
    ACTUAL_GROUP=$(getent group "$GROUP_ID" | cut -d: -f1)
else
    groupadd -g "$GROUP_ID" "$USER_NAME"
    ACTUAL_GROUP="$USER_NAME"
fi

# 4. 사용자 추가
echo "사용자 '$USER_NAME' (UID: $USER_ID) 생성 중..."
useradd -m -c "deployment" -d "/home/$USER_NAME" -s /bin/bash \
        -u "$USER_ID" -g "$GROUP_ID" "$USER_NAME"

# 5. 비밀번호 설정
echo "$USER_NAME:$USER_PASSWORD" | chpasswd

# 6. sudoers 설정 (안전한 /etc/sudoers.d 방식)
# Ubuntu/CentOS 공용 문법 적용
# echo -e "${USER_NAME}\tALL=(ALL)\tNOPASSWD: ALL" | sudo tee -a /etc/sudoers

if [ -d "/etc/sudoers.d" ]; then
    echo "sudoers 권한 부여 중..."
    SUDO_FILE="/etc/sudoers.d/90-cloud-init-$USER_NAME"
    echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" > "$SUDO_FILE"
    chmod 0440 "$SUDO_FILE"
else
    echo "경고: /etc/sudoers.d 디렉토리가 없습니다. 직접 설정을 권장합니다." >&2
fi

# 7. SSH 키 생성
if [ "$KEYGEN" == "true" ]; then
    echo "SSH 키 생성 중..."
    USER_HOME="/home/$USER_NAME"
    mkdir -m 700 -p "$USER_HOME/.ssh"
    
    # 사용자 권한으로 키 생성
    ssh-keygen -t rsa -b 2048 -C "deployment" -f "$USER_HOME/.ssh/id_rsa" -N "" -q
    
    # 소유권 및 권한 강제 설정 (중요)
    chown -R "$USER_NAME:$ACTUAL_GROUP" "$USER_HOME/.ssh"
    chmod 600 "$USER_HOME/.ssh/id_rsa"
    chmod 644 "$USER_HOME/.ssh/id_rsa.pub"
    echo "SSH 키 생성이 완료되었습니다."
else
    echo "SSH 키 생성을 건너뜁니다."
fi

echo "[$USER_NAME] 사용자 생성이 완료되었습니다."




### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/vagrant_useradd.sh | bash
#
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/vagrant_useradd.sh | bash -s vagrant vagrant 2002 2002 true
