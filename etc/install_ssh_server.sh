#!/bin/bash

if command -v apt &>/dev/null; then
    package_manager=apt-get
elif command -v yum &>/dev/null; then
    package_manager=yum
else
    echo "Unsupported package manager. Please install OpenSSH manually."
    exit 1
fi

sudo ${package_manager} update
sudo ${package_manager} install -y openssh-server
sudo systemctl start sshd

echo "OpenSSH server installed and started successfully."
