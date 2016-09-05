FROM alpine:3.4
MAINTAINER Wodby <admin@wodby.com>

# Create user www-data
RUN addgroup -g 82 -S www-data && \
	adduser -u 82 -D -S -G www-data www-data

# Install packages
RUN echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    echo '@community http://nl.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories && \

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

        # Temp packages
        build-base \
        autoconf \
        libtool \
        php7-dev@testing \
        pcre-dev \
        imagemagick-dev \

        # PHP packages
        php7@community \
        php7-fpm@community \
        php7-opcache@community \
        php7-session@community \
        php7-xml@community \
        php7-ctype@community \
        php7-ftp@community \
        php7-gd@community \
        php7-json@community \
        php7-posix@community \
        php7-curl@community \
        php7-dom@community \
        php7-pdo@community \
        php7-pdo_mysql@community \
        php7-sockets@community \
        php7-zlib@community \
        php7-mcrypt@community \
        php7-mysqli@community \
        php7-bz2@community \
        php7-phar@community \
        php7-openssl@community \
        php7-posix@community \
        php7-zip@community \
        php7-calendar@community \
        php7-iconv@community \
        php7-imap@community \
        php7-soap@community \
        php7-dev@community \
        php7-pear@community \
        php7-redis@testing \
        php7-mbstring@community \
        php7-xdebug@testing \
        php7-exif@community \
        php7-xsl@community \
        && \

    # Create symlinks for backward compatibility
    ln -sf /usr/bin/php7 /usr/bin/php && \
    ln -sf /usr/sbin/php-fpm7 /usr/bin/php-fpm && \

    # Install imagick
    sed -ie 's/-n//g' /usr/bin/pecl && \
    yes | pecl install imagick && \
    echo 'extension=imagick.so' > /etc/php7/conf.d/imagick.ini && \
    rm -rf /tmp/pear && \

    # Install uploadprogess
    cd /tmp/ && wget https://github.com/Jan-E/uploadprogress/archive/master.zip && \
    unzip master.zip && \
    cd uploadprogress-master/ && \
    phpize7 && ./configure --with-php-config=/usr/bin/php-config7 && \
    make && make install && \
    echo 'extension=uploadprogress.so' > /etc/php7/conf.d/20_uploadprogress.ini && \
    cd .. && rm -rf ./master.zip ./uploadprogress-master && \

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

    # Install drupal-console
    curl https://drupalconsole.com/installer -L -o drupal.phar && \
    mv drupal.phar /usr/local/bin/drupal && \
    chmod +x /usr/local/bin/drupal && \
    drupal init --override && \
    mkdir -p /home/www-data/.console && \
    cp /root/.console/config.yml /home/www-data/.console/ && \
    chown -R 82:82 /home/www-data && \

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
        -e "s/^error_reporting.*/error_reporting = E_ALL/" \
        -e "s/^display_errors.*/display_errors = On/" \
        -e "s/^display_startup_errors.*/display_startup_errors = On/" \
        -e "s/^track_errors.*/track_errors = On/" \
        -e "s/^mysqlnd.collect_memory_statistics.*/mysqlnd.collect_memory_statistics = On/" \
        /etc/php7/php.ini && \

    echo "error_log = \"/proc/self/fd/2\"" | tee -a /etc/php7/php.ini

RUN rm /etc/php7/conf.d/xdebug.ini
COPY 00_opcache.ini /etc/php7/conf.d/
COPY 00_xdebug.ini /etc/php7/conf.d/
COPY php-fpm.conf /etc/php7/

# Add default drush aliases
RUN mkdir -p /etc/drush/site-aliases
COPY default.aliases.drushrc.php /etc/drush/site-aliases/

# Create work dir
RUN mkdir -p /var/www/html && chown -R 82:82 /var/www
WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 9000

COPY docker-entrypoint.sh /usr/local/bin/
CMD "docker-entrypoint.sh"
