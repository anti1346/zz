#!/bin/bash

# SELinux를 비활성화하는 스크립트

echo "SELinux를 비활성화합니다."
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
sudo setenforce 0

echo "시스템을 다시 시작합니다."
#sudo reboot
