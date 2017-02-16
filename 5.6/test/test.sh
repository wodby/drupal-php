#!/usr/bin/env bash

set -ex

drush --version | grep 'Drush Version'
drupal --version | grep 'Drupal Console'
drush sa  | grep @default