#!/usr/bin/env bash

set -ex

make start

docker exec --user=82 $NAME drush --version | grep "Drush Version"
docker exec --user=82 $NAME drupal --version | grep "Drupal Console"

make clean