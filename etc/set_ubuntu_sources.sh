#!/bin/bash

# 사용 방법 표시
if [ "$#" -eq 0 ]; then
    echo "사용법: $0 [미러서버IP]"
    mirror_server="mirror.kakao.com"
else
    mirror_server="$1"
fi

# mirror.kakao.com을 사용하도록 패키지 소스를 업데이트합니다.
#sudo sed -i "s/\(kr\|archive\|ports\).ubuntu.com/$mirror_server/g" /etc/apt/sources.list
sudo sed -i.bak "s/\(kr\|archive\|ports\).ubuntu.com/$mirror_server/g" /etc/apt/sources.list

# 패키지 목록 업데이트
sudo apt-get update


### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/set_ubuntu_sources.sh | bash
#
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/set_ubuntu_sources.sh | bash -s mirror.navercorp.com

