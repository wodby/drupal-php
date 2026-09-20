# check=skip=InvalidDefaultArgInFrom

# The Makefile supplies the required digest-pinned BASE_IMAGE argument.

ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV PHP_REALPATH_CACHE_TTL="3600" \
    PHP_OUTPUT_BUFFERING="16384" \
    PHP_APCU_SHM_SIZE="256M"

USER root

RUN set -ex; \
    \
    mv /usr/local/bin/actions.mk /usr/local/bin/php.mk; \
    mv /usr/local/bin/init_container /usr/local/bin/php_init_container; \
    # Change overridden target name to avoid warnings.
    sed -i 's/git-checkout:/php-git-checkout:/' /usr/local/bin/php.mk; \
    \
    mkdir -p "${FILES_DIR}/config"; \
    chown www-data:www-data "${FILES_DIR}/config"; \
    chmod 775 "${FILES_DIR}/config"; \
    \
    # Clean up
    su-exec wodby composer clear-cache

USER wodby

COPY templates /etc/gotpl/
COPY bin /usr/local/bin
COPY init /docker-entrypoint-init.d/
