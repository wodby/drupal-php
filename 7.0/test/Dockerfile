FROM wodby/drupal-php:7.0

COPY ./test.sh /usr/local/bin/run-tests

CMD ["su-exec", "www-data", "run-tests"]