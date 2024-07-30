#!/bin/bash

# 설정 값 정의
export NAME1="node211"
export ADDRESS1="192.168.0.211"
export NAME2="node212"
export ADDRESS2="192.168.0.212"
export NAME3="node213"
export ADDRESS3="192.168.0.213"

# 유효 기간 설정
DAYS=3650

# SSL DIRECTORY
SSLDIR=ssl

# openssl.conf 파일 생성
cat > openssl.conf << EOF
[ req ]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[ req_distinguished_name ]

[ v3_req ]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = localhost
DNS.2 = $NAME1
DNS.3 = $NAME2
DNS.4 = $NAME3
IP.1 = 127.0.0.1
IP.2 = $ADDRESS1
IP.3 = $ADDRESS2
IP.4 = $ADDRESS3
EOF

# CA 인증서 및 키 생성
openssl genrsa -out $SSLDIR/ca.key 2048
openssl req -x509 -new -nodes -key $SSLDIR/ca.key -subj "/CN=etcd-ca" -days $DAYS -out $SSLDIR/ca.crt

# 클라이언트 인증서 및 키 생성
openssl genrsa -out $SSLDIR/node.key 2048
openssl req -new -key $SSLDIR/node.key -subj "/CN=etcd-node" -out $SSLDIR/node.csr -config $SSLDIR/openssl.conf
openssl x509 -req -in $SSLDIR/node.csr -CA $SSLDIR/ca.crt -CAkey $SSLDIR/ca.key -CAcreateserial -out $SSLDIR/node.crt \
    -days $DAYS -extensions v3_req -extfile $SSLDIR/openssl.conf

# 피어 인증서 및 키 생성
openssl genrsa -out $SSLDIR/peer.key 2048
openssl req -new -key $SSLDIR/peer.key -subj "/CN=etcd-peer" -out $SSLDIR/peer.csr -config $SSLDIR/openssl.conf
openssl x509 -req -in $SSLDIR/peer.csr -CA $SSLDIR/ca.crt -CAkey $SSLDIR/ca.key -CAcreateserial -out $SSLDIR/peer.crt \
    -days $DAYS -extensions v3_req -extfile $SSLDIR/openssl.conf



### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/ubuntu/sslcert_generator.sh -o sslcert_generator.sh
# chmod -x sslcert_generator.sh
