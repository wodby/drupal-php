#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

if [[ -n "${DRUPAL_VERSION}" ]]; then
    gotpl "/etc/gotpl/sites.php.tmpl" > "${CONF_DIR}/wodby.sites.php"
    gotpl "/etc/gotpl/drupal${DRUPAL_VERSION}.settings.php.tmpl" > "${CONF_DIR}/wodby.settings.php"

    # Tool containers render configuration without changing shared-volume ownership.
    if [[ -n "${DRUPAL_FILES_SYNC_SALT}" && "${WODBY_RUNTIME_CONFIGURATION_ONLY:-}" != 1 ]]; then
        sudo init_container "${FILES_DIR}/config/sync_${DRUPAL_FILES_SYNC_SALT}"
    fi
fi
