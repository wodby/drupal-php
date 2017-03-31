FROM wodby/php:7.0

ENV WODBY_DIR_FILES /mnt/files
ENV WODBY_DIR_CONF /var/www/conf

RUN su-exec www-data composer global config minimum-stability rc && \
    su-exec www-data composer global require drupal/console:~1.0 drush/drush && \
    su-exec www-data composer clear-cache && \
    mv /usr/local/bin/actions.mk /usr/local/bin/php.mk && \
    mkdir -p $WODBY_DIR_FILES && \
    mkdir -p $WODBY_DIR_CONF && \
    chown -R www-data:www-data $WODBY_DIR_CONF

COPY templates/* /etc/gotpl/
COPY actions /usr/local/bin
COPY init/* /docker-entrypoint-init.d/