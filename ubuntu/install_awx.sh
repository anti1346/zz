#!/bin/bash

set -e  # 오류 발생 시 즉시 종료

echo "Updating package list..."
sudo apt update
echo -e "\n"

install_python() {
    if command -v python >/dev/null 2>&1; then
        echo "✔ Python is already installed."
        echo -e "✅ Python Version : $(python --version)\n"
    else
        echo "Installing Python..."
        sudo apt install -y python3 python3-pip python-is-python3 python3-six python-setuptools
        python3 -m pip install --upgrade pip
        pip3 install --user docker
        pip3 install --user six
    fi
}

install_nodejs() {
    if command -v nodejs >/dev/null 2>&1; then
        echo "✔ Node.js is already installed."
        echo "✅ Node.js Version : $(node --version)"
        echo -e "✅ NPM Version : $(npm --version)\n"
    else
        echo "Installing Node.js and dependencies..."
        sudo apt install -y git nodejs npm
        #sudo apt install -y git pwgen nodejs npm
        sudo npm install -g npm
    fi
}

install_docker() {
    if command -v docker >/dev/null 2>&1; then
        echo "✔ Docker is already installed."
        echo -e "✅ Docker Version : $(docker --version | awk '{print $3}' | tr -d ',')\n"
    else
        echo "Installing Docker..."
        DOCKER_INSTALL_SCRIPT="get-docker.sh"
        curl -fsSL https://get.docker.com -o "$DOCKER_INSTALL_SCRIPT"
        chmod +x "$DOCKER_INSTALL_SCRIPT"
        sudo bash "$DOCKER_INSTALL_SCRIPT"
        sudo systemctl enable --now docker
        rm -f "$DOCKER_INSTALL_SCRIPT"
    fi
}

install_ansible() {
    if command -v ansible >/dev/null 2>&1; then
        echo "✔ Ansible is already installed."
        echo -e "✅ Ansible Version : $(ansible --version | egrep "^ansible" | awk '{print $3}' | tr -d ']')\n"
    else
        echo "Installing Ansible..."
        sudo apt update
        sudo apt install -y software-properties-common
        sudo add-apt-repository --yes --update ppa:ansible/ansible
        sudo apt install -y ansible
    fi
}

install_awx() {
    if [ -d "awx" ]; then
        echo "✔ AWX repository already exists."
        echo -e "✅ AWX Version : $(cd /opt/awx; git tag | sort -V | tail -n1)\n"
    else
        echo "Cloning AWX repository..."
        mkdir -p /opt/awx
        git clone https://github.com/ansible/awx.git /opt/awx
        cd /opt/awx
        git pull
    fi

    echo "Running AWX installation playbook..."
    ansible-playbook -i inventory install.yml
}

# 실행 순서
install_python
install_nodejs
install_docker
install_ansible
install_awx

echo "✅ Installation completed successfully!"
