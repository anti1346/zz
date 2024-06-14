#!/bin/bash

# 스크립트 설명
# 이 스크립트는 Nginx와 PHP를 소스에서 컴파일하여 설치하고, 시스템에 필요한 설정을 적용합니다.

# 패키지 목록을 업데이트하고 필수 패키지 설치
sudo apt-get update
sudo apt-get install -y build-essential pkg-config autoconf make wget vim git

# Nginx에 필요한 의존성 패키지 설치
sudo apt-get install -y zlib1g-dev libssl-dev libpcre3-dev libzip-dev

# Nginx 소스 다운로드 및 컴파일
cd /usr/local/src
wget https://nginx.org/download/nginx-1.26.1.tar.gz
tar -zxvf nginx-1.26.1.tar.gz
cd nginx-1.26.1

# Nginx 구성 옵션 설정 및 설치
./configure \
  --prefix=/usr/local/nginx \
  --conf-path=/usr/local/nginx/nginx.conf \
  --sbin-path=/usr/local/nginx/sbin/nginx \
  --modules-path=/usr/lib/nginx/modules \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --pid-path=/var/run/nginx.pid \
  --lock-path=/var/run/nginx.lock \
  --http-client-body-temp-path=/var/cache/nginx/client_temp \
  --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
  --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
  --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
  --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
  --user=www-data \
  --group=www-data \
  --with-compat \
  --with-file-aio \
  --with-threads \
  --with-http_addition_module \
  --with-http_auth_request_module \
  --with-http_dav_module \
  --with-http_flv_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_mp4_module \
  --with-http_random_index_module \
  --with-http_realip_module \
  --with-http_secure_link_module \
  --with-http_slice_module \
  --with-http_ssl_module \
  --with-http_stub_status_module \
  --with-http_sub_module \
  --with-http_v2_module \
  --with-http_v3_module \
  --with-stream \
  --with-stream_realip_module \
  --with-stream_ssl_module \
  --with-stream_ssl_preread_module

# Nginx 빌드 및 설치
make -j4 && sudo make install

# Nginx 바이너리에 대한 심볼릭 링크 생성
sudo ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx

