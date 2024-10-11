#!/bin/bash

#### 운영체제 판단 및 업데이트
function detect_os {
    if command -v apt >/dev/null; then
        # Debian 계열
        echo "Linux Distribution: Debian-based"
        apt update -qq -y >/dev/null 2>&1
        apt install -qq -y lsb-release >/dev/null 2>&1
        distro_name=$(lsb_release -is)
    elif command -v yum >/dev/null; then
        # RedHat 계열
        echo "Linux Distribution: RedHat-based"
        yum install -q -y redhat-lsb-core >/dev/null 2>&1
        distro_name=$(lsb_release -is)
    else
        echo "Unsupported OS"
        exit 1
    fi
    os_major_version=$(lsb_release -rs | cut -d'.' -f1)
}

### Docker 설치 함수
function install_docker {
    if ! command -v docker >/dev/null; then
        case "$distro_name" in
            "CentOS")
                if [[ "$os_major_version" -eq 7 || "$os_major_version" -eq 8 ]]; then
                    echo "Installing Docker on CentOS $os_major_version"
                    curl -fsSL https://get.docker.com -o get-docker.sh
                    chmod +x get-docker.sh
                    bash get-docker.sh
                    usermod -aG docker $(whoami)
                    systemctl --now enable docker.service
                else
                    echo "Unsupported CentOS version: $os_major_version"
                    exit 1
                fi
                ;;
            "Amazon")
                echo "Installing Docker on Amazon Linux $os_major_version"
                amazon-linux-extras install -y epel
                amazon-linux-extras install -y docker
                usermod -aG docker ec2-user
                systemctl --now enable docker.service
                ;;
            "Ubuntu")
                echo "Installing Docker on Ubuntu $os_major_version"
                apt install -y apt-transport-https ca-certificates curl software-properties-common
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
                apt update
                apt install -y docker-ce
                ;;
            *)
                echo "Unsupported distribution: $distro_name"
                exit 1
                ;;
        esac
    else
        echo "Docker is already installed."
    fi
}

### Docker Compose 설치 함수
function install_docker_compose {
    local docker_compose_version="1.29.2"
    local docker_compose_url="https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-$(uname -s)-$(uname -m)"
    
    echo "Installing Docker Compose version $docker_compose_version"
    curl -fsSL "$docker_compose_url" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
}

### CTOP 설치 함수
function install_ctop {
    local ctop_version=${CTOP_VERSION:-0.7.7}
    local ctop_url="https://github.com/bcicen/ctop/releases/download/v${ctop_version}/ctop-${ctop_version}-linux-amd64"
    
    echo "Installing CTOP version $ctop_version"
    curl -fsSL "$ctop_url" -o /usr/local/bin/ctop
    chmod +x /usr/local/bin/ctop
    ln -s /usr/local/bin/ctop /usr/bin/ctop
}

### 메인 스크립트 실행
detect_os
install_docker
# install_docker_compose
install_ctop

### Clean up
echo "Cleaning up installation files"
rm -f get-docker.sh

echo "Installation completed successfully"

### 스크립트 종료
exit 0



### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/common/install_docker.sh | bash
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/common/install_docker.sh | dos2unix | bash
