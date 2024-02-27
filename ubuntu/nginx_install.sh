#!/bin/bash

sudo apt-get install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring

curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list

sudo apt-get update

sudo apt-get install -y nginx



### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/nginx_install.sh | bash
