#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

sudo fix-permissions.sh www-data www-data "${WODBY_DIR_FILES}"
mkdir -p "${WODBY_DIR_FILES}/private" "${WODBY_DIR_FILES}/public"

if [[ -n "${DRUPAL_VERSION}" ]]; then
    if [[ "${DRUPAL_VERSION}" == "7" ]] || [[ "${DRUPAL_VERSION}" == "8" ]]; then
        gotpl "/etc/gotpl/sites.php.tpl" > "${WODBY_DIR_CONF}/wodby.sites.php"
    fi

    gotpl "/etc/gotpl/drupal${DRUPAL_VERSION}.settings.php.tpl" > "${WODBY_DIR_CONF}/wodby.settings.php"
fi
