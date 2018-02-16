#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

if [[ -n "${DRUPAL_VERSION}" ]]; then
    if [[ "${DRUPAL_VERSION}" == "7" ]] || [[ "${DRUPAL_VERSION}" == "8" ]]; then
        gotpl "/etc/gotpl/sites.php.tpl" > "${CONF_DIR}/wodby.sites.php"
    fi

    gotpl "/etc/gotpl/drupal${DRUPAL_VERSION}.settings.php.tpl" > "${CONF_DIR}/wodby.settings.php"
fi
