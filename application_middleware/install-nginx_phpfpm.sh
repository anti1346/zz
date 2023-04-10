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
    sudo apt-get install -y ubuntu-keyring
    sudo add-apt-repository ppa:ondrej/php
    apt-get update -y
    echo "127.0.0.1 $HOSTNAME" >> /etc/hosts
elif [[ $OS == "CentOS" ]]; then
    yum install -y epel-release yum-utils
fi

# Install nginx packages
if [[ $OS == "Ubuntu" ]]; then
    # Import nginx signing key
    curl -s https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
    ### Verify the fingerprint. If it's different, remove the file.
    # gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

    # Set up apt repository for stable nginx packages
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
        | sudo tee /etc/apt/sources.list.d/nginx.list

    # Update the package list and install Nginx
    sudo apt-get update
    sudo apt-get install -y nginx 
elif [[ $OS == "CentOS" ]]; then
    # Add the Nginx signing key
    sudo rpm --import https://nginx.org/keys/nginx_signing.key

    # Add the Nginx repository
    sudo tee /etc/yum.repos.d/nginx.repo << EOF
[nginx-stable]
name=nginx stable repo
baseurl=https://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=https://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF

    # Update the package list and install Nginx
    sudo yum update
    sudo yum install -y nginx
fi

# Install php-fpm packages
if [[ $OS == "Ubuntu" ]]; then
    PHP_VERSIOIN="php8.2"
    sudo apt-get install -y $PHP_VERSIOIN $PHP_VERSIOIN-dev $PHP_VERSIOIN-cli $PHP_VERSIOIN-fpm $PHP_VERSIOIN-common $PHP_VERSIOIN-igbinary
    sudo apt-get install -y $PHP_VERSIOIN-gd $PHP_VERSIOIN-mysql $PHP_VERSIOIN-curl $PHP_VERSIOIN-mbstring $PHP_VERSIOIN-mcrypt \
        $PHP_VERSIOIN-intl $PHP_VERSIOIN-xml $PHP_VERSIOIN-redis $PHP_VERSIOIN-readline $PHP_VERSIOIN-mongodb $PHP_VERSIOIN-zip \
        $PHP_VERSIOIN-imagick $PHP_VERSIOIN-rdkafka \ 
        php-json php-pear
elif [[ $OS == "CentOS" ]]; then
    yum install -y php8.2-fpm
fi

# Configure Nginx, PHP-FPM
if [[ $OS == "Ubuntu" ]]; then
    NGINX_NGINXCONF="/etc/nginx/nginx.conf"
    NGINX_DEFAULTCONF="/etc/nginx/conf.d/default.conf"
    PHPFPM_PHPINI="/etc/php/8.2/fpm/php.ini"
    PHPFPM_PHPFPMCONF="/etc/php/8.2/fpm/php-fpm.conf"
    PHPFPM_WWWCONF="/etc/php/8.2/fpm/pool.d/www.conf"
elif [[ $OS == "CentOS" ]]; then
    WWWCONF="/etc/php-fpm.d/www.conf"
fi

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
}
EOF

sudo cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.backup
sudo rm /etc/nginx/conf.d/default.conf
sudo tee /etc/nginx/conf.d/default.conf > /dev/null <<EOF
server {
    listen 80 default_server;
    server_name _;

    root /usr/share/nginx/html;

    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    error_page 404 /404.html;

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_pass unix:/var/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

# Configure PHP-FPM
sudo sed -i 's/expose_php = On/expose_php = Off/g' $PHPFPM_PHPINI
sudo sed -i 's/^user = www-data/user = nginx/' $PHPFPM_WWWCONF
sudo sed -i 's/^group = www-data/group = nginx/' $PHPFPM_WWWCONF

# Restart PHP-FPM and Nginx
if [[ $OS == "Ubuntu" ]]; then
    systemctl restart php8.2-fpm nginx
elif [[ $OS == "CentOS" ]]; then
    systemctl restart php-fpm nginx
fi
