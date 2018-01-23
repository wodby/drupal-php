ARG BASE_IMAGE_TAG

FROM wodby/php:${BASE_IMAGE_TAG}

ENV DRUSH_LAUNCHER_VER="0.5.1" \
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
    # Clean up
    su-exec www-data composer clear-cache; \
    su-exec www-data drush cc drush

USER www-data

COPY templates /etc/gotpl/
COPY actions /usr/local/bin
COPY init /docker-entrypoint-init.d/
