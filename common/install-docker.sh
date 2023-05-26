#!/bin/bash

# 운영체제 정보 확인
distro=$(lsb_release -i | cut -f2)
os_version=$(lsb_release -sr | cut -d'.' -f1)

# 도커 설치
if ! command -v docker >/dev/null; then
    if [ "$distro" == "CentOS" ]; then
        if [[ $os_version -eq 8 || $os_version -eq 7 ]]; then
            echo "CentOS $os_version"
            curl -fsSL https://get.docker.com -o get-docker.sh
            chmod +x get-docker.sh
            bash get-docker.sh
            usermod -aG docker $(whoami)
            systemctl --now enable docker.service
        fi
    elif [ "$distro" == "Ubuntu" ]; then
        echo "Ubuntu $os_version"
        curl -fsSL https://get.docker.com -o get-docker.sh
        chmod +x get-docker.sh
        sudo bash get-docker.sh
        usermod -aG docker $(whoami)
        systemctl --now enable docker.service
    elif [ "$distro" == "Amazon" ]; then
        echo "Amazon $os_version"
        amazon-linux-extras install -y epel
        amazon-linux-extras install -y docker
        usermod -aG docker ec2-user
        systemctl --now enable docker.service
    else
        echo "Other OS"
    fi
else
    echo "Docker already installed"
fi

# 도커 컴포즈 설치
if ! command -v docker-compose >/dev/null; then
    echo "Installing Docker Compose"
    curl -fsSL "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
else
    echo "Docker Compose already installed"
fi

# CTOP 설치
if ! command -v ctop >/dev/null; then
    echo "Installing CTOP"
    CTOP=${CTOPVersion:-0.7.7}
    curl -fsSL https://github.com/bcicen/ctop/releases/download/v${CTOP}/ctop-${CTOP}-linux-amd64 -o /usr/local/bin/ctop
    chmod +x /usr/local/bin/ctop
    ln -s /usr/local/bin/ctop /usr/bin/ctop
else
    echo "CTOP already installed"
fi

# 스크립트 종료
exit 0

# lsb_release 명령으로 운영체제 판단
# if command -v apt >/dev/null; then
#     echo "Linux Distribution : Debian"
#     apt update -qq -y >/dev/null 2>&1
#     apt install -qq -y lsb-release >/dev/null 2>&1
#     lsb_release -ds
# elif command -v yum >/dev/null; then
#     echo "Linux Distribution : RedHat"
#     yum install -q -y redhat-lsb-core >/dev/null 2>&1
#     lsb_release -ds | tr -d '"'
# else
#     echo "other OS"
# fi