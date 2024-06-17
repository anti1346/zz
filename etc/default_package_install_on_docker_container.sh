#!/bin/bash

# Determine the package manager
if [[ "$(command -v yum)" ]]; then
    PACKAGE_MANAGER="yum"
elif [[ "$(command -v apt-get)" ]]; then
    PACKAGE_MANAGER="apt-get"
else
    echo "Unsupported package manager."
    exit 1
fi




### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/set_vim.sh | bash
# 
# apt-get install -y dos2unix
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/set_vim.sh | dos2unix | bash



### Setting up vim in Ubuntu
# sudo update-alternatives --set editor /usr/bin/vim.basic
