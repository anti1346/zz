#!/bin/bash

# Check if the domain (or URL) and IP address are passed as arguments
if [ -z "$1" ]; then
  echo "Error: No domain or URL provided."
  exit 1
fi

# Extract protocol (https/http), domain, and port from the URL
TARGET_URL=$1
PROTOCOL=$(echo "$TARGET_URL" | grep -oP '^\w+(?=://)' || echo "https")
TARGET_DOMAIN=$(echo "$TARGET_URL" | sed -n 's#\w\+://\([^:/]\+\).*#\1#p')
TARGET_PORT=$(echo "$TARGET_URL" | sed -n 's#.*:\([0-9]\+\)#\1#p' || echo "443")
TARGET_IP="${2:-$(host -4 $TARGET_DOMAIN | awk 'NR==1 {print $NF}')}"

# Print the target protocol, domain, IP, and port
echo -e "\n=== Target protocol, domain, ip, port ==="
echo "${PROTOCOL}://${TARGET_DOMAIN}:${TARGET_PORT} - [${TARGET_IP}]"

# Print HTTP header response
echo -e "\n=== HTTP Header Response ==="
# curl -I --max-time 1 --resolve "www.scbyun.com:443:27.0.236.142" "https://www.scbyun.com"
HTTP_RESPONSE=$(curl -I --max-time 2 --resolve "${TARGET_DOMAIN}:${TARGET_PORT}:${TARGET_IP}" "${PROTOCOL}://${TARGET_DOMAIN}" 2>/dev/null)
echo "${HTTP_RESPONSE}"

# Print SSL certificate expiration dates
echo -e "\n=== SSL Certificate Expiration Dates ==="
# echo | openssl s_client -connect "27.0.236.142:443" -servername "www.scbyun.com" -showcerts 2>/dev/null | openssl x509 -noout -dates
# echo | openssl s_client -connect "27.0.236.142:443" -servername "www.scbyun.com" -showcerts -timeout 2 2>/dev/null | openssl x509 -noout -dates
SSL_CERT_INFO=$(timeout 2s echo | openssl s_client -servername ${TARGET_DOMAIN} -connect ${TARGET_IP}:${TARGET_PORT} 2>/dev/null | openssl x509 -noout -dates)
echo "${SSL_CERT_INFO}"
echo -e "\n"



### Execute
# bash sslcert_verify.sh https://scbyun.com:443
# bash sslcert_verify.sh https://scbyun.com:443 104.21.67.131
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/sslcert_verify.sh | bash -s https://scbyun.com:443
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/sslcert_verify.sh | bash -s https://scbyun.com:443 104.21.67.131
