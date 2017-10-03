#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

source=$1
tmp_dir="/tmp/source"

get-archive.sh "${source}" "${tmp_dir}" "tar.gz"

# Check for root directory.
if [[ ! -f "${tmp_dir}/MANIFEST.ini" ]]; then
    subdir=$(find "${tmp_dir}" -type d ! -path "${tmp_dir}" -maxdepth 1)
    tmp_dir="${tmp_dir}/${subdir}"
fi

# Import db.
sql_file=$(find "${tmp_dir}" -type f -name "*.sql" -maxdepth 1)

mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" -e "DROP DATABASE IF EXISTS ${DB_NAME};"
mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" -e "CREATE DATABASE ${DB_NAME};"
mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" < "${sql_file}"

# Import files.
tmp_dir_codebase=$(find "${tmp_dir}" -type d ! -path "${tmp_dir}" -maxdepth 1)
tmp_dir_files="${tmp_dir_codebase}/sites/${DRUPAL_SITE}/files"
chmod 755 "${tmp_dir_codebase}/sites/${DRUPAL_SITE}" || true

if [[ -d "${tmp_dir_files}/private" ]]; then
    rsync -rlt --force "${tmp_dir_files}/private/" "${WODBY_DIR_FILES}/private/"
fi

if [[ -d "${tmp_dir_files}/public" ]]; then
    rsync -rlt --force "${tmp_dir_files}/public/" "${WODBY_DIR_FILES}/public/"
elif [[ -d "${tmp_dir_files}" ]]; then
    rsync -rlt --force "${tmp_dir_files}/" "${WODBY_DIR_FILES}/public/"
fi

rm -rf "${tmp_dir}"
