#!/bin/bash

if command -v apt-get &>/dev/null; then
    package_manager=apt-get
    sudo ${package_manager} update
elif command -v yum &>/dev/null; then
    package_manager=yum
else
    echo "Unsupported package manager. Please install OpenSSH manually."
    exit 1
fi

sudo ${package_manager} install -y openssh-server wget

sudo systemctl start sshd

echo "OpenSSH server installed and started successfully."


### Shell Execute Commands
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/install_ssh_server.sh | bash
#
