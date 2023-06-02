#!/bin/bash

# Go 다운로드 링크 및 버전 정보
GO_VERSION="1.17.2"
GO_DOWNLOAD_URL="https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz"

# 설치할 디렉토리
INSTALL_DIR="/usr/local"

# Go 다운로드 및 설치
echo "Go 언어 설치를 시작합니다..."

# 다운로드한 파일 압축 해제
echo "Go 다운로드 중..."
wget -q "$GO_DOWNLOAD_URL" -O go.tar.gz
tar -C "$INSTALL_DIR" -xzf go.tar.gz
rm go.tar.gz

# 환경 변수 설정
echo "환경 변수 설정 중..."
echo "export PATH=\$PATH:$INSTALL_DIR/go/bin" >> ~/.profile
source ~/.profile

# 설치 완료 메시지
echo "Go 언어 설치가 완료되었습니다."
echo "현재 설치된 Go 버전:"
go version
