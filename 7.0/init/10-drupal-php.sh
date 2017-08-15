#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

execTpl() {
    if [[ -f "/etc/gotpl/$1" ]]; then
        gotpl "/etc/gotpl/$1" > "$2"
    fi
}

mkdir -p "${WODBY_DIR_FILES}/private" "${WODBY_DIR_FILES}/public"
chown www-data:www-data "${WODBY_DIR_FILES}" "${WODBY_DIR_FILES}/private" "${WODBY_DIR_FILES}/public"

if [[ -n "${DRUPAL_VERSION}" ]]; then
    if [[ "${DRUPAL_VERSION}" == "7" ]] || [[ "${DRUPAL_VERSION}" == "8" ]]; then
        execTpl 'sites.php.tpl' "${WODBY_DIR_CONF}/wodby.sites.php"
    fi

    execTpl "drupal${DRUPAL_VERSION}.settings.php.tpl" "${WODBY_DIR_CONF}/wodby.settings.php"
fi
