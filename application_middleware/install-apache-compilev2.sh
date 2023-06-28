#!/bin/bash

HTTP_VERSION="${HTTP_VERSION:-2.4.57}"
APR_VERSION="${APR_VERSION:-1.7.4}"
UTIL_VERSION="${UTIL_VERSION:-1.6.3}"

### Ubuntu 또는 CentOS에서 실행 중인지 확인
if [[ -x "$(command -v apt-get)" ]]; then
    OS="Ubuntu"
elif [[ -x "$(command -v yum)" ]]; then
    OS="CentOS"
else
    echo -e "\033[38;5;226m\n지원되지 않는 운영 체제입니다.\n\033[0m"
    exit 1
fi

# OS를 확인하고 적절한 패키지 관리자를 사용하세요.
if [[ $OS == "Ubuntu" ]]; then
    # Ubuntu
    # 필요한 패키지 설치
    sudo apt-get update
    sudo apt-get install -y build-essential
    # 의존성 패키지 설치
    sudo apt-get install -y libpcre3 libpcre3-dev libssl-dev
elif [[ $OS == "CentOS" ]]; then
    # CentOS
    sudo yum install -y epel-release
    sudo yum install -y vim
    # 필요한 패키지 설치
    sudo yum install -y wget epel-release gcc make pcre-devel openssl-devel libtool expat-devel
    # 의존성 패키지 설치
    sudo yum install -y libnghttp2-devel
    echo -e "\033[38;5;226m\napache 패키지 설치 완료\n\033[0m"
else
    echo -e "\033[38;5;226m\n지원되지 않는 운영 체제입니다.\n\033[0m"
    exit 1
fi

DST_DIR='/usr/local/apache2'
SRC_DIR='/usr/local/src'

HTTPD_DIR="${SRC_DIR}/httpd-${HTTP_VERSION}"
APR_DIR="${HTTPD_DIR}/srclib/apr"
APR_UTIL_DIR="${HTTPD_DIR}/srclib/apr-util"

cd $SRC_DIR

# Apache, APR 및 APR-UTIL 소스 파일 다운로드
wget --no-check-certificate https://dlcdn.apache.org/httpd/httpd-${HTTP_VERSION}.tar.gz
wget --no-check-certificate https://dlcdn.apache.org/apr/apr-${APR_VERSION}.tar.gz
wget --no-check-certificate https://dlcdn.apache.org/apr/apr-util-${APR_UTIL_VERSION}.tar.gz

# Apache 소스 파일 압축 해제
tar xfz httpd-${HTTP_VERSION}.tar.gz

# APR, APR-UTIL 디렉토리 생성
mkdir -p ${APR_DIR} ${APR_UTIL_DIR}

# APR, APR-UTIL 소스 파일 압축 해제
tar xfz apr-${APR_VERSION}.tar.gz -C ${APR_DIR} --strip-components=1
tar xfz apr-util-${APR_UTIL_VERSION}.tar.gz -C ${APR_UTIL_DIR} --strip-components=1

cd $HTTPD_DIR

# 아파치 DEFAULT_SERVER_LIMIT 수정하기
sed -i "s/#define DEFAULT_SERVER_LIMIT 256/#define DEFAULT_SERVER_LIMIT 2048/g" $HTTPD_DIR/server/mpm/prefork/prefork.c
sed -i "s/#define DEFAULT_SERVER_LIMIT 16/#define DEFAULT_SERVER_LIMIT 256/g" $HTTPD_DIR/server/mpm/worker/worker.c
sed -i "s/#define DEFAULT_SERVER_LIMIT 16/#define DEFAULT_SERVER_LIMIT 256/g" $HTTPD_DIR/server/mpm/event/event.c

# 컴파일 및 설치
./configure \
--prefix=${DST_DIR} \
--enable-http2 \
--enable-ssl \
--enable-rewrite \
--enable-module=so \
--enable-mods-shared=all \
--with-included-apr \
--with-mpm=worker

make -j $(($(nproc) + 1))

make install

rm -rf ${SRC_DIR}/httpd-${HTTP_VERSION} ${SRC_DIR}/httpd-${HTTP_VERSION}.tar.gz  ${SRC_DIR}/apr-${APR_VERSION}.tar.gz ${SRC_DIR}/apr-util-${APR_UTIL_VERSION}.tar.gz

echo -e "\033[38;5;226m\napache 소스 컴파일 완료\n\033[0m"

cp ${DST_DIR}/conf/httpd.conf ${DST_DIR}/conf/httpd.conf_$(date +"%Y%m%d-%H%M%S")

sed -i '/^User /s/.*/User nobody/' ${DST_DIR}/conf/httpd.conf
sed -i '/^Group /s/.*/Group nobody/' ${DST_DIR}/conf/httpd.conf
sed -i 's/#ServerName www.example.com:80/ServerName 0.0.0.0:80/' ${DST_DIR}/conf/httpd.conf
sed -i 's/ServerAdmin you@example.com/ServerAdmin root@localhost/' ${DST_DIR}/conf/httpd.conf
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.html index.htm/' ${DST_DIR}/conf/httpd.conf

echo -e "\033[38;5;226m\nhttpd.conf 편집 완료\n\033[0m"
