FROM alpine:3.4
MAINTAINER Wodby <admin@wodby.com>

# Create user www-data
RUN addgroup -g 82 -S www-data && \
    adduser -u 82 -D -S -G www-data www-data

# Install packages
RUN echo '@edge http://nl.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories && \
    echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \

    apk add --update \

        # Base packages
        openssl \
        ca-certificates \
        git \
        curl \
        wget \
        perl \
        pcre \
        imap \
        imagemagick \
        mariadb-client \
        ssmtp \

        # Temp packages
        build-base \
        autoconf \
        libtool \
        php5-dev \
        pcre-dev \
        imagemagick-dev \

        # PHP packages
        php5@edge \
        php5-common@edge \
        php5-cli@edge \
        php5-fpm@edge \
        php5-opcache@edge \
        php5-xml@edge \
        php5-ctype@edge \
        php5-ftp@edge \
        php5-gd@edge \
        php5-json@edge \
        php5-posix@edge \
        php5-curl@edge \
        php5-dom@edge \
        php5-pdo@edge \
        php5-pdo_mysql@edge \
        php5-sockets@edge \
        php5-zlib@edge \
        php5-mcrypt@edge \
        php5-pcntl@edge \
        php5-mysql@edge \
        php5-mysqli@edge \
        php5-bz2@edge \
        php5-pear@edge \
        php5-exif@edge \
        php5-phar@edge \
        php5-openssl@edge \
        php5-posix@edge \
        php5-zip@edge \
        php5-calendar@edge \
        php5-iconv@edge \
        php5-imap@edge \
        php5-soap@edge \
        php5-memcache \
        php5-redis@testing \
        php5-xdebug@testing && \

    # Replace sendmail by ssmtp
    ln -sf /usr/sbin/ssmtp /usr/sbin/sendmail && \
    echo "www-data:app:smtp:1025" >> /etc/ssmtp/revaliases && \

    # Install uploadprogress and imagick
    sed -ie 's/-n//g' /usr/bin/pecl && \
    yes | pecl install uploadprogress && \
    yes | pecl install imagick && \
    echo 'extension=imagick.so' > /etc/php5/conf.d/imagick.ini && \
    echo 'extension=uploadprogress.so' > /etc/php5/conf.d/uploadprogress.ini && \
    rm -rf /tmp/pear && \

    # Install composer
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \

    # Add composer parallel install plugin
    composer global require "hirak/prestissimo:^0.3" && \

    # Install drush
    git clone https://github.com/drush-ops/drush.git /usr/local/src/drush && \
    ln -sf /usr/local/src/drush/drush /usr/bin/drush && \
    ls -la /usr/local/src/drush && \
    (cd /usr/local/src/drush; composer install) && \
    rm -rf /usr/local/src/drush/.git && \

    # Cleanup
    apk del --purge *-dev build-base autoconf libtool && \
    rm -rf /usr/include/php /usr/lib/php/build && \
    rm -rf /var/cache/apk/*

# Configure php.ini
RUN sed -i \
        -e "s/^expose_php.*/expose_php = Off/" \
        -e "s/^;date.timezone.*/date.timezone = UTC/" \
        -e "s/^memory_limit.*/memory_limit = -1/" \
        -e "s/^max_execution_time.*/max_execution_time = 300/" \
        -e "s/^post_max_size.*/post_max_size = 512M/" \
        -e "s/^upload_max_filesize.*/upload_max_filesize = 512M/" \
        -e "s/^;always_populate_raw_post_data.*/always_populate_raw_post_data = -1/" \
        -e "s/^error_reporting.*/error_reporting = E_ALL/" \
        -e "s/^display_errors.*/display_errors = On/" \
        -e "s/^display_startup_errors.*/display_startup_errors = On/" \
        -e "s/^track_errors.*/track_errors = On/" \
        -e "s/^mysqlnd.collect_memory_statistics.*/mysqlnd.collect_memory_statistics = On/" \
        /etc/php5/php.ini && \

    echo "error_log = \"/proc/self/fd/2\"" | tee -a /etc/php5/php.ini

COPY opcache.ini /etc/php5/conf.d/
COPY xdebug.ini /etc/php5/conf.d/
COPY php-fpm.conf /etc/php5/

# Create work dir
RUN mkdir -p /var/www/html && chown -R 82:82 /var/www
WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 9000

CMD ["php-fpm"]
