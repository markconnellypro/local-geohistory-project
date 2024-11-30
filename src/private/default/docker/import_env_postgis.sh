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
  geohistoryTables=(adjudication adjudicationevent adjudicationlocation adjudicationlocationtype adjudicationsourcecitation adjudicationtype affectedgovernmentgroup affectedgovernmentgrouppart affectedgovernmentlevel affectedgovernmentpart affectedtype censusmap currentgovernment documentation event eventeffectivetype eventgranted eventmethod eventrelationship eventslugretired eventtype filing filingtype government governmentform governmentformgovernment governmentidentifier governmentidentifiertype governmentmapstatus governmentothercurrentparent governmentsource governmentsourceevent law lawalternate lawalternatesection lawgroup lawgroupeventtype lawgroupgovernmenttype lawgroupsection lawsection lawsectionevent locale metesdescription metesdescriptionline nationalarchives plss plssfirstdivision plssfirstdivisionpart plssmeridian plssseconddivision plssspecialsurvey plsstownship recording recordingevent recordingoffice recordingofficetype recordingtype researchlog researchlogtype shorttype source sourcecitation sourcecitationevent sourcecitationnote sourcecitationnotetype sourcegovernment sourceitem sourceitemcategory sourceitempart sourcetype tribunal tribunaltype)
  for tableName in "${geohistoryTables[@]}"
  do
    if [ -f "/inpostgis/${tableName,,}.tsv" ]; then
      tsvHeader=$(head -n +1 "/inpostgis/${tableName,,}.tsv" | sed "s/\t/,/g")
      tail -n +2 "/inpostgis/${tableName,,}.tsv" > "/tmp/inpostgis/${tableName,,}.tsv"
      tableString+="\COPY geohistory.${tableName,,} ($tsvHeader) FROM '/tmp/inpostgis/${tableName,,}.tsv';
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
      tsvHeader=$(head -n +1 "/inpostgis/${tableName,,}.tsv" | sed "s/\t/,/g")
      tail -n +2 "/inpostgis/${tableName,,}.tsv" > "/tmp/inpostgis/${tableName,,}.tsv"
      tableString+="\COPY gis.${tableName,,} ($tsvHeader) FROM '/tmp/inpostgis/${tableName,,}.tsv';
      "
    else
      echo "ERROR: ${tableName,,} data file missing"
    fi
  done
  ## Reinstate foreign key checks and refresh views
  tableString+="COMMIT;
  ALTER TABLE gis.governmentshape ENABLE TRIGGER governmentshape_insert_trigger;
  SELECT geohistory.refresh_view();
  SELECT gis.refresh_view();
  SELECT gis.refresh_sequence();
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
