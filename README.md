# PHP (FPM) for Drupal Docker Container Image 

[![Build Status](https://travis-ci.org/wodby/drupal-php.svg?branch=master)](https://travis-ci.org/wodby/drupal-php)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/drupal-php.svg)](https://hub.docker.com/r/wodby/drupal-php)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/drupal-php.svg)](https://hub.docker.com/r/wodby/drupal-php)
[![Docker Layers](https://images.microbadger.com/badges/image/wodby/drupal-php.svg)](https://microbadger.com/images/wodby/drupal-php)

## Docker Images

❗For better reliability we release images with stability tags (`wodby/drupal-php:7.3-X.X.X`) which correspond to [git tags](https://github.com/wodby/drupal-php/releases). We strongly recommend using images only with stability tags. 

Overview:

* All images are based on Alpine Linux
* Base image: [wodby/php](https://github.com/wodby/php)
* [Travis CI builds](https://travis-ci.org/wodby/drupal-php) 
* [Docker Hub](https://hub.docker.com/r/wodby/drupal-php)

Supported tags and respective `Dockerfile` links:

* `7.3`, `7`, `latest`  [_(7/Dockerfile)_]
* `7.2` [_(7/Dockerfile)_]
* `7.1` [_(7/Dockerfile)_]
* `5.6`, `5` [_(5.6/Dockerfile)_]
* `7.3-dev`, `7-dev`, `dev` [_(7/Dockerfile)_]
* `7.2-dev` [_(7/Dockerfile)_]
* `7.1-dev` [_(7/Dockerfile)_]
* `5.6-dev`, `5-dev` [_(5.6/Dockerfile)_]
* `7.3-dev-macos`, `7-dev-macos`, `dev-macos` [_(7/Dockerfile)_]
* `7.2-dev-macos` [_(7/Dockerfile)_]
* `7.1-dev-macos` [_(7/Dockerfile)_]
* `5.6-dev-macos`, `5-dev-macos` [_(5.6/Dockerfile)_]

See [wodby/php](https://github.com/wodby/php) for the exact PHP version

## Tools

| Tool                       | 7.3     | 7.2     | 7.1     | 5.6     |
| -------------------------- | ------- | ------- | ------- | ------- |
| [Drupal Console Launcher]  | 1.8.0   | 1.8.0   | 1.8.0   | -       |
| [Drush]                    | 8.x     | 8.x     | 8.x     | 8.x     |
| [Drush Launcher]           | 0.6.0   | 0.6.0   | 0.6.0   | 0.6.0   |
| [Drush Patchfile]          | latest  | latest  | latest  | latest  |
| [Drush Registry Rebuild]   | 7.x     | 7.x     | 7.x     | 7.x     |

## Environment Variables

| Variable                            | Default Value | Description |
| ----------------------------------- | ------------- | ----------- |
| `DRUPAL8_REVERSE_PROXY_ADDRESSES`   |               |             |
| `PHP_ALWAYS_POPULATE_RAW_POST_DATA` | `-1`          | <= 5.6      |
| `PHP_MBSTRING_ENCODING_TRANSLATION` | `Off`         | <= 5.6      |
| `PHP_MBSTRING_HTTP_INPUT`           | `pass`        | <= 5.6      |
| `PHP_MBSTRING_HTTP_OUTPUT`          | `pass`        | <= 5.6      |
| `PHP_OUTPUT_BUFFERING`              | `16384`       |             |
| `PHP_REALPATH_CACHE_SIZE`           | `64k`         | <= 5.6      |
| `PHP_REALPATH_CACHE_TTL`            | `3600`        |             |
| `PHP_SESSION_AUTO_START`            | `0`           | <= 5.6      |

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
    
default params values:
    target all
    is_hash 0 
```

See [wodby/php](https://github.com/wodby/php) for all actions

## Complete Drupal Stack

See [wodby/docker4drupal](https://github.com/wodby/docker4drupal)

[_(7/Dockerfile)_]: https://github.com/wodby/drupal-php/tree/master/7/Dockerfile
[_(5.6/Dockerfile)_]: https://github.com/wodby/drupal-php/tree/master/5.6/Dockerfile

[Drupal Console Launcher]: https://drupalconsole.com
[Drush]: https://packagist.org/packages/drush/drush
[Drush Launcher]: https://github.com/drush-ops/drush-launcher
[Drush Patchfile]: https://bitbucket.org/davereid/drush-patchfile
[Drush Registry Rebuild]: https://www.drupal.org/project/registry_rebuild
