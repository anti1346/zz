## centos.md

#### 히스토리
```
sudo cat <<EOF >> /etc/profile

## history
export HISTSIZE=10000
export HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S '
#export HISTCONTROL=erasedups
EOF
```
```
source /etc/profile
```

#### 프롬프트
docker container user
```
echo 'export PS1="\[\e[31m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[33m\]\h\[\e[m\]:\[\033[01;36m\]\W\[\e[m\]$ "' >> ~/.bashrc
```
user
```
echo 'export PS1="\[\e[33m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[34m\]\h\[\e[m\]:\[\033[01;31m\]\W\[\e[m\]$ "' >> ~/.bashrc
```
```
source ~/.bashrc
```
super user(root)
```
echo 'export PS1="\[\033[01;32m\]\u\[\e[m\]\[\033[01;32m\]@\[\e[m\]\[\033[01;32m\]\h\[\e[m\]:\[\033[01;34m\]\W\[\e[m\]$ "' >> ~/.bashrc
```
```
source ~/.bashrc
```

#### sudoers 변경
```
echo 'NoPasswordUser ALL=NOPASSWD: ALL' >> /etc/sudoers
```
```
echo 'centos ALL=NOPASSWD: ALL' >> /etc/sudoers
```
#### 타임존(timezone) 설정
```
sudo timedatectl set-timezone Asia/Seoul
```

#### resolv 설정
```
cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
nameserver 168.126.63.1
nameserver 8.8.4.4
EOF
```

#### chrony(chronyd) 설정
```
sudo yum install -y chrony
```
```
sudo systemctl --now enable chronyd
```
```
cat <<EOF > /etc/chrony.conf
server 169.254.169.123 iburst
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

#### CentOS EOL이슈 (Vault 저장소)
```
cat <<EOF > /etc/yum.repos.d/CentOS-Base.repo
[base]
name=CentOS-$releasever - Base
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
enabled=1
gpgcheck=1
EOF
