FROM alpine:3.4
MAINTAINER Wodby <admin@wodby.com>

ENV PHP_UPLOADPROGRESS_VERSION=0.1.0

RUN echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    apk add --no-cache \
        openssl \
        ca-certificates \
        build-base \
        autoconf \
        libtool \
        pcre-dev \
        imagemagick \
        git \
        curl \
        tar \
        php7@testing \
        php7-fpm@testing \
        php7-opcache@testing \
        php7-xml@testing \
        php7-ctype@testing \
        php7-ftp@testing \
        php7-gd@testing \
        php7-json@testing \
        php7-posix@testing \
        php7-curl@testing \
        php7-dom@testing \
        php7-pdo@testing \
        php7-pdo_mysql@testing \
        php7-sockets@testing \
        php7-zlib@testing \
        php7-mcrypt@testing \
        php7-mysqli@testing \
        php7-bz2@testing \
        php7-phar@testing \
        php7-openssl@testing \
        php7-posix@testing \
        php7-zip@testing \
        php7-calendar@testing \
        php7-iconv@testing \
        php7-imap@testing \
        php7-soap@testing \
        php7-dev@testing \
        php7-pear@testing \
        php7-redis@testing \
        php7-mbstring@testing \
        php7-xdebug@testing \
        php7-memcached@testing \
        php7-exif@testing

# Create symlinks for backward compatibility
RUN ln -sf /usr/bin/php7 /usr/bin/php && \
    ln -sf /usr/sbin/php-fpm7 /usr/bin/php-fpm

# Install composer
RUN curl -sS https://getcomposer.org/installer | php7 -- --install-dir=/usr/local/bin --filename=composer

# Install drush
RUN git clone https://github.com/drush-ops/drush.git /usr/local/src/drush && \
    cd /usr/local/src/drush && \
    ln -sf /usr/local/src/drush/drush /usr/bin/drush && \
    composer install && rm -rf ./.git

# Install uploadprogess
RUN wget -qO- https://s3.amazonaws.com/wodby-releases/uploadprogress/v${PHP_UPLOADPROGRESS_VERSION}/php7-uploadprogress.tar.gz | tar xz -C /tmp/ && \
    cd /tmp/uploadprogress-${PHP_UPLOADPROGRESS_VERSION} && \
    phpize7 && ./configure --with-php-config=/usr/bin/php-config7 && \
    make && make install && \
    echo 'extension=uploadprogress.so' > /etc/php7/conf.d/20_uploadprogress.ini

# Cleanup
RUN apk del --no-cache --purge *-dev build-base autoconf libtool tar git && \
    rm -rf /usr/include/php7 /usr/lib/php7/build /usr/lib/php7/modules/*.a && \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/man

# Create user www-data
RUN addgroup -g 82 -S www-data && \
	adduser -u 82 -D -S -G www-data www-data

# Init php config and files
RUN sed -i \
        -e "s/^expose_php.*/expose_php = Off/" \
        -e "s/^;date.timezone.*/date.timezone = UTC/" \
        -e "s/^memory_limit.*/memory_limit = -1/" \
        -e "s/^max_execution_time.*/max_execution_time = 300/" \
        -e "s/^post_max_size.*/post_max_size = 512M/" \
        -e "s/^upload_max_filesize.*/upload_max_filesize = 512M/" \
        -e "s/^error_reporting.*/error_reporting = E_ALL/" \
        -e "s/^display_errors.*/display_errors = On/" \
        -e "s/^display_startup_errors.*/display_startup_errors = On/" \
        -e "s/^track_errors.*/track_errors = On/" \
        -e "s/^mysqlnd.collect_memory_statistics.*/mysqlnd.collect_memory_statistics = On/" \
        /etc/php7/php.ini && \

    echo "error_log = \"/var/log/php7/error.log\"" | tee -a /etc/php7/php.ini && \

    touch /var/log/php7/error.log && \
    touch /var/log/php7/fpm-error.log && \
    touch /var/log/php7/fpm-slow.log && \
    chown -R 82:82 /var/log/php7

RUN rm /etc/php7/conf.d/xdebug.ini
COPY 00_opcache.ini /etc/php7/conf.d/
COPY 00_xdebug.ini /etc/php7/conf.d/
COPY php-fpm.conf /etc/php7/

# Create work dir
RUN mkdir -p /var/www/html && chown -R 82:82 /var/www
WORKDIR /var/www/html

VOLUME /var/www/html
EXPOSE 9000
CMD ["php-fpm"]
