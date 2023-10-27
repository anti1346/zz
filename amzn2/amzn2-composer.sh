#!/bin/bash

# composer 실행 파일이 있는지 확인
if [ -x "$(command -v composer)" ]; then
    echo "Composer is already installed."
else
    # Download and install Composer
    sudo curl -Ssf https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin/
    sudo ln -s /usr/local/bin/composer.phar /usr/local/bin/composer
    echo "Composer has been installed."
fi

echo "composer `composer --version | awk 'NR==1{print $3}'` 설치가 완료되었습니다."
