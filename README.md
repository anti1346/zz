## README.md
#### resolv.conf 설정
```
cat <<EOF > /etc/resolv.conf
# Generated by NetworkManager
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
```

