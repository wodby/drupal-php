#!/usr/bin/env bash

# TODO: test sites.php entries

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

check_rq() {
    echo "Checking requirement: ${1} must be ${2}"
    drush rq --format=json | jq '.[] | select(.title=="'"${1}"'") | .value' | grep -q "${2}"
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
drush version --format=yaml
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
make git-checkout target=8.x -f /usr/local/bin/actions.mk

COMPOSER_MEMORY_LIMIT=-1 composer install -n
composer require drupal/redis

cd "${DRUPAL_ROOT}"

run_action files-import source="${FILES_ARCHIVE_URL}"
run_action init-drupal

drush si -y --db-url="${DB_DRIVER}://${DB_USER}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME}"

# Comment out redis settings before enabling the module.
sed -i "s#^\$wodby\['redis'\]#//&#" "${CONF_DIR}/wodby.settings.php"
drush en redis -y --quiet
sed -i "s#^//\(\$wodby\['redis'\]\)#\1#" "${CONF_DIR}/wodby.settings.php"

run_action cache-clear target=render
run_action cache-rebuild

echo -n "Checking drupal console launcher... "
drupal -V --root=/var/www | grep -q "Launcher"
echo "OK"

check_status "root" "${DRUPAL_ROOT}"
check_status "site" "sites/${DRUPAL_SITE}"
check_status "files" "sites/${DRUPAL_SITE}/files"
check_status "private" "${FILES_DIR}/private"
check_status "temp" "/tmp"
# Drush 9 no longer provides this info.
#check_status "drupal-settings-file" "sites/${DRUPAL_SITE}/settings.php"
#check_status "config-sync" "${FILES_DIR}/config/sync_${DRUPAL_FILES_SYNC_SALT}"

check_rq "Redis" "Connected"
check_rq "Trusted Host Settings" "Enabled"
check_rq "File system" "Writable"
check_rq "Configuration files" "Protected"

# Drush 9 no longer provides this info.
#echo -n "Checking trusted hosts... "
#drush rq --format=yaml | grep "trusted_host_patterns setting" | \
#    sed 's/\\n//g; s/\\\\//g; s/\^//g; s/\$//g; s/, /\//g' | grep -q "${WODBY_HOSTS}"
#echo "OK"

echo -n "Checking imported files... "
curl -s -I -H "host: ${WODBY_HOST_PRIMARY}" "nginx/sites/default/files/logo.png" | grep -q "200 OK"
echo "OK"

echo -n "Checking Drupal homepage... "
curl -s -H "host: ${WODBY_HOST_PRIMARY}" "nginx" | grep -q "Drupal ${DRUPAL_VERSION} (https://www.drupal.org)"
echo "OK"
