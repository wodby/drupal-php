#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

if [[ -n "${DRUPAL_VERSION}" ]]; then
    gotpl "/etc/gotpl/sites.php.tmpl" > "${CONF_DIR}/wodby.sites.php"
    gotpl "/etc/gotpl/drupal${DRUPAL_VERSION}.settings.php.tmpl" > "${CONF_DIR}/wodby.settings.php"

    if [[ -n "${DRUPAL_FILES_SYNC_SALT}" ]]; then
        sudo init_container "${FILES_DIR}/config/sync_${DRUPAL_FILES_SYNC_SALT}"
    fi
fi
