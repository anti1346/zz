#!/bin/bash

# 운영체제 정보 확인
distro=$(lsb_release -i | cut -f2)
os_version=$(lsb_release -sr | cut -d'.' -f1)

# 도커 설치
if ! command -v docker >/dev/null; then
    if [ "$distro" == "CentOS" ]; then
        if [[ $os_version -eq 8 || $os_version -eq 7 ]]; then
            echo "Installing Docker on $distro $os_version"
            sudo curl -fsSL https://get.docker.com -o get-docker.sh
            sudo chmod +x get-docker.sh
            sudo bash get-docker.sh
            sudo usermod -aG docker $(whoami)
            sudo systemctl --now enable docker.service
        fi
    elif [ "$distro" == "Ubuntu" ]; then
        echo "Installing Docker on $distro $os_version"
        sudo curl -fsSL https://get.docker.com -o get-docker.sh
        sudo chmod +x get-docker.sh
        sudo bash get-docker.sh
        sudo usermod -aG docker $(whoami)
        sudo systemctl --now enable docker.service
    elif [ "$distro" == "Amazon" ]; then
        echo "Installing Docker on $distro $os_version"
        sudo amazon-linux-extras install -y epel
        sudo amazon-linux-extras install -y docker
        sudo usermod -aG docker $(whoami)
        sudo systemctl --now enable docker.service
    else
        echo "Other OS"
    fi
    echo "Docker version: $(docker version --format '{{.Server.Version}}')"
else
    echo "Docker already installed"
    echo "Docker version: $(docker version --format '{{.Server.Version}}')"
fi

# 도커 컴포즈 설치
if ! command -v docker-compose >/dev/null; then
    echo "Installing Docker Compose"
    sudo curl -fsSL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    echo "Docker Compose version: $(docker-compose version --short)"
else
    echo "Docker Compose already installed"
    echo "Docker Compose version: $(docker-compose version --short)"
fi

# CTOP 설치
if ! command -v ctop >/dev/null; then
    echo "Installing CTOP"
    CTOP_VERSION=$(sudo curl -sSL "https://api.github.com/repos/bcicen/ctop/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')
    sudo curl -fsSL "https://github.com/bcicen/ctop/releases/download/${CTOP_VERSION}/ctop-${CTOP_VERSION}-linux-amd64" -o /usr/local/bin/ctop
    sudo chmod +x /usr/local/bin/ctop
    sudo ln -s /usr/local/bin/ctop /usr/bin/ctop
    echo "CTOP version: $(ctop -v | grep -oP '(?<=version )[\d.]+')"
else
    echo "CTOP already installed"
    echo "CTOP version: $(ctop -v | grep -oP '(?<=version )[\d.]+')"
fi

# 스크립트 종료
exit 0