# Nginx 설정 디렉토리 생성 및 권한 설정
sudo mkdir -p /usr/local/nginx/{backupConf,conf.d}
sudo cp /usr/local/nginx/nginx.conf /usr/local/nginx/backupConf/nginx.conf
sudo mv /usr/local/nginx/*.default /usr/local/nginx/backupConf/
sudo mkdir -p /var/cache/nginx/client_temp
sudo chown www-data:www-data -R /var/cache/nginx

# Nginx용 systemd 서비스 파일 생성
sudo tee /usr/lib/systemd/system/nginx.service > /dev/null <<EOL
[Unit]
Description=nginx - high performance web server
Documentation=https://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx -c /usr/local/nginx/nginx.conf
ExecReload=/bin/sh -c "/bin/kill -s HUP \$(/bin/cat /var/run/nginx.pid)"
ExecStop=/bin/sh -c "/bin/kill -s TERM \$(/bin/cat /var/run/nginx.pid)"

[Install]
WantedBy=multi-user.target
EOL

# Nginx 서비스 활성화 및 시작
sudo systemctl daemon-reload
sudo systemctl --now enable nginx.service

# PHP에 필요한 의존성 패키지 설치
sudo apt-get install -y \
  libxml2-dev libsqlite3-dev libcurl4-openssl-dev libonig-dev \
  libreadline-dev libargon2-dev libjpeg-dev libpng-dev libfreetype6-dev \
  libmcrypt-dev libxslt1-dev libffi-dev libsodium-dev libexpat1-dev \
  libpcre2-dev imagemagick bison re2c

# PHP 소스 다운로드 및 컴파일
cd /usr/local/src
wget https://www.php.net/distributions/php-8.3.8.tar.gz
tar -zxvf php-8.3.8.tar.gz
cd php-8.3.8

# PHP 구성 옵션 설정 및 설치
./configure \
  --prefix=/usr/local/php/8.3 \
  --sysconfdir=/usr/local/php/8.3/fpm \
  --with-config-file-path=/usr/local/php/8.3/fpm \
  --enable-fpm \
  --enable-bcmath \
  --enable-calendar \
  --enable-exif \
  --enable-ftp \
  --enable-gd \
  --enable-intl \
  --enable-mbstring \
  --enable-mysqlnd \
  --enable-pcntl \
  --enable-shmop \
  --enable-sockets \
  --enable-sysvmsg \
  --enable-sysvsem \
  --enable-sysvshm \
  --enable-cgi \
  --with-fpm-user=www-data \
  --with-fpm-group=www-data \
  --with-curl \
  --with-ffi \
  --with-gettext \
  --with-mysqli \
  --with-openssl \
  --with-sodium \
  --with-xsl \
  --with-zip \
  --with-zlib \
  --with-pdo-mysql \
  --with-readline \
  --with-expat \
  --with-external-pcre

# PHP 빌드 및 설치
make -j4 && sudo make install

# PHP 바이너리에 대한 심볼릭 링크 생성
sudo ln -s /usr/local/php/8.3/bin/php /usr/bin/php8.3
sudo ln -s /usr/local/php/8.3/bin/php-config /usr/bin/php-config8.3
sudo ln -s /usr/local/php/8.3/bin/phpize /usr/bin/phpize8.3
sudo ln -s /usr/local/php/8.3/sbin/php-fpm /usr/sbin/php-fpm8.3

# PHP-FPM에 필요한 디렉토리 생성 및 권한 설정
sudo mkdir -p /var/log/php-fpm
sudo chown www-data:root -R /var/log/php-fpm
sudo mkdir -p /var/run/php
sudo chown www-data:www-data -R /var/run/php

# PHP-FPM 구성 설정 복사
sudo cp /usr/local/src/php-8.3.8/php.ini-production /usr/local/php/8.3/fpm/php.ini
sudo cp /usr/local/php/8.3/fpm/php-fpm.conf.default /usr/local/php/8.3/fpm/php-fpm.conf
sudo cp /usr/local/php/8.3/fpm/php-fpm.d/www.conf.default /usr/local/php/8.3/fpm/php-fpm.d/www.conf

# PHP-FPM용 systemd 서비스 파일 생성
sudo tee /usr/lib/systemd/system/php8.3-fpm.service > /dev/null <<EOL
[Unit]
Description=The PHP 8.3 FastCGI Process Manager
Documentation=man:php-fpm8.3(8)
After=network.target

[Service]
Type=simple
PIDFile=/var/run/php/php8.3-fpm.pid
ExecStart=/usr/sbin/php-fpm8.3 --nodaemonize --fpm-config /usr/local/php/8.3/fpm/php-fpm.conf
ExecReload=/bin/kill -USR2 \$MAINPID
ExecStop=/bin/kill -WINCH \$MAINPID

[Install]
WantedBy=multi-user.target
EOL

# PHP-FPM 서비스 활성화 및 시작
sudo systemctl daemon-reload
sudo systemctl --now enable php8.3-fpm.service

# PHP 확장 모듈 설치
EXTENSIONS=(igbinary-3.2.15 mongodb-1.19.2 redis-6.0.2)
for EXT in "${EXTENSIONS[@]}"; do
    cd /usr/local/src
    wget "https://pecl.php.net/get/$EXT.tgz"
    tar xvfz "$EXT.tgz"
    cd "$EXT"
    phpize8.3
    ./configure --with-php-config=php-config8.3
    make -j4 && sudo make install
done

# rdkafka 설치
sudo apt-get install -y librdkafka-dev
cd /usr/local/src
wget https://pecl.php.net/get/rdkafka-6.0.3.tgz
tar xvfz rdkafka-6.0.3.tgz
cd rdkafka-6.0.3
phpize8.3
./configure --with-php-config=php-config8.3
make -j4 && sudo make install

# mod_screwim 설치
cd /usr/local/src
git clone https://github.com/OOPS-ORG-PHP/mod_screwim.git
cd mod_screwim
phpize8.3
./configure --with-php-config=php-config8.3
make -j4  && sudo make install

sudo tee -a /usr/local/php/8.3/fpm/php.ini > /dev/null <<EOL
extension=igbinary.so
extension=mongodb.so
extension=redis.so
extension=rdkafka.so
EOL

# Nginx 서버 설정 파일 생성
sudo tee /usr/local/nginx/nginx.conf > /dev/null <<'EOL'
# nginx.conf
user www-data www-data;
worker_processes auto;

error_log /var/log/nginx/error.log notice;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /usr/local/nginx/mime.types;
    default_type application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    server_tokens off;

    sendfile           on;
    tcp_nopush         on;
    tcp_nodelay        on;
    keepalive_timeout  10;

    ## Gzip config
    gzip on;
    gzip_disable "msie6";
    gzip_proxied any;
    gzip_comp_level 9;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_min_length 256;
    gzip_types
        application/atom+xml
        application/geo+json
        application/javascript
        application/x-javascript
        application/json
        application/ld+json
        application/manifest+json
        application/rdf+xml
        application/rss+xml
        application/xhtml+xml
        application/xml
        font/eot
        font/otf
        font/ttf
        image/svg+xml
        text/css
        text/javascript
        text/plain
        text/xml;
    ## end Gzip config

    include /usr/local/nginx/conf.d/*.conf;
}
EOL

# Nginx 기본 서버 설정 파일 생성
sudo mkdir -p /usr/local/nginx/html
sudo tee /usr/local/nginx/conf.d/default.conf > /dev/null <<'EOL'
server {
    listen 80;
    server_name _;
    root /usr/local/nginx/html;
    index index.html index.htm index.php;

    access_log /var/log/nginx/host-accesss.log;
    error_log /var/log/nginx/host-error.log;

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt { access_log off; log_not_found off; }

    error_page 404 /40x.html;
    location = /40x.html {
        root /usr/share/nginx/html;
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    location = /basic_status {
        stub_status;
        access_log off;
        allow 127.0.0.1;
        deny all;
    }

    location /status {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        access_log off;
        allow 127.0.0.1;
        deny all;
    }
}
EOL

# PHP-FPM 구성 파일 생성
sudo tee /usr/local/php/8.3/fpm/php-fpm.conf > /dev/null <<'EOL'
include=/usr/local/php/8.3/fpm/php-fpm.d/www.conf

[global]
pid = /var/run/php/php8.3-fpm.pid
error_log = /var/log/php-fpm/phpfpm83-error.log
daemonize = yes
EOL

# PHP-FPM 풀 구성 파일 생성
sudo tee /usr/local/php/8.3/fpm/php-fpm.d/www.conf > /dev/null <<'EOL'
[www83]
user = www-data
group = www-data

listen = /var/run/php/php8.3-fpm.sock

listen.owner = www-data
listen.group = www-data
listen.mode = 0660

pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

pm.status_path = /status
ping.path = /ping

slowlog = /var/log/php-fpm/$pool-slow.log

access.log = /var/log/php-fpm/$pool-access.log
access.format = "%R - %u %t \"%m %r%Q%q\" %s %f %{milli}d %{kilo}M %C%%"

php_admin_value[error_log] = /var/log/php-fpm/$pool-error.log
php_admin_flag[log_errors] = on
php_admin_value[memory_limit] = 32M

security.limit_extensions = .php .php3 .php4 .php5 .php7
EOL

# PHP 정보 페이지 생성
sudo tee /usr/local/nginx/html/info.php > /dev/null <<EOL
<?php phpinfo(); ?>
EOL

# NGINX, PHP-FPM 서비스 재시작
sudo systemctl restart nginx.service php8.3-fpm.service

# 화면 출력
cat <<EOF
################################################################
PHP 정보 페이지: http://localhost/info.php

NGINX 서비스 재시작: sudo systemctl restart nginx.service
PHP-FPM 서비스 재시작: sudo systemctl restart php8.3-fpm.service

심볼릭 링크 생성 명령어
sudo ln -s /usr/local/nginx /etc/nginx
sudo ln -s /usr/local/php /etc/php
################################################################
EOF



### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/install_nginx_php_compile.sh | bash