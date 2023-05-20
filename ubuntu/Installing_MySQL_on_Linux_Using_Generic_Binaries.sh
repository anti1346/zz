#!/bin/bash

### Define MySQL URL
#mysql_url="https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.41-linux-glibc2.12-x86_64.tar"
mysql_url="https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.33-linux-glibc2.17-aarch64.tar"

### Define MySQL installation details
mysql_basedir=/usr/local/mysql
mysql_username=mysql
mysql_groupname=mysql
mysql_userid=121
mysql_groupid=121

### Extract MySQL filename and version from the URL
mysql_filename=$(basename "$mysql_url")
mysql_version=$(echo "$mysql_filename" | grep -oP '\d+\.\d+\.\d+')

### Check if required packages are installed, and install if not
if ! dpkg -s libaio1 >/dev/null 2>&1; then
  sudo apt-get update -qq -y
  sudo apt-get install -qq -y libaio1 libnuma1 libncurses5
fi

### Check if MySQL user exists and create if not
if ! id -u ${mysql_username} >/dev/null 2>&1; then
  sudo groupadd --gid ${mysql_groupid} ${mysql_groupname}
  sudo useradd -r --uid ${mysql_userid} -g ${mysql_groupname} -s /bin/false ${mysql_username}
fi

### Set the MySQL base directory based on version
if [ ! -d "${mysql_basedir}" ]; then
  base_dir=${mysql_basedir}
elif [ ! -d "${mysql_basedir}-${mysql_version}" ]; then
  base_dir=${mysql_basedir}-${mysql_version}
else
  exit 127
fi

### Set data directory and user/group names
data_dir=${base_dir}/data
user_name=${mysql_username}
group_name=${mysql_groupname}

### Create MySQL base directory if it doesn't exist
if [ ! -d "${base_dir}" ]; then
  mkdir "${base_dir}"
else
  exit 127
fi

cd /tmp

### Download MySQL
wget -q --show-progress ${mysql_url}

tar xf ${mysql_filename}

### Create data directory if it doesn't exist
if [ ! -d "${data_dir}" ]; then
  mkdir "${data_dir}"
else
  exit 127
fi

tar xfz ${mysql_filename}.gz -C "${base_dir}" --strip-components=1

sudo chown -R ${user_name}:${group_name} "${base_dir}"

sudo tee ${base_dir}/my.cnf > /dev/null <<EOF
[mysqld]
user = ${user_name}
port = 3306
basedir = ${base_dir}
datadir = ${data_dir}
socket = ${base_dir}/mysql.sock

log-error = ${data_dir}/error.log
log-error-verbosity = 3

symbolic-links = 0

[client]
port = 3306
socket = ${base_dir}/mysql.sock
EOF

cd ${base_dir}

### Initialize MySQL
echo "Initialize MySQL"
# /usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
${base_dir}/bin/mysqld --initialize-insecure --user=${user_name} --basedir=${base_dir} --datadir=${data_dir}

### Start MySQL
echo "Start MySQL"
# /usr/local/mysql/bin/mysqld --defaults-file=/usr/local/mysql/my.cnf --user=mysql &
${base_dir}/bin/mysqld_safe --defaults-file=${base_dir}/my.cnf --user=${user_name} &

### Connect to MySQL
# /usr/local/mysql/bin/mysql -uroot --socket /usr/local/mysql/mysql.sock

### Stop(shutdown) MySQL
# /usr/local/mysql/bin/mysqladmin -u root shutdown --socket /usr/local/mysql/mysql.sock
