# PHP docker container image for Drupal

[![Build Status](https://travis-ci.org/wodby/drupal-php.svg?branch=master)](https://travis-ci.org/wodby/drupal-php)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/drupal-php.svg)](https://hub.docker.com/r/wodby/drupal-php)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/drupal-php.svg)](https://hub.docker.com/r/wodby/drupal-php)
[![Wodby Slack](http://slack.wodby.com/badge.svg)](http://slack.wodby.com)

To get full docker-based environment for Drupal see [Docker4Drupal](http://docker4drupal.org)

## Supported tags and respective `Dockerfile` links

- [`7.1-2.3.0`, `7.1`, `latest` (*7.1/Dockerfile*)](https://github.com/wodby/drupal-php/tree/master/7.1/Dockerfile)
- [`7.0-2.3.0`, `7.0`, (*7.0/Dockerfile*)](https://github.com/wodby/drupal-php/tree/master/7.0/Dockerfile)
- [`5.6-2.3.0`, `5.6`, (*5.6/Dockerfile*)](https://github.com/wodby/drupal-php/tree/master/5.6/Dockerfile)
- [`5.3-2.3.0`, `5.3`, (*5.3/Dockerfile*)](https://github.com/wodby/drupal-php/tree/master/5.3/Dockerfile)

## Environment variables available for customization

| Environment Variable | Default Value | Description |
| -------------------- | ------------- | ----------- |
| PHP_SESSION_COOKIE_LIFETIME | 2000000 | |
| PHP_SESSION_GC_MAXLIFETIME  | 2000000 | |
| PHP_REALPATH_CACHE_SIZE     | 64k     | <= 5.6 |
| PHP_REALPATH_CACHE_TTL      | 3600    | |
| PHP_OUTPUT_BUFFERING        | 16384   | |
| PHP_MBSTRING_HTTP_INPUT     | pass    | 5.6 |
| PHP_MBSTRING_HTTP_OUTPUT    | pass    | 5.6 |

See more at [wodby/php](https://github.com/wodby/php)

## Using in production

Deploy docker-based infrastructure for Drupal to your own server via [![Wodby](https://www.google.com/s2/favicons?domain=wodby.com) Wodby](https://wodby.com).
