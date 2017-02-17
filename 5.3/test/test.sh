#!/usr/bin/env bash

set -ex

drush --version | grep 'Drush Version'
drush sa  | grep @default