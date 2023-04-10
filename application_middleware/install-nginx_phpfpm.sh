#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Check if running on Ubuntu or CentOS
if [[ -x "$(command -v apt-get)" ]]; then
    OS="Ubuntu"
elif [[ -x "$(command -v yum)" ]]; then
    OS="CentOS"
else
    echo "Unsupported operating system"
    exit 1
fi

# Update package lists
if [[ $OS == "Ubuntu" ]]; then
    apt-get update -y
elif [[ $OS == "CentOS" ]]; then
    #yum update -y
    echo "update"
fi

# Install required packages
if [[ $OS == "Ubuntu" ]]; then
    apt-get install -y nginx php8.4-fpm
elif [[ $OS == "CentOS" ]]; then
    yum install -y nginx php8.4-fpm
fi

# Configure PHP-FPM
sudo sed -i 's/^user = apache/user = nginx/' /etc/php-fpm.d/www.conf
sudo sed -i 's/^group = apache/group = nginx/' /etc/php-fpm.d/www.conf

# Configure Nginx
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
sudo tee /etc/nginx/nginx.conf > /dev/null <<EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
        '\$status \$body_bytes_sent "\$http_referer" '
        '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF

sudo cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.backup
sudo rm /etc/nginx/conf.d/default.conf
sudo tee /etc/nginx/conf.d/default.conf > /dev/null <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /usr/share/nginx/html;
    index index.php index.html index.htm;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;

    location = /50x.html {
        root /usr/share/nginx/html;
    }

    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_pass unix:/var/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

# Restart PHP-FPM and Nginx
if [[ $OS == "Ubuntu" ]]; then
    systemctl restart php8.4-fpm nginx
elif [[ $OS == "CentOS" ]]; then
    systemctl restart php-fpm nginx
fi
