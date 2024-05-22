#!/bin/bash

MYSQL_VERSION=8.0.37
GLIBC_VERSION=2.28
OS_ARCH=86_64
MYSQL_DOWNLOAD_URL=https://dev.mysql.com/get/Downloads/MySQL-8.0
MYSQL_PACKAGE=mysql-${MYSQL_VERSION}-linux-glibc${GLIBC_VERSION}-${OS_ARCH}.tar.xz
WORK_DIR=/tmp
MYSQL_INSTALL_DIR=/usr/local/mysql

# MySQL 사용자 생성
if ! id "mysql" &>/dev/null; then
    sudo useradd -r -u 104 -g mysql -c "MySQL Server" -d ${MYSQL_INSTALL_DIR} -s /bin/false mysql
fi


# libncurses5가 설치되어 있는지 확인
if [[ "$(command -v apt-get)" ]]; then
    if ! dpkg -l | grep -q libncurses5; then
        sudo apt-get update
        sudo apt-get install -y libncurses5
    fi
elif [[ "$(command -v yum)" ]]; then
    if ! rpm -q ncurses-compat-libs; then
        sudo yum install -y ncurses-compat-libs
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

sudo tar xf ${WORK_DIR}/${MYSQL_PACKAGE} -C ${MYSQL_INSTALL_DIR} --strip-components=1

sudo mkdir -p ${MYSQL_INSTALL_DIR}/data

sudo chown -R mysql:mysql ${MYSQL_INSTALL_DIR}