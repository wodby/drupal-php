#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

source=$1
tmp_dir="/tmp/source"

get-archive.sh "${source}" "${tmp_dir}" "zip tgz tar.gz tar"

if [[ ! -d "${tmp_dir}/.wodby" ]]; then
    warning=1
fi

# TODO: deprecate /private /public import from non-wodby backups.
# TODO: use generic files-import.sh from wodby/php
if [[ -d "${tmp_dir}/private" ]]; then
    if [[ -n "${warning}" ]]; then
        echo "Directory /private detected. We consider it for drupal private files dir."
    fi

    rsync -rlt --force "${tmp_dir}/private/" "${FILES_DIR}/private/"
fi

if [[ -d "${tmp_dir}/public" ]]; then
    if [[ -n "${warning}" ]]; then
        echo "Directory /public detected. We consider it for drupal public files dir."
    fi

    rsync -rlt --force "${tmp_dir}/public/" "${FILES_DIR}/public/"
else
    rsync -rlt --force "${tmp_dir}/" "${FILES_DIR}/public/"
fi

rm -rf "${tmp_dir}"
