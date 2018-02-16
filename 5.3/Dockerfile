ARG BASE_IMAGE_TAG

FROM wodby/php:${BASE_IMAGE_TAG}

ENV DRUSH_VER="7.4.0" \
    \
    PHP_ALWAYS_POPULATE_RAW_POST_DATA="-1" \
    PHP_MBSTRING_ENCODING_TRANSLATION="Off" \
    PHP_MBSTRING_HTTP_INPUT="pass" \
    PHP_MBSTRING_HTTP_OUTPUT="pass" \
    PHP_OUTPUT_BUFFERING="16384" \
    PHP_REALPATH_CACHE_SIZE="64k" \
    PHP_REALPATH_CACHE_TTL="3600" \
    PHP_SESSION_AUTO_START="0"

USER root

RUN set -ex; \
    \
    # Drush
    su-exec wodby composer global require drush/drush:"${DRUSH_VER}"; \
    \
    # Drush extensions
    su-exec wodby mkdir -p /home/wodby/.drush; \
    drush_patchfile_url="https://bitbucket.org/davereid/drush-patchfile.git"; \
    su-exec wodby git clone "${drush_patchfile_url}" /home/wodby/.drush/drush-patchfile; \
    \
    mv /usr/local/bin/actions.mk /usr/local/bin/php.mk; \
    # Change overridden target name to avoid warnings.
    sed -i 's/git-checkout:/php-git-checkout:/' /usr/local/bin/php.mk; \
    \
    # Clean up
    su-exec wodby composer clear-cache; \
    su-exec wodby drush cc drush

USER wodby

COPY templates /etc/gotpl/
COPY bin /usr/local/bin
COPY init /docker-entrypoint-init.d/