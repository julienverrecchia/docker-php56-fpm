# Derived from official PHP Docker repository (https://hub.docker.com/_/php/)
FROM php:5.6-fpm

MAINTAINER Julien Verrecchia


RUN apt-get update && apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libpq-dev \
        libldap2-dev \
        libcurl4-openssl-dev \
        libicu-dev \
        libxml2-dev \
        zlib1g-dev \
        memcached \
        libmemcached-dev \
        ssmtp \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install mbstring mcrypt pdo_pgsql curl intl xmlrpc \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap \
    && docker-php-ext-install opcache \
    && docker-php-ext-install zip \
    && apt-get purge -y --auto-remove $buildDeps \
    && cd /usr/src/php \
    && make clean

# Setup timezone to Europe/Paris
RUN cat /usr/src/php/php.ini-production | sed 's/^;\(date.timezone.*\)/\1 \"Europe\/Paris\"/' > /usr/local/etc/php/php.ini

# Memcached
RUN pecl install memcached \
    && docker-php-ext-enable memcached

# SSMTP config
ADD ssmtp.conf /etc/ssmtp/ssmtp.conf
ADD php-smtp.ini /usr/local/etc/php/conf.d/php-smtp.ini

RUN usermod -u 1000 www-data

WORKDIR /var/www