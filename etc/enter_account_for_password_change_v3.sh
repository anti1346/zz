#!/bin/bash

# 출력을 위한 색상 코드
CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW="\033[1;33m"
LT_GREEN="\033[1;32m"
NC='\033[0m'

# 함수: 주어진 문자열이 유효한 IP 주소인지 확인하는 함수
function validate_ip() {
  local ip=$1
  local stat=1

  if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    OIFS=$IFS
    IFS='.'
    ip=($ip)
    IFS=$OIFS
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    stat=$?
  fi

  return $stat
}

# 아이피 주소를 입력 받습니다.
if [[ -n "$1" ]]; then
  MyIP="${ifconfig | awk '/inet .*broadcast/{print $2}':$1}"
fi

if ! validate_ip "$MyIP"; then
  echo -e "${RED}올바르지 않은 IP 주소입니다.${NC}"
  exit 1
fi

NetworkID=$(echo "$MyIP" | cut -d . -f1-3)
HostID=$(echo "$MyIP" | cut -d . -f4)

# 사용자 목록은 명령줄 인수로 전달
default_users=("root" "ec2-user" "vagrant" "ubuntu" "centos")
users=("${@:2}")

# 비밀번호 변경 함수
function PASSWORD {
  for user in "${users[@]}"; do
    if id "$user" >/dev/null 2>&1; then
      SHADOW=$(sudo grep "^$user:" /etc/shadow)
      if [ -n "$SHADOW" ]; then
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
          ubuntu|centos)
            pwdstr="rltnf"
            ;;
          *)
            echo -e "알 수 없는 사용자 이름 '$user'."
            continue
            ;;
        esac

        echo -e "\n${YELLOW}(비밀번호 변경 전):\n$SHADOW${NC}"
        echo "$user:$pwdstr$nid$hid" | sudo chpasswd > /dev/null 2>&1
        echo -e "${GREEN}$user 사용자의 비밀번호가 변경되었습니다.${NC}"
        echo -e "${RED}sshpass -p'$pwdstr$nid$hid' ssh $user@$MyIP -oStrictHostKeyChecking=no${NC}\n"
      else
        echo -e "${RED}사용자 '$user'의 shadow 파일에서 항목을 찾을 수 없습니다.${NC}\n"
      fi
    else
      echo -e "${CYAN}시스템에 '$user' 사용자가 존재하지 않습니다.${NC}\n"
    fi
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
    echo -e "${CYAN}알 수 없는 네트워크 ID (Netmask) '$NetworkID'입니다.${NC}\n"
    ;;
esac
