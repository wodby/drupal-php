FROM wodby/php:5.6-2.4.0

ENV WODBY_DIR_FILES /mnt/files
ENV WODBY_DIR_CONF /var/www/conf

ENV PHP_ALWAYS_POPULATE_RAW_POST_DATA -1
ENV PHP_MBSTRING_ENCODING_TRANSLATION Off
ENV PHP_MBSTRING_HTTP_INPUT pass
ENV PHP_MBSTRING_HTTP_OUTPUT pass
ENV PHP_OUTPUT_BUFFERING 16384
ENV PHP_REALPATH_CACHE_SIZE 64k
ENV PHP_REALPATH_CACHE_TTL 3600
ENV PHP_SESSION_AUTO_START 0

RUN su-exec www-data composer global require drush/drush && \
    su-exec www-data composer clear-cache && \
    mv /usr/local/bin/actions.mk /usr/local/bin/php.mk && \
    mkdir -p $WODBY_DIR_FILES $WODBY_DIR_CONF && \
    chown -R www-data:www-data $WODBY_DIR_CONF

COPY templates /etc/gotpl/
COPY actions /usr/local/bin
COPY init /docker-entrypoint-init.d/