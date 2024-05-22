#!/bin/bash

MYSQL_VERSION=8.0.37
GLIBC_VERSION=2.28
OS_ARCH=86_64
MYSQL_DOWNLOAD_URL=https://dev.mysql.com/get/Downloads/MySQL-8.0
MYSQL_PACKAGE=mysql-${MYSQL_VERSION}-linux-glibc${GLIBC_VERSION}-${OS_ARCH}.tar.xz
WORK_DIR=/usr/local/src
MYSQL_INSTALL_DIR=/usr/local/mysql

# Check if the MySQL package already exists in the WORK_DIR
if [ ! -f ${WORK_DIR}/${MYSQL_PACKAGE} ]; then
    cd ${WORK_DIR}
    wget -q ${MYSQL_DOWNLOAD_URL}/${MYSQL_PACKAGE} -O ${MYSQL_PACKAGE}
fi

tar xf ${WORK_DIR}/${MYSQL_PACKAGE} -C ${MYSQL_INSTALL_DIR} --strip-components=1

mkdir -p ${MYSQL_INSTALL_DIR}/data

chown -R mysql:mysql ${MYSQL_INSTALL_DIR}
