#!/bin/bash

set -e  # 오류 발생 시 즉시 종료

install_python() {
    if command -v python >/dev/null 2>&1; then
        echo "✔ Python is already installed."
        echo -e "✅ Python Version : $(python --version)\n"
    else
        echo "📌 Updating package list..."
        sudo apt update
        echo "📌 Installing Python..."
        sudo apt install -y python3 python3-setuptools python-is-python3 pipx
        pipx ensurepath
        pipx install six docker
    fi
}

install_nodejs() {
    if command -v nodejs >/dev/null 2>&1; then
        echo "✔ Node.js is already installed."
        echo "✅ Node.js Version : $(node --version)"
        echo -e "✅ NPM Version : $(npm --version)\n"
    else
        echo "📌 Updating package list..."
        sudo apt update    
        echo "📌 Installing Node.js and dependencies..."
        sudo apt install -y git nodejs npm pwgen
        sudo npm install -g npm
    fi
}

install_docker() {
    if command -v docker >/dev/null 2>&1; then
        echo "✔ Docker is already installed."
        echo -e "✅ Docker Version : $(docker --version | awk '{print $3}' | tr -d ',')\n"
    else
        echo "📌 Updating package list..."
        sudo apt update    
        echo "📌 Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        chmod +x get-docker.sh
        sudo bash get-docker.sh
        sudo systemctl enable --now docker
        rm -f get-docker.sh
    fi
}

install_ansible() {
    if command -v ansible >/dev/null 2>&1; then
        echo "✔ Ansible is already installed."
        echo -e "✅ Ansible Version : $(ansible --version | egrep "^ansible" | awk '{print $3}' | tr -d ']')\n"
    else
        echo "📌 Updating package list..."
        sudo apt update    
        echo "📌 Installing Ansible..."
        sudo apt install -y software-properties-common
        sudo add-apt-repository --yes --update ppa:ansible/ansible
        sudo apt install -y ansible
    fi
}

install_awx() {
    local AWX_DIRECTORY="/opt/awx"

    if [ -d "$AWX_DIRECTORY/.git" ]; then
        echo "✔ AWX repository already exists."
        echo -e "✅ AWX Version: $(cd $AWX_DIRECTORY; git tag | sort -V | tail -n1)\n"
        
        echo "📌 Updating AWX repository..."
        cd "$AWX_DIRECTORY"
        git fetch --all
        git reset --hard origin/main
    else
        echo "📌 Cloning AWX repository..."
        sudo rm -rf "$AWX_DIRECTORY"
        sudo mkdir -p "$AWX_DIRECTORY"
        sudo git clone https://github.com/ansible/awx.git "$AWX_DIRECTORY"
    fi

    echo "📌 Running AWX installation playbook..."
    cd "$AWX_DIRECTORY"
    ansible-playbook -i inventory install.yml
}

# 실행 순서
install_python
install_nodejs
install_docker
install_ansible
# install_awx

echo -e "✅ Installation completed successfully!\n"
