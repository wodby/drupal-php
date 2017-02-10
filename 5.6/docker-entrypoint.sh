#!/bin/bash

set -e

if [[ $DEBUG ]]; then
  set -x
fi

if [ -d /mnt/ssh ]; then
    mkdir -p /home/www-data/.ssh
    cp /mnt/ssh/* /home/www-data/.ssh/
    chown -R www-data:www-data /home/www-data/.ssh
    chmod -R 700 /home/www-data/.ssh
fi

if [[ $PHP_SENDMAIL_PATH ]]; then
     sed -i 's@^;sendmail_path.*@'"sendmail_path = ${PHP_SENDMAIL_PATH}"'@' /etc/php5/php.ini
fi

if [[ $PHP_XDEBUG_ENABLED = 1 ]]; then
     sed -i 's/^;zend_extension.*/zend_extension = xdebug.so/' /etc/php5/conf.d/xdebug.ini
fi

if [[ $PHP_XDEBUG_AUTOSTART = 0 ]]; then
     sed -i 's/^xdebug.remote_autostart.*/xdebug.remote_autostart = 0/' /etc/php5/conf.d/xdebug.ini
fi

if [[ $PHP_XDEBUG_REMOTE_CONNECT_BACK = 0 ]]; then
     sed -i 's/^xdebug.remote_connect_back.*/xdebug.remote_connect_back = 0/' /etc/php5/conf.d/xdebug.ini
fi

if [ $PHP_XDEBUG_REMOTE_HOST ]; then
     sed -i 's/^xdebug.remote_host.*/'"xdebug.remote_host = ${PHP_XDEBUG_REMOTE_HOST}"'/' /etc/php5/conf.d/xdebug.ini
fi

exec "$@"
