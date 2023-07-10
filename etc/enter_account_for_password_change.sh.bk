#!/bin/bash
# IP 주소 네트워크 ID에 따라 지정된 사용자의 비밀번호를 변경하는 스크립트

# 출력을 위한 색상 코드
CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 로컬 IP 주소를 가져와서 네트워크 ID와 호스트 ID 추출
MyIP=$(ifconfig | grep "inet" | grep "broadcast" | awk '{print $2}')
NetworkID=$(echo "$MyIP" | cut -d . -f1-3)
HostID=$(echo "$MyIP" | cut -d . -f4)

# 사용자 목록은 명령줄 인수로 전달
users=$@

# 비밀번호 변경 함수
function PASSWORD {
  for user in $users; do
    case $user in
      root)
        pwdstr="flsnrtm"
        ;;
      ec2-user)
        pwdstr="tjqjfmf"
        ;;
      vagrant)
        pwdstr="ekfnsms"
        ;;
      ubuntu)
        pwdstr="rltnf"
        ;;
      centos)
        pwdstr="rltnf"
        ;;
      *)
        echo -e "알 수 없는 사용자 이름 '$user'."
        exit 1
        ;;
    esac

    echo "$user:$pwdstr$nid$hid" | chpasswd > /dev/null 2>&1
    echo -e "${GREEN}$user 사용자의 비밀번호가 변경되었습니다.${NC}"
    echo -e "${RED}sshpass -p'$pwdstr$nid$hid' ssh $user@$MyIP -oStrictHostKeyChecking=no${NC}"
  done
}

# 네트워크 ID에 따라 비밀번호 변경 수행
case $NetworkID in
  223.130.200)
    nid='@@#'
    hid=$HostID
    PASSWORD
    ;;
  121.53.105)
    nid='%#'
    hid=$HostID
    PASSWORD
    ;;
  142.250.206)
    nid='@%)'
    hid=$HostID
    PASSWORD
    ;;
  120.50.131)
    nid='!#!'
    hid=$HostID
    PASSWORD
    ;;
  192.168.0)
    nid='!(@)'
    hid=$HostID
    PASSWORD
    ;;
  172.17.0)
    nid='!&'
    hid=$HostID
    PASSWORD
    ;;
  *)
    echo -e "알 수 없는 네트워크 ID (Netmask) '$NetworkID'입니다."
    ;;
esac
