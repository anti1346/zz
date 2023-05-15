#!/bin/bash

# Extract mirror.kakao.com fields from /etc/apt/sources.list
mirrors=$(cat /etc/apt/sources.list | egrep -v "jammy-security" | awk '/^deb/ {print $2}' | awk -F/ '{print $3}' | sort -u)

# Replace archive.ubuntu.com with mirror.kakao.com in /etc/apt/sources.list
sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list

# Update package repositories
apt-get update
