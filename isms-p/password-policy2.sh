#!/bin/bash

# Apply Password Policy Settings
if [[ $DISTRO == "CentOS" || $DISTRO == "Amazon Linux" ]]; then
    sudo cp /etc/pam.d/system-auth /etc/pam.d/system-auth.$BACKUP_DATE
    sudo cp /etc/pam.d/password-auth /etc/pam.d/password-auth.$BACKUP_DATE

    if grep -Fxq "auth        required        pam_faillock.so preauth silent audit deny=5 unlock_time=600" /etc/pam.d/system-auth
    then
        echo "pam_faillock already configured in system-auth file"
    else
        #sed -i '/auth.*required.*pam_env.so/a auth        required        pam_faillock.so preauth silent audit deny=5 unlock_time=600' /etc/pam.d/system-auth
        echo "pam_faillock module added to system-auth file"
    fi

    # Check if the pam_faillock module is already configured in password-auth file
    if grep -Fxq "auth        required        pam_faillock.so preauth silent audit deny=5 unlock_time=600" /etc/pam.d/password-auth
    then
        echo "pam_faillock already configured in password-auth file"
    else
        #sed -i '/auth.*required.*pam_env.so/a auth        required        pam_faillock.so preauth silent audit deny=5 unlock_time=600' /etc/pam.d/password-auth
        echo "pam_faillock module added to password-auth file"
    fi
elif [[ $DISTRO == "Ubuntu" ]]; then
    sudo cp /etc/pam.d/common-password /etc/pam.d/common-password.$BACKUP_DATE

    if grep -Fxq "password.*requisite.*pam_pwquality.so" /etc/pam.d/common-password
    then
        echo "pam_pwquality already configured in common-password file"
    else
        #sed -i "s/^password.*pam_unix.so.*$/password    requisite     pam_pwquality.so minlen=8 minclass=3 dcredit=-1 lcredit=-1 ocredit=-1 retry=3/" /etc/pam.d/common-password
        echo "pam_pwquality module added to common-password file"
    fi
fi



