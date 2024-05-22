#!/bin/bash

MYSQL_VERSION=8.0.37
GLIBC_VERSION=2.28
OS_ARCH=86_64
MYSQL_DOWNLOAD_URL=https://dev.mysql.com/get/Downloads/MySQL-8.0
MYSQL_PACKAGE=mysql-${MYSQL_VERSION}-linux-glibc${GLIBC_VERSION}-${OS_ARCH}.tar.xz
WORK_DIR=/tmp
MYSQL_INSTALL_DIR=/usr/local/mysql

# Tomcat 설치 및 설정
if ! id "mysql" &>/dev/null; then
    sudo useradd -r -U -u 104 -c "MySQL Server" -d ${MYSQL_INSTALL_DIR} -s /bin/false mysql
    mysql:x:104:105:MySQL Server,,,:/nonexistent:/bin/false
fi

# Check if libncurses5 is installed (only for Ubuntu)
if [[ $(lsb_release -si) == "Ubuntu" ]]; then
    if ! dpkg -l | grep -q libncurses5; then
        echo "Installing libncurses5..."
        sudo apt-get update
        sudo apt-get install -y libncurses5
    fi
fi

# Check if the MySQL package already exists in the WORK_DIR
if [ ! -f ${WORK_DIR}/${MYSQL_PACKAGE} ]; then
    cd ${WORK_DIR}
    wget -q ${MYSQL_DOWNLOAD_URL}/${MYSQL_PACKAGE} -O ${MYSQL_PACKAGE}
fi

tar xf ${WORK_DIR}/${MYSQL_PACKAGE} -C ${MYSQL_INSTALL_DIR} --strip-components=1

mkdir -p ${MYSQL_INSTALL_DIR}/data

chown -R mysql:mysql ${MYSQL_INSTALL_DIR}
