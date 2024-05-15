#!/bin/bash
set -x

# 백업 디렉토리 이름 설정
backup_dir="fvm01.scbyun.com-$(date +%Y%m%d)"

# 백업 디렉토리 및 하위 디렉토리 생성
cd /root/.nl/
mkdir "$backup_dir"
mkdir "$backup_dir/sbin"
mkdir "$backup_dir/etc"

# 필요한 파일 복사
cp -rpf /var/named "$backup_dir"
cp /etc/named.conf "$backup_dir/etc"
cp /etc/named.logging.conf "$backup_dir/etc"
cp /etc/named.root.key "$backup_dir/etc"
cp /etc/named.iscdlv.key "$backup_dir/etc"
cp /etc/rndc.* "$backup_dir/etc"
cp /usr/sbin/named "$backup_dir/sbin"
cp -pr /usr/local/named "$backup_dir"
rm -rf "$backup_dir/named/log"

# 백업 파일 생성 및 압축
tar cvfp "${backup_dir}.tar" "$backup_dir" --exclude="${backup_dir}/named/log"
gzip "${backup_dir}.tar"

# 생성된 백업 디렉토리 삭제
rm -rf "$backup_dir"
