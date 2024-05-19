#!/bin/bash

# JDK 설치
sudo mkdir -p /app/java
sudo wget -q https://download.oracle.com/java/17/archive/jdk-17.0.10_linux-aarch64_bin.tar.gz -O /app/jdk-17.tar.gz
sudo tar -xzf /app//app/jdk-17.0.10_linux-aarch64_bin.tar.gz -C /app/java --strip-components=1

# JDK 환경 변수 설정
echo 'export JAVA_HOME=/app/java' | sudo tee /etc/profile.d/jdk.sh
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile.d/jdk.sh
source /etc/profile.d/jdk.sh

# NGINX 설치
sudo apt-get update
sudo apt-get install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring apt-transport-https
curl -s https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl --now enable nginx

# Tomcat 설치 및 설정
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /app/tomcat tomcat
sudo mkdir -p /app/tomcat/{instance1,instance2}
sudo wget -q https://downloads.apache.org/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz -O /app/apache-tomcat-9.tar.gz
sudo tar -xzf /app/apache-tomcat-9.0.89.tar.gz -C /app/tomcat/instance1 --strip-components=1
sudo tar -xzf /app/apache-tomcat-9.0.89.tar.gz -C /app/tomcat/instance2 --strip-components=1
sudo chown -R tomcat:tomcat /app/tomcat

# Tomcat 서비스 파일 작성
for instance in tomcat1 tomcat2; do
    cat <<EOF | sudo tee /etc/systemd/system/$instance.service >/dev/null
[Unit]
Description=Tomcat Instance $instance
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment=CATALINA_PID=/app/tomcat/$instance/temp/tomcat.pid
Environment=CATALINA_HOME=/app/tomcat/$instance
Environment=CATALINA_BASE=/app/tomcat/$instance
Environment=JAVA_HOME=/app/java
ExecStart=/app/tomcat/$instance/bin/startup.sh
ExecStop=/app/tomcat/$instance/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
done

# Tomcat 서비스 시작 및 자동 시작 설정
sudo systemctl daemon-reload
for instance in tomcat1 tomcat2; do
    sudo systemctl --now enable $instance
done
