FROM wodby/php:5.3

    # Install drush
RUN su-exec www-data composer global require drush/drush:7.2.0 && \

    su-exec www-data composer clear-cache

# Add default drush aliases
RUN mkdir -p /etc/drush/site-aliases
COPY default.aliases.drushrc.php /etc/drush/site-aliases/
