#!/bin/bash
##### node-01 -> node-02 데이터를 당겨오기
##### ssh key 생성
### node-02> ssh-keygen
### node-02> ssh-copy-id root@node-01
##### node-02 서버에서 rsync_script.sh 스크립트 실행
### node-02> chmod +x rsync_script.sh
### node-02> bash rsync_script.sh

# 현재 날짜 구하기
today=$(date +%Y%m%d)

# 년, 월, 일
year=${today:0:4}
month=${today:4:2}
day=${today:6:2}

# 동기화할 디렉토리 목록
directories=(
  "/app/www/data"
  "/app/www/data2"
  "/app/www/data3"
)

# rsync 명령어로 다른 서버로 동기화하기
for directory in "${directories[@]}"
do
  mkdir -p $directory/$year/$month/$day
  rsync -azp root@node-01:"$directory/$year/$month/$day/" "$directory/$year/$month/$day/"
done

# .jpg 파일과 빈 디렉토리 삭제하기
for dir in "${directories[@]}"
do
  # .jpg 파일 삭제
  find "$dir" -type f -name "*.jpg" -mtime +7 -delete

  # 빈 디렉토리 삭제
  find "$dir" -type d -empty -mtime +7 -delete
done