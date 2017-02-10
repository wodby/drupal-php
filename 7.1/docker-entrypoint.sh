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

if [[ -n "$PHP_DRUSH_MEMORY_LIMIT" ]]; then
     sed -i 's/^memory_limit.*/'"memory_limit = ${PHP_DRUSH_MEMORY_LIMIT}"'/' "$PHP_INI_DIR/php.ini"
fi

if [ -n "$PHP_SENDMAIL_PATH" ]; then
     sed -i 's@^;sendmail_path.*@'"sendmail_path = ${PHP_SENDMAIL_PATH}"'@' "$PHP_INI_DIR/php.ini"
fi

if [[ $PHP_XDEBUG_ENABLED = 1 ]]; then
     sed -i 's/^;zend_extension.*/zend_extension = xdebug.so/' "$PHP_INI_DIR/conf.d/00_xdebug.ini"
fi

if [[ $PHP_XDEBUG_AUTOSTART = 0 ]]; then
     sed -i 's/^xdebug.remote_autostart.*/xdebug.remote_autostart = 0/' "$PHP_INI_DIR/conf.d/00_xdebug.ini"
fi

if [[ $PHP_XDEBUG_REMOTE_CONNECT_BACK = 0 ]]; then
     sed -i 's/^xdebug.remote_connect_back.*/xdebug.remote_connect_back = 0/' "$PHP_INI_DIR/conf.d/00_xdebug.ini"
fi

if [[ $PHP_XDEBUG_REMOTE_HOST ]]; then
     sed -i 's/^xdebug.remote_host.*/'"xdebug.remote_host = ${PHP_XDEBUG_REMOTE_HOST}"'/' "$PHP_INI_DIR/conf.d/00_xdebug.ini"
fi

exec "$@"
