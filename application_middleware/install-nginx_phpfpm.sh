#!/bin/bash

### 이 스크립트에서 발생한 에러가 무시되지 않도록 합니다.
set -euo pipefail

### Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

### Check if running on Ubuntu or CentOS
if [[ -x "$(command -v apt-get)" ]]; then
    OS="Ubuntu"
elif [[ -x "$(command -v yum)" ]]; then
    OS="CentOS"
else
    echo "지원되지 않는 운영 체제입니다."
    exit 1
fi

### 패키지 리스트 업데이트
if [[ $OS == "Ubuntu" ]]; then
    apt-get update
    echo "127.0.0.1 $HOSTNAME" | sudo tee -a /etc/hosts >/dev/null
elif [[ $OS == "CentOS" ]]; then
    sudo yum install -y epel-release yum-utils
fi

############################################################################################################
############################################################################################################
############################################################################################################
### Nginx 패키지 설치
if [[ $OS == "Ubuntu" ]]; then
    NGINX_NGINXCONF="/etc/nginx/nginx.conf"
    NGINX_DEFAULTCONF="/etc/nginx/conf.d/default.conf"

    ### 필요한 종속성 설치
    sudo apt-get install -y ubuntu-keyring
        
    ### Nginx 서명 키 가져오기
    curl -s https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
    ### 키 지문 확인. 다르면 파일 삭제.
    # gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

    ### 안정 버전 Nginx 패키지를 위한 apt 저장소 설정
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
        | sudo tee /etc/apt/sources.list.d/nginx.list

    ### 패키지 리스트 업데이트 및 Nginx 설치
    sudo apt-get update
    sudo apt-get install -y nginx 
elif [[ $OS == "CentOS" ]]; then
    NGINX_NGINXCONF="/etc/nginx/nginx.conf"
    NGINX_DEFAULTCONF="/etc/nginx/conf.d/default.conf"

    ### Nginx 서명 키 추가
    sudo rpm --import https://nginx.org/keys/nginx_signing.key

    ### Nginx 저장소 추가
    sudo tee /etc/yum.repos.d/nginx.repo << EOF
[nginx-stable]
name=nginx stable repo
baseurl=https://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=https://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF

    ### Nginx 설치
    sudo yum install -y nginx
fi

############################################################################################################
############################################################################################################
############################################################################################################
# Install PHP-FPM packages
if [[ $OS == "Ubuntu" ]]; then
    # Configure PHP-FPM
    PHP_VERSIOIN="8.2"
    PHPFPM_PHPINI="/etc/php/$PHP_VERSIOIN/fpm/php.ini"
    PHPFPM_PHPFPMCONF="/etc/php/$PHP_VERSIOIN/fpm/php-fpm.conf"
    PHPFPM_WWWCONF="/etc/php/$PHP_VERSIOIN/fpm/pool.d/www.conf"

    sudo add-apt-repository ppa:ondrej/php
    apt-get update -y

    sudo apt-get install -y php$PHP_VERSIOIN php$PHP_VERSIOIN-dev php$PHP_VERSIOIN-cli php$PHP_VERSIOIN-fpm \
        php$PHP_VERSIOIN-common php$PHP_VERSIOIN-igbinary

    sudo apt-get install -y php$PHP_VERSIOIN-gd php$PHP_VERSIOIN-mysql php$PHP_VERSIOIN-curl php$PHP_VERSIOIN-mbstring \
        php$PHP_VERSIOIN-mcrypt php$PHP_VERSIOIN-intl php$PHP_VERSIOIN-xml php$PHP_VERSIOIN-redis php$PHP_VERSIOIN-readline \
        php$PHP_VERSIOIN-mongodb php$PHP_VERSIOIN-zip php$PHP_VERSIOIN-imagick php$PHP_VERSIOIN-rdkafka \
        php-json php-pear
elif [[ $OS == "CentOS" ]]; then
    # Configure Nginx
    WWWCONF="/etc/php-fpm.d/www.conf"
    yum install -y php8.2-fpm
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
