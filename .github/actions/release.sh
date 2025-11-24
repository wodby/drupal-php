#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

if [[ "${GITHUB_REF}" == refs/heads/master || "${GITHUB_REF}" == refs/tags/* ]]; then      
  minor_ver="${PHP_VER}"
  minor_tag="${minor_ver}"
  major_tag="${minor_ver%.*}"

  if [[ -n "${PHP_DEV}" ]]; then            
    minor_tag="${minor_tag}-dev"
    if [[ -n "${LATEST_MAJOR}" ]]; then
      major_tag="${major_tag}-dev"
    fi
  elif [[ -n "${PHP_DEV_MACOS}" ]]; then
    minor_tag="${minor_tag}-dev-macos"
    if [[ -n "${LATEST_MAJOR}" ]]; then
      major_tag="${major_tag}-dev-macos"
    fi
  fi

  tags=("${minor_tag}")
  if [[ -n "${LATEST_MAJOR}" ]]; then
     tags+=("${major_tag}")
  fi

  if [[ "${GITHUB_REF}" == refs/tags/* ]]; then
    stability_tag="${GITHUB_REF##*/}"
    tags=("${minor_tag}-${stability_tag}")
    if [[ -n "${LATEST_MAJOR}" ]]; then
      tags+=("${major_tag}-${stability_tag}")
    fi
  else          
    if [[ -n "${LATEST}" ]]; then
      if [[ -n "${PHP_DEV}" ]]; then
        tags+=("dev")
      elif [[ -n "${PHP_DEV_MACOS}" ]]; then
        tags+=("dev-macos")
      else
        tags+=("latest")
      fi
    fi
  fi

  for tag in "${tags[@]}"; do
    make buildx-imagetools-create IMAGETOOLS_TAG=${tag}
  done
fi