FROM wodby/php:7.0-2.4.0

ENV WODBY_DIR_FILES /mnt/files
ENV WODBY_DIR_CONF /var/www/conf

ENV PHP_REALPATH_CACHE_TTL 3600
ENV PHP_OUTPUT_BUFFERING 16384

RUN su-exec www-data composer global require drush/drush && \
    su-exec www-data composer clear-cache && \
    curl https://drupalconsole.com/installer -L -o drupal.phar && \
    mv drupal.phar /usr/local/bin/drupal && \
    chmod +x /usr/local/bin/drupal && \
    mv /usr/local/bin/actions.mk /usr/local/bin/php.mk && \
    mkdir -p $WODBY_DIR_FILES $WODBY_DIR_CONF && \
    chown -R www-data:www-data $WODBY_DIR_CONF

COPY templates /etc/gotpl/
COPY actions /usr/local/bin
COPY init /docker-entrypoint-init.d/