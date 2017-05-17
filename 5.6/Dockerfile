FROM wodby/php:5.6-2.2.0

ENV WODBY_DIR_FILES /mnt/files
ENV WODBY_DIR_CONF /var/www/conf

ENV PHP_SESSION_COOKIE_LIFETIME 2000000
ENV PHP_SESSION_GC_MAXLIFETIME 2000000
ENV PHP_REALPATH_CACHE_SIZE 64k
ENV PHP_REALPATH_CACHE_SIZE 3600

RUN su-exec www-data composer global require drush/drush && \
    su-exec www-data composer clear-cache && \
    mv /usr/local/bin/actions.mk /usr/local/bin/php.mk && \
    mkdir -p $WODBY_DIR_FILES $WODBY_DIR_CONF && \
    chown -R www-data:www-data $WODBY_DIR_CONF

COPY templates /etc/gotpl/
COPY actions /usr/local/bin
COPY init /docker-entrypoint-init.d/