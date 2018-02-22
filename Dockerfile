FROM php:5.6-fpm-jessie

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        libmemcached-dev \
        libz-dev \
        libpq-dev \
        libjpeg-dev \
        libpng12-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev \
        libldap2-dev \
        libxml2-dev \
        zlib1g-dev \
        libicu-dev \
        g++ \
        unzip \
        build-essential \
        libaio1 \
        re2c

RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/include/ \
        --with-freetype-dir=/usr/include/ \
    && docker-php-ext-configure soap --enable-soap \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure mbstring

RUN docker-php-ext-install \
        mcrypt \
        pdo_pgsql \
        ldap \
        gd \
        soap \
        zip \
        intl

# Memcached
RUN pecl install memcached-2.2.0 && \
    docker-php-ext-enable memcached

# Opcache
RUN docker-php-ext-install opcache
COPY ./config/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# ionCube Loader
ADD ./ext/ioncube_loader_lin_5.6.so /usr/local/lib/php/extensions/no-debug-non-zts-20131226/

# SQL Server / dblib
RUN apt-get install -y --no-install-recommends freetds-dev \
    && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so \
    && docker-php-ext-configure mssql --with-mssql=/usr \
    && docker-php-ext-install mssql \
    && docker-php-ext-configure pdo_dblib --with-pdo-dblib=/usr \
    && docker-php-ext-install pdo_dblib

# Oracle (oci8 / pdo_oci)
# credits https://github.com/tassoevan/pdo-oci-extension
#  1) Oracle InstantClient
RUN curl -L -o /tmp/instantclient-sdk-12.2.zip http://bit.ly/2Bab3NM \
    && curl -L -o /tmp/instantclient-basic-12.2.zip http://bit.ly/2mBFHdA \
    && ln -s /usr/include/php5 /usr/include/php \
    && mkdir -p /opt/oracle/instantclient \
    && unzip -q /tmp/instantclient-basic-12.2.zip -d /opt/oracle \
    && mv /opt/oracle/instantclient_12_2 /opt/oracle/instantclient/lib \
    && unzip -q /tmp/instantclient-sdk-12.2.zip -d /opt/oracle \
    && mv /opt/oracle/instantclient_12_2/sdk/include /opt/oracle/instantclient/include \
    && ln -s /opt/oracle/instantclient/lib/libclntsh.so.12.1 /opt/oracle/instantclient/lib/libclntsh.so \
    && ln -s /opt/oracle/instantclient/lib/libocci.so.12.1 /opt/oracle/instantclient/lib/libocci.so \
    && echo /opt/oracle/instantclient/lib >> /etc/ld.so.conf \
    && ldconfig
#  2) OCI8
RUN echo 'instantclient,/opt/oracle/instantclient/lib' | pecl install oci8-2.0.12
ADD ./config/oci8.ini /usr/local/etc/php/conf.d/20-oci8.ini
ADD ./config/oci8-test.php /tmp/oci8-test.php
RUN php /tmp/oci8-test.php
#  2) PDO_OCI
RUN pecl channel-update pear.php.net \
    && cd /tmp \
    && pecl download pdo_oci \
    && tar xvf /tmp/PDO_OCI-1.0.tgz -C /tmp \
    && sed 's/function_entry/zend_function_entry/' -i /tmp/PDO_OCI-1.0/pdo_oci.c \
    && sed 's/10.1/12.1/' -i /tmp/PDO_OCI-1.0/config.m4 \
    && cd /tmp/PDO_OCI-1.0 \
    && phpize \
    && ./configure --with-pdo-oci=/opt/oracle/instantclient \
    && make install
ADD ./config/pdo_oci.ini /usr/local/etc/php/conf.d/20-pdo_oci.ini
ADD ./config/pdo_oci-test.php /tmp/pdo_oci-test.php
RUN php /tmp/pdo_oci-test.php

# PHP config
ADD ./config/ioncube.ini /usr/local/etc/php/conf.d/00-ioncube.ini
ADD ./config/php56.pool.conf /usr/local/etc/php-fpm.d/
ADD ./config/custom.php.ini /usr/local/etc/php/conf.d
RUN sed -e '/9000/ s/^;*/;/' -i /usr/local/etc/php-fpm.d/zz-docker.conf
RUN sed -e '/9000/ s/^;*/;/' -i /usr/local/etc/php-fpm.d/www.conf

# Clean up
RUN apt-get clean \
    && rm -r /var/lib/apt/lists/*

RUN usermod -u 1000 www-data

WORKDIR /var/www

CMD ["php-fpm"]

LABEL \
    maintainer="Julien Verrecchia" \
    version="2018.02.22"