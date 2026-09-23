#!/usr/bin/env bash
# Run without Drupal installed; real Git tracking rules guard all mutations.
set -euo pipefail
script="$(cd "$(dirname "$0")/.." && pwd)/bin/init_drupal"
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
export APP_ROOT="$fixture" DRUPAL_ROOT="$fixture/web" DRUPAL_SITE=default
export DRUPAL_SITE_DIR="$DRUPAL_ROOT/sites/default" CONF_DIR=/var/www/conf FILES_DIR="$fixture/uploads" WODBY_WORKSPACE=1 DEBUG=''
mkdir -p "$DRUPAL_SITE_DIR" "$fixture/bin"
printf '#!/bin/sh\n[ -L "$1" ] || ln -s "$FILES_DIR/public" "$1"\n' > "$fixture/bin/files_link"
chmod +x "$fixture/bin/files_link"
export PATH="$fixture/bin:$PATH"
git -C "$fixture" init -q
printf '<?php\n// customer settings\n' > "$DRUPAL_SITE_DIR/settings.php"
printf 'web/sites/default/files\n' > "$fixture/.gitignore"
git -C "$fixture" add .gitignore web/sites/default/settings.php
before=$(git -C "$fixture" diff --binary)
if bash "$script" > "$fixture/error" 2>&1; then echo 'Modified tracked settings' >&2; exit 1; fi
test "$before" = "$(git -C "$fixture" diff --binary)"
test ! -L "$DRUPAL_SITE_DIR/files"
grep -q 'Add the required Wodby settings include' "$fixture/error"
# Explicitly configured tracked settings are left byte-for-byte unchanged.
printf "<?php\ninclude '/var/www/conf/wodby.settings.php';\n" > "$DRUPAL_SITE_DIR/settings.php"
git -C "$fixture" add web/sites/default/settings.php
bash "$script"
test -z "$(git -C "$fixture" diff --binary)"
# Missing settings can be generated only when ignored and untracked.
git -C "$fixture" rm --cached -q web/sites/default/settings.php
rm "$DRUPAL_SITE_DIR/settings.php"
if bash "$script" > "$fixture/error" 2>&1; then echo 'Generated visible settings' >&2; exit 1; fi
printf 'web/sites/default/settings.php\n' >> "$fixture/.gitignore"
bash "$script"
grep -q wodby.settings.php "$DRUPAL_SITE_DIR/settings.php"
# Tracked upload placeholders must never be removed, even if .gitignored.
rm "$DRUPAL_SITE_DIR/files"
mkdir "$DRUPAL_SITE_DIR/files"
printf '*' > "$DRUPAL_SITE_DIR/files/.gitignore"
git -C "$fixture" add -f web/sites/default/files/.gitignore
if bash "$script" > "$fixture/error" 2>&1; then echo 'Replaced tracked uploads' >&2; exit 1; fi
test -f "$DRUPAL_SITE_DIR/files/.gitignore"
