#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

. ../../../test-images.env

docker-compose up -d
docker-compose exec mariadb make check-ready -f /usr/local/bin/actions.mk
docker-compose exec nginx make check-ready -f /usr/local/bin/actions.mk
docker-compose exec --user=82 php tests.sh
docker-compose down
