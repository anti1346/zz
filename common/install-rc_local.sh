#!/bin/bash

# Check if /etc/rc.local file exists
if [ ! -f /etc/rc.local ]; then

    # Create /etc/rc.local file with exit 0 as default content
    printf '%s\n' '#!/bin/bash' 'exit 0' | sudo tee /etc/rc.local

    # Set execute permission for /etc/rc.local
    sudo chmod +x /etc/rc.local

    # Create rc-local.service file
    sudo tee /etc/systemd/system/rc-local.service > /dev/null <<EOF
[Unit]
Description=/etc/rc.local Compatibility
Documentation=man:systemd-rc-local-generator(8)
ConditionPathExists=/etc/rc.local
After=network.target

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
RemainAfterExit=yes
GuessMainPID=no

[Install]
WantedBy=multi-user.target
EOF

    # Enable and start the rc-local.service
    systemctl --now enable rc-local.service

    # Check the status of rc-local.service
    systemctl status rc-local.service

else
    # Exit with code 127 if /etc/rc.local file already exists
    echo -e "\n\e[33m/etc/rc.local file already exists\e[0m"
    exit 127
fi