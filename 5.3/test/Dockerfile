FROM wodby/drupal-php:5.3

COPY ./test.sh /usr/local/bin/run-tests

CMD ["su-exec", "www-data", "run-tests"]