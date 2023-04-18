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

# ### 애플리케이션 유저(www-data) 생성
# if id "www-data" >/dev/null 2>&1; then
#     echo -e "\033[38;5;226m\nwww-data user already exists\n\033[0m"
# else
#     sudo useradd -r -s /usr/sbin/nologin -d /var/www -U www-data
#     echo -e "\033[38;5;226m\nwww-data user created\n\033[0m"
# fi

# ### 호스트 파일에 호스트명 등록
# if grep -q "^127.0.0.1\s$HOSTNAME\s*$" /etc/hosts; then
#     echo -e "\033[38;5;226m\n127.0.0.1 $HOSTNAME 에 대한 호스트 항목이 /etc/hosts 에 이미 존재합니다.\n\033[0m"
# else
#     echo "127.0.0.1 $HOSTNAME" | sudo tee -a /etc/hosts >/dev/null
#     echo -e "\033[38;5;226m\n/etc/hosts 에 127.0.0.1 $HOSTNAME 에 대한 호스트 항목 추가\n\033[0m"
# fi

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
# Install PHP packages
if [[ $OS == "Ubuntu" ]]; then
    ### Configure PHP
    PHP_PHPINI="/etc/php/$PHP_VERSION/cli/php.ini"

    sudo DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:ondrej/php
    apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y php$PHP_VERSION php$PHP_VERSION-dev php$PHP_VERSION-cli \
        php$PHP_VERSION-common php$PHP_VERSION-igbinary
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y php$PHP_VERSION-gd php$PHP_VERSION-mysql php$PHP_VERSION-curl php$PHP_VERSION-mbstring \
        php$PHP_VERSION-mcrypt php$PHP_VERSION-intl php$PHP_VERSION-xml php$PHP_VERSION-redis php$PHP_VERSION-readline \
        php$PHP_VERSION-mongodb php$PHP_VERSION-zip php$PHP_VERSION-imagick php$PHP_VERSION-rdkafka \
        php-json php-pear
    echo -e "\033[38;5;226m\nPHP 패키지 설치\n\033[0m"
elif [[ $OS == "CentOS" ]]; then
    ### Configure PHP
    PHPFPM_PHPINI="/etc/php.ini"
    if yum list installed "remi-release" >/dev/null 2>&1; then
        echo -e "\033[38;5;226m\nremi-release가 이미 설치되어 있습니다.\n\033[0m"
    else
        echo -e "\033[38;5;226m\nremi-release가 설치되지 않았습니다. 지금 설치 중...\n\033[0m"
        sudo yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
    fi
    yum-config-manager --enable remi-php${PHP_VERSION//./}
    yum install -y php php-cli php-common php-devel php-pear
    yum install -y php-mysql php-gd php-curl php-xml php-json php-intl php-mbstring \
        php-mcrypt php-pecl-igbinary php-pecl-redis php-pecl-rdkafka php-pecl-zip php-pecl-imagick \
        php-pecl-mongodb
    echo -e "\033[38;5;226m\nPHP 패키지 설치\n\033[0m"
fi


if [[ $OS == "Ubuntu" ]]; then
    sudo sed -i 's/expose_php = On/expose_php = Off/g' $PHPFPM_PHPINI
elif [[ $OS == "CentOS" ]]; then
    sudo sed -i 's/expose_php = On/expose_php = Off/g' $PHPFPM_PHPINI
fi
echo -e "\033[38;5;226m\nPHP 설정\n\033[0m"

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
echo -e "\033[38;5;226m\nPHP 테스트 페이지 생성\n\033[0m"

### Restart apache2
if [[ $OS == "Ubuntu" ]]; then
    systemctl restart apache2
elif [[ $OS == "CentOS" ]]; then
    systemctl restart apache
fi
