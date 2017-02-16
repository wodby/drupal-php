FROM wodby/drupal-php:7.1

COPY ./test.sh /usr/local/bin/run-tests

CMD ["su-exec", "www-data", "run-tests"]