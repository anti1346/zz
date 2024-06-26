#!/bin/bash

# 인스턴스 수를 설정합니다. 기본값은 1입니다.
INSTANCE_COUNT=2

# 명령줄 인수를 확인하여 인스턴스 수를 조정합니다.
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -c|--count)
        INSTANCE_COUNT="$2"
        shift # past argument
        shift # past value
        ;;
        *)    # unknown option
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
done

# JDK 설치
sudo mkdir -p /app/java
# 시스템 아키텍처 확인
architecture=$(uname -m)
if [ "$architecture" = "x86_64" ]; then
    sudo wget -q https://download.oracle.com/java/17/archive/jdk-17.0.10_linux-x64_bin.tar.gz -O /app/jdk-17.0.10.tar.gz
elif [ "$architecture" = "aarch64" ]; then
    sudo wget -q https://download.oracle.com/java/17/archive/jdk-17.0.10_linux-aarch64_bin.tar.gz -O /app/jdk-17.0.10.tar.gz
else
    echo "Unsupported architecture."
    exit 1
fi
sudo tar -xzf /app/jdk-17.0.10.tar.gz -C /app/java --strip-components=1

# JDK 환경 변수 설정
if [ ! -f /etc/profile.d/jdk.sh ] || ! grep -q 'export JAVA_HOME=/app/java' /etc/profile.d/jdk.sh; then
    echo 'export JAVA_HOME=/app/java' | sudo tee /etc/profile.d/jdk.sh
    echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile.d/jdk.sh
    source /etc/profile.d/jdk.sh
fi

# NGINX 설치
sudo apt-get update
sudo apt-get install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring apt-transport-https
curl -s https://nginx.org/keys/nginx_signing.key | gpg --dearmor --yes -o /usr/share/keyrings/nginx-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl --now enable nginx

# Tomcat 설치 및 설정
if ! id "tomcat" &>/dev/null; then
    sudo useradd -r -U -d /app/tomcat -s /bin/false tomcat
fi

# Tomcat 아카이브 파일이 있는지 확인하고 없는 경우 다운로드
if [ ! -f /app/apache-tomcat-9.0.89.tar.gz ]; then
    sudo wget -q https://downloads.apache.org/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz -O /app/apache-tomcat-9.0.89.tar.gz
fi

# 인스턴스별로 반복하여 Tomcat을 설치하고 설정합니다.
for ((i = 1; i <= INSTANCE_COUNT; i++)); do
    INSTANCE_NAME="tomcat$i"
    INSTANCE_DIR="/app/tomcat/$INSTANCE_NAME"
    INSTANCE_SHUTDOWN_PORT=$((8000 + $i))
    INSTANCE_CONNECTOR_PORT=$((8080 + $i))
    INSTANCE_REDIRECT_PORT=$((8500 + $i))

    # Tomcat 설치
    sudo mkdir -p "$INSTANCE_DIR"
    sudo tar -xzf /app/apache-tomcat-9.0.89.tar.gz -C "$INSTANCE_DIR" --strip-components=1
    sudo chown -R tomcat:tomcat "$INSTANCE_DIR"

    # Tomcat 서버 설정 파일 수정
    sed -i "s/port=\"8005\"/port=\"$INSTANCE_SHUTDOWN_PORT\"/g; \
            s/port=\"8080\"/port=\"$INSTANCE_CONNECTOR_PORT\"/g; \
            s/redirectPort=\"8443\"/redirectPort=\"$INSTANCE_REDIRECT_PORT\"/g" "$INSTANCE_DIR/conf/server.xml"

    # Tomcat 서비스 파일 작성
    cat <<EOF | sudo tee "/etc/systemd/system/$INSTANCE_NAME.service" >/dev/null
[Unit]
Description=Tomcat Instance $i
After=network.target

[Service]
Type=forking
Environment=JAVA_HOME=/app/java
Environment=CATALINA_PID=$INSTANCE_DIR/temp/tomcat.pid
Environment=CATALINA_HOME=$INSTANCE_DIR
Environment=CATALINA_BASE=$INSTANCE_DIR
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"

ExecStart=$INSTANCE_DIR/bin/startup.sh
ExecStop=$INSTANCE_DIR/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    # Tomcat 서비스 시작 및 자동 시작 설정
    sudo systemctl daemon-reload
    sudo systemctl --now enable $INSTANCE_NAME
done



# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/install_jdk_nginx_tomcat.sh | bash
