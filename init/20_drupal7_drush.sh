#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

if [[ -n "${DRUPAL_VERSION}" && "${DRUPAL_VERSION}" == "7" && -n "${DRUPAL7_INSTALL_GLOBAL_DRUSH}" ]]; then
    composer global require "drush/drush:7.*"
fi
