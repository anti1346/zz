#!/bin/bash

# 로그 파일 생성
LOG_FILE="/var/log/ssacli_raid_setup.log"
echo "RAID Controller Configuration - $(date)" > "$LOG_FILE"

# RAID 컨트롤러의 전체 구성을 표시
echo "Displaying RAID Controller Configuration" | tee -a "$LOG_FILE"
ssacli ctrl all show config | tee -a "$LOG_FILE"

# 슬롯 0의 모든 논리 드라이브 확인
echo "Listing all Logical Drives in Slot 0" | tee -a "$LOG_FILE"
ssacli ctrl slot=0 ld all show | tee -a "$LOG_FILE"

# Array C 삭제
echo "Deleting Array C in Slot 0 if it exists" | tee -a "$LOG_FILE"
ssacli ctrl slot=0 array C delete | tee -a "$LOG_FILE"

# Array 삭제 후 논리 드라이브 상태 재확인
echo "Rechecking Logical Drives after deletion" | tee -a "$LOG_FILE"
ssacli ctrl slot=0 ld all show | tee -a "$LOG_FILE"

# 모든 물리 드라이브 상태 확인
echo "Listing all Physical Drives in Slot 0" | tee -a "$LOG_FILE"
ssacli ctrl slot=0 pd all show | tee -a "$LOG_FILE"

# RAID 1 구성 생성 (드라이브 1I:1:3, 1I:1:4 사용)
echo "Creating RAID 1 Array with drives 1I:1:3 and 1I:1:4" | tee -a "$LOG_FILE"
ssacli ctrl slot=0 create type=ld drives=1I:1:3,1I:1:4 raid=1 | tee -a "$LOG_FILE"

# RAID 논리 드라이브 확인 (이름 확인)
echo "Checking newly created RAID Device" | tee -a "$LOG_FILE"
RAID_DEVICE=$(ls /dev/cciss/* /dev/sd* 2>/dev/null | grep -E '(/dev/cciss|/dev/sd)' | head -n 1)
if [ -z "$RAID_DEVICE" ]; then
  echo "Error: RAID device not found!" | tee -a "$LOG_FILE"
  exit 1
fi
echo "RAID Device found: $RAID_DEVICE" | tee -a "$LOG_FILE"

# growpart를 사용하여 파티셔닝
echo "Growing partition on $RAID_DEVICE" | tee -a "$LOG_FILE"
sudo growpart "$RAID_DEVICE" 1

# 논리 드라이브 확인
echo "Listing block devices to verify partition" | tee -a "$LOG_FILE"
lsblk | tee -a "$LOG_FILE"

# XFS 파일 시스템 생성
PARTITION="${RAID_DEVICE}1"
echo "Creating XFS filesystem on $PARTITION" | tee -a "$LOG_FILE"
sudo mkfs.xfs "$PARTITION"

# 마운트 지점 생성 및 마운트
MOUNT_POINT="/data"
echo "Creating mount point at $MOUNT_POINT and mounting $PARTITION" | tee -a "$LOG_FILE"
sudo mkdir -p "$MOUNT_POINT"
sudo mount "$PARTITION" "$MOUNT_POINT"

# 자동 마운트 설정
echo "Adding $PARTITION to /etc/fstab for automatic mounting" | tee -a "$LOG_FILE"
echo "$PARTITION $MOUNT_POINT xfs defaults 0 0" | sudo tee -a /etc/fstab

echo "RAID 1 Setup and XFS filesystem creation completed successfully!" | tee -a "$LOG_FILE"
