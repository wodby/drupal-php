#!/usr/bin/env bash
# Run from any directory; stub image commands to verify lifecycle side effects.
set -euo pipefail
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
export CONF_DIR="$fixture" FILES_DIR="$fixture/files" DRUPAL_VERSION=11
export DRUPAL_FILES_SYNC_SALT=fixture DEBUG='' INIT_LOG="$fixture/storage-init"
gotpl() { printf 'rendered configuration\n'; }
sudo() { printf '%s\n' "$*" >> "$INIT_LOG"; }
script="$(cd "$(dirname "$0")/.." && pwd)/init/10_drupal_php.sh"
WODBY_RUNTIME_CONFIGURATION_ONLY=1 source "$script"
test -s "$CONF_DIR/wodby.settings.php"
test ! -e "$INIT_LOG"
source "$script"
grep -q init_container "$INIT_LOG"
