#!/bin/bash

# 히스토리 설정 값을 설정합니다.
TMOUT=600

HISTSIZE=10000
HISTFILESIZE=10000
HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S '

# .bashrc 파일을 백업합니다.
cp ~/.bashrc ~/.bashrc.bak

# 기존 "TMOUT" 또는 "HISTTIMEFORMAT" 설정이 존재하는지 확인합니다.
grep -q "^TMOUT=" ~/.bashrc
TMOUT_EXIST=$?

grep -q "^HISTTIMEFORMAT=" ~/.bashrc
HISTTIMEFORMAT_EXIST=$?

# 히스토리 설정을 .bashrc 파일에 적용합니다.
if [ $TMOUT_EXIST -ne 0 ]; then
    echo "### TIMEOUT" >> ~/.bashrc
    echo "TMOUT=$TMOUT" >> ~/.bashrc
fi

if [ $HISTTIMEFORMAT_EXIST -ne 0 ]; then
    echo "### HISTORY" >> ~/.bashrc
    echo "HISTSIZE=$HISTSIZE" >> ~/.bashrc
    echo "HISTFILESIZE=$HISTFILESIZE" >> ~/.bashrc
    echo "HISTTIMEFORMAT=$HISTTIMEFORMAT" >> ~/.bashrc
fi

# 변경사항을 적용합니다.
source ~/.bashrc

echo "히스토리 설정이 적용되었습니다."
