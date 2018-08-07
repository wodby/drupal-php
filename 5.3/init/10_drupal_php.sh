#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

if [[ -n "${DRUPAL_VERSION}" ]]; then
    gotpl "/etc/gotpl/drupal${DRUPAL_VERSION}.settings.php.tmpl" > "${CONF_DIR}/wodby.settings.php"
fi
