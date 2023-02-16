

```
groupadd -g 1101 vagrant
```
```
useradd -m -c "System Account" -d /home/vagrant -s /bin/bash -u 1101 -g 1101 vagrant
```

```
usermod -G dba user1
```

```
echo 'vagrant ALL=NOPASSWD: ALL' >> /etc/sudoers

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

### 타임존(timezone) 설정
```
sudo timedatectl set-timezone Asia/Seoul
```

### 우분투 editor 변경
```
sudo update-alternatives --config editor
```
