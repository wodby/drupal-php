#!/usr/bin/env bash

set -e

if [[ "${GITHUB_REF}" == refs/heads/master || "${GITHUB_REF}" == refs/tags/* ]]; then
    docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"

    if [[ "${GITHUB_REF}" == refs/tags/* ]]; then
      export STABILITY_TAG="${GITHUB_REF##*/}"
    fi

    IFS=',' read -ra tags <<< "${TAGS}"

    for tag in "${tags[@]}"; do
        make buildx-push TAG="${tag}";
    done

    docker login -u "${WODBY1_REGISTRY_USERNAME}" -p "${WODBY1_REGISTRY_PASSWORD}" registry.wodby.com

    for tag in "${tags[@]}"; do
        make buildx-push TAG="${tag}" REGISTRY="registry.wodby.com";
    done
fi
