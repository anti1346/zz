#!/bin/bash

# Check if /var/run/yum.pid file exists
while [ -f /var/run/yum.pid ]; do
    echo "Waiting for another yum process to finish..."
    sleep 5
done

# Determine the package manager and set related variables
if command -v yum &> /dev/null; then
    PACKAGE_MANAGER="yum"
    SERVICE_NAME="chronyd.service"
    CONFIG_FILE_PATH="/etc/chrony.conf"
elif command -v apt-get &> /dev/null; then
    PACKAGE_MANAGER="apt-get"
    SERVICE_NAME="chrony.service"
    CONFIG_FILE_PATH="/etc/chrony/chrony.conf"
else
    echo "Unsupported package manager."
    exit 1
fi

# Check if chrony is already installed
if ! command -v chronyc &> /dev/null; then
    # Install chrony
    sudo $PACKAGE_MANAGER install -y chrony

    # Enable and start chrony service
    sudo systemctl --now enable $SERVICE_NAME
fi

# Backup the default configuration file
if [ -f $CONFIG_FILE_PATH ]; then
    sudo cp $CONFIG_FILE_PATH ${CONFIG_FILE_PATH}.bak
fi

# Update configuration file with new server settings
sudo tee $CONFIG_FILE_PATH > /dev/null <<EOF
server 169.254.169.123 iburst
server time.bora.net iburst
server times.postech.ac.kr iburst

driftfile /var/lib/chrony/drift

makestep 1.0 3

rtcsync

logdir /var/log/chrony
EOF

# Enable the chrony service
sudo systemctl enable $SERVICE_NAME

# Restart the chrony service
sudo systemctl restart $SERVICE_NAME

# Display the current chrony source statistics
echo -e "\n### chronyc sourcestats -v"
chronyc sourcestats -v

# Display the current chrony sources
echo -e "\n### chronyc sources -v"
chronyc sources -v

# Display the current tracking of the system's time
echo -e "\n### chronyc tracking"
chronyc tracking

echo -e "\n"




### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/install_chrony.sh | bash