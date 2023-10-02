#!/bin/bash

sudo yum install -y epel-release

sudo yum install -y php8.1 php8.1-cli php8.1-common php8.1-devel php8.1-fpm
sudo yum install -y php8.1-bcmath php8.1-gd php8.1-intl php8.1-mbstring php8.1-mysqlnd php8.1-pdo php8.1-xml
sudo yum install -y php-pear

sudo yum install -y  ImageMagick ImageMagick-devel
sudo yum install -y re2c librdkafka librdkafka-devel


echo | pecl install redis
echo | pecl install mongodb
echo | pecl install imagick
echo | pecl install rdkafka
echo | pecl install zip

echo "extension=redis.so" >> /etc/php.ini
echo "extension=mongodb.so" >> /etc/php.ini
echo "extension=imagick.so" >> /etc/php.ini
