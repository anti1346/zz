#!/bin/bash

systemctl disable systemd-resolved

systemctl stop systemd-resolved

rm /etc/resolv.conf

cat <<EOF > /etc/resolv.conf
nameserver 168.126.63.1
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
