##### ssh key 생성
```
ssh-keygen -t rsa
```
```
ssh-copy-id root@192.168.56.101
```


##### ssh root login
```
sudo sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
```
```
systemctl restart sshd
```
