FROM wodby/php:5.3

    # Install Drupal Console
RUN su-exec www-data composer global require drupal/console && \
    su-exec www-data drupal init && \

    # Install drush
    su-exec www-data composer global require drush/drush

# Add default drush aliases
RUN mkdir -p /etc/drush/site-aliases
COPY default.aliases.drushrc.php /etc/drush/site-aliases/
