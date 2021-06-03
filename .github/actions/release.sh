#!/usr/bin/env bash

set -e

username="${1}"
password="${2}"
registry="${3}"

if [[ "${GITHUB_REF}" == refs/heads/master || "${GITHUB_REF}" == refs/tags/* ]]; then
    docker login -u "${username}" -p "${password}" ${registry}

    if [[ "${GITHUB_REF}" == refs/tags/* ]]; then
      export STABILITY_TAG="${GITHUB_REF##*/}"
    fi

    IFS=',' read -ra tags <<< "${TAGS}"

    for tag in "${tags[@]}"; do
        make buildx-push TAG="${tag}" REGISTRY=${registry};
    done
fi
