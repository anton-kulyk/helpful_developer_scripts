#!/bin/bash

PHP_VER=$1

sudo update-alternatives --set php /usr/bin/php"${PHP_VER}"
sudo update-alternatives --set phar /usr/bin/phar"${PHP_VER}"
sudo update-alternatives --set phar.phar /usr/bin/phar.phar"${PHP_VER}"
php -v