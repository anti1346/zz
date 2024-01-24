#!/bin/bash

# 인수를 사용하여 첫 번째 DNS 서버를 설정하거나 기본값을 168.126.63.1로 설정합니다.
variable1="${1:-168.126.63.1}"

# /etc/resolv.conf에 DNS 구성을 작성합니다.
cat <<EOF > /etc/resolv.conf
nameserver $variable1
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF


### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/set_nameserver.sh | bash
