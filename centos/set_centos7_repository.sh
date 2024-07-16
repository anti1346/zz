#!/bin/bash

# 제공된 인수를 사용하여 첫 번째 DNS 서버를 설정하거나 기본값을 mirror.kakao.com으로 설정합니다.
variable1="${1:-mirror.kakao.com}"

# 원본 CentOS-Base.repo 파일을 백업
sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

# 기존 미러리스트 행을 주석 처리합니다.
sudo sed -i '/^mirrorlist/s/^/#/' /etc/yum.repos.d/CentOS-Base.repo

# 기존 baseurl 줄의 주석 처리를 해제하고 미러를 교체하세요.
sudo sed -i "s|^#baseurl=http://mirror.centos.org|baseurl=https://$variable1|" /etc/yum.repos.d/CentOS-Base.repo

# Yum 캐시를 지우고 다시 작성하세요.
sudo yum clean all

sudo yum makecache



### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/set_centos7_repository.sh | bash
#
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/set_centos7_repository.sh | bash -s mirror.navercorp.com
