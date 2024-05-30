#!/bin/bash

# Description: Sets APT or Bash proxy configuration.
# Usage: set_proxy.sh {apt_proxy|bash_proxy} [PROXY_IP] [PROXY_PORT]

# Validate command
if [[ "$1" != "apt_proxy" && "$1" != "bash_proxy" ]]; then
    echo "Error: Invalid command. The first argument must be 'apt_proxy' or 'bash_proxy'."
    echo "Usage: $(basename "$0") {apt_proxy|bash_proxy} [PROXY_IP] [PROXY_PORT]"
    exit 1
fi

# Ensure the script is called with the correct number of arguments
if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "Usage: $(basename "$0") {apt_proxy|bash_proxy} [PROXY_IP] [PROXY_PORT]"
    exit 1
fi

# Extract arguments
COMMAND=$1
PROXY_IP=$2
PROXY_PORT=${3:-3128}  # Default to 3128 if no proxy port is provided

# Function to set proxy
set_proxy() {
    local PROXY_CONFIG=""
    local PROXY_FILE=""

    case $COMMAND in
        apt_proxy)
            PROXY_CONFIG="Acquire::http::Proxy \"http://${PROXY_IP}:${PROXY_PORT}/\";\nAcquire::https::Proxy \"https://${PROXY_IP}:${PROXY_PORT}/\";"
            PROXY_FILE="/etc/apt/apt.conf.d/02proxy"
            ;;
        bash_proxy)
            PROXY_CONFIG="export http_proxy=http://${PROXY_IP}:${PROXY_PORT}\nexport https_proxy=https://${PROXY_IP}:${PROXY_PORT}"
            PROXY_FILE="$HOME/.bashrc"
            ;;
    esac

    echo -e "${PROXY_CONFIG}" | sudo tee -a ${PROXY_FILE} > /dev/null
    echo "${PROXY_FILE}"
}

# Main execution
proxy_file=$(set_proxy)
echo -e "${COMMAND^} 프록시 설정이 완료되었습니다.\n- 설정 파일: ${proxy_file}"




### Execute
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/set_apt_proxy.sh | bash -s apt_proxy 192.168.56.1 8080
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/set_apt_proxy.sh | bash -s bash_proxy 192.168.56.1 8080
