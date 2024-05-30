#!/bin/bash

# Ensure the script is called with the correct number of arguments
if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "Usage: $(basename "$0") {apt|bash} PROXY_IP [PROXY_PORT]"
    exit 1
fi

# Extract arguments
COMMAND=$1
PROXY_IP=$2
PROXY_PORT=${3:-3128}  # Default to 3128 if no proxy port is provided

# Function to set proxy
set_proxy() {
    local PROXY_TYPE=$1
    local PROXY_CONFIG=""

    case $PROXY_TYPE in
        apt_proxy)
            PROXY_CONFIG="Acquire::http::Proxy \"http://${PROXY_IP}:${PROXY_PORT}/\";\nAcquire::https::Proxy \"https://${PROXY_IP}:${PROXY_PORT}/\";"
            PROXY_FILE="/etc/apt/apt.conf.d/02proxy"
            ;;
        bash_proxy)
            PROXY_CONFIG="export http_proxy=http://${PROXY_IP}:${PROXY_PORT}\nexport https_proxy=https://${PROXY_IP}:${PROXY_PORT}"
            PROXY_FILE="$HOME/.bashrc"
            ;;
        *)
            echo "Unknown proxy type: $PROXY_TYPE"
            exit 1
            ;;
    esac

    echo -e "${PROXY_CONFIG}" | sudo tee ${PROXY_FILE} > /dev/null
    echo "${PROXY_FILE}"
}

# Main execution based on command
proxy_file=$(set_proxy "$COMMAND")
echo "${COMMAND^} 프록시 설정이 완료되었습니다. 설정 파일: ${proxy_file}"



### Execute
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/set_apt_proxy.sh | bash -s bash_proxy 192.168.56.1 8080
