#!/bin/bash

ifconfig | awk '/^[a-z]/{gsub(/:/, "", $1); dev=$1; next} /inet[^6]/ && $2 !~ /127.0.0.1/ && dev != "docker0" {print dev}'

#
