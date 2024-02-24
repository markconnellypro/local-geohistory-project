#!/bin/bash
# Use the default production configuration
cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
sed -i "s/^\t<\/IfModule>/\t\tAddOutputFilterByType DEFLATE application\/geo+json\n\t\tAddOutputFilterByType DEFLATE application\/json\n\t\tAddOutputFilterByType DEFLATE application\/x-protobuf\n\t<\/IfModule>/" /etc/apache2/mods-available/deflate.conf
echo 'application/x-protobuf                        mvt pbf' >> /etc/mime.types
sed -i 's/;opcache.enable=1/opcache.enable=1/' /usr/local/etc/php/php.ini
if [[ -e "/usr/src/docker/import_development_php.sh" ]]; then
  /usr/src/docker/import_development_php.sh
fi
if [[ -e "/usr/src/docker/import_production_php.sh" ]]; then
  /usr/src/docker/import_production_php.sh
fi
# Modify entrypoint to run composer install and retrieve dependencies
sed -i "s/#!\/bin\/sh/#!\/bin\/sh\ncomposer install --no-dev --working-dir=\/var\/www\n\/usr\/src\/docker\/import_dependency.sh\n/" /usr/local/bin/docker-php-entrypoint