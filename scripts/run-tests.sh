#!/bin/bash

set -ev

docker ps | grep -q php
docker run --user=82 php php -v | grep "PHP $TEST_PHP"
docker run --user=82 php pwd | grep "/var/www/html"
docker run --user=82 php composer --version | grep "1.2.1"
docker run --user=82 php drush version | grep "8.1.5"
docker run --user=82 php drupal --version | grep "1.0.0-rc5"
