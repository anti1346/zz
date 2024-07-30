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
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=etcd-ca" -days $DAYS -out ca.crt

# 클라이언트 인증서 및 키 생성
openssl genrsa -out node.key 2048
openssl req -new -key node.key -subj "/CN=etcd-node" -out node.csr -config openssl.conf
openssl x509 -req -in node.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out node.crt \
    -days $DAYS -extensions v3_req -extfile openssl.conf

# 피어 인증서 및 키 생성
openssl genrsa -out peer.key 2048
openssl req -new -key peer.key -subj "/CN=etcd-peer" -out peer.csr -config openssl.conf
openssl x509 -req -in peer.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out peer.crt \
    -days $DAYS -extensions v3_req -extfile openssl.conf
