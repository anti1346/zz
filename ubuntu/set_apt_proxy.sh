#!/bin/bash

# Ensure the script is called with the correct number of arguments
if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "Usage: $0 {apt_proxy|bash_proxy} PROXY_IP [PROXY_PORT]"
    exit 1
fi

# Extract arguments
COMMAND=$1
PROXY_IP=$2
PROXY_PORT=${3:-3128}  # Default to 3128 if no proxy port is provided

# Function to set APT proxy
apt_proxy() {
    local PROXY_CONFIG="Acquire::http::Proxy \"http://${PROXY_IP}:${PROXY_PORT}/\";\nAcquire::https::Proxy \"https://${PROXY_IP}:${PROXY_PORT}/\";"
    local PROXY_FILE=/etc/apt/apt.conf.d/02proxy
    echo -e "${PROXY_CONFIG}" | sudo tee ${PROXY_FILE} > /dev/null
    echo "${PROXY_FILE}"
}

# Function to set bashrc proxy
bash_proxy() {
    local PROXY_CONFIG="export http_proxy=http://${PROXY_IP}:${PROXY_PORT}\nexport https_proxy=https://${PROXY_IP}:${PROXY_PORT}"
    local PROXY_FILE=$HOME/.bashrc
    echo -e "${PROXY_CONFIG}" | tee -a ${PROXY_FILE} > /dev/null
    echo "${PROXY_FILE}"
}

# Main execution based on command
case $COMMAND in
    apt_proxy)
        apt_proxy_file=$(apt_proxy)
        echo "APT 프록시 설정이 완료되었습니다. 설정 파일: ${apt_proxy_file}"
        ;;
    bash_proxy)
        bashrc_proxy_file=$(bash_proxy)
        echo "Bashrc 프록시 설정이 완료되었습니다. 설정 파일: ${bashrc_proxy_file}"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Usage: $0 {apt_proxy|bash_proxy} PROXY_IP [PROXY_PORT]"
        exit 1
        ;;
esac



### Execute
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/set_apt_proxy.sh | bash -s bash_proxy 192.168.56.1 8080
