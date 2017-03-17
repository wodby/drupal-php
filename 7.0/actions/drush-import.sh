#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

source=$1

DB_URL="mysql://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME}"
tmp_source_dir="/tmp/source"
tmp_dir="/tmp/drush_import"
tmp_dir_site="${tmp_dir}/sites/${DRUPAL_SITE}"
tmp_dir_files="${tmp_dir_site}/files"

[[ -d "${tmp_source_dir}" ]] && rm -rf "${tmp_source_dir}"

mkdir -p "${tmp_source_dir}"

if [[ "${source}" =~ ^https?:// ]]; then
    wget -q -P "${tmp_source_dir}" "${source}"
else
    mv "${source}" "${tmp_source_dir}"
fi

archive_file=$(find "${tmp_source_dir}" -type f)

if [[ ! "${archive_file}" =~ \.tar.gz$ ]]; then
    echo >&2 'Unsupported file format. Expecting .tar.gz drush archive'
    exit 1
fi

# Import db and code.
drush -y arr "${archive_file}" "${DRUPAL_SITE}" --destination="${tmp_dir}" --db-url="${DB_URL}"
chmod -f 755 "${tmp_dir_site}"
rsync -rlt --delete --force --exclude ".git" --exclude "sites/${DRUPAL_SITE}/files" "${tmp_dir}/" "${DRUPAL_ROOT}/"

# Import files.
if [[ -d "${tmp_dir_files}/private" ]]; then
    rsync -rlt --delete --force "${tmp_dir_files}/private/" "${WODBY_DIR_FILES}/private/"
fi

if [[ -d "${tmp_dir_files}/public" ]]; then
    rsync -rlt --delete --force "${tmp_dir_files}/public/" "${WODBY_DIR_FILES}/public/"
elif [[ -d "${tmp_dir_files}" ]]; then
    rsync -rlt --delete --force "${tmp_dir_files}/" "${WODBY_DIR_FILES}/public/"
fi

# Cleanup "drush arr" artifacts.
if [[ -f "${DRUPAL_SITE_DIR}/settings.php" ]]; then
    sed -i -e '/Appended by drush archive-restore command/,$d' "${DRUPAL_SITE_DIR}/settings.php"
fi

rm -rf "${tmp_source_dir}"
rm -rf "${tmp_dir}"

exec init-drupal.sh
