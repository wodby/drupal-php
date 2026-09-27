#!/usr/bin/env bash
# Run without Drupal installed; real Git tracking rules guard all mutations.
set -euo pipefail
script="$(cd "$(dirname "$0")/.." && pwd)/bin/init_drupal"
fixture=$(mktemp -d)
outside=$(mktemp -d)
trap 'rm -rf "$fixture" "$outside"' EXIT
export APP_ROOT="$fixture" DRUPAL_ROOT="$fixture/web" DRUPAL_SITE=default
export DRUPAL_SITE_DIR="$DRUPAL_ROOT/sites/default" CONF_DIR=/var/www/conf FILES_DIR="$fixture/uploads" WODBY_WORKSPACE=1 DEBUG=''
settings="$DRUPAL_SITE_DIR/settings.php"
mkdir -p "$DRUPAL_SITE_DIR" "$fixture/bin"
printf '#!/bin/sh\n[ -L "$1" ] || ln -s "$FILES_DIR/public" "$1"\n' > "$fixture/bin/files_link"
chmod +x "$fixture/bin/files_link"
export PATH="$fixture/bin:$PATH"
git -C "$fixture" init -q
printf '<?php\n// customer settings\n' > "$settings"
printf 'web/sites/*/files\n' > "$fixture/.gitignore"
git -C "$fixture" add .gitignore web/sites/default/settings.php

# PHP checks run where PHP is installed, such as CI and the image itself.
php_check() {
    if command -v php >/dev/null; then php -l "$1" >/dev/null; fi
}

# Tracked settings get an include that is skipped outside Wodby, as a change to commit.
bash "$script"
test -L "$DRUPAL_SITE_DIR/files"
grep -q '// customer settings' "$settings"
grep -Fq "\$wodbyConfig = (getenv('CONF_DIR') ?: '/var/www/conf') . '/wodby.settings.php';" "$settings"
grep -Fq 'if (is_file($wodbyConfig)) {' "$settings"
test "$(git -C "$fixture" diff --numstat | cut -f1-2)" = "$(printf '6\t0')"
php_check "$settings"
if command -v php >/dev/null; then
    conf=$(mktemp -d "$outside/conf.XXXXXX")
    printf '<?php\n$settings["wodby"] = TRUE;\n' > "$conf/wodby.settings.php"
    test "$(CONF_DIR="$conf" php -r 'include $argv[1]; echo empty($settings["wodby"]) ? "skipped" : "included";' "$settings")" = included
    test "$(CONF_DIR="$outside/missing" php -r 'include $argv[1]; echo empty($settings["wodby"]) ? "skipped" : "included";' "$settings")" = skipped
fi

# Running setup again changes nothing.
before=$(git -C "$fixture" diff --binary)
bash "$script"
test "$before" = "$(git -C "$fixture" diff --binary)"

# Explicitly configured tracked settings are left byte-for-byte unchanged.
printf "<?php\ninclude '/var/www/conf/wodby.settings.php';\n" > "$settings"
git -C "$fixture" add web/sites/default/settings.php
bash "$script"
test -z "$(git -C "$fixture" diff --binary)"

# Missing settings are created from default.settings.php, tracked or not.
git -C "$fixture" rm --cached -q web/sites/default/settings.php
rm "$settings"
printf '<?php\n// Drupal defaults\n' > "$DRUPAL_SITE_DIR/default.settings.php"
bash "$script"
grep -q '// Drupal defaults' "$settings"
grep -Fq 'include $wodbyConfig;' "$settings"
php_check "$settings"

# Multisite projects get the same guarded include in sites.php.
DRUPAL_SITE=example DRUPAL_SITE_DIR="$DRUPAL_ROOT/sites/example" bash "$script"
grep -Fq "\$wodbySites = (getenv('CONF_DIR') ?: '/var/www/conf') . '/wodby.sites.php';" "$DRUPAL_ROOT/sites/sites.php"
grep -Fq 'include $wodbyConfig;' "$DRUPAL_ROOT/sites/example/settings.php"
php_check "$DRUPAL_ROOT/sites/sites.php"

# Settings linked outside the checkout are never changed.
rm "$settings"
printf '<?php\n' > "$outside/settings.php"
ln -s "$outside/settings.php" "$settings"
if bash "$script" > "$fixture/error" 2>&1; then echo 'Modified settings outside the checkout' >&2; exit 1; fi
grep -q 'outside the checkout' "$fixture/error"
test "$(cat "$outside/settings.php")" = '<?php'
rm "$settings"
printf '<?php\n' > "$settings"

# Tracked upload placeholders must never be removed, even if .gitignored, and
# settings stay unchanged when setup stops.
rm "$DRUPAL_SITE_DIR/files"
mkdir "$DRUPAL_SITE_DIR/files"
printf '*' > "$DRUPAL_SITE_DIR/files/.gitignore"
git -C "$fixture" add -f web/sites/default/files/.gitignore
if bash "$script" > "$fixture/error" 2>&1; then echo 'Replaced tracked uploads' >&2; exit 1; fi
grep -q 'link to the files volume' "$fixture/error"
test -f "$DRUPAL_SITE_DIR/files/.gitignore"
test "$(cat "$settings")" = '<?php'
