#!/bin/bash

# Check the OS and use the appropriate package manager
if [ -f /etc/lsb-release ]; then
    # Ubuntu
    # Install prerequisites
    sudo apt install -y curl gnupg2 ca-certificates lsb-release

    # Install nginx
    sudo apt-get update
    sudo apt-get -y install apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
    sudo systemctl status apache2
elif [ -f /etc/redhat-release ]; then
    # CentOS
    sudo yum update
    sudo yum -y install epel-release
    sudo yum -y install nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo firewall-cmd --permanent --zone=public --add-service=http
    sudo firewall-cmd --reload
    sudo systemctl status nginx
else
    echo "Unsupported operating system."
    exit 1
fi
