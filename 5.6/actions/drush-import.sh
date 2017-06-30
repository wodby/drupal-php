#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

source=$1
tmp_source_dir="/tmp/source"

[[ -d "${tmp_source_dir}" ]] && rm -rf "${tmp_source_dir}"

mkdir -p "${tmp_source_dir}"

if [[ "${source}" =~ ^https?:// ]]; then
    wget -q -P "${tmp_source_dir}" "${source}"
else
    mv "${source}" "${tmp_source_dir}"
fi

cd "${tmp_source_dir}"
archive_file=$(find -type f)

if [[ ! "${archive_file}" =~ \.tar.gz$ ]]; then
    echo >&2 'Unsupported file format. Expecting .tar.gz drush archive'
    exit 1
fi

tar -zxf "${archive_file}" --delay-directory-restore

# Enter parent directory.
if [[ ! -f "MANIFEST.ini" ]]; then
    subdir=$(find -type d ! -path . -maxdepth 1)
    cd "${subdir}"
fi

# Import db.
sql_file=$(find -type f -name "*.sql" -maxdepth 1)

mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" -e "DROP DATABASE IF EXISTS ${DB_NAME};"
mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" -e "CREATE DATABASE ${DB_NAME};"
mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" < "${sql_file}"

tmp_dir_codebase=$(find -type d ! -path . -maxdepth 1)
tmp_dir_files="${tmp_dir_codebase}/sites/${DRUPAL_SITE}/files"
chmod 755 "${tmp_dir_codebase}/sites/${DRUPAL_SITE}" || true

# Import files.
if [[ -d "${tmp_dir_files}/private" ]]; then
    rsync -rlt --force "${tmp_dir_files}/private/" "${WODBY_DIR_FILES}/private/"
fi

if [[ -d "${tmp_dir_files}/public" ]]; then
    rsync -rlt --force "${tmp_dir_files}/public/" "${WODBY_DIR_FILES}/public/"
elif [[ -d "${tmp_dir_files}" ]]; then
    rsync -rlt --force "${tmp_dir_files}/" "${WODBY_DIR_FILES}/public/"
fi

rm -rf "${tmp_source_dir}"
