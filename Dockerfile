ARG BASE_IMAGE_TAG

FROM --platform=$BUILDPLATFORM wodby/php:${BASE_IMAGE_TAG}

ENV DRUSH_LAUNCHER_FALLBACK="/home/wodby/.composer/vendor/bin/drush" \
    \
    PHP_REALPATH_CACHE_TTL="3600" \
    PHP_OUTPUT_BUFFERING="16384"

USER root

RUN set -ex; \
    \
    # We keep drush 8 as default for PHP 7.x because it's used for Drupal 7 as well.
    #####
    su-exec wodby composer global require drush/drush:^8.0; \
    drush_launcher_url="https://github.com/drush-ops/drush-launcher/releases/download/0.9.0/drush.phar"; \
    wget -O drush.phar "${drush_launcher_url}"; \
    chmod +x drush.phar; \
    mv drush.phar /usr/local/bin/drush; \
    \
    # Drush extensions
    su-exec wodby mkdir -p /home/wodby/.drush; \
    drush_patchfile_url="https://bitbucket.org/davereid/drush-patchfile.git"; \
    su-exec wodby git clone "${drush_patchfile_url}" /home/wodby/.drush/drush-patchfile; \
    drush_rr_url="https://ftp.drupal.org/files/projects/registry_rebuild-7.x-2.5.tar.gz"; \
    wget -qO- "${drush_rr_url}" | su-exec wodby tar zx -C /home/wodby/.drush; \
    \
    # Drupal console
    console_url="https://github.com/hechoendrupal/drupal-console-launcher/releases/download/1.9.7/drupal.phar"; \
    curl "${console_url}" -L -o drupal.phar; \
    mv drupal.phar /usr/local/bin/drupal; \
    chmod +x /usr/local/bin/drupal; \
    \
    mv /usr/local/bin/actions.mk /usr/local/bin/php.mk; \
    # Change overridden target name to avoid warnings.
    sed -i 's/git-checkout:/php-git-checkout:/' /usr/local/bin/php.mk; \
    \
    mkdir -p "${FILES_DIR}/config"; \
    chown www-data:www-data "${FILES_DIR}/config"; \
    chmod 775 "${FILES_DIR}/config"; \
    \
    # Clean up
    su-exec wodby composer clear-cache; \
    su-exec wodby drush cc drush

USER wodby

COPY templates /etc/gotpl/
COPY bin /usr/local/bin
COPY init /docker-entrypoint-init.d/
