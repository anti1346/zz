#!/bin/bash

apt-get update -qq

apt-get install -qq -y net-tools

# Define the list of SSH users
SSH_USERS=("ubuntu" "vagrant")
# Loop through each SSH user
for SSH_USER in "${SSH_USERS[@]}"; do
    useradd -m -c "$SSH_USER" -d "/home/$SSH_USER" -s /bin/bash "$SSH_USER"
    echo "$SSH_USER:$SSH_USER" | chpasswd
    echo 'export PS1="\[\e[33m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[34m\]\h\[\e[m\]:\[\033[01;31m\]\W\[\e[m\]$ "' >> "/home/$SSH_USER/.bashrc"
    echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
done

sudo update-alternatives --set editor /usr/bin/vim.basic

### set timezone
curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/common/set-timezone.sh | sudo bash

### install chrony 
curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/common/set-chrony.sh | sudo bash

### set PS1
curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/common/set-ps1.sh | sudo bash

### install jq
curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/common/jqinstall.sh | sudo bash

### remove accounts and groups
curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/common/remove_accounts_and_groups.sh | sudo bash

### remove pakage
curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/common/remove_pakage.sh | sudo bash

### install mysql
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/Installing_MySQL_on_Linux_Using_Generic_Binaries.sh | sudo bash
