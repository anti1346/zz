#!/bin/bash

set -e  # 스크립트가 실패하면 중지
set -u  # 정의되지 않은 변수를 사용할 경우 오류 발생

OPENSSL_VERSION="3.1.3"
OPENSSL_PREFIX="/usr/local/openssl"
WORK_DIR="/usr/local/src"

# 필요한 개발 도구 및 의존성 설치
echo "Installing development tools and dependencies..."
yum install -y perl-core zlib-devel gcc make perl-IPC-Cmd

# OpenSSL 소스 코드 다운로드 및 압축 해제
echo "Downloading OpenSSL ${OPENSSL_VERSION}..."
cd "${WORK_DIR}"
if [ -f "openssl-${OPENSSL_VERSION}.tar.gz" ]; then
    rm -f "openssl-${OPENSSL_VERSION}.tar.gz"
fi
wget "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"

if [ $? -ne 0 ]; then
    echo "Failed to download OpenSSL source code. Exiting."
    exit 1
fi

echo "Extracting OpenSSL ${OPENSSL_VERSION}..."
tar xvzf "openssl-${OPENSSL_VERSION}.tar.gz"

# OpenSSL 구성, 컴파일 및 설치
cd "openssl-${OPENSSL_VERSION}"
echo "Configuring OpenSSL..."
./config --prefix="${OPENSSL_PREFIX}" --openssldir="${OPENSSL_PREFIX}"
echo "Compiling OpenSSL..."
make -j "$(nproc)"
echo "Installing OpenSSL..."
make install
ldconfig

# OpenSSL 환경 변수를 생성 및 업데이트
echo "Updating environment variables..."
cat <<EOF | sudo tee /etc/profile.d/openssl.sh
export PATH=${OPENSSL_PREFIX}/bin:\$PATH
export LD_LIBRARY_PATH=${OPENSSL_PREFIX}/lib:${OPENSSL_PREFIX}/lib64:\$LD_LIBRARY_PATH
EOF

# 현재 세션에 환경 변수 설정 파일 적용
echo "Sourcing environment variables..."
source /etc/profile.d/openssl.sh

# 설치 확인
echo -e "\nOpenSSL version: $(openssl version)"



### OpenSSL SITE : https://www.openssl.org/source/
### Shell Execute Command
# curl -fsSL  https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/install_openssl.sh | bash
