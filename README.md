# PHP (FPM) for Drupal Docker Container Image 

[![Build Status](https://github.com/wodby/drupal-php/workflows/Build%20docker%20image/badge.svg)](https://github.com/wodby/drupal-php/actions)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/drupal-php.svg)](https://hub.docker.com/r/wodby/drupal-php)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/drupal-php.svg)](https://hub.docker.com/r/wodby/drupal-php)
[![Docker Layers](https://images.microbadger.com/badges/image/wodby/drupal-php.svg)](https://microbadger.com/images/wodby/drupal-php)

## Docker Images

❗For better reliability we release images with stability tags (`wodby/drupal-php:8.0-X.X.X`) which correspond to [git tags](https://github.com/wodby/drupal-php/releases). We strongly recommend using images only with stability tags. 

Overview:

- All images based on Alpine Linux
- Base image: [wodby/php](https://github.com/wodby/php)
- [GitHub actions builds](https://github.com/wodby/drupal-php/actions) 
- [Docker Hub](https://hub.docker.com/r/wodby/drupal-php)

Supported tags and respective `Dockerfile` links:

- `8.0`, `8`, `latest`  [_(Dockerfile)_]
- `7.4`, `7` [_(Dockerfile)_]
- `7.3` [_(Dockerfile)_]
- `8.0-dev`, `8-dev`, `dev` [_(Dockerfile)_]
- `7.4-dev`, `7-dev` [_(Dockerfile)_]
- `7.3-dev` [_(Dockerfile)_]
- `8.0-dev-macos`, `8-dev-macos`, `dev-macos` [_(Dockerfile)_]
- `7.4-dev-macos`, `7-dev-macos` [_(Dockerfile)_]
- `7.3-dev-macos` [_(Dockerfile)_]

See [wodby/php](https://github.com/wodby/php) for the exact PHP version

## Tools

| Tool                       | 8.0     | 7.4     | 7.3     |
| -------------------------- | ------- | ------- | ------- |
| [Drupal Console Launcher]  | 1.9.7   | 1.9.7   | 1.9.7   |
| [Drush]                    | latest  | 8.x     | 8.x     |
| [Drush Launcher]           | -       | 0.7.4   | 0.7.4   |
| [Drush Patchfile]          | latest  | latest  | latest  |
| [Drush Registry Rebuild]   | 7.x     | 7.x     | 7.x     |

## Environment Variables

| Variable                            | Default Value | Description |
| ----------------------------------- | ------------- | ----------- |
| `DRUPAL_REVERSE_PROXY_ADDRESSES`    |               |             |
| `PHP_OUTPUT_BUFFERING`              | `16384`       |             |
| `PHP_REALPATH_CACHE_TTL`            | `3600`        |             |

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

## Complete Drupal Stack

See [wodby/docker4drupal](https://github.com/wodby/docker4drupal)

[_(Dockerfile)_]: https://github.com/wodby/drupal-php/tree/master/Dockerfile

[Drupal Console Launcher]: https://drupalconsole.com
[Drush]: https://packagist.org/packages/drush/drush
[Drush Launcher]: https://github.com/drush-ops/drush-launcher
[Drush Patchfile]: https://bitbucket.org/davereid/drush-patchfile
[Drush Registry Rebuild]: https://www.drupal.org/project/registry_rebuild
