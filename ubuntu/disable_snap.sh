#!/bin/bash

# 스냅 서비스 중지
echo "Stopping snapd service..."
sudo systemctl stop snapd

# 스냅 서비스 비활성화
echo "Disabling snapd service..."
sudo systemctl disable snapd

# 설치된 스냅 패키지 목록 가져오기
echo "Fetching list of installed snap packages..."
snap_list=$(sudo snap list | awk 'NR>1 {print $1}')

# 모든 스냅 패키지 삭제
if [ -n "$snap_list" ]; then
    echo "Removing all installed snap packages..."
    for snap in $snap_list; do
        sudo snap remove --purge "$snap"
    done
else
    echo "No snap packages installed."
fi

# 스냅 패키지 삭제
echo "Purging snapd package..."
sudo apt purge snapd -y

# 스냅 캐시와 설정 삭제
echo "Removing snap cache and configuration..."
sudo rm -rf /var/cache/snapd/
rm -rf ~/snap

echo "Snap has been successfully disabled and removed."
