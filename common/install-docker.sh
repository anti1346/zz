#!/bin/bash

### lsb_release 명령으로 운영체제 판단 ###
if command -v apt >/dev/null; then
    echo "Linux Distribution : Debian"
    apt update -qq -y >/dev/null 2>&1
    apt install -qq -y lsb-release >/dev/null 2>&1
    lsb_release -ds
elif command -v yum >/dev/null; then
    echo "Linux Distribution : RedHat"
    yum install -q -y redhat-lsb-core >/dev/null 2>&1
    lsb_release -ds | tr -d '"'
else
    echo "other OS"
fi

distro=$(lsb_release -i | cut -f2)
os_version=$(lsb_release -sr | cut -d'.' -f1)



### 도커 설치 ###
if [ "$distro" == "CentOS" ]; then
    if [[ $os_version -eq 8 || $os_version -eq 7 ]]; then
        echo "CentOS $os_version"
        curl -fsSL https://get.docker.com -o get-docker.sh
        chmod +x get-docker.sh
        bash get-docker.sh
        usermod -aG docker $(whoami)
        systemctl --now enable docker.service
    elif [ "$distro" == "Amazon" ]; then
        echo "Amazon $os_version"
        amazon-linux-extras install -y epel
        amazon-linux-extras install -y docker
        usermod -aG docker ec2-user
        systemctl --now enable docker.service
    elif [ "$distro" == "Ubuntu" ]; then
        echo "Ubuntu $os_version"
        apt install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt update
        apt install -y docker-ce
    else
        echo "Other OS"
fi



### 도커 컴포즈 설치 ###
curl -fsSL "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose



# ### CTOP 설치 ###
# CTOP=${CTOPVersion:-0.7.7}
# #https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64
# curl -fsSL https://github.com/bcicen/ctop/releases/download/v${CTOP}/ctop-${CTOP}-linux-amd64 -o /usr/local/bin/ctop
# chmod +x /usr/local/bin/ctop
# ln -s /usr/local/bin/ctop /usr/bin/ctop
