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

if [[ -n "${sql_file}" ]]; then
    echo "DB dump found: ${sql_file}. Importing..."

    mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" -e "DROP DATABASE IF EXISTS ${DB_NAME};"
    mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" -e "CREATE DATABASE ${DB_NAME};"
    mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" < "${sql_file}"
else
    echo "No db dump found for import"
fi

# Import files.
tmp_dir_codebase=$(find "${tmp_dir}" -type d ! -path "${tmp_dir}" -maxdepth 1)
tmp_dir_files="${tmp_dir_codebase}/sites/${DRUPAL_SITE}/files"

if [[ -n "${tmp_dir_files}" ]]; then
    echo "Files directory found: sites/${DRUPAL_SITE}/files. Importing..."

    chmod 755 "${tmp_dir_codebase}/sites/${DRUPAL_SITE}" || true

    if [[ -d "${tmp_dir_files}/private" ]]; then
        rsync -rlt --force "${tmp_dir_files}/private/" "${WODBY_DIR_FILES}/private/"
    fi

    if [[ -d "${tmp_dir_files}/public" ]]; then
        rsync -rlt --force "${tmp_dir_files}/public/" "${WODBY_DIR_FILES}/public/"
    elif [[ -d "${tmp_dir_files}" ]]; then
        rsync -rlt --force "${tmp_dir_files}/" "${WODBY_DIR_FILES}/public/"
    fi
else
    echo "No files directory found for import"
fi

rm -rf "${tmp_dir}"
