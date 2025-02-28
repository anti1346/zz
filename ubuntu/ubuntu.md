#### 타임존(timezone) 설정
```
sudo timedatectl set-timezone Asia/Seoul
```

#### 호스트 네임 설정
```
sudo hostnamectl set-hostname node177
```

#### 우분투 editor 변경
```
sudo update-alternatives --set editor /usr/bin/vim.basic
```
```
sudo update-alternatives --config editor
```

#### 방화벽 설정
```
sudo systemctl disable --now ufw
```

#### 저장소 URL 변경(24.04 ubuntu.sources)
```
cat /etc/apt/sources.list.d/ubuntu.sources
```
```
sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/ubuntu.sources_$(date '+%Y%m%d-%H%M%S')
```
```
sudo tee /etc/apt/sources.list.d/ubuntu.sources > /dev/null <<EOF
Types: deb
URIs: https://mirror.kakao.com/ubuntu/
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
```
<details>
<summary>ubuntu 22.04 sources.list</summary>

```
cat /etc/apt/sources.list
```
```
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bk
```
```
sudo sed -i 's/http:\/\/archive.ubuntu.com/https:\/\/mirror.kakao.com/g' /etc/apt/sources.list
```
```
sudo sed -i 's/http:\/\/kr.archive.ubuntu.com/https:\/\/mirror.kakao.com/g' /etc/apt/sources.list
```
```
sudo sed -i 's/kr.archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list
```
</details>

#### 계정 생성
###### user1 계정 생성
```
groupadd -g 1201 user1
```
```
useradd -m -c "user1" -d /home/user1 -s /bin/bash -u 1201 -g 1201 user1
```
```
usermod -G dba user1
```
<details>
<summary>user1 계정</summary>

```
useradd -m -c "user1" -d /home/user1 -s /bin/bash -u 1201 user1
```
</details>

###### ubuntu 계정 생성
```
useradd -m -c "ubuntu" -d /home/ubuntu -s /bin/bash -u 1101 ubuntu
```
```
echo 'ubuntu:ubuntu' | sudo chpasswd
```
```
echo 'ubuntu ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
```

###### vagrant 계정 생성
```
useradd -m -c "vagrant" -d /home/vagrant -s /bin/bash -u 1102 vagrant
```
```
echo 'vagrant:vagrant' | sudo chpasswd
```
```
echo 'vagrant ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
```

#### sudoers 설정
```
echo 'NoPasswordUser ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
```

#### SSH 키 생성
```
ssh-keygen -t rsa -b 2048 -C "deployment"
```

#### 히스토리
##### ${HOME}/.bashrc
```
cat <<EOF >> ~/.bashrc

## history
export HISTSIZE=10000
export HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S '
#export HISTCONTROL=erasedups
EOF
```
```
source ~/.bashrc
```

##### /etc/profile
```
sudo cat <<EOF >> /etc/profile

### TIMEOUT
TIMEOUT=3600
export TIMEOUT

### history
export HISTSIZE=10000
export HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S '
#export HISTCONTROL=erasedups
EOF
```
```
source /etc/profile
```

#### 프롬프트
###### linux user 
```
echo 'export PS1="\[\e[31m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[33m\]\h\[\e[m\]:\[\033[01;36m\]\W\[\e[m\]$ "' >> ${HOME}/.bashrc
```
```
source ${HOME}/.bashrc
```
###### docker user
```
echo 'export PS1="\[\e[33m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[34m\]\h\[\e[m\]:\[\033[01;31m\]\W\[\e[m\]$ "' >> ${HOME}/.bashrc
```
```
source ${HOME}/.bashrc
```
###### root
```
echo 'export PS1="\[\033[01;32m\]\u\[\e[m\]\[\033[01;32m\]@\[\e[m\]\[\033[01;32m\]\h\[\e[m\]:\[\033[01;34m\]\W\[\e[m\]$ "' >> ${HOME}/.bashrc
```
```
source ${HOME}/.bashrc
```

#### 고정 IP 설정
###### Ubuntu 24.04
```
sudo vim /etc/netplan/50-cloud-init.yaml
```
```
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        enp0s3:
            dhcp4: false
            dhcp6: false
            addresses:
              - 192.168.10.51/24
            routes:
              - to: default
                via: 192.168.10.1
            nameservers:
              addresses: [8.8.8.8, 8.8.4.4]
    version: 2
```
```
sudo netplan apply
```

<details>
<summary>details summary block sample</summary>

details block sample
</details>
