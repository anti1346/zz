#!/bin/bash

### Define MySQL URL
mysql_url="https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.41-linux-glibc2.12-x86_64.tar"
#mysql_url="https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.33-linux-glibc2.17-aarch64.tar"

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
echo -e "\n\e[33mPackages Install\e[0m"
echo "packages : libaio1 libnuma1 libncurses5"
if ! dpkg -s libaio1 >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo apt-get install -qq -y libaio1 libnuma1 libncurses5
fi

### Check if MySQL user exists and create if not
echo -e "\n\e[33mMySQL User Create\e[0m"
if ! id -u ${mysql_username} >/dev/null 2>&1; then
  sudo groupadd --gid ${mysql_groupid} ${mysql_groupname}
  sudo useradd -r -d /usr/local/mysql --uid ${mysql_userid} -g ${mysql_groupname} -s /bin/false ${mysql_username}
fi
cat /etc/passwd | egrep mysql | awk -F: 'BEGIN { printf "username : "; } { printf $1; } END { printf "\nhome directory : "; printf $6; printf "\n"; }'

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
echo -e "\n\e[33mMySQL Base Directory Create\e[0m"
if [ ! -d "${base_dir}" ]; then
  mkdir "${base_dir}"
else
  exit 127
fi
echo "base dir : ${base_dir}"

cd /tmp

### Download MySQL
echo -e "\n\e[33mMySQL Packages Download\e[0m"
wget -q --show-progress ${mysql_url}

tar xf ${mysql_filename}

### Create data directory if it doesn't exist
echo -e "\n\e[33mMySQL Data Directory Create\e[0m"
if [ ! -d "${data_dir}" ]; then
  mkdir "${data_dir}"
else
  exit 127
fi
echo "data dir : ${data_dir}"

tar xfz ${mysql_filename}.gz -C "${base_dir}" --strip-components=1

### Change ownership of MySQL base directory
echo -e "\n\e[33mSetting MySQL Base Directory Ownership\e[0m"
sudo chown -R ${user_name}:${group_name} "${base_dir}"
ls -ld ${base_dir} | awk '{print "Owner:", $3, "\nDirectory:", $NF}'

echo -e "\n\e[33mMySQL Configure File(my.cnf) Create\e[0m"
echo "my.cnf path : ${base_dir}/my.cnf"
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
echo -e "\n\e[33mInitialize MySQL\e[0m"
# /usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
${base_dir}/bin/mysqld --initialize-insecure --user=${user_name} --basedir=${base_dir} --datadir=${data_dir}
wait

### Start MySQL
echo -e "\n\e[33mStart MySQL\e[0m"
# /usr/local/mysql/bin/mysqld --defaults-file=/usr/local/mysql/my.cnf --user=mysql &
${base_dir}/bin/mysqld_safe --defaults-file=${base_dir}/my.cnf --user=${user_name} &
sleep 5

### Connect MySQL
echo -e "\n\e[33mConnect MySQL\e[0m"
# /usr/local/mysql/bin/mysql -uroot --socket /usr/local/mysql/mysql.sock
echo "${base_dir}/bin/mysql -uroot --socket ${base_dir}/mysql.sock"

### Stop(shutdown) MySQL
echo -e "\n\e[33mShutdown MySQL\e[0m"
# /usr/local/mysql/bin/mysqladmin -u root shutdown --socket /usr/local/mysql/mysql.sock
echo -e "${base_dir}/bin/mysqladmin -u root shutdown --socket ${base_dir}/mysql.sock\n"
