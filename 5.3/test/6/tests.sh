#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

checkRq() {
    drush rq --format=json | jq ".\"${1}\".value" | grep -q "${2}"
    echo "OK"
}

checkStatus() {
    drush status --format=yaml | grep -q "${1}: ${2}"
    echo "OK"
}

runAction() {
    make "${@}" -f /usr/local/bin/actions.mk
}

echo -n "Checking environment variables... "
env | grep -q ^WODBY_DIR_CONF=
env | grep -q ^WODBY_DIR_FILES=
env | grep -q ^DOCROOT_SUBDIR=
env | grep -q ^DRUPAL_VERSION=
env | grep -q ^DRUPAL_SITE=
echo "OK"

if [[ -n "${DOCROOT_SUBDIR}" ]]; then
	DRUPAL_ROOT="${APP_ROOT}/${DOCROOT_SUBDIR}"
else
	DRUPAL_ROOT="${APP_ROOT}"
fi

DRUPAL_DOMAIN="$( echo "${WODBY_HOST_PRIMARY}" | sed 's/https\?:\/\///' )"
FILES_ARCHIVE_URL="https://s3.amazonaws.com/wodby-sample-files/drupal-php-import-test/files.tar.gz"

drush make make.yml -y
drush si -y --db-url="${DB_DRIVER}://${DB_USER}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME}"
drush archive-dump -y --destination=/tmp/drush-archive.tar.gz
drush sql-drop -y

runAction drush-import source=/tmp/drush-archive.tar.gz
runAction files-import source="${FILES_ARCHIVE_URL}"
runAction init-drupal
runAction cache-clear

drush en memcache -y

echo -n "Checking drush version... "
checkStatus "drush-version" "7.*"

echo -n "Checking Drupal root... "
checkStatus "root" "${DRUPAL_ROOT}"

echo -n "Checking Drupal site path... "
checkStatus "site" "sites/${DRUPAL_SITE}"

echo -n "Checking Drupal file directory path... "
checkStatus "files" "sites/${DRUPAL_SITE}/files"

echo -n "Checking Drupal temporary file directory path... "
checkStatus "temp" "/tmp"

echo -n "Checking memcached connection... "
checkRq "memcache_extension" "2.*"

echo -n "Checking Drupal file system permissions... "
checkRq "file system" "Writable (<em>public</em> download method)"

echo -n "Checking settings.php permissions... "
checkRq "settings.php" "Protected"

echo -n "Checking imported files... "
curl -s -I -H "host: ${DRUPAL_DOMAIN}" "nginx/sites/default/files/logo.png" | grep -q "200 OK"
echo "OK"

echo -n "Checking Drupal homepage... "
curl -s -H "host: ${DRUPAL_DOMAIN}" "nginx" | grep -q "Welcome to your new Drupal website!"
echo "OK"
