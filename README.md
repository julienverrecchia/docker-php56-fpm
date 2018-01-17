# docker-php56-fpm
PHP 5.6 FPM based on official PHP Docker repository
https://github.com/docker-library/docs/tree/master/php

## What is it?
Docker image for PHP-5.6-FPM with :
 - mbstring
 - mcrypt
 - pdo_pgsql
 - intl
 - gd
 - ldap
 - opcache
 - memcached
 - soap
 - zip
 - ioncubeLoader
 - oci8 + pdo_oci
 - dblib + mssql

Timezone is set to _Europe/Paris_.

## Usage
Intended use : coupled to nginx with docker-compose

User : www-data
Listen : /var/run/php-fpm/php56.sock

Volume `sock` should be shared between containers : 
```
    php56:
      ...
      volumes:
        - sock:/var/run/php-fpm

    nginx:
      ...
      volumes:
        - sock:/var/run/php-fpm
```
