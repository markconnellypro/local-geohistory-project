FROM php:8.2.4-apache
# Create writable dictory for CodeIgniter
RUN mkdir /writable
RUN mkdir /writable/cache
RUN mkdir /writable/debugbar
RUN mkdir /writable/logs
RUN mkdir /writable/session
RUN mkdir /writable/uploads
RUN chown -R www-data:www-data /writable/
# Enable Apache modules
RUN a2dismod autoindex -f
RUN a2enmod expires
RUN a2enmod headers
RUN a2enmod remoteip
RUN a2enmod rewrite
RUN a2enmod ssl
# Add PHP extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions intl pgsql xsl
# Adjust configuration files
COPY /docker/php/mods-enabled/headers.conf /etc/apache2/mods-enabled/
RUN mkdir /docker-php-entrypoint
COPY ./docker/php/import_common_php.sh ./src/private/development/docker/import_developmen[t]_php.sh ./src/private/production/docke[r]/* /docker-php-entrypoint/
RUN chmod -R 764 /docker-php-entrypoint/*
ARG CI_ENVIRONMENT
RUN /docker-php-entrypoint/import_common_php.sh
# Restart Apache
RUN service apache2 restart
