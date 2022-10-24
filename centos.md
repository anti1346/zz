## centos.md

#### 히스토리
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

#### 프롬프트
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

#### sudoers 변경
```
echo 'NoPasswordUser ALL=NOPASSWD: ALL' >> /etc/sudoers
```

#### 타임존(timezone) 설정
```
sudo timedatectl set-timezone Asia/Seoul
```

### chrony(chronyd) 설정
```
yum install -q -y chrony
```
```
cat <<EOF > /etc/chrony.conf
server time.bora.net iburst
server times.postech.ac.kr iburst

driftfile /var/lib/chrony/drift

makestep 1.0 3

rtcsync

logdir /var/log/chrony

EOF
```
```
systemctl restart chronyd
```
```
chronyc sourcestats -v
```
```
chronyc sources -v
```
```
chronyc tracking
```


