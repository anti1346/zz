#!/bin/bash
#############################
# knode1 : target Server    #
# knode2 : localhost Server #
#############################

haproxy_conf="/etc/haproxy/haproxy.cfg"
target_server="root@knode1"

# haproxy 실행 파일이 있는지 확인합니다.
if command -v haproxy &>/dev/null; then
    # haproxy.cfg 파일의 구문이 올바른지 확인합니다.
    if haproxy -c -f "$haproxy_conf" -V; then
        echo -e "haproxy configuration syntax is valid. Proceeding...\n"

        # localhost 서버의 haproxy를 다시 시작합니다.
        echo "Restarting HAProxy on target server..."
        sudo systemctl restart haproxy &&
        
        # 구문이 올바르다면 haproxy.cfg 파일을 Target 서버로 복사합니다.
        scp -q "$haproxy_conf" "$target_server":"$haproxy_conf"
        # Target 서버의 haproxy를 다시 시작합니다.
        echo -e "\nRestarting HAProxy on target server..."
        ssh "$target_server" "sudo systemctl restart haproxy"
        
        echo "HAProxy configuration synchronized and HAProxy restarted successfully."
    else
        echo "ERROR: Configuration file is not valid. Please check haproxy.cfg."
    fi
else
    echo "ERROR: haproxy command not found. Please install haproxy."
fi
