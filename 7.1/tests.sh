#!/bin/bash

set -e

if [[ ! -z $DEBUG ]]; then
  set -x
fi

mkdir -p /tmp/.ssh
rm -f /tmp/.ssh/testkey
ssh-keygen -q -t dsa -N '' -f /tmp/.ssh/testkey
chmod 700 /tmp/.ssh
docker run -d -v /tmp/.ssh:/mnt/ssh --name=$NAME $REPO:$VERSION
docker ps | grep -q "$REPO:$VERSION"
docker exec --user=82 $NAME pwd | grep "/var/www/html"
docker exec --user=82 $NAME composer --version
docker exec --user=82 $NAME drush version
docker exec --user=82 $NAME drupal --version
docker exec --user=82 $NAME ssh -V
docker exec --user=82 $NAME rsync --version
docker exec --user=82 $NAME [ -f /home/www-data/.ssh/testkey ]
docker exec --user=82 $NAME [ -f /home/www-data/.ssh/testkey.pub ]
