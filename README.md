# PHP (FPM) for Drupal Docker Container Image

[![Build Status](https://github.com/wodby/drupal-php/workflows/Build%20docker%20image/badge.svg)](https://github.com/wodby/drupal-php/actions)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/drupal-php.svg)](https://hub.docker.com/r/wodby/drupal-php)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/drupal-php.svg)](https://hub.docker.com/r/wodby/drupal-php)

## Docker Images

Use image revision tags such as `wodby/drupal-php:8.5-rN` to select a Wodby image revision.
Major and minor tags use the repository release number, starting at `r0`. Full-version tags such as
`wodby/drupal-php:8.5.10-r0` start at `r0` for each exact upstream version.
Every published versioned revision tag has a matching annotated Git tag pointing to its release commit.
Existing tags remain available after support for their major or minor version ends.
See [release tags](https://github.com/wodby/drupal-php/tags) for available revisions and the [image revision policy](https://github.com/wodby/images#image-revisions) for upgrade guidance.
Previously published image tags remain available.

Overview:

- All images are based on Alpine Linux
- Base image: [wodby/php](https://github.com/wodby/php)
- [GitHub actions builds](https://github.com/wodby/drupal-php/actions)
- [Docker Hub](https://hub.docker.com/r/wodby/drupal-php)

Supported tags and respective `Dockerxfile` links:

- `8.5`, `8`, `latest`  [_(Dockerfile)_]
- `8.4` [_(Dockerfile)_]
- `8.3` [_(Dockerfile)_]
- `8.2` [_(Dockerfile)_]
- `8.5-dev`, `8-dev`, `dev` [_(Dockerfile)_]
- `8.4-dev` [_(Dockerfile)_]
- `8.3-dev` [_(Dockerfile)_]
- `8.2-dev` [_(Dockerfile)_]
- `8.5-dev-macos`, `8-dev-macos`, `dev-macos` [_(Dockerfile)_]
- `8.4-dev-macos` [_(Dockerfile)_]
- `8.3-dev-macos` [_(Dockerfile)_]
- `8.2-dev-macos` [_(Dockerfile)_]

See [wodby/php](https://github.com/wodby/php) for the exact PHP version

All images built for `linux/amd64` and `linux/arm64`

## Environment Variables

| Variable                         | Default Value | Description                                                                     |
|----------------------------------|---------------|---------------------------------------------------------------------------------|
| `DRUPAL_REVERSE_PROXY_ADDRESSES` |               |                                                                                 |
| `DRUPAL_PHP_STORAGE_DIR`         |               | Sets the default storage dir for generated PHP code (i.e. Twig)                 |
| `PHP_OUTPUT_BUFFERING`           | `16384`       |                                                                                 |
| `PHP_REALPATH_CACHE_TTL`         | `3600`        |                                                                                 |
| `DRUPAL_VERSION`                 |               |                                                                                 |
| `DRUPAL7_INSTALL_GLOBAL_DRUSH`   |               | Installs global drush 7.* during entrypoint, works only with `DRUPAL_VERSION=7` |

See [wodby/php](https://github.com/wodby/php) for all variables

## Orchestration Actions

Usage:
```
make COMMAND [params ...]

commands:
    git-checkout target [ is_hash]
    drush-import source
    init-drupal
    cache-clear target
    cache-rebuild
    drush8-alias
    drush9-alias
    user-login

default params values:
    target all
    is_hash 0
```

See [wodby/php](https://github.com/wodby/php) for all actions

## Aggregate file permissions

At startup and after files imports, the image prepares `${FILES_DIR}/public/css` and
`${FILES_DIR}/public/js` with ownership `www-data:www-data` and mode `0775`. This allows
PHP-FPM to create aggregates and the `wodby` user running Drush to delete them during
cache rebuilds, including when an import supplied directories with mode `0755`.

Only these two directories are adjusted; existing files and other upload directories
retain their permissions. Custom symlinked directories and a separately configured
Drupal `file_assets_path` remain the application's responsibility. Explicit Drupal
permission overrides can still affect directories recreated by Drupal.

## Complete Drupal Stack

See [wodby/docker4drupal](https://github.com/wodby/docker4drupal)

[_(Dockerfile)_]: https://github.com/wodby/drupal-php/tree/master/Dockerfile

[Drupal Console Launcher]: https://drupalconsole.com

## Building with pinned base images

Build with the Makefile to use the base image digests in `base-images.mk`. Local
builds and CI resolve the same version and variant to the same multi-platform
image. A version without a pin fails before the build starts.

When adding a supported base version or variant, add its image index digest to
`base-images.mk`. For a custom build, override `BASE_IMAGE` with a complete
`repository:tag@sha256:...` reference.

### Workspace preparation and Git

With `WODBY_WORKSPACE=1`, initialization preflights settings and upload paths before
changing the checkout. It refuses to append configuration to tracked settings or
replace tracked upload files. Generated settings must be ignored and untracked;
ignoring an already tracked file alone is insufficient.

For tracked settings, add the bootstrap include deliberately and commit it with
application configuration. For example, in `settings.php`:

```php
$wodbyConfig = (getenv('CONF_DIR') ?: '/var/www/conf') . '/wodby.settings.php';
if (is_file($wodbyConfig)) {
    include $wodbyConfig;
}
```

Multisite projects need the equivalent `wodby.sites.php` include in `sites/sites.php`.
Keep uploaded files and generated local settings out of Git. Retry preparation after
fixing the reported paths. Standard initialization retains its existing behavior.
Dependency managers and project scripts can still change source files; inspect the
Git diff before committing. Inherited workspace support requires a PHP base image
that declares workspace contract version 1.
