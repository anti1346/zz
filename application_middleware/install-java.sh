#!/bin/bash

# Check if running as root
if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Set Zulu Java version
zulu_version="17.40.19-ca-jdk17.0.6"

# Set Zulu Java download URL
zulu_url="https://cdn.azul.com/zulu/bin/zulu${zulu_version}-linux_x64.tar.gz"

# Set Java home directory
java_home="/usr/local/zulu-${zulu_version}"

# Create Java home directory
mkdir -p ${java_home}

ln -s ${java_home} /usr/local/java

# Download Zulu Java
echo "Downloading Zulu Java ${zulu_version}..."
wget ${zulu_url} -P /tmp/

# Extract Zulu Java
echo "Extracting Zulu Java ${zulu_version}..."
tar -xzf /tmp/zulu${zulu_version}-linux_x64.tar.gz -C ${java_home} --strip-components=1

# Set Java environment variables
echo "Setting Java environment variables..."
echo "export JAVA_HOME=/usr/local/java" > /etc/profile.d/javaEnvironment.sh
echo "export PATH=\${JAVA_HOME}/bin:\${PATH}" >> /etc/profile.d/javaEnvironment.sh

# Load environment variables
echo "Loading environment variables..."
source /etc/profile.d/javaEnvironment.sh

# Verify Java installation
echo "Verifying Java installation..."
java -version

# Clean up
rm -f /tmp/zulu${zulu_version}-linux_x64.tar.gz
