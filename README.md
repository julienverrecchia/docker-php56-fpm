# docker-php56-fpm
PHP 5.6 FPM based on official PHP Docker repository
https://github.com/docker-library/docs/tree/master/php

## What is it?
This Docker image provides a php-fpm environment with built-in options :
 - mbstring
 - mcrypt
 - pdo_pgsql
 - curl
 - intl
 - xmlrpc
 - gd
 - ldap
 - opcache

Timezone is set to _Europe/Paris_

## Usage
Intended use : coupled to nginx with docker-compose
