#!/bin/bash

# 사용 방법 안내 함수
usage() {
    echo "사용법: $0 [--config-dir CERTBOT_CONFIG_DIR] [--domain DOMAIN_NAME] [--email ADMIN_EMAIL]"
    echo "  --config-dir CERTBOT_CONFIG_DIR : Let's Encrypt 설정 디렉토리 (기본값: letsencrypt)"
    echo "  --domain DOMAIN_NAME           : 인증서를 발급받을 도메인 이름 (기본값: registry.domain.com)"
    echo "  --email ADMIN_EMAIL            : 관리자 이메일 주소 (기본값: admin@domain.com)"
    exit 1
}

# 기본값 설정
CERTBOT_CONFIG_DIR="letsencrypt"
DOMAIN_NAME="registry.domain.com"
ADMIN_EMAIL="admin@domain.com"

# 인수 파싱
while [ $# -gt 0 ]; do
    case "$1" in
        --config-dir)
            CERTBOT_CONFIG_DIR="$2"
            shift 2
            ;;
        --domain)
            DOMAIN_NAME="$2"
            shift 2
            ;;
        --email)
            ADMIN_EMAIL="$2"
            shift 2
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo "알 수 없는 인수: $1"
            usage
            ;;
    esac
done

# letsencrypt 디렉토리 생성
if [ ! -d "$CERTBOT_CONFIG_DIR" ]; then
    echo "디렉토리가 존재하지 않아서 생성합니다: $CERTBOT_CONFIG_DIR"
    mkdir -p "$CERTBOT_CONFIG_DIR"
else
    echo "디렉토리가 이미 존재합니다: $CERTBOT_CONFIG_DIR"
fi

# 절대 경로로 변환
CERTBOT_CONFIG_DIR=$(realpath "$CERTBOT_CONFIG_DIR")

# Docker 컨테이너 실행을 통해 Let's Encrypt 인증서 발급 및 갱신
docker run -it --rm --name certbot \
    -v "$CERTBOT_CONFIG_DIR:/etc/letsencrypt" \
    certbot/certbot certonly \
    -d "$DOMAIN_NAME" \
    --email "$ADMIN_EMAIL" \
    --manual --preferred-challenges dns \
    --agree-tos

# Docker 명령어 실행 결과 확인
if [ $? -eq 0 ]; then
    echo "인증서 발급 및 갱신이 성공적으로 완료되었습니다."
else
    echo "인증서 발급 및 갱신에 실패했습니다."
    exit 1
fi
