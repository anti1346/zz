#### 타임존(timezone) 설정
```
sudo timedatectl set-timezone Asia/Seoul
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

#### 저장소 URL 변경
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

###### vagrant 계정 생성
```
useradd -m -c "vagrant" -d /home/vagrant -s /bin/bash -u 1101 vagrant
```
```
echo 'vagrant:vagrant' | sudo chpasswd
```
```
echo 'vagrant ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
```
###### ubuntu 계정 생성
```
useradd -m -c "ubuntu" -d /home/ubuntu -s /bin/bash -u 1201 ubuntu
```
```
echo 'ubuntu:ubuntu' | sudo chpasswd
```
```
echo 'ubuntu ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
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
echo 'export PS1="\[\e[31m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[33m\]\h\[\e[m\]:\[\033[01;36m\]\W\[\e[m\]$ "' >> ~/.bashrc
```
```
source ~/.bashrc
```
###### docker user
```
echo 'export PS1="\[\e[33m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[34m\]\h\[\e[m\]:\[\033[01;31m\]\W\[\e[m\]$ "' >> ~/.bashrc
```
```
source ~/.bashrc
```
###### root
```
echo 'export PS1="\[\033[01;32m\]\u\[\e[m\]\[\033[01;32m\]@\[\e[m\]\[\033[01;32m\]\h\[\e[m\]:\[\033[01;34m\]\W\[\e[m\]$ "' >> ~/.bashrc
```
```
source ~/.bashrc
```

<details>
<summary>details summary block sample</summary>

details block sample

</details>
