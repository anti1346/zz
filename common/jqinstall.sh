#!/bin/bash

# Check if jq is already installed
if command -v jq &> /dev/null; then
  echo "jq is already installed."
else
  # Check package manager and install jq
  if command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y jq
  elif command -v yum &> /dev/null; then
    sudo yum install -y jq
  else
    echo "Unable to determine package manager. Please install jq manually."
    exit 1
  fi
fi
