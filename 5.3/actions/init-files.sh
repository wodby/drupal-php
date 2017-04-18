#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

rm -rf "${DRUPAL_SITE_DIR}/files"
mkdir -p "${WODBY_DIR_FILES}/public"
ln -sf "${WODBY_DIR_FILES}/public" "${DRUPAL_SITE_DIR}/files"
