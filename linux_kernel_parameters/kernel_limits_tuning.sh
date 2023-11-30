#!/bin/bash

# 사용자 및 시스템 제한 설정 파일 경로
LIMITS_CONF="/etc/security/limits.conf"
SYSCTL_CONF="/etc/sysctl.conf"

# 사용자 제한 설정
echo "* hard nofile 65535" >> "$LIMITS_CONF"
echo "* soft nofile 65535" >> "$LIMITS_CONF"
echo "* hard nproc unlimited" >> "$LIMITS_CONF"
echo "* soft nproc unlimited" >> "$LIMITS_CONF"
echo "* hard memlock unlimited" >> "$LIMITS_CONF"
echo "* soft memlock unlimited" >> "$LIMITS_CONF"

# 커널 파라미터 설정
### TCP 스택 튜닝
echo "net.core.somaxconn = 65535" >> "$SYSCTL_CONF"
echo "net.core.netdev_max_backlog = 65535" >> "$SYSCTL_CONF"
### TCP 연결 설정 튜닝
echo "net.ipv4.tcp_max_syn_backlog = 65535" >> "$SYSCTL_CONF"
echo "net.ipv4.tcp_tw_reuse = 1" >> "$SYSCTL_CONF"
echo "net.ipv4.tcp_tw_recycle = 1" >> "$SYSCTL_CONF"
### 파일 디스크립터 및 프로세스 관련 튜닝
echo "fs.file-max = 65535" >> "$SYSCTL_CONF"
echo "vm.max_map_count = 262144" >> "$SYSCTL_CONF"
### 메모리 관련 튜닝
echo "vm.swappiness = 10" >> "$SYSCTL_CONF"
### TCP 버퍼 사이즈 튜닝
echo "net.core.rmem_max = 16777216" >> "$SYSCTL_CONF"
echo "net.core.wmem_max = 16777216" >> "$SYSCTL_CONF"
echo "net.ipv4.tcp_rmem = 4096 87380 16777216" >> "$SYSCTL_CONF"
echo "net.ipv4.tcp_wmem = 4096 65536 16777216" >> "$SYSCTL_CONF"

# 변경된 설정 값 확인
echo "Changed limits.conf settings:"
cat "$LIMITS_CONF"
echo "Changed sysctl.conf settings:"
cat "$SYSCTL_CONF"

# 변경된 설정 값을 적용
sysctl -p
