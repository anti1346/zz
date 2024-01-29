#!/bin/bash

# 사용 방법 표시
if [ "$#" -eq 0 ]; then
    echo "사용법: $0 [미러서버IP]"
    exit 1
fi

mirror_server="${1:-mirror.kakao.com}"

# Update package sources to use mirror.kakao.com
sudo sed -i "s/\(kr\|archive\|ports\).ubuntu.com/$mirror_server/g" /etc/apt/sources.list

# Update package lists
sudo apt-get update


### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/set_ubuntu_sources.sh | bash
#
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/set_ubuntu_sources.sh | bash -s mirror.navercorp.com
