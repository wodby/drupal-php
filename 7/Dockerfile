ARG BASE_IMAGE_TAG

FROM wodby/php:${BASE_IMAGE_TAG}

ENV DRUSH_LAUNCHER_VER="0.5.1" \
    \
    PHP_REALPATH_CACHE_TTL="3600" \
    PHP_OUTPUT_BUFFERING="16384"

USER root

RUN set -ex; \
    \
    su-exec wodby composer global require drush/drush; \
    \
    # Drush launcher
    drush_launcher_url="https://github.com/drush-ops/drush-launcher/releases/download/${DRUSH_LAUNCHER_VER}/drush.phar"; \
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
    curl https://drupalconsole.com/installer -L -o drupal.phar; \
    mv drupal.phar /usr/local/bin/drupal; \
    chmod +x /usr/local/bin/drupal; \
    \
    mv /usr/local/bin/actions.mk /usr/local/bin/php.mk; \
    # Change overridden target name to avoid warnings.
    sed -i 's/git-checkout:/php-git-checkout:/' /usr/local/bin/php.mk; \
    \
    mkdir -p "${FILES_DIR}/config"; \
    chown wodby:wodby "${FILES_DIR}/config"; \
    chmod 775 "${FILES_DIR}/config"; \
    \
    # Clean up
    su-exec wodby composer clear-cache; \
    su-exec wodby drush cc drush

USER wodby

COPY templates /etc/gotpl/
COPY actions /usr/local/bin
COPY init /docker-entrypoint-init.d/
