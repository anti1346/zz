#!/bin/bash

# Update package sources to use mirror.kakao.com
sudo sed -i 's/\(kr\|archive\|ports\).ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list

# Update package lists
sudo apt-get update
