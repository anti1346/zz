#!/bin/bash

### 이 스크립트에서 발생한 에러가 무시되지 않도록 합니다.
set -euo pipefail

PHP_VERSIOIN="8.2"

### Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

### 애플리케이션 유저(www-data) 생성
if id "www-data" >/dev/null 2>&1; then
    echo -e "\nwww-data user already exists\n"
else
    sudo useradd -r -s /usr/sbin/nologin -d /var/www -U www-data
    echo -e "\nwww-data user created\n"
fi

### 호스트 파일에 호스트명 등록
if grep -q "^127.0.0.1\s$HOSTNAME\s*$" /etc/hosts; then
    echo -e "\n127.0.0.1 $HOSTNAME에 대한 호스트 항목이 /etc/hosts에 이미 존재합니다.\n"
else
    echo "127.0.0.1 $HOSTNAME" | sudo tee -a /etc/hosts >/dev/null
    echo -e "\n/etc/hosts에 127.0.0.1 $HOSTNAME에 대한 호스트 항목 추가\n"
fi

### Check if running on Ubuntu or CentOS
if [[ -x "$(command -v apt-get)" ]]; then
    OS="Ubuntu"
elif [[ -x "$(command -v yum)" ]]; then
    OS="CentOS"
else
    echo -e "/n지원되지 않는 운영 체제입니다./n"
    exit 1
fi

### 패키지 리스트 업데이트
if [[ $OS == "Ubuntu" ]]; then
    apt-get update
    ### sources.list 파일 백업 및 저장소
    cp /etc/apt/sources.list /etc/apt/sources.list-$(date +%Y%m%d_%H%M%S)
    sed -i 's/kr.archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list
    echo -e "/n패키지 리스트 업데이트/n"
elif [[ $OS == "CentOS" ]]; then
    sudo yum install -y epel-release yum-utils
    echo -e "/n패키지 리스트 업데이트/n"
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
    echo -e "/nNginx 패키지 설치/n"
elif [[ $OS == "CentOS" ]]; then
    NGINX_NGINXCONF="/etc/nginx/nginx.conf"
    NGINX_DEFAULTCONF="/etc/nginx/conf.d/default.conf"

    ### Nginx 서명 키 추가
    #sudo rpm --import https://nginx.org/keys/nginx_signing.key

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

    ### Nginx stable
    sudo yum-config-manager --enable nginx-stable

    ### Nginx 설치
    sudo yum install -y nginx
fi

############################################################################################################
############################################################################################################
############################################################################################################
# Install PHP-FPM packages
if [[ $OS == "Ubuntu" ]]; then
    ### Configure PHP-FPM
    #PHP_VERSIOIN="8.2"
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
    ### Configure PHP-FPM
    #PHP_VERSIOIN="8.2"
    PHPFPM_PHPINI="/etc/php.ini"
    PHPFPM_PHPFPMCONF="/etc/php-fpm.conf"
    PHPFPM_WWWCONF="/etc/php-fpm.d/www.conf"
    if rpm -q remi-release-7 >/dev/null 2>&1; then
        echo "remi-release-7 package is already installed"
    else
        sudo yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
        echo "remi-release-7 package installed"
    fi
    yum-config-manager --enable remi-php${PHP_VERSIOIN//./}
    yum install -y php php-cli php-common php-devel php-pear php-fpm
    yum install -y php-mysql php-gd php-curl php-xml php-json php-intl php-mbstring \
        php-mcrypt php-pecl-igbinary php-pecl-redis php-pecl-rdkafka php-pecl-zip php-pecl-imagick \
        php-pecl-mongodb
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
        fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

### Configure PHP-FPM
sudo tee $PHPFPM_PHPFPMCONF > /dev/null <<EOF
[global]
pid = /run/php-fpm/php-fpm.pid
error_log = /var/log/php-fpm/error.log
daemonize = yes
include=/etc/php-fpm.d/*.conf
EOF

sudo tee $PHPFPM_WWWCONF > /dev/null <<EOF
[www]
user = www-data
group = www-data

listen = /var/run/php-fpm/php-fpm.sock

listen.owner = www-data
listen.group = www-data
listen.mode = 0666
;listen.allowed_clients = 127.0.0.1

pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35

request_terminate_timeout = 30
request_slowlog_timeout = 10

;ping.path = /ping
pm.status_path = /status

slowlog = /var/log/php-fpm/www-slow.log

access.log = /var/log/php-fpm/www-access.log
access.format = "[%t] %m %{REQUEST_SCHEME}e://%{HTTP_HOST}e%{REQUEST_URI}e %f pid:%p TIME:%ds MEM:%{mega}Mmb CPU:%C%% status:%s {%{REMOTE_ADDR}e|%{HTTP_USER_AGENT}e}"

php_admin_value[error_log] = /var/log/php-fpm/www-error.log
php_admin_flag[log_errors] = on
php_value[session.save_handler] = files
php_value[session.save_path]    = /var/lib/php/session
php_value[soap.wsdl_cache_dir]  = /var/lib/php/wsdlcache
EOF

if [[ $OS == "Ubuntu" ]]; then
    mkdir -p /var/run/php-fpm
    chown nginx.nginx /var/run/php-fpm
    mkdir -p /var/log/php-fpm
    chmod 770 /var/log/php-fpm
    sudo sed -i 's/expose_php = On/expose_php = Off/g' $PHPFPM_PHPINI
    sudo sed -i 's/^listen = .*/listen = \/var\/run\/php-fpm\/php-fpm.sock/g' $PHPFPM_WWWCONF
    sudo sed -i 's/^user = www-data/user = www-data/' $PHPFPM_WWWCONF
    sudo sed -i 's/^group = www-data/group = www-data/' $PHPFPM_WWWCONF
elif [[ $OS == "CentOS" ]]; then
    sudo sed -i 's/expose_php = On/expose_php = Off/g' $PHPFPM_PHPINI
    sudo sed -i 's/^listen = .*/listen = \/var\/run\/php-fpm\/php-fpm.sock/g' $PHPFPM_WWWCONF
    sudo sed -i 's/^user = apache/user = www-data/' $PHPFPM_WWWCONF
    sudo sed -i 's/^group = apache/group = www-data/' $PHPFPM_WWWCONF
fi

### Php info page(/usr/share/nginx/html)
sudo tee /usr/share/nginx/html/test.php > /dev/null <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>PHP Test Page</title>
</head>
<body>
    <h1>PHP Test Page</h1>
    <p>IP Address: <?php echo $_SERVER['REMOTE_ADDR']; ?></p>
    <p>Server Hostname: <?php echo gethostname(); ?></p>
    <p>NGINX Version: <?php echo $_SERVER['SERVER_SOFTWARE']; ?></p>
    <p>NGINX Home Directory: <?php echo $_SERVER['DOCUMENT_ROOT']; ?></p>
    <p>PHP Version: <?php echo phpversion(); ?></p>
    <p>PHP Modules:</p>
    <ul>
        <?php foreach(get_loaded_extensions() as $module): ?>
            <li><?php echo $module; ?></li>
        <?php endforeach; ?>
    </ul>
</body>
</html>
EOF

### Restart PHP-FPM and Nginx
if [[ $OS == "Ubuntu" ]]; then
    systemctl restart php8.2-fpm nginx
elif [[ $OS == "CentOS" ]]; then
    systemctl restart php-fpm nginx
fi
