FROM php:8.2.11-apache
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
RUN install-php-extensions gd intl pgsql xsl zip
# Adjust configuration files
COPY /docker/php/mods-enabled/headers.conf /etc/apache2/mods-enabled/
RUN mkdir /usr/src/docker
# OTHER OPERATING SYSTEMS: May need to use the commented version below instead of the uncommented version 2 lines down
# COPY ./docker/php/import_common_php.sh /usr/src/docker/
COPY ./docker/php/import_common_php.sh ./src/private/development/docker/import_developmen[t]_php.sh ./src/private/production/docke[r]/* ./src/private/personal-production/personal-docke[r]/* /usr/src/docker/
RUN chmod -R 764 /usr/src/docker/*
ARG CI_ENVIRONMENT
RUN /usr/src/docker/import_common_php.sh
# Restart Apache
RUN service apache2 restart
# Install Composer and prerequisites
RUN apt-get update
RUN apt-get install -y unzip zip
COPY --from=composer:2.6.5 /usr/bin/composer /usr/bin/composer
