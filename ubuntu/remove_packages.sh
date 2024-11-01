#!/bin/bash

# Define package patterns for specific categories
packages_to_apm='apache2|nginx|php'
packages_to_haproxy='roxy-wi|haproxy'
packages_to_pacemaker='corosync|pacemaker|pcs'
packages_to_zabbix='zabbix|mysql|php'
packages_to_loki='grafana|loki|promtail'

# Function to remove packages based on a given pattern
remove_packages() {
  local pattern="$1"
  packages=$(dpkg -l | egrep "$pattern" | awk '{print $2}')
  if [ -n "$packages" ]; then
    sudo apt purge -y $packages
  else
    echo "No packages found matching pattern: $pattern"
  fi
}

# Check if an argument was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <package_pattern_variable>"
  exit 1
fi

pattern_variable="${!1}"

if [ -n "$pattern_variable" ]; then
  remove_packages "$pattern_variable"
  sudo apt autoremove -y  # Remove unnecessary dependencies
else
  echo "Pattern variable '$1' not found. Please provide a valid pattern name."
  exit 1
fi



### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/remove_packages.sh | bash -s packages_to_apm
# 
# apt-get install -y dos2unix
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/remove_packages.sh | dos2unix | bash -s packages_to_apm
