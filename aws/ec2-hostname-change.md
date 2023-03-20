### script 디렉터리 생성
```
mkdir -pv /home/ec2-user/script
```
### ec2-hostname-change 복사
```
cp -f ec2-hostname-change.sh /home/ec2-user/script/.
```
### ec2-hostname-change 링크 생성
```
ln -s /home/ec2-user/script/ec2-hostname-change.sh /etc/profile.d/ec2-hostname-change.sh
```
