
```
groupadd -g 2001 user1
```
```
useradd -m -c "System Account" -d /home/user1 -s /bin/bash -u 2001 -g 2001 user1
```

```
usermod -G dba user1
```

```
echo 'user1 ALL=NOPASSWD: ALL' >> /etc/sudoers

```
