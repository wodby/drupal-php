# PHP (FPM) for Drupal Docker Container Image 

[![Build Status](https://travis-ci.org/wodby/drupal-php.svg?branch=master)](https://travis-ci.org/wodby/drupal-php)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/drupal-php.svg)](https://hub.docker.com/r/wodby/drupal-php)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/drupal-php.svg)](https://hub.docker.com/r/wodby/drupal-php)
[![Wodby Slack](http://slack.wodby.com/badge.svg)](http://slack.wodby.com)

## Docker Images

Images are built via [Travis CI](https://travis-ci.org/wodby/drupal-php) and published on [Docker Hub](https://hub.docker.com/r/wodby/drupal-php). 

## Versions

See [wodby/php versions](https://github.com/wodby/php#versions)

## Environment Variables

| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| PHP_ALWAYS_POPULATE_RAW_POST_DATA | -1    | <= 5.6 |
| PHP_MBSTRING_ENCODING_TRANSLATION | Off   | <= 5.6 |
| PHP_MBSTRING_HTTP_INPUT           | pass  | <= 5.6 |
| PHP_MBSTRING_HTTP_OUTPUT          | pass  | <= 5.6 |
| PHP_OUTPUT_BUFFERING              | 16384 | |
| PHP_REALPATH_CACHE_SIZE           | 64k   | <= 5.6 |
| PHP_REALPATH_CACHE_TTL            | 3600  | |
| PHP_SESSION_AUTO_START            | 0     | <= 5.6 |

Also see [wodby/php](https://github.com/wodby/php)

## Complete Drupal Stack

To get full docker-based Drupal stack see [Docker4Drupal](https://github.com/wodby/docker4drupal).
