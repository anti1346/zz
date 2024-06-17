#!/bin/bash

# Determine the package manager
if [[ "$(command -v yum)" ]]; then
    PACKAGE_MANAGER="yum"
elif [[ "$(command -v apt-get)" ]]; then
    PACKAGE_MANAGER="apt-get"
    $PACKAGE_MANAGER update
else
    echo "Unsupported package manager."
    exit 1
fi




### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/default_package_install_on_docker_container.sh | bash
# 
# apt-get install -y dos2unix
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/default_package_install_on_docker_container.sh | dos2unix | bash



### Setting up vim in Ubuntu
# sudo update-alternatives --set editor /usr/bin/vim.basic
