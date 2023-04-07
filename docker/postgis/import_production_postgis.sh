#!/bin/bash
set -e
if [ "$CI_ENVIRONMENT" = "production" ]; then
  echo "PRODUCTION DATABASE RESTORATION:"
  # Create schemas
  psql --file="/inpostgis/postgresql_public_backup.sql" $POSTGRES_DB
  # Combine Commands
  ## Block foreign key checks
  tableString="BEGIN;
  SET CONSTRAINTS ALL DEFERRED;
  "
  ## Geohistory
  geohistoryTables=(adjudication adjudicationevent adjudicationlocation adjudicationlocationtype adjudicationsourcecitation adjudicationtype affectedgovernmentgroup affectedgovernmentgrouppart affectedgovernmentlevel affectedgovernmentpart affectedtype censusmap currentgovernment documentation event eventeffectivetype eventgranted eventmethod eventrelationship eventslugretired eventtype filing filingtype government governmentform governmentformgovernment governmentidentifier governmentidentifiertype governmentmapstatus governmentothercurrentparent governmentsource governmentsourceevent law lawalternate lawalternatesection lawsection lawsectionevent metesdescription metesdescriptionline nationalarchives plss plssfirstdivision plssfirstdivisionpart plssmeridian plssseconddivision plssspecialsurvey plsstownship recording recordingevent recordingoffice recordingofficetype recordingtype researchlog researchlogtype shorttype source sourcecitation sourcecitationevent sourceitem sourceitemcategory sourceitempart sourcetype tribunal tribunaltype)
  for tableName in "${geohistoryTables[@]}"
  do
    if [ -f "/inpostgis/${tableName,,}.tsv" ]; then
      tail -n +2 "/inpostgis/${tableName,,}.tsv" > "/tmp/inpostgis/${tableName,,}.tsv"
      tableString+="\COPY geohistory.${tableName,,} FROM '/tmp/inpostgis/${tableName,,}.tsv';
      "
    else
      echo "ERROR: ${tableName,,} data file missing"
    fi
  done
  ## GIS
  tableString+="ALTER TABLE gis.governmentshape DISABLE TRIGGER governmentshape_insert_trigger;
  "
  gisTables=(affectedgovernmentgis governmentshape metesdescriptiongis)
  for tableName in "${gisTables[@]}"
  do
    if [ -f "/inpostgis/${tableName,,}.tsv" ]; then
      tail -n +2 "/inpostgis/${tableName,,}.tsv" > "/tmp/inpostgis/${tableName,,}.tsv"
      tableString+="\COPY gis.${tableName,,} FROM '/tmp/inpostgis/${tableName,,}.tsv';
      "
    else
      echo "ERROR: ${tableName,,} data file missing"
    fi
  done
  ## Reinstate foreign key checks and refresh views
  tableString+="COMMIT;
  ALTER TABLE gis.governmentshape ENABLE TRIGGER governmentshape_insert_trigger;
  SELECT extra.refresh_view_quick();
  SELECT extra.refresh_view_long();
  SELECT extra.refresh_sequence();
  "
  ## Save combined commands
  echo "${tableString}" > /tmp/inpostgis/import.sql
  # Run combined commands
  psql --file="/tmp/inpostgis/import.sql" $POSTGRES_DB
  ## Delete temporary files combined commands
  rm -rf /tmp/inpostgis/*
else
  echo "SKIP PRODUCTION DATABASE RESTORATION"
fi
