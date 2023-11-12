#!/bin/bash
# Use the default production configuration
cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
sed -i "s/^\t<\/IfModule>/\t\tAddOutputFilterByType DEFLATE application\/geo+json\n\t\tAddOutputFilterByType DEFLATE application\/json\n\t\tAddOutputFilterByType DEFLATE application\/x-protobuf\n\t<\/IfModule>/" /etc/apache2/mods-available/deflate.conf
echo 'application/x-protobuf                        mvt pbf' >> /etc/mime.types
sed -i 's/;opcache.enable=1/opcache.enable=1/' /usr/local/etc/php/php.ini
if [[ -e "/docker-php-entrypoint/import_development_php.sh" ]]; then
  /docker-php-entrypoint/import_development_php.sh
fi
if [[ -e "/docker-php-entrypoint/import_production_php.sh" ]]; then
  /docker-php-entrypoint/import_production_php.sh
fi