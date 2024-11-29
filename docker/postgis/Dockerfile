FROM postgis/postgis:17-3.5
# Install pg_tle
RUN apt-get update
RUN apt-get install -y flex git libkrb5-dev make postgresql-server-dev-17
RUN mkdir /tmp/pg_tle/
WORKDIR /tmp/pg_tle/
RUN git clone https://github.com/aws/pg_tle.git .
RUN git checkout -b last-tested f557f0c3d65f595ceff4e5dff430bd9d74126e0b
RUN make -C /tmp/pg_tle/
RUN make -C /tmp/pg_tle/ install
# Copy scripts and imports to launch database
ARG DOCKER_POSTGIS
COPY /docker/postgis/import_common_postgis.sh /src/private/${DOCKER_POSTGIS}/docker/import_env_postgis.sh /docker-entrypoint-initdb.d/
RUN mkdir /tmp/inpostgis/
RUN chmod -R 777 /tmp/inpostgis/
RUN rm -rf /docker-entrypoint-initdb.d/10_postgis.sh
