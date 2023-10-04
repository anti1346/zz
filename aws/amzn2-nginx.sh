#!/bin/bash
set -x

# /var/run/yum.pid 파일이 존재하는지 확인
while [ -f /var/run/yum.pid ]; do
    echo "Waiting for another yum process to finish..."
    sleep 5
done

###sudo yum install -y epel-release
sudo amazon-linux-extras install -y epel

sudo yum install -y yum-utils

sudo cat <<'EOF' > /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=https://nginx.org/packages/amzn/2023/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
priority=9

[nginx-mainline]
name=nginx mainline repo
baseurl=https://nginx.org/packages/mainline/amzn/2023/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
priority=9
EOF

sudo yum-config-manager --enable nginx-stable

sudo yum install -y libcrypt libssl libc

### sudo amazon-linux-extras install nginx1
sudo yum install -y nginx

sudo systemctl --now enable nginx

echo "NGINT TEST PAGE" > /usr/share/nginx/html/tt.html

echo "NGINX 1.24 설치가 완료되었습니다."
