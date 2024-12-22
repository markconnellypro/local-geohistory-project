FROM postgis/postgis:16-3.5
# Install pg_tle
RUN apt-get update
RUN apt-get install -y flex git make postgresql-server-dev-16
RUN mkdir /tmp/pg_tle/
RUN git clone -b v1.1.1 https://github.com/aws/pg_tle.git /tmp/pg_tle/
RUN make -C /tmp/pg_tle/
RUN make -C /tmp/pg_tle/ install
# Copy scripts and imports to launch database
ARG DOCKER_POSTGIS
COPY /docker/postgis/import_common_postgis.sh /private/${DOCKER_POSTGIS}/docker/import_env_postgis.sh /docker-entrypoint-initdb.d/
RUN mkdir /tmp/inpostgis/
RUN chmod -R 777 /tmp/inpostgis/
RUN rm -rf /docker-entrypoint-initdb.d/10_postgis.sh
