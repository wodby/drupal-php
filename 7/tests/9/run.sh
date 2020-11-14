#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

check_ready() {
    docker-compose exec -T "${1}" make check-ready "${@:2}" -f /usr/local/bin/actions.mk
}

docker-compose up -d

check_ready nginx max_try=10
check_ready php max_try=10
check_ready mariadb max_try=12 wait_seconds=5

# Fix php volumes permissions again
# Docker sets ephemeral shared volume ownership to default user (wodby) in nginx container (started after php)
# In case of -dev-macos version of php images wodby owner uid/gid in php and nginx containers do not match
if [[ "${IMAGE}" =~ "-dev-macos" ]]; then
    docker-compose exec -T php sudo init_container
fi

docker-compose exec -T --user=0 php apk add --update jq grep
docker-compose exec -T php tests.sh
docker-compose down
