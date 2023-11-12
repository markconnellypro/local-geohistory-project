#!/usr/bin/env bash
composer install --no-dev --working-dir=/var/www
/usr/local/bin/docker-php-entrypoint