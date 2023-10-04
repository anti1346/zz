#!/bin/bash
set -x

###sudo yum install -y epel-release
sudo amazon-linux-extras install -y epel

sudo yum install -y yum-utils

sudo cat <<'EOF' > /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/amzn/2023/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
priority=9

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/amzn/2023/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
priority=9
EOF

sudo yum-config-manager --enable nginx-stable

sudo yum install -y libcrypt

sudo yum install -y nginx

sudo systemctl --now enable nginx

echo "NGINT TEST PAGE" > /usr/share/nginx/html/tt.html

