FROM wodby/php:7.0

ENV WODBY_DIR_FILES="/mnt/files" \
    WODBY_DIR_CONF="/var/www/conf" \

    PHP_REALPATH_CACHE_TTL="3600" \
    PHP_OUTPUT_BUFFERING="16384" \

    DRUSH_PATCHFILE_URL="https://bitbucket.org/davereid/drush-patchfile.git"

RUN su-exec www-data composer global require drush/drush && \
    su-exec www-data composer clear-cache && \
    su-exec www-data drush @none dl registry_rebuild-7.x && \
    su-exec www-data git clone ${DRUSH_PATCHFILE_URL} /home/www-data/.drush/drush-patchfile && \
    su-exec www-data drush cc drush && \
    curl https://drupalconsole.com/installer -L -o drupal.phar && \
    mv drupal.phar /usr/local/bin/drupal && \
    chmod +x /usr/local/bin/drupal && \
    mv /usr/local/bin/actions.mk /usr/local/bin/php.mk && \
    # Change overridden target name to avoid warnings.
    sed -i 's/git-checkout:/php-git-checkout:/' /usr/local/bin/php.mk && \
    mkdir -p $WODBY_DIR_FILES $WODBY_DIR_CONF && \
    chown -R www-data:www-data $WODBY_DIR_CONF

COPY templates /etc/gotpl/
COPY actions /usr/local/bin
COPY init /docker-entrypoint-init.d/