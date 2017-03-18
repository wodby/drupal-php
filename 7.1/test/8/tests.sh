#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

checkRq() {
    drush rq --fields=title,description | grep -q "${1}\s\+${2}"
    echo "OK"
}

checkStatus() {
    drush status --format=yaml | grep -q "${1}: ${2}"
    echo "OK"
}

if [[ "${DOCROOT_SUBDIR}" == "" ]]; then
	DRUPAL_ROOT="${DOCROOT_SUBDIR}"
else
	DRUPAL_ROOT="${APP_ROOT}/${DOCROOT_SUBDIR}"
fi

DRUPAL_DOMAIN="$( echo "${WODBY_HOST_PRIMARY}" | sed 's/https\?:\/\///' )"

echo -n "Checking drupal console... "
drupal -V | grep -q "Drupal Console"
echo "OK"

echo -n "Checking environment variables... "
env | grep -q ^WODBY_DIR_CONF=
env | grep -q ^WODBY_DIR_FILES=
env | grep -q ^DOCROOT_SUBDIR=
env | grep -q ^DRUPAL_VERSION=
env | grep -q ^DRUPAL_SITE=
echo "OK"

echo -n "Checking drush version... "
checkStatus "drush-version" "8.*"

echo -n "Checking Drupal root... "
checkStatus "root" "${DRUPAL_ROOT}"

echo -n "Checking settings file... "
checkStatus "drupal-settings-file" "sites/${DRUPAL_SITE}/settings.php"

echo -n "Checking Drupal site path... "
checkStatus "site" "sites/${DRUPAL_SITE}"

echo -n "Checking Drupal file directory path... "
checkStatus "files" "sites/${DRUPAL_SITE}/files"

echo -n "Checking Drupal private file directory path... "
checkStatus "private" "${WODBY_DIR_FILES}/private"

echo -n "Checking Drupal temporary file directory path... "
checkStatus "temp" "/tmp"

echo -n "Checking Drupal sync config path... "
checkStatus "config-sync" "${WODBY_DIR_FILES}/public/sync_${DRUPAL_FILES_SYNC_SALT}"

echo -n "Checking redis connection... "
checkRq "Redis" "Connected, using the PhpRedis client"

echo -n "Checking trusted host settings... "
checkRq "Trusted Host Settings" "Enabled"

echo -n "Checking Drupal file system permissions... "
checkRq "File system" "Writable (public download method)"

echo -n "Checking settings.php permissions... "
checkRq "Configuration files" "Protected"

echo -n "Checking trusted hosts... "
drush rq --format=yaml | grep "trusted_host_patterns setting" | \
    sed 's/\\n//g; s/\\\\//g; s/\^//g; s/\$//g; s/, /\//g' | grep -q "${WODBY_HOSTS}"
echo "OK"

echo -n "Checking imported files... "
curl -s -I -H "host: ${DRUPAL_DOMAIN}" "nginx/sites/default/files/logo.png" | grep -q "200 OK"
echo "OK"

echo -n "Checking Drupal homepage... "
curl -s -H "host: ${DRUPAL_DOMAIN}" "nginx" | grep -q "Welcome to Drupal ${DRUPAL_VERSION}"
echo "OK"
