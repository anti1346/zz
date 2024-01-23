#!/bin/bash

ifconfig | awk '/^[a-z]/{gsub(/:/, "", $1); dev=$1; next} /inet[^6]/ && $2 !~ /127.0.0.1/ && dev != "docker0" {print dev}'


### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/get_inet.sh | bash
