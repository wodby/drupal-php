ARG FROM_TAG

FROM wodby/php:${FROM_TAG}

ENV DRUSH_LAUNCHER_VER="0.4.3" \
    \
    WODBY_DIR_FILES="/mnt/files" \
    WODBY_DIR_CONF="/var/www/conf" \
    \
    PHP_REALPATH_CACHE_TTL="3600" \
    PHP_OUTPUT_BUFFERING="16384" \
    \
    DRUSH_PATCHFILE_URL="https://bitbucket.org/davereid/drush-patchfile.git"

USER root

RUN set -ex; \
    \
    # Drush
    su-exec www-data composer global require drush/drush; \
    \
    # Drush launcher
    wget -O drush.phar \
        "https://github.com/drush-ops/drush-launcher/releases/download/${DRUSH_LAUNCHER_VER}/drush.phar"; \
    chmod +x drush.phar; \
    mv drush.phar /usr/local/bin/drush; \
    \
    # Drush extensions
    su-exec www-data drush @none dl registry_rebuild-7.x; \
    su-exec www-data git clone "${DRUSH_PATCHFILE_URL}" /home/www-data/.drush/drush-patchfile; \
    \
    # Drupal console
    curl https://drupalconsole.com/installer -L -o drupal.phar; \
    mv drupal.phar /usr/local/bin/drupal; \
    chmod +x /usr/local/bin/drupal; \
    \
    mv /usr/local/bin/actions.mk /usr/local/bin/php.mk; \
    # Change overridden target name to avoid warnings.
    sed -i 's/git-checkout:/php-git-checkout:/' /usr/local/bin/php.mk; \
    \
    mkdir -p "${WODBY_DIR_FILES}" "${WODBY_DIR_CONF}"; \
    chown www-data:www-data "${WODBY_DIR_CONF}"; \
    \
    # Clean up
    su-exec www-data composer clear-cache; \
    su-exec www-data drush cc drush

USER www-data

COPY templates /etc/gotpl/
COPY actions /usr/local/bin
COPY init /docker-entrypoint-init.d/