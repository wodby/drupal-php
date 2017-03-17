#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

GIT_URL=git@bitbucket.org:wodby/php-git-test.git

. ../../../test-images.env

DRUPAL_VERSION=8
DRUSH_ARCHIVE_URL="https://s3-us-west-1.amazonaws.com/wodby-presets/drupal${DRUPAL_VERSION}/wodby-drupal${DRUPAL_VERSION}-latest.tar.gz"
FILES_ARCHIVE_URL=https://s3.amazonaws.com/wodby-sample-files/drupal-php-import-test/files.tar.gz

dockerExec() {
    docker-compose exec --user=82 "${@}"
}

phpAction() {
    docker-compose exec php su-exec www-data make "${@}" -f /usr/local/bin/actions.mk
}

docker-compose up -d
docker-compose exec mariadb make check-ready -f /usr/local/bin/actions.mk
docker-compose exec nginx make check-ready -f /usr/local/bin/actions.mk

dockerExec php bash -c 'echo -e "Host bitbucket.org\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config'
phpAction git-clone url="${GIT_URL}" branch=master
phpAction drush-import source="${DRUSH_ARCHIVE_URL}"
phpAction files-import source="${FILES_ARCHIVE_URL}"
phpAction cache-clear target=render
phpAction cache-rebuild
dockerExec php tests.sh

docker-compose down
