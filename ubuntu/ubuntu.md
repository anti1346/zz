### 타임존(timezone) 설정
```
sudo timedatectl set-timezone Asia/Seoul
```

### 우분투 editor 변경
```
sudo update-alternatives --set editor /usr/bin/vim.basic
```
```
sudo update-alternatives --config editor
```

### 방화벽 설정
```
systemctl stop ufw && systemctl disable ufw
```

### 저장소 URL 변경
```
cat /etc/apt/sources.list
```
```
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bk
```
```
sudo sed -i 's/kr.archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list
```
```
sudo sed -i 's/http:\/\/archive.ubuntu.com/https:\/\/mirror.kakao.com/g' /etc/apt/sources.list
```

### 계정 생성
```
groupadd -g 1201 user1
```
```
useradd -m -c "user1" -d /home/user1 -s /bin/bash -u 1201 -g 1201 user1
```
```
useradd -m -c "vagrant" -d /home/vagrant -s /bin/bash -u 1101 vagrant
```
```
useradd -m -c "ubuntu" -d /home/ubuntu -s /bin/bash -u 1102 ubuntu
```
```
usermod -G dba user1
```
```
echo 'vagrant ALL=NOPASSWD: ALL' >> /etc/sudoers
```

### 히스토리
##### ${HOME}/.bashrc
```
sudo cat <<EOF >> ~/.bashrc

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

### 프롬프트
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

### sudoers 변경
```
echo 'NoPasswordUser ALL=NOPASSWD: ALL' >> /etc/sudoers
```

### chrony 설치 및 설정
```
apt-get install -y chrony
```
