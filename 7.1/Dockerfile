FROM wodby/php:7.1-2.0.0

    # Install Drupal Console
RUN su-exec www-data composer global require drupal/console && \
    su-exec www-data drupal init && \

    # Install drush
    su-exec www-data composer global require drush/drush && \

    su-exec www-data composer clear-cache
