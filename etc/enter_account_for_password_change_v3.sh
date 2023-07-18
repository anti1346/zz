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
    IFS='.' read -r -a ip_arr <<< "$ip"
    for octet in "${ip_arr[@]}"; do
      if [[ $octet -gt 255 ]]; then
        return 1
      fi
    done
    stat=0
  fi

  return $stat
}

# 아이피 주소와 사용자 목록을 초기화합니다.
IP_ADDRESS=""
USER_LIST=()

# 명령줄 인수를 처리합니다.
while [[ $# -gt 0 ]]; do
  case $1 in
    -i | --ip)
      shift
      IP_ADDRESS=$1
      ;;
    -u | --user)
      shift
      while [[ $# -gt 0 ]]; do
        USER_LIST+=("$1")
        shift
      done
      ;;
    *)
      echo "알 수 없는 옵션: $1"
      exit 1
      ;;
  esac
done

# IP 주소 유효성을 확인합니다.
if [[ -z $IP_ADDRESS ]]; then
  IP_ADDRESS=$(ifconfig | awk '/inet .*broadcast/{print $2}' | head -n 1)
fi

if ! validate_ip "$IP_ADDRESS"; then
  echo "올바르지 않은 IP 주소입니다: $IP_ADDRESS"
  exit 1
fi

NetworkID=$(echo "$IP_ADDRESS" | cut -d . -f1-3)
HostID=$(echo "$IP_ADDRESS" | cut -d . -f4)

# 사용자 목록이 비어있는지 확인합니다.
if [[ ${#USER_LIST[@]} -eq 0 ]]; then
  echo "사용자 목록이 필요합니다."
  exit 1
fi

# 비밀번호 변경 함수
function PASSWORD {
  for user in "${USER_LIST[@]}"; do
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
        echo -e "${RED}sshpass -p'$pwdstr$nid$hid' ssh $user@$IP_ADDRESS -oStrictHostKeyChecking=no${NC}\n"
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
