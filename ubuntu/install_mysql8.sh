#!/bin/bash
# Chapter 4 Installing the MySQL Binary Package
# https://dev.mysql.com/doc/mysql-secure-deployment-guide/8.0/en/secure-deployment-install.html

MYSQL_VERSION=8.0.37
GLIBC_VERSION=2.28
MYSQL_DOWNLOAD_URL=https://dev.mysql.com/get/Downloads/MySQL-8.0
MYSQL_PACKAGE=mysql-${MYSQL_VERSION}-linux-glibc${GLIBC_VERSION}-$(arch).tar.xz
WORK_DIR=/tmp
MYSQL_INSTALL_DIR=/usr/local/mysql

# MySQL 사용자 생성
if ! id "mysql" &>/dev/null; then
    sudo groupadd -r mysql
    sudo useradd -M -N -g mysql -o -r -d ${MYSQL_INSTALL_DIR} -s /bin/false -c "MySQL Server" -u 27 mysql
fi

# libncurses5가 설치되어 있는지 확인
if [[ "$(command -v apt-get)" ]]; then
    if ! dpkg -l | grep -q libncurses5; then
        sudo apt-get update
        sudo apt-get install -y libncurses5
    fi
elif [[ "$(command -v yum)" ]]; then
    if ! rpm -q libaio; then
        sudo yum install -y libaio
    fi
else
    echo "Unsupported package manager."
    exit 1
fi

# WORK_DIR에 MySQL 패키지가 이미 있는지 확인
if [ ! -f ${WORK_DIR}/${MYSQL_PACKAGE} ]; then
    cd ${WORK_DIR}
    wget -q ${MYSQL_DOWNLOAD_URL}/${MYSQL_PACKAGE} -O ${MYSQL_PACKAGE}
fi

sudo mkdir -p ${MYSQL_INSTALL_DIR}/data

sudo tar xf ${WORK_DIR}/${MYSQL_PACKAGE} -C ${MYSQL_INSTALL_DIR} --strip-components=1

sudo chown -R mysql:mysql ${MYSQL_INSTALL_DIR}



# curl -fsSL  https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/install_mysql8.sh | bash
