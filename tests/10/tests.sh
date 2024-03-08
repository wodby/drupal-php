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
GIT_URL="https://github.com/drupal/recommended-project"

make git-clone url="${GIT_URL}" -f /usr/local/bin/actions.mk
# Get latest stable drupal 10 tag.
latest_ver=$(git show-ref --tags | grep -P -o '(?<=refs/tags/)10\.[0-9]+\.[0-9]+$' | sort -rV | head -n1)
make git-checkout target="${latest_ver}" -f /usr/local/bin/actions.mk

COMPOSER_MEMORY_LIMIT=-1 composer install -n
composer require drush/drush
composer require drupal/redis

echo -n "Checking drush... "
drush version --format=yaml
echo "OK"

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

check_status "root" "${DRUPAL_ROOT}"
check_status "site" "sites/${DRUPAL_SITE}"
check_status "files" "sites/${DRUPAL_SITE}/files"
check_status "private" "${FILES_DIR}/private"
check_status "temp" "/tmp"

check_rq "Redis" "Connected"
check_rq "Trusted Host Settings" "Enabled"
check_rq "File system" "Writable"
check_rq "Configuration files" "Protected"

echo -n "Checking imported files... "
curl -s -I -H "host: ${WODBY_HOST_PRIMARY}" "nginx/sites/default/files/logo.png" | grep -q "200 OK"
echo "OK"

echo -n "Checking Drupal homepage... "
curl -s -H "host: ${WODBY_HOST_PRIMARY}" "nginx" | grep -q "Drupal ${DRUPAL_VERSION} (https://www.drupal.org)"
echo "OK"
