#!/bin/bash

# 함수 정의
set_vim() {
    if ! command -v dos2unix &> /dev/null; then
        echo "dos2unix is not installed. Please install it first."
        exit 1
    fi

    if curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/set_vim.sh | dos2unix | bash; then
        echo "Vim configuration script executed successfully."
    else
        echo "Failed to download or execute the Vim configuration script."
        exit 1
    fi
}

# Determine the package manager
if [[ "$(command -v yum)" ]]; then
    PACKAGE_MANAGER="yum"

    sudo $PACKAGE_MANAGER install -y vim
    set_vim
elif [[ "$(command -v apt-get)" ]]; then
    PACKAGE_MANAGER="apt-get"

    sudo $PACKAGE_MANAGER update
    sudo $PACKAGE_MANAGER install -y vim dos2unix
    sudo update-alternatives --set editor /usr/bin/vim.basic
    set_vim
else
    echo "Unsupported package manager."
    exit 1
fi



### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/default_package_install_on_docker_container.sh | bash
# 
# apt-get install -y dos2unix
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/default_package_install_on_docker_container.sh | dos2unix | bash
