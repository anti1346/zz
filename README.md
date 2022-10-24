
### user1 그룹 생성
```
groupadd -g 2001 user1
```
### user1 계정 생성
```
useradd -m -c "System Account" -d /home/user1 -s /bin/bash -u 2001 -g 2001 user1
```
### user1 사용자 그룹 변경
```
usermod -G dba user1
```
### sudo editor
```
echo 'user1 ALL=NOPASSWD: ALL' >> /etc/sudoers

```

### 히스토리
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

### 프롬프트
```
echo 'export PS1="\[\e[31m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[33m\]\h\[\e[m\]:\[\033[01;36m\]\W\[\e[m\]$ "' >> ~/.bashrc
```
```
echo 'export PS1="\[\e[33m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[34m\]\h\[\e[m\]:\[\033[01;31m\]\W\[\e[m\]$ "' >> ~/.bashrc
```
```
source ~/.bashrc
```
```
echo 'export PS1="\[\033[01;32m\]\u\[\e[m\]\[\033[01;32m\]@\[\e[m\]\[\033[01;32m\]\h\[\e[m\]:\[\033[01;34m\]\W\[\e[m\]$ "' >> /etc/profile
```
```
source /etc/profile
```

### sudoers 변경
```
echo 'NoPasswordUser ALL=NOPASSWD: ALL' >> /etc/sudoers
```

### 타임존(timezone) 설정
```
sudo timedatectl set-timezone Asia/Seoul
```

### 우분투 editor 변경
```
sudo update-alternatives --config editor
```
