FROM wodby/php:5.3

ENV WODBY_DIR_FILES="/mnt/files" \
    WODBY_DIR_CONF="/var/www/conf" \

    PHP_ALWAYS_POPULATE_RAW_POST_DATA="-1" \
    PHP_MBSTRING_ENCODING_TRANSLATION="Off" \
    PHP_MBSTRING_HTTP_INPUT="pass" \
    PHP_MBSTRING_HTTP_OUTPUT="pass" \
    PHP_OUTPUT_BUFFERING="16384" \
    PHP_REALPATH_CACHE_SIZE="64k" \
    PHP_REALPATH_CACHE_TTL="3600" \
    PHP_SESSION_AUTO_START="0" \

    DRUSH_PATCHFILE_URL="https://bitbucket.org/davereid/drush-patchfile.git"

RUN su-exec www-data composer global require drush/drush:7.4.0 && \
    su-exec www-data composer clear-cache && \
    mv /usr/local/bin/actions.mk /usr/local/bin/php.mk && \
    su-exec www-data drush @none dl registry_rebuild-7.x && \
    su-exec www-data git clone ${DRUSH_PATCHFILE_URL} /home/www-data/.drush/drush-patchfile && \
    su-exec www-data drush cc drush && \
    # Change overridden target name to avoid warnings.
    sed -i 's/git-checkout:/php-git-checkout:/' /usr/local/bin/php.mk && \
    mkdir -p $WODBY_DIR_FILES $WODBY_DIR_CONF && \
    chown -R www-data:www-data $WODBY_DIR_CONF

COPY templates /etc/gotpl/
COPY actions /usr/local/bin
COPY init /docker-entrypoint-init.d/