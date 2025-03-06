#!/bin/bash

set -e

# Disable snapd services
echo "Disabling snapd services..."
sudo systemctl disable snapd.service snapd.socket snapd.seeded.service

# List installed snaps
echo "Listing installed snaps..."
sudo snap list

# Remove snaps
snaps_to_remove=("lxd" "core20" "snapd")

echo "Removing snaps..."
for snap in "${snaps_to_remove[@]}"; do
    if sudo snap list | grep -q "$snap"; then
        sudo snap remove "$snap"
    else
        echo "$snap is not installed."
    fi
done

# Ensure services are stopped
echo "Stopping snapd services..."
sudo systemctl stop snapd.socket snapd.service

# Remove snapd package and dependencies
echo "Removing snapd package and dependencies..."
sudo apt autoremove -y --purge snapd

# Remove snap directories
snap_dirs=(~/snap /snap /var/snap /var/cache/snapd)

echo "Removing snap directories..."
for dir in "${snap_dirs[@]}"; do
    if [ -d "$dir" ]; then
        sudo rm -rf "$dir"
    else
        echo "$dir does not exist."
    fi
done

echo "Snapd and related components have been successfully removed."



### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/remove_snap.sh | bash
# 
# apt-get install -y dos2unix
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/remove_snap.sh | dos2unix | bash
