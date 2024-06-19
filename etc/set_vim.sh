#!/bin/bash

# 패키지 관리자를 결정하고 PACKAGE_MANAGER 변수 설정
if command -v yum &> /dev/null; then
    PACKAGE_MANAGER="yum"
elif command -v apt-get &> /dev/null; then
    PACKAGE_MANAGER="apt-get"
else
    echo "지원되지 않는 패키지 관리자입니다."
    exit 1
fi

# vim 및 기타 필요한 패키지를 설치하는 함수
install_vim() {
    case $PACKAGE_MANAGER in
        yum)
            sudo yum install -y vim
            ;;
        apt-get)
            sudo apt-get update
            sudo apt-get install -y vim dos2unix
            sudo update-alternatives --set editor /usr/bin/vim.basic
            ;;
    esac
}

# vim이 설치되어 있는지 확인하고 설치되어 있지 않으면 설치
if ! command -v vim &> /dev/null; then
    install_vim
fi

# .vimrc 파일에 설정이 이미 존재하는지 확인
VIMRC_FILE=$HOME/.vimrc
if ! grep -q 'set encoding=utf-8' $VIMRC_FILE 2>/dev/null; then
    cat <<EOF >> $VIMRC_FILE
set encoding=utf-8
set fileencoding=utf-8
set termencoding=utf-8
EOF

    echo ".vimrc 파일에 설정이 추가되었습니다."
else
    echo ".vimrc 파일에 설정이 이미 존재합니다. 변경하지 않았습니다."
fi



### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/set_vim.sh | bash
# 
# apt-get install -y dos2unix
# curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/set_vim.sh | dos2unix | bash

