#!/bin/bash

if [[ $(cat /etc/os-release | grep "^ID=" | awk -F'=' '{print $2}' | tr -d '"') == "ubuntu" ]]; then
    bashrc_file="~/.bashrc"
elif [[ $(cat /etc/os-release | grep "^ID=" | awk -F'=' '{print $2}' | tr -d '"') == "centos" ]]; then
    bashrc_file="~/.bashrc"
elif [[ $(cat /etc/os-release | grep "^ID=" | awk -F'=' '{print $2}' | tr -d '"') == "amzn" ]]; then
    bashrc_file="~/.bashrc"
else
    echo "지원하지 않는 운영체제입니다."
    exit 1
fi

while IFS=: read -r username _; do
    if [[ "$username" == "root" || "$username" == "ec2-user" || "$username" == "ubuntu" || "$username" == "vagrant" ]]; then
        home_dir="$(eval echo "~$username")"
        bashrc_file="$home_dir/.bashrc"
        if [[ -f "$bashrc_file" ]]; then
            if [[ "$username" == "root" ]]; then
                echo "export PS1='\[\033[01;32m\]\u\[\e[m\]\[\033[01;32m\]@\[\e[m\]\[\033[01;32m\]\h\[\e[m\]:\[\033[01;34m\]\W\[\e[m\]$ '" >> "$bashrc_file"
            elif [[ "$username" == "ec2-user" || "$username" == "ubuntu" ]]; then
                echo "export PS1='\[\e[31m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[33m\]\h\[\e[m\]:\[\033[01;36m\]\W\[\e[m\]$ '" >> "$bashrc_file"
            elif [[ "$username" == "vagrant" ]]; then
                echo "export PS1='\[\e[33m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[34m\]\h\[\e[m\]:\[\033[01;31m\]\W\[\e[m\]$ '" >> "$bashrc_file"
            fi
        fi
    fi
done < "/etc/passwd"
