#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

if [[ "${DOCROOT_SUBDIR}" == "" ]]; then
	DRUPAL_ROOT="${DOCROOT_SUBDIR}"
else
	DRUPAL_ROOT="${APP_ROOT}/${DOCROOT_SUBDIR}"
fi

DRUPAL_DOMAIN="$( echo "${WODBY_HOST_PRIMARY}" | sed 's/https\?:\/\///' )"

echo -n "Checking drush... "
drush status | grep -q "Drush version"
echo "OK"

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

echo -n "Checking database connection... "
drush status | grep -q "Database\s\+:\s\+Connected"
echo "OK"

echo -n "Checking memcached connection... "
drush rq | grep -q "Memcache\s\+OK\s\+2.2.0"
echo "OK"

echo -n "Checking memcached admin... "
drush rq | grep -q "Memcache admin\s\+OK\s\+Memcache included"
echo "OK"

echo -n "Checking PHP version... "
drush rq | grep -q "PHP\s\+Info\s\+${PHP_VERSION}"
echo "OK"

echo -n "Checking Drupal root... "
drush status | grep -q "Drupal root\s\+:\s\+${DRUPAL_ROOT}"
echo "OK"

echo -n "Checking Drupal settings file... "
drush status | grep -q "Drupal Settings File\s\+:\s\+sites/${DRUPAL_SITE}/settings.php"
echo "OK"

echo -n "Checking Drupal site path... "
drush status | grep -q "Site path\s\+:\s\+sites/${DRUPAL_SITE}"
echo "OK"

echo -n "Checking Drupal file directory path... "
drush status | grep -q "File directory path\s\+:\s\+sites/${DRUPAL_SITE}/files"
echo "OK"

echo -n "Checking Drupal temporary file directory path... "
drush status | grep -q "Temporary file directory path\s\+:\s\+/tmp"
echo "OK"

echo -n "Checking Drupal file system permissions... "
drush rq | grep -q "File system\s\+Info\s\+Writable (public download method)"
echo "OK"

echo -n "Checking settings.php permissions... "
drush rq | grep -q "Configuration file\s\+Info\s\+Protected"
echo "OK"

echo -n "Checking imported files... "
curl -s -I -H "host: ${DRUPAL_DOMAIN}" nginx/sites/default/files/logo.png | grep -q "200 OK"
echo "OK"

echo -n "Checking Drupal homepage... "
curl -s -H "host: ${DRUPAL_DOMAIN}" nginx | grep -q "Welcome to your new Pressflow website!"
echo "OK"
