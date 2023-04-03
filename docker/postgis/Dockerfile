FROM postgis/postgis:15-3.3
# Install pg_tle
RUN apt-get update
RUN apt-get install -y flex git make postgresql-server-dev-15
RUN mkdir /tmp/pg_tle/
RUN git clone https://github.com/aws/pg_tle.git /tmp/pg_tle/
RUN make -C /tmp/pg_tle/
RUN make -C /tmp/pg_tle/ install
# Copy scripts and imports to launch database
COPY ./docker/postgis/import_common_postgis.sh ./docker/postgis/import_production_postgis.sh ./src/private/development/docker/import_developmen[t]_postgis.sh /docker-entrypoint-initdb.d/
RUN mkdir /tmp/inpostgis/
RUN chmod -R 777 /tmp/inpostgis/
RUN rm -rf /docker-entrypoint-initdb.d/10_postgis.sh
