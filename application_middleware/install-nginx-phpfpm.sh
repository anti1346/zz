#!/bin/bash

### 이 스크립트에서 발생한 에러가 무시되지 않도록 합니다.
set -euo pipefail

### PHP 버전
PHP_VERSION="${PHP_VERSION:-8.1}"

if [[ ! -z "$1" ]]; then
    ### PHP_VERSION=8.1
    PHP_VERSION="${1#*=}"
fi

### Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

### 애플리케이션 유저(www-data) 생성
if id "www-data" >/dev/null 2>&1; then
    echo -e "\033[38;5;226m\nwww-data user already exists\n\033[0m"
else
    sudo useradd -r -s /usr/sbin/nologin -d /var/www -U www-data
    echo -e "\033[38;5;226m\nwww-data user created\n\033[0m"
fi

### 호스트 파일에 호스트명 등록
if grep -q "^127.0.0.1\s$HOSTNAME\s*$" /etc/hosts; then
    echo -e "\033[38;5;226m\n127.0.0.1 $HOSTNAME 에 대한 호스트 항목이 /etc/hosts 에 이미 존재합니다.\n\033[0m"
else
    echo "127.0.0.1 $HOSTNAME" | sudo tee -a /etc/hosts >/dev/null
    echo -e "\033[38;5;226m\n/etc/hosts 에 127.0.0.1 $HOSTNAME 에 대한 호스트 항목 추가\n\033[0m"
fi

### Check if running on Ubuntu or CentOS
if [[ -x "$(command -v apt-get)" ]]; then
    OS="Ubuntu"
elif [[ -x "$(command -v yum)" ]]; then
    OS="CentOS"
else
    echo -e "\033[38;5;226m\n지원되지 않는 운영 체제입니다.\n\033[0m"
    exit 1
fi

### 패키지 리스트 업데이트
if [[ $OS == "Ubuntu" ]]; then
    apt-get update
    ### sources.list 파일 백업 및 저장소
    cp /etc/apt/sources.list /etc/apt/sources.list-$(date +%Y%m%d_%H%M%S)
    sed -i 's/kr.archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list
    echo -e "\033[38;5;226m\n패키지 리스트 업데이트\n\033[0m"
elif [[ $OS == "CentOS" ]]; then
    sudo yum install -y epel-release yum-utils
    echo -e "\033[38;5;226m\n패키지 리스트 업데이트\n\033[0m"
fi

############################################################################################################
############################################################################################################
############################################################################################################
### Nginx 패키지 설치
if [[ $OS == "Ubuntu" ]]; then
    NGINX_NGINXCONF="/etc/nginx/nginx.conf"
    NGINX_DEFAULTCONF="/etc/nginx/conf.d/default.conf"

    ### 필요한 종속성 설치
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-keyring
    ### Nginx 서명 키 가져오기
    curl -s https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
    ### 키 지문 확인. 다르면 파일 삭제.
    # gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
    ### 안정 버전 Nginx 패키지를 위한 apt 저장소 설정
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
        | sudo tee /etc/apt/sources.list.d/nginx.list
    ### 패키지 리스트 업데이트 및 Nginx 설치
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nginx 
    echo -e "\033[38;5;226m\nNginx 패키지 설치\n\033[0m"
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
    echo -e "\033[38;5;226m\nNginx 패키지 설치\n\033[0m"
fi

# Configure Nginx
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf_$(date +%Y%m%d_%H%M%S)
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
sudo cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf_$(date +%Y%m%d_%H%M%S)
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

    # nginx, php-fpm status
    location ~ ^/(status|ping)$ {
        fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_index index.php;
        include fastcgi_params;
        allow 127.0.0.1;
        deny all;
        access_log off;
    }
    location /basic_status {
        stub_status on;
        allow 127.0.0.1;
        deny all;
        access_log off;
    }
}
EOF
echo -e "\033[38;5;226m\nNginx 설정\n\033[0m"

############################################################################################################
############################################################################################################
############################################################################################################
# Install PHP-FPM packages
if [[ $OS == "Ubuntu" ]]; then
    ### Configure PHP-FPM
    #PHP_VERSION="8.2"
    PHPFPM_PHPINI="/etc/php/$PHP_VERSION/fpm/php.ini"
    PHPFPM_PHPFPMCONF="/etc/php/$PHP_VERSION/fpm/php-fpm.conf"
    PHPFPM_WWWCONF="/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"

    sudo DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:ondrej/php
    apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y php$PHP_VERSION php$PHP_VERSION-dev php$PHP_VERSION-cli php$PHP_VERSION-fpm \
        php$PHP_VERSION-common php$PHP_VERSION-igbinary
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y php$PHP_VERSION-gd php$PHP_VERSION-mysql php$PHP_VERSION-curl php$PHP_VERSION-mbstring \
        php$PHP_VERSION-mcrypt php$PHP_VERSION-intl php$PHP_VERSION-xml php$PHP_VERSION-redis php$PHP_VERSION-readline \
        php$PHP_VERSION-mongodb php$PHP_VERSION-zip php$PHP_VERSION-imagick php$PHP_VERSION-rdkafka \
        php-json php-pear
    echo -e "\033[38;5;226m\nPHP-FPM 패키지 설치\n\033[0m"
elif [[ $OS == "CentOS" ]]; then
    ### Configure PHP-FPM
    #PHP_VERSION="8.2"
    PHPFPM_PHPINI="/etc/php.ini"
    PHPFPM_PHPFPMCONF="/etc/php-fpm.conf"
    PHPFPM_WWWCONF="/etc/php-fpm.d/www.conf"
    if yum list installed "remi-release" >/dev/null 2>&1; then
        echo -e "\033[38;5;226m\nremi-release가 이미 설치되어 있습니다.\n\033[0m"
    else
        echo -e "\033[38;5;226m\nremi-release가 설치되지 않았습니다. 지금 설치 중...\n\033[0m"
        sudo yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
    fi
    yum-config-manager --enable remi-php${PHP_VERSION//./}
    yum install -y php php-cli php-common php-devel php-pear php-fpm
    yum install -y php-mysql php-gd php-curl php-xml php-json php-intl php-mbstring \
        php-mcrypt php-pecl-igbinary php-pecl-redis php-pecl-rdkafka php-pecl-zip php-pecl-imagick \
        php-pecl-mongodb
    echo -e "\033[38;5;226m\nPHP-FPM 패키지 설치\n\033[0m"
fi

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
    ### sock 디렉토리 생성
    mkdir -p /var/run/php-fpm
    chown www-data.www-data /var/run/php-fpm
    ### 로그 디렉토리 생성
    mkdir -p /var/log/php-fpm
    chmod 770 /var/log/php-fpm
    sudo sed -i "s|^include=/etc/php-fpm.d/\*.conf|include=/etc/php/$PHP_VERSION/fpm/pool.d/\*.conf|g" $PHPFPM_PHPFPMCONF
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
echo -e "\033[38;5;226m\nPHP-FPM 설정\n\033[0m"

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
    <p>Server IP Address: <?php echo $_SERVER['SERVER_ADDR']; ?></p>
    <p>Virtual Host Domain: <?php echo $_SERVER['HTTP_HOST']; ?></p>
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
echo -e "\033[38;5;226m\nPHP 테스트 페이지 생성\n\033[0m"

### Restart PHP-FPM and Nginx
if [[ $OS == "Ubuntu" ]]; then
    systemctl restart php8.2-fpm nginx
elif [[ $OS == "CentOS" ]]; then
    systemctl restart php-fpm nginx
fi
