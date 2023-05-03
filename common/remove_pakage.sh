#!/bin/bash

# Check if /run/systemd/resolve/stub-resolv.conf exists
if [ ! -f "/run/systemd/resolve/stub-resolv.conf" ]; then
    echo "/run/systemd/resolve/stub-resolv.conf does not exist. Script will not be executed."
    exit 1
fi

# Stop and disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

# Remove /etc/resolv.conf and create a new one
sudo rm /etc/resolv.conf
sudo bash -c 'cat << EOF > /etc/resolv.conf
nameserver 168.126.63.1
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF'

# Check if snapd is installed
if [ ! "$(which snap)" ]; then
    echo "snapd not installed. Script will not be executed."
    exit 1
fi

# Stop and disable snapd services
sudo systemctl stop snapd.socket snapd.service
sudo systemctl disable snapd.socket snapd.service
sudo systemctl disable snapd.seeded.service

# Remove snap packages
sudo snap remove lxd amazon-ssm-agent core18 core20 snapd

# Remove snapd package and dependencies
sudo apt autoremove -y --purge snapd

# Remove snap cache and directories
sudo rm -rf /var/cache/snapd/
sudo rm -rf ~/snap
