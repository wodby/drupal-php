#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

source=$1

tmp_dir="/tmp/source"

[[ -d "${tmp_dir}" ]] && rm -rf "${tmp_dir}"

mkdir -p "${tmp_dir}"

if [[ "${source}" =~ ^https?:// ]]; then
    wget -q -P "${tmp_dir}" "${source}"
else
    mv "${source}" "${tmp_dir}"
fi

archive_file=$(find "${tmp_dir}" -type f)

if [[ "${archive_file}" =~ \.zip$ ]]; then
    unzip "${archive_file}" -d "${tmp_dir}"
elif [[ "${archive_file}" =~ \.tgz$ ]] || [[ "${archive_file}" =~ \.tar.gz$ ]]; then
    tar zxf "${archive_file}" -C "${tmp_dir}"
elif [[ "${archive_file}" =~ \.tar$ ]]; then
    tar xf "${archive_file}" -C "${tmp_dir}"
else
    echo >&2 'Unsupported file format. Expecting .zip .tar.gz .tgz archive'
    exit 1
fi

rm "${archive_file}"

if [[ -d "${tmp_dir}/private" ]]; then
    rsync -rlt --delete --force "${tmp_dir}/private/" "${WODBY_DIR_FILES}/private/"
fi

if [[ -d "${tmp_dir}/public" ]]; then
    rsync -rlt --delete --force "${tmp_dir}/public/" "${WODBY_DIR_FILES}/public/"
else
    rsync -rlt --delete --force "${tmp_dir}/" "${WODBY_DIR_FILES}/public/"
fi

rm -rf "${tmp_dir}"

exec init-files.sh
