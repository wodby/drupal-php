#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

rm -f "${DRUPAL_SITE_DIR}/files"
ln -sf "${WODBY_DIR_FILES}/public" "${DRUPAL_SITE_DIR}/files"

if [[ "${DRUPAL_VERSION}" == "8" ]]; then
    mkdir -p "${WODBY_DIR_FILES}/config/sync_${DRUPAL_FILES_SYNC_SALT}"
fi
