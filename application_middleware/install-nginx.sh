#!/bin/bash

# Check the OS and use the appropriate package manager
if [ -f /etc/lsb-release ]; then
    # Ubuntu
    # Install prerequisites
    sudo apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring -y

    # Import nginx signing key
    curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
        | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
    gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
    # Verify the fingerprint. If it's different, remove the file.

    # Set up apt repository for stable nginx packages
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
    http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
        | sudo tee /etc/apt/sources.list.d/nginx.list

    # Set up repository pinning
    echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
        | sudo tee /etc/apt/preferences.d/99nginx

    # Install nginx
    sudo apt-get update
    sudo apt-get -y install nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo ufw allow 'Nginx HTTP'
    sudo systemctl status nginx
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
