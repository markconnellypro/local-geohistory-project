#!/bin/bash
set -e
# Create new database
psql --command="CREATE ROLE readonly NOLOGIN;"
psql --command="CREATE ROLE $POSTGRES_OTHER_USER LOGIN PASSWORD '$POSTGRES_OTHER_PASSWORD';"
psql --command="GRANT readonly TO $POSTGRES_OTHER_USER;"
psql --command="GRANT USAGE ON SCHEMA public TO readonly;" $POSTGRES_DB
psql --command="ALTER DATABASE $POSTGRES_DB SET timezone TO '$TZ';" $POSTGRES_DB
psql --command="CREATE EXTENSION postgis;" $POSTGRES_DB
psql --command="CREATE EXTENSION unaccent;" $POSTGRES_DB
# Custom state plane SRID for Pennsylvania
psql --command="DELETE FROM spatial_ref_sys WHERE srid = 100007;  INSERT INTO spatial_ref_sys values ('100007', 'Other', '100007', 'PROJCS[\"NAD_1983_Lambert_Conformal_Conic\",GEOGCS[\"GCS_North_American_1983\",DATUM[\"D_North_American_1983\",SPHEROID[\"GRS_1980\",6378137.0,298.257222101]],PRIMEM[\"Greenwich\",0.0],UNIT[\"Degree\",0.0174532925199433]],PROJECTION[\"Lambert_Conformal_Conic\"],PARAMETER[\"False_Easting\",0.0],PARAMETER[\"False_Northing\",0.0],PARAMETER[\"Central_Meridian\",-78.0],PARAMETER[\"Standard_Parallel_1\",40.25],PARAMETER[\"Standard_Parallel_2\",41.5],PARAMETER[\"Latitude_Of_Origin\",39.0],UNIT[\"Foot_US\",0.3048006096012192]]', '+proj=lcc +lat_0=39 +lon_0=-78 +lat_1=40.25 +lat_2=41.5 +x_0=0 +y_0=0 +datum=NAD83 +units=us-ft +no_defs');" $POSTGRES_DB
# Install pg_tle
psql --command="CREATE EXTENSION pg_tle;" $POSTGRES_DB
# Install calendar extension
psql --command="CREATE SCHEMA calendar;" $POSTGRES_DB
psql --command="GRANT USAGE ON SCHEMA calendar TO readonly;" $POSTGRES_DB
psql --file="/inpostgis/postgresql_calendar_extension.sql" $POSTGRES_DB
psql --command="CREATE EXTENSION calendar;" $POSTGRES_DB