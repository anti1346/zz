#!/bin/bash

packages_to_apm='apache2|nginx|php'
packages_to_haproxy='roxy-wi|haproxy'
packages_to_pacemaker='corosync|pacemaker|pcs'
packages_to_zabbix='zabbix|mysql|php'
packages_to_loki='grafana|loki|promtail'
p_java='grafana|loki|promtail'

display_available_categories() {
  echo "Available package categories:"
  echo "  - packages_to_apm"
  echo "  - packages_to_haproxy"
  echo "  - packages_to_pacemaker"
  echo "  - packages_to_zabbix"
  echo "  - packages_to_loki"
  echo "  - p_java"
}

remove_packages() {
  local pattern="$1"
  packages=$(dpkg -l | egrep "$pattern" | awk '{print $2}')
  if [ -n "$packages" ]; then
    sudo apt purge -y $packages
  else
    echo "No packages found matching pattern: $pattern"
  fi
}

if [ -z "$1" ]; then
  echo "Usage: $0 <package_pattern_variable>"
  display_available_categories
  exit 1
fi

pattern_variable="${!1}"

if [ -n "$pattern_variable" ]; then
  remove_packages "$pattern_variable"
  sudo apt autoremove -y
else
  echo "Pattern variable '$1' not found."
  display_available_categories
  exit 1
fi



### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/remove_packages.sh | bash -s packages_to_apm
# 
# apt-get install -y dos2unix
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/remove_packages.sh | dos2unix | bash -s packages_to_apm
