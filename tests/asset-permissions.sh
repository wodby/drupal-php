#!/usr/bin/env bash

# Run as root in a disposable container without application volumes.
set -euo pipefail

assert_directory() {
    local path=$1
    [[ $(stat -c '%U:%G:%a' "${path}") == www-data:www-data:775 ]]
}

# Create as PHP-FPM, then delete both files and directories as Drush's user.
check_deletion() {
    for type in css js; do
        assert_directory "${FILES_DIR}/public/${type}"
        su-exec www-data php -r '
            umask(0022);
            $path = getenv("FILES_DIR") . "/public/" . $argv[1] . "/aggregate." . $argv[1];
            if (file_put_contents($path, "fixture") === false || !chmod($path, 0664)) {
                exit(1);
            }
        ' "${type}"
        su-exec wodby sh -ec 'rm "$1/aggregate.$2"; rmdir "$1"' sh "${FILES_DIR}/public/${type}" "${type}"
    done
}

echo 'Checking startup, deletion, and repeated initialization...'
check_deletion
init_container
init_container
check_deletion

echo 'Checking existing directories and unchanged file permissions...'
mkdir -p "${FILES_DIR}/public/css" "${FILES_DIR}/public/js" "${FILES_DIR}/public/uploads"
chown -R www-data:www-data "${FILES_DIR}/public"
chmod 755 "${FILES_DIR}/public/css" "${FILES_DIR}/public/js"
chmod 700 "${FILES_DIR}/public/uploads"
touch "${FILES_DIR}/public/css/existing.css"
chmod 600 "${FILES_DIR}/public/css/existing.css"
before=$(stat -c '%u:%g:%a' "${FILES_DIR}/public/css/existing.css" "${FILES_DIR}/public/uploads" "${APP_ROOT}" /home/wodby)
init_container "${FILES_DIR}/config/sync-test"
assert_directory "${FILES_DIR}/config/sync-test"
[[ "${before}" == "$(stat -c '%u:%g:%a' "${FILES_DIR}/public/css/existing.css" "${FILES_DIR}/public/uploads" "${APP_ROOT}" /home/wodby)" ]]
su-exec wodby rm "${FILES_DIR}/public/css/existing.css"
check_deletion

echo 'Checking an import with restrictive directory modes...'
archive=$(mktemp -d)
trap 'rm -rf "${archive}"' EXIT
mkdir "${archive}/css" "${archive}/js" "${archive}/uploads"
chmod 755 "${archive}/css" "${archive}/js"
chmod 700 "${archive}/uploads"
touch "${archive}/css/imported.css" "${archive}/js/imported.js"
chmod 600 "${archive}/css/imported.css" "${archive}/js/imported.js"
files_sync "${archive}/" "${FILES_DIR}/public/"
[[ $(stat -c '%a' "${FILES_DIR}/public/uploads") == 700 ]]
for type in css js; do
    [[ $(stat -c '%a' "${FILES_DIR}/public/${type}/imported.${type}") == 600 ]]
    su-exec wodby rm "${FILES_DIR}/public/${type}/imported.${type}"
done
check_deletion

echo 'Checking custom symlinked storage is left unchanged...'
mkdir "${archive}/custom-css"
chmod 700 "${archive}/custom-css"
ln -s "${archive}/custom-css" "${FILES_DIR}/public/css"
init_container
[[ -L "${FILES_DIR}/public/css" ]]
[[ $(stat -c '%U:%G:%a' "${archive}/custom-css") == root:root:700 ]]

echo 'Drupal aggregate permission tests passed.'
