#!/usr/bin/env bash

# TODO: test sites.php entries

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

check_rq() {
    echo "Checking requirement: ${1} must be ${2}"
    drush rq --format=json | jq ".\"${1}\".value" | grep -q "${2}"
    echo "OK"
}

check_status() {
    echo "Checking status: ${1} must be ${2}"
    drush status --format=yaml | grep -q "${1}: ${2}"
    echo "OK"
}

run_action() {
    make "${@}" -f /usr/local/bin/actions.mk
}

echo -n "Checking Drupal Console... "
drupal | grep -q "Drupal Console"
echo "OK"

echo -n "Checking drush... "
drush version --format=yaml | grep -q "Core Drush commands"
echo "OK"

echo -n "Checking drush patchfile... "
drush patch-add --help | grep -q "Aliases: pa"
echo "OK"

echo -n "Checking drush registry rebuild... "
drush registry-rebuild --help | grep -q "Aliases: rr"
echo "OK"

echo -n "Checking environment variables... "
env | grep -q ^DOCROOT_SUBDIR=
env | grep -q ^DRUPAL_VERSION=
env | grep -q ^DRUPAL_SITE=
echo "OK"

if [[ -n "${DOCROOT_SUBDIR}" ]]; then
	DRUPAL_ROOT="${APP_ROOT}/${DOCROOT_SUBDIR}"
else
	DRUPAL_ROOT="${APP_ROOT}"
fi

FILES_ARCHIVE_URL="https://s3.amazonaws.com/wodby-sample-files/drupal-php-import-test/files.tar.gz"
GIT_URL="https://github.com/drupal-composer/drupal-project.git"

make git-clone url="${GIT_URL}" -f /usr/local/bin/actions.mk
make git-checkout target=7.x -f /usr/local/bin/actions.mk

composer install
composer require drupal/varnish drupal/redis

cd "${DRUPAL_ROOT}"

drush si -y --db-url="${DB_DRIVER}://${DB_USER}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME}"
drush en varnish redis -y --quiet
drush archive-dump -y --destination=/tmp/drush-archive.tar.gz
drush sql-drop -y

# Normally drupal installation can't happen before drupal-init, we don't expect files dir here.
chmod 755 "sites/${DRUPAL_SITE}"
rm -rf "sites/${DRUPAL_SITE}/files"
run_action drush-import source=/tmp/drush-archive.tar.gz
run_action files-import source="${FILES_ARCHIVE_URL}"
run_action init-drupal
run_action cache-clear

check_status "drush-version" "8.*"
check_status "root" "${DRUPAL_ROOT}"
check_status "drupal-settings-file" "sites/${DRUPAL_SITE}/settings.php"
check_status "site" "sites/${DRUPAL_SITE}"
check_status "files" "sites/${DRUPAL_SITE}/files"
check_status "private" "${FILES_DIR}/private"
check_status "temp" "/tmp"

check_rq "redis" "Connected, using the <em>PhpRedis</em> client"
check_rq "varnish" "Running"
check_rq "file system" "Writable (<em>public</em> download method)"
check_rq "settings.php" "Protected"

echo -n "Checking imported files... "
curl -s -I -H "host: ${WODBY_HOST_PRIMARY}" "nginx/sites/default/files/logo.png" | grep -q "200 OK"
echo "OK"

echo -n "Checking Drupal homepage... "
curl -s -H "host: ${WODBY_HOST_PRIMARY}" "nginx" | grep -q "Drupal ${DRUPAL_VERSION} (http://drupal.org)"
echo "OK"
