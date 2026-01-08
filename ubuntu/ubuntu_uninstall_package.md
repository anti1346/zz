# ubuntu uninstall packages

#### resolve(systemd-resolved)
```
sudo systemctl disable --now systemd-resolved
```
```
rm /etc/resolv.conf
```
```
cat <<EOF > /etc/resolv.conf
nameserver 168.126.63.1
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
```

#### Snap
```
sudo systemctl disable --now snapd.socket
```
```
sudo systemctl disable --now snapd.service
```
```
sudo systemctl disable --now snapd.seeded.service
```
```
sudo apt autoremove --purge -y snapd
```

#### Multipathd
```
sudo systemctl disable --now multipathd.socket
```
```
sudo systemctl disable --now multipathd
```
```
sudo apt autoremove --purge -y multipath-tools
```

#### ModemManager
```
sudo systemctl disable --now ModemManager
```
```
sudo apt autoremove --purge -y modemmanager
```

#### upowerd (전원 관리)
```
sudo systemctl disable --now upower
```
```
sudo apt autoremove --purge -y upower
```

#### udisksd (디스크 자동 마운트)
```
sudo systemctl disable --now udisks2
```
```
sudo apt autoremove --purge -y udisks2
```

#### PackageKit Daemon (GUI 패키지 관리)
```
sudo systemctl disable --now packagekit
```
```
sudo apt autoremove --purge -y packagekit*
```

##### 다른 패키지가 사용하지 않는 의존성만 제거
```
sudo apt autoremove -y
```
##### 불필요한 계정 삭제
```
echo "games lp mail news uucp proxy backup list gnats irc" | xargs -n1 sudo userdel -r
```

