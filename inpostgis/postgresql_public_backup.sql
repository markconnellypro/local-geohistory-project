--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1 (Debian 16.1-1.pgdg110+1)
-- Dumped by pg_dump version 16.2 (Ubuntu 16.2-1.pgdg22.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: extra; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extra;


ALTER SCHEMA extra OWNER TO postgres;

--
-- Name: geohistory; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA geohistory;


ALTER SCHEMA geohistory OWNER TO postgres;

--
-- Name: gis; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA gis;


ALTER SCHEMA gis OWNER TO postgres;

--
-- Name: affectedtypeshort(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.affectedtypeshort(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
        SELECT affectedtypeshort
        FROM geohistory.affectedtype
        WHERE affectedtypeid = $1;
    $_$;


ALTER FUNCTION extra.affectedtypeshort(integer) OWNER TO postgres;

--
-- Name: array_combine(integer[]); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.array_combine(integer[]) RETURNS integer[]
    LANGUAGE sql STABLE
    AS $_$

 WITH arraylist AS (
   SELECT unnest($1) AS arrayitems
 )
 SELECT array_agg(DISTINCT arrayitems ORDER BY arrayitems) AS combinedarray
 FROM arraylist;
     
$_$;


ALTER FUNCTION extra.array_combine(integer[]) OWNER TO postgres;

--
-- Name: ci_model_area_affectedgovernment(integer, character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_area_affectedgovernment(v_governmentshape integer, v_state character varying, v_locale character varying) RETURNS TABLE(eventid integer, eventslug text, municipalityfrom text, municipalityfromlong text, affectedtypemunicipalityfrom text, countyfrom text, countyfromshort text, affectedtypecountyfrom text, statefrom text, statefromabbreviation text, affectedtypestatefrom text, municipalityto text, municipalitytolong text, affectedtypemunicipalityto text, countyto text, countytoshort text, affectedtypecountyto text, stateto text, statetoabbreviation text, affectedtypestateto text, textflag boolean, submunicipalityfrom text, submunicipalityfromlong text, affectedtypesubmunicipalityfrom text, submunicipalityto text, submunicipalitytolong text, affectedtypesubmunicipalityto text, subcountyfrom text, subcountyfromshort text, affectedtypesubcountyfrom text, subcountyto text, subcountytoshort text, affectedtypesubcountyto text, eventrange text, eventeffective text, eventsortdate numeric, eventorder integer)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
WITH foundaffectedgovernment AS (
 SELECT event.eventid,
    eventextracache.eventslug,
    extra.governmentstatelink(affectedgovernment_reconstructed.municipalityfrom, v_state, v_locale) AS municipalityfrom,
    extra.governmentlong(affectedgovernment_reconstructed.municipalityfrom, upper(v_state)) AS municipalityfromlong,
    extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypemunicipalityfrom) AS affectedtypemunicipalityfrom,
    extra.governmentstatelink(affectedgovernment_reconstructed.countyfrom, v_state, v_locale) AS countyfrom,
    extra.governmentshort(affectedgovernment_reconstructed.countyfrom, upper(v_state)) AS countyfromshort,
    extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypecountyfrom) AS affectedtypecountyfrom,
    extra.governmentstatelink(affectedgovernment_reconstructed.statefrom, v_state, v_locale) AS statefrom,
    extra.governmentabbreviation(affectedgovernment_reconstructed.statefrom) AS statefromabbreviation,
    extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypestatefrom) AS affectedtypestatefrom,
    extra.governmentstatelink(affectedgovernment_reconstructed.municipalityto, v_state, v_locale) AS municipalityto,
    extra.governmentlong(affectedgovernment_reconstructed.municipalityto, upper(v_state)) AS municipalitytolong,
    extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypemunicipalityto) AS affectedtypemunicipalityto,
    extra.governmentstatelink(affectedgovernment_reconstructed.countyto, v_state, v_locale) AS countyto,
    extra.governmentshort(affectedgovernment_reconstructed.countyto, upper(v_state)) AS countytoshort,
    extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypecountyto) AS affectedtypecountyto,
    extra.governmentstatelink(affectedgovernment_reconstructed.stateto, v_state, v_locale) AS stateto,
    extra.governmentabbreviation(affectedgovernment_reconstructed.stateto) AS statetoabbreviation,
    extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypestateto) AS affectedtypestateto,
    CASE WHEN affectedgovernment_reconstructed.submunicipalityfrom IS NOT NULL 
      OR affectedgovernment_reconstructed.submunicipalityto IS NOT NULL
      OR affectedgovernment_reconstructed.subcountyfrom IS NOT NULL
      OR affectedgovernment_reconstructed.subcountyto IS NOT NULL THEN TRUE ELSE FALSE END AS textflag,
    extra.nulltoempty(extra.governmentstatelink(affectedgovernment_reconstructed.submunicipalityfrom, v_state, v_locale)) AS submunicipalityfrom,
    extra.nulltoempty(extra.governmentlong(affectedgovernment_reconstructed.submunicipalityfrom, upper(v_state))) AS submunicipalityfromlong,
    extra.nulltoempty(extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypesubmunicipalityfrom)) AS affectedtypesubmunicipalityfrom,
    extra.nulltoempty(extra.governmentstatelink(affectedgovernment_reconstructed.submunicipalityto, v_state, v_locale)) AS submunicipalityto,
    extra.nulltoempty(extra.governmentlong(affectedgovernment_reconstructed.submunicipalityto, upper(v_state))) AS submunicipalitytolong,
    extra.nulltoempty(extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypesubmunicipalityto)) AS affectedtypesubmunicipalityto,
    extra.nulltoempty(extra.governmentstatelink(affectedgovernment_reconstructed.subcountyfrom, v_state, v_locale)) AS subcountyfrom,
    extra.nulltoempty(extra.governmentshort(affectedgovernment_reconstructed.subcountyfrom, upper(v_state))) AS subcountyfromshort,
    extra.nulltoempty(extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypesubcountyfrom)) AS affectedtypesubcountyfrom,
    extra.nulltoempty(extra.governmentstatelink(affectedgovernment_reconstructed.subcountyto, v_state, v_locale)) AS subcountyto,
    extra.nulltoempty(extra.governmentshort(affectedgovernment_reconstructed.subcountyto, upper(v_state))) AS subcountytoshort,
    extra.nulltoempty(extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypesubcountyto)) AS affectedtypesubcountyto,
    extra.rangefix(event.eventfrom::text, event.eventto::text) AS eventrange,
    extra.shortdate(event.eventeffective) AS eventeffective,
    extra.eventsortdate(event.eventid) AS eventsortdate,
    (ROW_NUMBER () OVER (ORDER BY extra.eventsortdate(event.eventid), event.eventid))::integer AS eventorder,
    (ROW_NUMBER () OVER (ORDER BY extra.eventsortdate(event.eventid) DESC, event.eventid DESC))::integer AS eventorderreverse
   FROM geohistory.event
   JOIN geohistory.eventgranted
   ON event.eventgranted = eventgranted.eventgrantedid
   AND eventgranted.eventgrantedsuccess
   JOIN extra.eventextracache
   ON event.eventid = eventextracache.eventid
   AND eventextracache.eventslugnew IS NULL
   JOIN extra.affectedgovernment_reconstructed
   ON affectedgovernment_reconstructed.event = event.eventid
   JOIN gis.affectedgovernmentgis
   ON affectedgovernment_reconstructed.affectedgovernmentid = affectedgovernmentgis.affectedgovernment
  WHERE affectedgovernmentgis.governmentshape = v_governmentshape
  GROUP BY 1, eventslug, municipalityfrom, municipalityfromlong, affectedtypemunicipalityfrom, countyfrom, countyfromshort, affectedtypecountyfrom, statefrom, statefromabbreviation, affectedtypestatefrom, municipalityto, municipalitytolong, affectedtypemunicipalityto, countyto, countytoshort, affectedtypecountyto, stateto, statetoabbreviation, affectedtypestateto, submunicipalityfrom, submunicipalityfromlong, affectedtypesubmunicipalityfrom, submunicipalityto, submunicipalitytolong, affectedtypesubmunicipalityto, subcountyfrom, subcountyfromshort, affectedtypesubcountyfrom, subcountyto, subcountytoshort, affectedtypesubcountyto, extra.rangefix(event.eventfrom::text, event.eventto::text), extra.shortdate(event.eventeffective), extra.eventsortdate(event.eventid)
)
  SELECT eventid, eventslug, municipalityfrom, municipalityfromlong, affectedtypemunicipalityfrom, countyfrom, countyfromshort, affectedtypecountyfrom, statefrom, statefromabbreviation, affectedtypestatefrom, municipalityto, municipalitytolong, affectedtypemunicipalityto, countyto, countytoshort, affectedtypecountyto, stateto, statetoabbreviation, affectedtypestateto, textflag, submunicipalityfrom, submunicipalityfromlong, affectedtypesubmunicipalityfrom, submunicipalityto, submunicipalitytolong, affectedtypesubmunicipalityto, subcountyfrom, subcountyfromshort, affectedtypesubcountyfrom, subcountyto, subcountytoshort, affectedtypesubcountyto, eventrange, eventeffective, eventsortdate, 
    (eventorder * 2 - 1) AS eventorder
  FROM foundaffectedgovernment
  UNION
  SELECT NULL AS eventid,
    '' AS eventslug,
    oldg.municipalityto AS municipalityfrom,
    oldg.municipalitytolong AS municipalityfromlong,
    'Missing' AS affectedtypemunicipalityfrom,
    oldg.countyto AS countyfrom,
    oldg.countytoshort AS countyfromshort,
    'Missing' AS affectedtypecountyfrom,
    oldg.stateto AS statefrom,
    oldg.statetoabbreviation AS statefromabbreviation,
    'Missing' AS affectedtypestatefrom,
    newg.municipalityfrom AS municipalityto,
    newg.municipalityfromlong AS municipalitytolong,
    'Missing' AS affectedtypemunicipalityto,
    newg.countyfrom AS countyto,
    newg.countyfromshort AS countytoshort,
    'Missing' AS affectedtypecountyto,
    newg.statefrom AS stateto,
    newg.statefromabbreviation AS statetoabbreviation,
    'Missing' AS affectedtypestateto,
    oldg.textflag OR newg.textflag AS textflag,
    oldg.submunicipalityto AS submunicipalityfrom,
    oldg.submunicipalitytolong AS submunicipalityfromlong,
    CASE WHEN oldg.submunicipalityto = '' THEN '' ELSE 'Missing' END AS affectedtypesubmunicipalityfrom,
    newg.submunicipalityfrom AS submunicipalityto,
    newg.submunicipalityfromlong AS submunicipalitytolong,
    CASE WHEN newg.submunicipalityfrom = '' THEN '' ELSE 'Missing' END AS affectedtypesubmunicipalityto,
    oldg.subcountyto AS subcountyfrom,
    oldg.subcountytoshort AS subcountyfromshort,
    CASE WHEN oldg.subcountyto = '' THEN '' ELSE 'Missing' END AS affectedtypesubcountyfrom,
    newg.subcountyfrom AS subcountyto,
    newg.subcountyfromshort AS subcountytoshort,
    CASE WHEN newg.subcountyfrom = '' THEN '' ELSE 'Missing' END AS affectedtypesubcountyto,
    '' AS eventrange,
    '' AS eventeffective,
    NULL AS eventsortdate,
    (oldg.eventorder * 2) AS eventorder
  FROM foundaffectedgovernment oldg
  JOIN foundaffectedgovernment newg
    ON oldg.eventorder = newg.eventorder - 1
    AND NOT (
      oldg.submunicipalityto = newg.submunicipalityfrom AND
      oldg.subcountyto = newg.subcountyfrom AND
      oldg.municipalityto = newg.municipalityfrom AND
      oldg.countyto = newg.countyfrom AND
      (oldg.stateto = newg.statefrom OR oldg.statetoabbreviation ~ ('^' || newg.statefromabbreviation || '[\-][A-Z]$'))
    )
  UNION
  SELECT NULL AS eventid,
    '' AS eventslug,
    oldg.municipalityto AS municipalityfrom,
    oldg.municipalitytolong AS municipalityfromlong,
    'Missing' AS affectedtypemunicipalityfrom,
    oldg.countyto AS countyfrom,
    oldg.countytoshort AS countyfromshort,
    'Missing' AS affectedtypecountyfrom,
    oldg.stateto AS statefrom,
    oldg.statetoabbreviation AS statefromabbreviation,
    'Missing' AS affectedtypestatefrom,
    newg.governmentmunicipality AS municipalityto,
    newg.governmentmunicipalitylong AS municipalitytolong,
    'Missing' AS affectedtypemunicipalityto,
    newg.governmentcounty AS countyto,
    newg.governmentcountyshort AS countytoshort,
    'Missing' AS affectedtypecountyto,
    newg.governmentstate AS stateto,
    newg.governmentstateabbreviation AS statetoabbreviation,
    'Missing' AS affectedtypestateto,
    oldg.textflag OR newg.governmentsubmunicipality <> '' AS textflag,
    oldg.submunicipalityto AS submunicipalityfrom,
    oldg.submunicipalitytolong AS submunicipalityfromlong,
    CASE WHEN oldg.submunicipalityto = '' THEN '' ELSE 'Missing' END AS affectedtypesubmunicipalityfrom,
    newg.governmentsubmunicipality AS submunicipalityto,
    newg.governmentsubmunicipalitylong AS submunicipalitytolong,
    CASE WHEN newg.governmentsubmunicipality = '' THEN '' ELSE 'Missing' END AS affectedtypesubmunicipalityto,
    oldg.subcountyto AS subcountyfrom,
    oldg.subcountytoshort AS subcountyfromshort,
    CASE WHEN oldg.subcountyto = '' THEN '' ELSE 'Missing' END AS affectedtypesubcountyfrom,
    '' AS subcountyto,
    '' AS subcountytoshort,
    '' AS affectedtypesubcountyto,
    '' AS eventrange,
    '' AS eventeffective,
    NULL AS eventsortdate,
    (oldg.eventorder * 2) AS eventorder
  FROM foundaffectedgovernment oldg
  JOIN extra.ci_model_area_currentgovernment(v_governmentshape, v_state, v_locale) newg
    ON oldg.eventorderreverse = 1
    AND NOT (
      oldg.submunicipalityto = newg.governmentsubmunicipality AND
      oldg.municipalityto = newg.governmentmunicipality AND
      oldg.countyto = newg.governmentcounty AND
      (oldg.stateto = newg.governmentstate OR oldg.statetoabbreviation ~ ('^' || newg.governmentstateabbreviation || '[\-][A-Z]$'))
    )
  ORDER BY 37;
$_$;


ALTER FUNCTION extra.ci_model_area_affectedgovernment(v_governmentshape integer, v_state character varying, v_locale character varying) OWNER TO postgres;

--
-- Name: ci_model_area_currentgovernment(integer, character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_area_currentgovernment(v_governmentshapeid integer, v_state character varying, v_locale character varying) RETURNS TABLE(governmentshapeid integer, governmentsubmunicipality text, governmentsubmunicipalitylong text, governmentmunicipality text, governmentmunicipalitylong text, governmentcounty text, governmentcountyshort text, governmentstate text, governmentstateabbreviation text, id integer, geometry text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
SELECT DISTINCT governmentshape.governmentshapeid,
    extra.nulltoempty(extra.governmentstatelink(governmentshape.governmentsubmunicipality, v_state, v_locale)) AS governmentsubmunicipality,
    extra.nulltoempty(extra.governmentlong(governmentshape.governmentsubmunicipality, upper(v_state))) AS governmentsubmunicipalitylong,
    extra.governmentstatelink(governmentshape.governmentmunicipality, v_state, v_locale) AS governmentmunicipality,
    extra.governmentlong(governmentshape.governmentmunicipality, upper(v_state)) AS governmentmunicipalitylong,
    extra.governmentstatelink(governmentshape.governmentcounty, v_state, v_locale) AS governmentcounty,
    extra.governmentshort(governmentshape.governmentcounty, upper(v_state)) AS governmentcountyshort,
    extra.governmentstatelink(governmentshape.governmentstate, v_state, v_locale) AS governmentstate,
    extra.governmentabbreviation(governmentshape.governmentstate) AS governmentstateabbreviation,
    governmentshape.governmentshapeid AS id,
    public.st_asgeojson(governmentshape.governmentshapegeometry) AS geometry
   FROM gis.governmentshape
   LEFT JOIN extra.areagovernmentcache
   ON governmentshape.governmentshapeid = areagovernmentcache.governmentshapeid
  WHERE governmentshape.governmentshapeid = v_governmentshapeid
  AND (governmentrelationstate = upper(v_state) OR governmentrelationstate IS NULL)
  ORDER BY 8, 6, 4, 2;
$$;


ALTER FUNCTION extra.ci_model_area_currentgovernment(v_governmentshapeid integer, v_state character varying, v_locale character varying) OWNER TO postgres;

--
-- Name: ci_model_area_currentgovernment(text, character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_area_currentgovernment(v_governmentshapeid text, v_state character varying, v_locale character varying) RETURNS TABLE(governmentshapeid integer, governmentsubmunicipality text, governmentsubmunicipalitylong text, governmentmunicipality text, governmentmunicipalitylong text, governmentcounty text, governmentcountyshort text, governmentstate text, governmentstateabbreviation text, id integer, geometry text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
SELECT * FROM extra.ci_model_area_currentgovernment(extra.governmentshapeslugid(v_governmentshapeid), v_state, v_locale);
$$;


ALTER FUNCTION extra.ci_model_area_currentgovernment(v_governmentshapeid text, v_state character varying, v_locale character varying) OWNER TO postgres;

--
-- Name: ci_model_area_event_failure(integer, integer[]); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_area_event_failure(integer, integer[]) RETURNS TABLE(eventslug text, eventtypeshort character varying, eventlong character varying, eventrange text, eventgranted character varying, eventeffective text, eventsortdate numeric)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
SELECT DISTINCT eventextracache.eventslug,
    eventtype.eventtypeshort,
    event.eventlong,
    extra.rangefix(event.eventfrom::text, event.eventto::text) AS eventrange,
    eventgranted.eventgrantedshort AS eventgranted,
    extra.shortdate(event.eventeffective) AS eventeffective,
    extra.eventsortdate(event.eventid) AS eventsortdate
   FROM geohistory.event
   JOIN geohistory.eventgranted
     ON event.eventgranted = eventgranted.eventgrantedid
   JOIN geohistory.eventtype
     ON event.eventtype = eventtype.eventtypeid
   JOIN extra.eventextracache
     ON event.eventid = eventextracache.eventid
     AND eventextracache.eventslugnew IS NULL
     AND event.eventid <> ALL ($2)
  WHERE (event.eventid IN ( SELECT event_1.eventid
           FROM geohistory.event event_1,
            geohistory.affectedgovernmentgroup,
            gis.affectedgovernmentgis
          WHERE event_1.eventid = affectedgovernmentgroup.event
            AND affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgis.affectedgovernment
            AND affectedgovernmentgis.governmentshape = $1
        UNION
         SELECT event_1.eventid
           FROM geohistory.event event_1,
            geohistory.metesdescription,
            gis.metesdescriptiongis
          WHERE event_1.eventid = metesdescription.event 
            AND metesdescription.metesdescriptionid = metesdescriptiongis.metesdescription
            AND metesdescriptiongis.governmentshape = $1))
  ORDER BY (extra.eventsortdate(event.eventid)), event.eventlong;
$_$;


ALTER FUNCTION extra.ci_model_area_event_failure(integer, integer[]) OWNER TO postgres;

--
-- Name: ci_model_area_metesdescription(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_area_metesdescription(integer) RETURNS TABLE(metesdescriptionslug text, metesdescriptiontype character varying, metesdescriptionsource character varying, metesdescriptionbeginningpoint text, metesdescriptionlong text, metesdescriptionacres double precision, event integer, eventslug text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
SELECT metesdescriptionextracache.metesdescriptionslug,
    metesdescription.metesdescriptiontype,
    metesdescription.metesdescriptionsource,
    metesdescription.metesdescriptionbeginningpoint,
    metesdescriptionextracache.metesdescriptionlong,
    metesdescription.metesdescriptionacres,
    metesdescription.event,
    eventextracache.eventslug
   FROM geohistory.metesdescription
   JOIN extra.metesdescriptionextracache
     ON metesdescription.metesdescriptionid = metesdescriptionextracache.metesdescriptionid
   JOIN gis.metesdescriptiongis
     ON metesdescription.metesdescriptionid = metesdescriptiongis.metesdescription
   JOIN extra.eventextracache
     ON metesdescription.event = eventextracache.eventid
     AND eventextracache.eventslugnew IS NULL
  WHERE governmentshape = $1
  ORDER BY 5;
$_$;


ALTER FUNCTION extra.ci_model_area_metesdescription(integer) OWNER TO postgres;

--
-- Name: ci_model_area_point(double precision, double precision); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_area_point(pointy double precision, pointx double precision) RETURNS TABLE(governmentshapeid integer)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
 SELECT DISTINCT governmentshape.governmentshapeid
   FROM gis.governmentshape
  WHERE ST_Contains(governmentshape.governmentshapegeometry, ST_SetSRID(ST_Point(pointx,pointy),4326))
  ORDER BY 1;
 $$;


ALTER FUNCTION extra.ci_model_area_point(pointy double precision, pointx double precision) OWNER TO postgres;

--
-- Name: ci_model_event_adjudication(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_event_adjudication(integer) RETURNS TABLE(adjudicationslug text, adjudicationtypelong character varying, tribunallong text, adjudicationnumber character varying, adjudicationterm text, adjudicationtermsort character varying, eventrelationship character varying)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT adjudicationextracache.adjudicationslug,
    adjudicationtype.adjudicationtypelong,
    extra.tribunallong(adjudicationtype.tribunal) AS tribunallong,
    adjudication.adjudicationnumber,
    extra.shortdate(adjudication.adjudicationterm || CASE
        WHEN length(adjudication.adjudicationterm) = 4 THEN '-~07-~28'
        WHEN length(adjudication.adjudicationterm) = 7 THEN '-~28'
        ELSE ''
    END) AS adjudicationterm,
    adjudication.adjudicationterm AS adjudicationtermsort,
    eventrelationship.eventrelationshipshort AS eventrelationship
   FROM geohistory.adjudicationevent
   JOIN geohistory.eventrelationship
     ON adjudicationevent.eventrelationship = eventrelationship.eventrelationshipid
   JOIN geohistory.adjudication
     ON adjudicationevent.adjudication = adjudication.adjudicationid
   JOIN extra.adjudicationextracache
     ON adjudication.adjudicationid = adjudicationextracache.adjudicationid
   JOIN geohistory.adjudicationtype
     ON adjudication.adjudicationtype = adjudicationtype.adjudicationtypeid
  WHERE adjudicationevent.event = $1;
 
$_$;


ALTER FUNCTION extra.ci_model_event_adjudication(integer) OWNER TO postgres;

--
-- Name: ci_model_event_affectedgovernment(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_event_affectedgovernment(integer) RETURNS TABLE(id integer, geometry text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
SELECT DISTINCT affectedgovernmentgroup.affectedgovernmentgroupid AS id,
    public.st_asgeojson(public.st_buffer(public.st_collect(governmentshape.governmentshapegeometry), 0)) AS geometry
   FROM geohistory.affectedgovernmentgroup
   JOIN gis.affectedgovernmentgis
     ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgis.affectedgovernment
     AND affectedgovernmentgroup.event = $1
   JOIN gis.governmentshape
     ON affectedgovernmentgis.governmentshape = governmentshape.governmentshapeid
  GROUP BY 1
  ORDER BY 1;
$_$;


ALTER FUNCTION extra.ci_model_event_affectedgovernment(integer) OWNER TO postgres;

--
-- Name: ci_model_event_affectedgovernment2(integer, character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_event_affectedgovernment2(integer, character varying, character varying) RETURNS TABLE(id integer, municipalityfrom text, municipalityfromlong text, affectedtypemunicipalityfrom text, countyfrom text, countyfromshort text, affectedtypecountyfrom text, statefrom text, statefromabbreviation text, affectedtypestatefrom text, municipalityto text, municipalitytolong text, affectedtypemunicipalityto text, countyto text, countytoshort text, affectedtypecountyto text, stateto text, statetoabbreviation text, affectedtypestateto text, textflag boolean, submunicipalityfrom text, submunicipalityfromlong text, affectedtypesubmunicipalityfrom text, submunicipalityto text, submunicipalitytolong text, affectedtypesubmunicipalityto text, subcountyfrom text, subcountyfromshort text, affectedtypesubcountyfrom text, subcountyto text, subcountytoshort text, affectedtypesubcountyto text, geometry text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
SELECT affectedgovernment.affectedgovernmentid AS id,
    extra.governmentstatelink(affectedgovernment.municipalityfrom, $2, $3) AS municipalityfrom,
    extra.governmentlong(affectedgovernment.municipalityfrom, upper($2)) AS municipalityfromlong,
    extra.affectedtypeshort(affectedgovernment.affectedtypemunicipalityfrom) AS affectedtypemunicipalityfrom,
    extra.governmentstatelink(affectedgovernment.countyfrom, $2, $3) AS countyfrom,
    extra.governmentshort(affectedgovernment.countyfrom, upper($2)) AS countyfromshort,
    extra.affectedtypeshort(affectedgovernment.affectedtypecountyfrom) AS affectedtypecountyfrom,
    extra.governmentstatelink(affectedgovernment.statefrom, $2, $3) AS statefrom,
    extra.governmentabbreviation(affectedgovernment.statefrom) AS statefromabbreviation,
    extra.affectedtypeshort(affectedgovernment.affectedtypestatefrom) AS affectedtypestatefrom,
    extra.governmentstatelink(affectedgovernment.municipalityto, $2, $3) AS municipalityto,
    extra.governmentlong(affectedgovernment.municipalityto, upper($2)) AS municipalitytolong,
    extra.affectedtypeshort(affectedgovernment.affectedtypemunicipalityto) AS affectedtypemunicipalityto,
    extra.governmentstatelink(affectedgovernment.countyto, $2, $3) AS countyto,
    extra.governmentshort(affectedgovernment.countyto, upper($2)) AS countytoshort,
    extra.affectedtypeshort(affectedgovernment.affectedtypecountyto) AS affectedtypecountyto,
    extra.governmentstatelink(affectedgovernment.stateto, $2, $3) AS stateto,
    extra.governmentabbreviation(affectedgovernment.stateto) AS statetoabbreviation,
    extra.affectedtypeshort(affectedgovernment.affectedtypestateto) AS affectedtypestateto,
    CASE WHEN affectedgovernment.submunicipalityfrom IS NOT NULL 
      OR affectedgovernment.submunicipalityto IS NOT NULL
      OR affectedgovernment.subcountyfrom IS NOT NULL
      OR affectedgovernment.subcountyto IS NOT NULL THEN TRUE ELSE FALSE END AS textflag,
    extra.nulltoempty(extra.governmentstatelink(affectedgovernment.submunicipalityfrom, $2, $3)) AS submunicipalityfrom,
    extra.nulltoempty(extra.governmentlong(affectedgovernment.submunicipalityfrom, upper($2))) AS submunicipalityfromlong,
    extra.nulltoempty(extra.affectedtypeshort(affectedgovernment.affectedtypesubmunicipalityfrom)) AS affectedtypesubmunicipalityfrom,
    extra.nulltoempty(extra.governmentstatelink(affectedgovernment.submunicipalityto, $2, $3)) AS submunicipalityto,
    extra.nulltoempty(extra.governmentlong(affectedgovernment.submunicipalityto, upper($2))) AS submunicipalitytolong,
    extra.nulltoempty(extra.affectedtypeshort(affectedgovernment.affectedtypesubmunicipalityto)) AS affectedtypesubmunicipalityto,
    extra.nulltoempty(extra.governmentstatelink(affectedgovernment.subcountyfrom, $2, $3)) AS subcountyfrom,
    extra.nulltoempty(extra.governmentshort(affectedgovernment.subcountyfrom, upper($2))) AS subcountyfromshort,
    extra.nulltoempty(extra.affectedtypeshort(affectedgovernment.affectedtypesubcountyfrom)) AS affectedtypesubcountyfrom,
    extra.nulltoempty(extra.governmentstatelink(affectedgovernment.subcountyto, $2, $3)) AS subcountyto,
    extra.nulltoempty(extra.governmentshort(affectedgovernment.subcountyto, upper($2))) AS subcountytoshort,
    extra.nulltoempty(extra.affectedtypeshort(affectedgovernment.affectedtypesubcountyto)) AS affectedtypesubcountyto,
    public.st_asgeojson(public.st_buffer(public.st_collect(governmentshape.governmentshapegeometry), 0)) AS geometry
   FROM extra.affectedgovernment_reconstructed affectedgovernment
   LEFT JOIN gis.affectedgovernmentgis
   ON affectedgovernment.affectedgovernmentid = affectedgovernmentgis.affectedgovernment
   LEFT JOIN gis.governmentshape
   ON affectedgovernmentgis.governmentshape = governmentshape.governmentshapeid   
  WHERE affectedgovernment.event = $1
  GROUP BY id, municipalityfrom, municipalityfromlong, affectedtypemunicipalityfrom, countyfrom, countyfromshort, affectedtypecountyfrom, statefrom, statefromabbreviation, affectedtypestatefrom, municipalityto, municipalitytolong, affectedtypemunicipalityto, countyto, countytoshort, affectedtypecountyto, stateto, statetoabbreviation, affectedtypestateto, submunicipalityfrom, submunicipalityfromlong, affectedtypesubmunicipalityfrom, submunicipalityto, submunicipalitytolong, affectedtypesubmunicipalityto, subcountyfrom, subcountyfromshort, affectedtypesubcountyfrom, subcountyto, subcountytoshort, affectedtypesubcountyto
  ORDER BY affectedgovernmentid;
$_$;


ALTER FUNCTION extra.ci_model_event_affectedgovernment2(integer, character varying, character varying) OWNER TO postgres;

--
-- Name: ci_model_event_affectedgovernment_part(integer, character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_event_affectedgovernment_part(integer, character varying, character varying) RETURNS TABLE(id integer, affectedgovernmentlevellong character varying, affectedgovernmentleveldisplayorder integer, includelink boolean, governmentfrom text, governmentfromlong text, affectedtypefrom text, governmentto text, governmenttolong text, affectedtypeto text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
SELECT DISTINCT affectedgovernmentgrouppart.affectedgovernmentgroup AS id,
    affectedgovernmentlevel.affectedgovernmentlevellong AS affectedgovernmentlevellong,
    affectedgovernmentlevel.affectedgovernmentleveldisplayorder AS affectedgovernmentleveldisplayorder,
    affectedgovernmentlevel.affectedgovernmentlevelgroup = 4 AS includelink,
    extra.nulltoempty(extra.governmentstatelink(affectedgovernmentpart.governmentfrom, $2, $3)) AS governmentfrom,
    extra.nulltoempty(extra.governmentlong(affectedgovernmentpart.governmentfrom, upper($2))) AS governmentfromlong,
    extra.nulltoempty(extra.affectedtypeshort(affectedgovernmentpart.affectedtypefrom)) AS affectedtypefrom,
    extra.nulltoempty(extra.governmentstatelink(affectedgovernmentpart.governmentto, $2, $3)) AS governmentto,
    extra.nulltoempty(extra.governmentlong(affectedgovernmentpart.governmentto, upper($2))) AS governmenttolong,
    extra.nulltoempty(extra.affectedtypeshort(affectedgovernmentpart.affectedtypeto)) AS affectedtypeto
   FROM geohistory.affectedgovernmentgroup
   JOIN geohistory.affectedgovernmentgrouppart
     ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
     AND affectedgovernmentgroup.event = $1
   JOIN geohistory.affectedgovernmentlevel
     ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
   JOIN geohistory.affectedgovernmentpart
     ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
  ORDER BY 1, 2;
$_$;


ALTER FUNCTION extra.ci_model_event_affectedgovernment_part(integer, character varying, character varying) OWNER TO postgres;

--
-- Name: ci_model_event_affectedgovernmentform(integer, character varying, boolean, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_event_affectedgovernmentform(integer, character varying, boolean, character varying) RETURNS TABLE(governmentstatelink text, governmentlong text, governmentformlong text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
SELECT DISTINCT extra.governmentstatelink(affectedgovernmentpart.governmentto, $2, $4) AS governmentstatelink,
    extra.governmentlong(affectedgovernmentpart.governmentto, upper($2)) AS governmentlong,
    extra.governmentformlong(affectedgovernmentpart.governmentformto, $3) governmentformlong
   FROM geohistory.affectedgovernmentgroup
   JOIN geohistory.affectedgovernmentgrouppart
     ON affectedgovernmentgroup.event = $1
     AND affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
   JOIN geohistory.affectedgovernmentpart
     ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
     AND affectedgovernmentpart.governmentformto IS NOT NULL
  ORDER BY 3, 2;
$_$;


ALTER FUNCTION extra.ci_model_event_affectedgovernmentform(integer, character varying, boolean, character varying) OWNER TO postgres;

--
-- Name: ci_model_event_currentgovernment(integer, character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_event_currentgovernment(integer, character varying, character varying) RETURNS TABLE(governmentsubmunicipality text, governmentsubmunicipalitylong text, governmentmunicipality text, governmentmunicipalitylong text, governmentcounty text, governmentcountyshort text, governmentstate text, governmentstateabbreviation text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
SELECT extra.governmentstatelink(currentgovernment.governmentsubmunicipality, $2, $3) AS governmentsubmunicipality,
    extra.governmentlong(currentgovernment.governmentsubmunicipality, upper($2)) AS governmentsubmunicipalitylong,
    extra.governmentstatelink(currentgovernment.governmentmunicipality, $2, $3) AS governmentmunicipality,
    extra.governmentlong(currentgovernment.governmentmunicipality, upper($2)) AS governmentmunicipalitylong,
    extra.governmentstatelink(currentgovernment.governmentcounty, $2, $3) AS governmentcounty,
    extra.governmentshort(currentgovernment.governmentcounty, upper($2)) AS governmentcountyshort,
    extra.governmentstatelink(currentgovernment.governmentstate, $2, $3) AS governmentstate,
    extra.governmentabbreviation(currentgovernment.governmentstate) AS governmentstateabbreviation
   FROM geohistory.currentgovernment
  WHERE currentgovernment.event = $1
  ORDER BY 8, 6, 4, 2;
$_$;


ALTER FUNCTION extra.ci_model_event_currentgovernment(integer, character varying, character varying) OWNER TO postgres;

--
-- Name: ci_model_event_detail(integer, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_event_detail(integer, character varying) RETURNS TABLE(eventid integer, eventtypeshort character varying, eventmethodlong character varying, eventlong character varying, eventgranted character varying, textflag boolean, eventrange text, eventeffective text, eventeffectivetype text, otherdate text, otherdatetype character varying, eventismapped boolean, government text)
    LANGUAGE sql STABLE
    AS $_$

 SELECT DISTINCT 
    event.eventid,
    eventtype.eventtypeshort,
    eventmethod.eventmethodlong,
    event.eventlong,
    eventgranted.eventgrantedshort AS eventgranted,
        CASE
            WHEN eventgranted.eventgrantedshort = 'government' OR (event.eventfrom = 0 AND event.eventto = 0 AND event.eventeffective::text = ''::text AND event.eventeffectivetypepresumedsource IS NULL AND other.otherdatetype IS NULL) THEN false
            ELSE true
        END AS textflag,
    extra.rangefix(event.eventfrom::text, event.eventto::text) AS eventrange,
    extra.shortdate(event.eventeffective) AS eventeffective,
    eventeffectivetype.eventeffectivetypegroup::text ||
        CASE
            WHEN eventeffectivetype.eventeffectivetypequalifier IS NOT NULL AND eventeffectivetype.eventeffectivetypequalifier::text = ''::text THEN ''::text
            ELSE ': '::text || eventeffectivetype.eventeffectivetypequalifier::text
        END AS eventeffectivetype,
    other.otherdate,
    other.otherdatetype,
    event.eventismapped,
    extra.governmentstatelink(event.government, $2, 'en') AS government
   FROM geohistory.event
     JOIN geohistory.eventgranted
       ON event.eventgranted = eventgranted.eventgrantedid
     JOIN geohistory.eventmethod
       ON event.eventmethod = eventmethod.eventmethodid 
     JOIN geohistory.eventtype
       ON event.eventtype = eventtype.eventtypeid
     LEFT JOIN ( SELECT other_1.otherdate,
            other_1.otherdatetype
           FROM ( SELECT DISTINCT extra.shortdate(filing.filingdate) AS otherdate,
                    'Final Decree'::text AS otherdatetype
                   FROM geohistory.adjudicationevent,
                    geohistory.filing,
                    geohistory.filingtype
                  WHERE adjudicationevent.adjudication = filing.adjudication AND filing.filingtype = filingtype.filingtypeid AND filingtype.filingtypefinalrecording AND adjudicationevent.event = $1
                UNION
                 SELECT DISTINCT extra.shortdate(governmentsource.governmentsourcedate) AS otherdate,
                    'Letters Patent'::text AS otherdatetype
                   FROM geohistory.governmentsource,
                    geohistory.governmentsourceevent
                  WHERE governmentsource.governmentsourceid = governmentsourceevent.governmentsource AND governmentsource.governmentsourcetype::text = 'Letters Patent'::text AND governmentsourceevent.event = $1) other_1
          WHERE 1 = (( SELECT count(*) AS rowct
                   FROM ( SELECT DISTINCT extra.shortdate(filing.filingdate) AS otherdate,
                            'Final Decree'::text AS otherdatetype,
                            true AS isother
                           FROM geohistory.adjudicationevent,
                            geohistory.filing,
                            geohistory.filingtype
                          WHERE adjudicationevent.adjudication = filing.adjudication AND filing.filingtype = filingtype.filingtypeid AND filingtype.filingtypefinalrecording AND adjudicationevent.event = $1
                        UNION
                         SELECT DISTINCT extra.shortdate(governmentsource.governmentsourcedate) AS otherdate,
                            'Letters Patent'::text AS otherdatetype,
                            true AS isother
                           FROM geohistory.governmentsource,
                            geohistory.governmentsourceevent
                          WHERE governmentsource.governmentsourceid = governmentsourceevent.governmentsource AND governmentsource.governmentsourcetype::text = 'Letters Patent'::text AND governmentsourceevent.event = $1) other_2))) other ON 0 = 0
     LEFT JOIN geohistory.eventeffectivetype ON event.eventeffectivetypepresumedsource = eventeffectivetype.eventeffectivetypeid
     LEFT JOIN extra.eventgovernmentcache ON event.eventid = eventgovernmentcache.eventid
     LEFT JOIN extra.governmentrelationcache ON eventgovernmentcache.government = governmentrelationcache.governmentid
  WHERE event.eventid = $1 AND (governmentrelationcache.governmentrelationstate = upper($2) OR governmentrelationcache.governmentrelationstate IS NULL);
 
$_$;


ALTER FUNCTION extra.ci_model_event_detail(integer, character varying) OWNER TO postgres;

--
-- Name: ci_model_event_detail(text, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_event_detail(text, character varying) RETURNS TABLE(eventid integer, eventtypeshort character varying, eventmethodlong character varying, eventlong character varying, eventgranted character varying, textflag boolean, eventrange text, eventeffective text, eventeffectivetype text, otherdate text, otherdatetype character varying, eventismapped boolean, government text, eventslugnew text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
  WITH slugs AS (
    SELECT * FROM extra.eventslugidreplacement($1)
  )
 SELECT ci_model_event_detail.*, 
    slugs.eventslugnew
 FROM extra.ci_model_event_detail((SELECT eventid FROM slugs), $2) ci_model_event_detail,
   slugs;
$_$;


ALTER FUNCTION extra.ci_model_event_detail(text, character varying) OWNER TO postgres;

--
-- Name: ci_model_event_governmentsource(integer, character varying, boolean, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_event_governmentsource(integer, character varying, boolean, character varying) RETURNS TABLE(government text, governmentlong text, governmentsourcetype character varying, governmentsourcenumber character varying, governmentsourcetitle text, governmentsourcedate text, governmentsourcedatesort character varying, governmentsourceapproveddate text, governmentsourceapproveddatesort character varying, governmentsourceeffectivedate text, governmentsourceeffectivedatesort character varying, governmentsourcesort text, governmentsourcebody character varying, governmentsourceterm character varying, governmentsourceapproved boolean, governmentsourceslug text, governmentsourcelocation text, sourcecitationlocation text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
SELECT DISTINCT extra.governmentstatelink(governmentsource.government, $2, $4) AS government,
    extra.governmentlong(governmentsource.government, upper($2)) AS governmentlong,
    governmentsource.governmentsourcetype,
    governmentsource.governmentsourcenumber,
        CASE
            WHEN (NOT $3) AND (governmentsource.governmentsourcetitle ~* '^[~#]' OR governmentsource.governmentsourcetitle ~~ '[Type %') THEN ''
            ELSE governmentsource.governmentsourcetitle
        END AS governmentsourcetitle,
    extra.shortdate(governmentsource.governmentsourcedate) AS governmentsourcedate,
    governmentsource.governmentsourcedate AS governmentsourcedatesort,
    extra.shortdate(governmentsource.governmentsourceapproveddate) AS governmentsourceapproveddate,
    governmentsource.governmentsourceapproveddate AS governmentsourceapproveddatesort,
    extra.shortdate(governmentsource.governmentsourceeffectivedate) AS governmentsourceeffectivedate,
    governmentsource.governmentsourceeffectivedate AS governmentsourceeffectivedatesort,
        CASE
            WHEN governmentsource.governmentsourceapproveddate <> '' THEN governmentsource.governmentsourceapproveddate
            WHEN governmentsource.governmentsourcedate <> '' THEN governmentsource.governmentsourcedate
            WHEN governmentsource.governmentsourceeffectivedate <> '' THEN governmentsource.governmentsourceeffectivedate
            ELSE ''
        END || governmentsource.governmentsourcetype || extra.zeropad(governmentsource.governmentsourcenumber, 5) AS governmentsourcesort,
    governmentsource.governmentsourcebody,
    governmentsource.governmentsourceterm,
    governmentsource.governmentsourceapproved,
    governmentsourceextracache.governmentsourceslug,
    trim(CASE
        WHEN governmentsource.governmentsourcevolumetype = '' OR governmentsource.governmentsourcevolume = '' THEN ''
        ELSE governmentsource.governmentsourcevolumetype
    END ||
    CASE
        WHEN governmentsource.governmentsourcevolume = '' THEN ''
        ELSE ' v. ' || governmentsource.governmentsourcevolume
    END ||
    CASE
        WHEN governmentsource.governmentsourcevolume <> '' AND governmentsource.governmentsourcepagefrom <> '' AND governmentsource.governmentsourcepagefrom <> '0' THEN ', '
        ELSE ''
    END ||
    CASE
        WHEN governmentsource.governmentsourcepagefrom = '' OR governmentsource.governmentsourcepagefrom = '0' THEN ''
        ELSE ' p. ' || extra.rangefix(governmentsource.governmentsourcepagefrom, governmentsource.governmentsourcepageto)
    END) AS governmentsourcelocation,
    trim(CASE
        WHEN governmentsource.sourcecitationvolumetype = '' OR governmentsource.sourcecitationvolume = '' THEN ''
        ELSE governmentsource.sourcecitationvolumetype
    END ||
    CASE
        WHEN governmentsource.sourcecitationvolume = '' THEN ''
        ELSE ' v. ' || governmentsource.sourcecitationvolume
    END ||
    CASE
        WHEN governmentsource.sourcecitationvolume <> '' AND governmentsource.sourcecitationpagefrom <> '' AND governmentsource.sourcecitationpagefrom <> '0' THEN ', '
        ELSE ''
    END ||
    CASE
        WHEN governmentsource.sourcecitationpagefrom = '' OR governmentsource.sourcecitationpagefrom = '0' THEN ''
        ELSE ' p. ' || extra.rangefix(governmentsource.sourcecitationpagefrom, governmentsource.sourcecitationpageto)
    END) AS sourcecitationlocation
   FROM geohistory.governmentsource
   JOIN geohistory.governmentsourceevent
     ON governmentsource.governmentsourceid = governmentsourceevent.governmentsource
     AND governmentsourceevent.event = $1
   LEFT JOIN extra.governmentsourceextracache
     ON governmentsource.governmentsourceid = governmentsourceextracache.governmentsourceid
  ORDER BY 12;
$_$;


ALTER FUNCTION extra.ci_model_event_governmentsource(integer, character varying, boolean, character varying) OWNER TO postgres;

--
-- Name: ci_model_event_law(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_event_law(integer) RETURNS TABLE(lawsectionslug text, lawapproved character varying, lawsectioncitation text, lawsectioneventrelationship character varying, lawsectionfrom character varying, lawnumberchapter smallint, lawgrouplong character varying)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT DISTINCT lawsectionextracache.lawsectionslug,
    law.lawapproved,
    lawsectionextracache.lawsectioncitation,
    eventrelationship.eventrelationshipshort AS lawsectioneventrelationship,
    lawsection.lawsectionfrom,
    law.lawnumberchapter,
    lawgroup.lawgrouplong
   FROM geohistory.law
   JOIN geohistory.lawsection
     ON law.lawid = lawsection.law   
   JOIN extra.lawsectionextracache
     ON lawsection.lawsectionid = lawsectionextracache.lawsectionid
   JOIN geohistory.lawsectionevent
     ON lawsection.lawsectionid = lawsectionevent.lawsection 
     AND lawsectionevent.event = $1
   JOIN geohistory.eventrelationship
     ON lawsectionevent.eventrelationship = eventrelationship.eventrelationshipid
   LEFT JOIN geohistory.lawgroup
     ON lawsectionevent.lawgroup = lawgroup.lawgroupid
  ORDER BY 4, 2, 1;
 
$_$;


ALTER FUNCTION extra.ci_model_event_law(integer) OWNER TO postgres;

--
-- Name: ci_model_event_metesdescription(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_event_metesdescription(integer) RETURNS TABLE(metesdescriptionslug text, metesdescriptiontype character varying, metesdescriptionsource character varying, metesdescriptionbeginningpoint text, metesdescriptionlong text, metesdescriptionacres double precision)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT metesdescriptionextracache.metesdescriptionslug,
    metesdescription.metesdescriptiontype,
    metesdescription.metesdescriptionsource,
    metesdescription.metesdescriptionbeginningpoint,
    metesdescriptionextracache.metesdescriptionlong,
    metesdescription.metesdescriptionacres
   FROM geohistory.metesdescription
   JOIN extra.metesdescriptionextracache
     ON metesdescription.metesdescriptionid = metesdescriptionextracache.metesdescriptionid
  WHERE metesdescription.event = $1
  ORDER BY 5;
 
$_$;


ALTER FUNCTION extra.ci_model_event_metesdescription(integer) OWNER TO postgres;

--
-- Name: ci_model_event_plss(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_event_plss(integer) RETURNS TABLE(plsstownship text, plssfirstdivision text, plssfirstdivisionpart text, plssrelationship character varying)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
-- Need to add support for second division and special survey
 SELECT extra.plsstownshiplong(plss.plsstownship) AS plsstownship,
    plssfirstdivision.plssfirstdivisionlong ||
        CASE
            WHEN plss.plssfirstdivisionnumber = '0' THEN ''
            ELSE ' ' || plss.plssfirstdivisionnumber
        END ||
        CASE
            WHEN plss.plssfirstdivisionduplicate = '0' THEN ''
            ELSE ' ' || plss.plssfirstdivisionduplicate
        END AS plssfirstdivision,
    replace(plss.plssfirstdivisionpart, '|', ', ') AS plssfirstdivisionpart,
    plss.plssrelationship
   FROM geohistory.plss
     LEFT JOIN geohistory.plssfirstdivision
       ON plss.plssfirstdivision = plssfirstdivision.plssfirstdivisionid
  WHERE event = $1;
$_$;


ALTER FUNCTION extra.ci_model_event_plss(integer) OWNER TO postgres;

--
-- Name: ci_model_event_recording(integer, character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_event_recording(integer, character varying, character varying) RETURNS TABLE(government text, governmentshort text, recordingtype character varying, recordinglocation text, recordingnumbertype character varying, recordingnumberlocation text, hasbothtype boolean, recordingdate text, recordingdatesort character varying, recordingeventrelationship character varying, recordingrepositoryshort character varying, recordingrepositoryitemnumber character varying, recordingrepositoryitemrange text, recordingrepositoryitemlocation character varying, recordingrepositoryseries character varying, recordingrepositorycontainer character varying)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
SELECT extra.governmentstatelink(recordingoffice.government, $2, $3) AS government,
    extra.governmentshort(recordingoffice.government, upper($2)) AS governmentshort,
    trim(recordingtype.recordingtypelong || CASE
        WHEN recordingtype.recordingtypetype = '' THEN ''
        ELSE ' ' || recordingtype.recordingtypetype
    END) AS recordingtype,
    trim(CASE
        WHEN recordingtype.recordingtypevolumetype IS NULL OR recordingtype.recordingtypevolumetype = '' OR recording.recordingvolume = '' THEN ''
        WHEN recordingtype.recordingtypevolumetype = 'Volume' THEN 'v.'
        ELSE recordingtype.recordingtypevolumetype
    END ||
    CASE
        WHEN recording.recordingvolumeofficerinitials = '' AND recording.recordingvolume = '' THEN ''
        ELSE ' ' || trim(recording.recordingvolumeofficerinitials || ' ' || recording.recordingvolume)
    END ||
    CASE
        WHEN recording.recordingvolume <> '' AND recording.recordingpage IS NOT NULL AND recording.recordingpage <> '0' THEN ', '
        ELSE ''
    END ||
    CASE
        WHEN recordingtype.recordingtypepagetype IS NULL OR recordingtype.recordingtypepagetype = '' OR recording.recordingpage IS NULL OR (recording.recordingpage = 0 AND recording.recordingpagetext = '') THEN ''
        WHEN recordingtype.recordingtypepagetype = 'Page' THEN 'p.'
        WHEN recordingtype.recordingtypepagetype = 'Number' THEN 'no.'
        ELSE recordingtype.recordingtypepagetype
    END ||
    CASE
        WHEN recording.recordingpage = 0 THEN ''::text
        ELSE ' ' || recording.recordingpage::text
    END || recording.recordingpagetext::text) AS recordinglocation,
    trim(recordingnumbertype.recordingtypelong || CASE
        WHEN recordingnumbertype.recordingtypetype = '' THEN ''
        ELSE ' ' || recordingnumbertype.recordingtypetype
    END) AS recordingnumbertype,
    trim(CASE
        WHEN recording.recordingnumber IS NULL THEN NULL
        ELSE ' no. ' || recording.recordingnumber || recording.recordingnumbertext
    END) AS recordingnumberlocation,
    recordingtype.recordingtypeid IS NOT NULL AND recordingnumbertype.recordingtypeid IS NOT NULL AS hasbothtype,
    extra.shortdate(recording.recordingdate) AS recordingdate,
    recording.recordingdate AS recordingdatesort,
    eventrelationship.eventrelationshipshort AS recordingeventrelationship,
    recording.recordingrepositoryshort,
    recording.recordingrepositoryitemnumber,
    extra.rangefix(recording.recordingrepositoryitemfrom::text, recording.recordingrepositoryitemto::text) AS recordingrepositoryitemrange,
    recording.recordingrepositoryitemlocation,
    recording.recordingrepositoryseries,
    recording.recordingrepositorycontainer
   FROM geohistory.recording
   JOIN geohistory.recordingevent
    ON recording.recordingid = recordingevent.recording
    AND recordingevent.event = $1
   JOIN geohistory.eventrelationship
    ON recordingevent.eventrelationship = eventrelationship.eventrelationshipid
   JOIN geohistory.recordingoffice
    ON recording.recordingoffice = recordingoffice.recordingofficeid
   LEFT JOIN geohistory.recordingtype
    ON recording.recordingtype = recordingtype.recordingtypeid
   LEFT JOIN geohistory.recordingtype recordingnumbertype
     ON recording.recordingnumbertype = recordingnumbertype.recordingtypeid
  ORDER BY 1, 6;
$_$;


ALTER FUNCTION extra.ci_model_event_recording(integer, character varying, character varying) OWNER TO postgres;

--
-- Name: ci_model_event_source(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_event_source(integer) RETURNS TABLE(sourcecitationslug text, sourceabbreviation character varying, sourcecitationdate text, sourcecitationdatesort character varying, sourcecitationdaterange text, sourcecitationdaterangesort character varying, sourcecitationvolume character varying, sourcecitationpage text, sourcecitationtypetitle text, sourcecitationperson text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT sourcecitationextracache.sourcecitationslug,
    sourceextra.sourceabbreviation,
    sourcecitation.sourcecitationdatetype || 
        CASE WHEN sourcecitation.sourcecitationdatetype = '' THEN '' ELSE ' ' END ||
        extra.shortdate(sourcecitation.sourcecitationdate) AS sourcecitationdate,
    sourcecitation.sourcecitationdate AS sourcecitationdatesort,
    sourcecitation.sourcecitationdaterangetype || 
        CASE WHEN sourcecitation.sourcecitationdaterangetype = '' THEN '' ELSE ' ' END ||
    extra.shortdate(sourcecitation.sourcecitationdaterange) AS sourcecitationdaterange,
    sourcecitation.sourcecitationdaterange AS sourcecitationdaterangesort,
    sourcecitation.sourcecitationvolume,
    extra.rangefix(sourcecitation.sourcecitationpagefrom, sourcecitation.sourcecitationpageto) AS sourcecitationpage,
    sourcecitation.sourcecitationtypetitle,
    sourcecitation.sourcecitationperson
   FROM geohistory.source
   JOIN extra.sourceextra
     ON source.sourceid = sourceextra.sourceid
   JOIN geohistory.sourcecitation
     ON source.sourceid = sourcecitation.source
   JOIN extra.sourcecitationextracache
     ON sourcecitation.sourcecitationid = sourcecitationextracache.sourcecitationid
   JOIN geohistory.sourcecitationevent
     ON sourcecitation.sourcecitationid = sourcecitationevent.sourcecitation 
    AND sourcecitationevent.event = $1
  ORDER BY 1, 6, 7, 10;
 
$_$;


ALTER FUNCTION extra.ci_model_event_source(integer) OWNER TO postgres;

--
-- Name: ci_model_government_affectedgovernment(integer, character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_government_affectedgovernment(integer, character varying, character varying) RETURNS TABLE(eventsortdate numeric, event integer, eventslug text, affectedtypesame text, governmentlong text, governmentstatelink text, affectedtypeother text, eventrange text, eventeffective text, eventeffectivesort character varying, eventreconstructed boolean, governmentaffectedlong text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
SELECT DISTINCT extra.eventsortdate(event.eventid) AS eventsortdate,
    affectedgovernment.event,
    eventextracache.eventslug,
    affectedtypesame.affectedtypeshort || CASE
        WHEN affectedgovernment.affectedtypesamewithin THEN ' (Within)'
        ELSE ''
    END AS affectedtypesame,
    extra.governmentlong(affectedgovernment.government, upper($2)) AS governmentlong,
    CASE
        WHEN affectedgovernment.government = ANY (extra.governmentsubstitutedcache($1)) THEN ''
        ELSE extra.governmentstatelink(affectedgovernment.government, $2, $3)
	END AS governmentstatelink,
    affectedtypeother.affectedtypeshort || CASE
        WHEN affectedgovernment.affectedtypeotherwithin THEN ' (Within)'
        ELSE ''
    END AS affectedtypesame,
    extra.rangefix(event.eventfrom::text, event.eventto::text) AS eventrange,
    extra.shortdate(event.eventeffective) AS eventeffective,
    event.eventeffective AS eventeffectivesort,
    NOT eventgranted.eventgrantedcertainty AS eventreconstructed,
    extra.governmentlong(affectedgovernment.governmentaffected, upper($2)) AS governmentaffectedlong
   FROM (
    -- To-From
         SELECT DISTINCT affectedgovernmentgroup.event,
            affectedgovernmentpart.affectedtypeto AS affectedtypesame,
            FALSE AS affectedtypesamewithin,
            affectedgovernmentpart.governmentfrom AS government,
            affectedgovernmentpart.affectedtypefrom AS affectedtypeother,
            FALSE AS affectedtypeotherwithin,
            affectedgovernmentpart.governmentto AS governmentaffected
           FROM geohistory.affectedgovernmentgroup
           JOIN geohistory.affectedgovernmentgrouppart
             ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
           JOIN geohistory.affectedgovernmentpart
             ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
           JOIN extra.governmentsubstitutecache
             ON affectedgovernmentpart.governmentto = governmentsubstitutecache.governmentid
             AND governmentsubstitutecache.governmentsubstitute = $1
        UNION
    -- From-To
         SELECT DISTINCT affectedgovernmentgroup.event,
            affectedgovernmentpart.affectedtypefrom AS affectedtypesame,
            FALSE AS affectedtypesamewithin,
            affectedgovernmentpart.governmentto AS government,
            affectedgovernmentpart.affectedtypeto AS affectedtypeother,
            FALSE AS affectedtypeotherwithin,
            affectedgovernmentpart.governmentfrom AS governmentaffected
           FROM geohistory.affectedgovernmentgroup
           JOIN geohistory.affectedgovernmentgrouppart
             ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
           JOIN geohistory.affectedgovernmentpart
             ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
           JOIN extra.governmentsubstitutecache
             ON affectedgovernmentpart.governmentfrom = governmentsubstitutecache.governmentid
             AND governmentsubstitutecache.governmentsubstitute = $1
        UNION
    -- From-To (Different Level)
         SELECT DISTINCT affectedgovernmentgroup.event,
            affectedgovernmentpart.affectedtypefrom AS affectedtypesame,
            affectedgovernmentlevel.affectedgovernmentleveldisplayorder < otherlevel.affectedgovernmentleveldisplayorder AS affectedtypesamewithin,
            otherpart.governmentto AS government,
            otherpart.affectedtypeto AS affectedtypeother,
            affectedgovernmentlevel.affectedgovernmentleveldisplayorder > otherlevel.affectedgovernmentleveldisplayorder AS affectedtypeotherwithin,
            affectedgovernmentpart.governmentfrom AS governmentaffected
           FROM geohistory.affectedgovernmentgroup
           JOIN geohistory.affectedgovernmentgrouppart
             ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
           JOIN geohistory.affectedgovernmentpart
             ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
           JOIN extra.governmentsubstitutecache
             ON affectedgovernmentpart.governmentfrom = governmentsubstitutecache.governmentid
             AND governmentsubstitutecache.governmentsubstitute = $1
           JOIN geohistory.affectedgovernmentlevel
             ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
           JOIN geohistory.affectedgovernmentlevel otherlevel
             ON affectedgovernmentlevel.affectedgovernmentlevelgroup = otherlevel.affectedgovernmentlevelgroup
             AND affectedgovernmentlevel.affectedgovernmentlevelid <> otherlevel.affectedgovernmentlevelid
           JOIN geohistory.affectedgovernmentgrouppart othergrouppart
             ON affectedgovernmentgroup.affectedgovernmentgroupid = othergrouppart.affectedgovernmentgroup
             AND othergrouppart.affectedgovernmentlevel = otherlevel.affectedgovernmentlevelid
           JOIN geohistory.affectedgovernmentpart otherpart
             ON othergrouppart.affectedgovernmentpart = otherpart.affectedgovernmentpartid
             AND otherpart.governmentto IS NOT NULL
        UNION
    -- To-From (Different Level)
         SELECT DISTINCT affectedgovernmentgroup.event,
            affectedgovernmentpart.affectedtypeto AS affectedtypesame,
            affectedgovernmentlevel.affectedgovernmentleveldisplayorder < otherlevel.affectedgovernmentleveldisplayorder AS affectedtypesamewithin,
            otherpart.governmentfrom AS government,
            otherpart.affectedtypefrom AS affectedtypeother,
            affectedgovernmentlevel.affectedgovernmentleveldisplayorder > otherlevel.affectedgovernmentleveldisplayorder AS affectedtypeotherwithin,
            affectedgovernmentpart.governmentto AS governmentaffected
           FROM geohistory.affectedgovernmentgroup
           JOIN geohistory.affectedgovernmentgrouppart
             ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
           JOIN geohistory.affectedgovernmentpart
             ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
           JOIN extra.governmentsubstitutecache
             ON affectedgovernmentpart.governmentto = governmentsubstitutecache.governmentid
             AND governmentsubstitutecache.governmentsubstitute = $1
           JOIN geohistory.affectedgovernmentlevel
             ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
           JOIN geohistory.affectedgovernmentlevel otherlevel
             ON affectedgovernmentlevel.affectedgovernmentlevelgroup = otherlevel.affectedgovernmentlevelgroup
             AND affectedgovernmentlevel.affectedgovernmentlevelid <> otherlevel.affectedgovernmentlevelid
           JOIN geohistory.affectedgovernmentgrouppart othergrouppart
             ON affectedgovernmentgroup.affectedgovernmentgroupid = othergrouppart.affectedgovernmentgroup
             AND othergrouppart.affectedgovernmentlevel = otherlevel.affectedgovernmentlevelid
           JOIN geohistory.affectedgovernmentpart otherpart
             ON othergrouppart.affectedgovernmentpart = otherpart.affectedgovernmentpartid
             AND otherpart.governmentfrom IS NOT NULL
   ) AS affectedgovernment
    JOIN geohistory.event
      ON affectedgovernment.event = event.eventid
    JOIN extra.eventextracache
      ON event.eventid = eventextracache.eventid
      AND eventextracache.eventslugnew IS NULL
    JOIN geohistory.eventgranted
      ON event.eventgranted = eventgranted.eventgrantedid
      AND eventgranted.eventgrantedsuccess
    JOIN geohistory.affectedtype affectedtypesame
      ON affectedgovernment.affectedtypesame = affectedtypesame.affectedtypeid
    JOIN geohistory.affectedtype affectedtypeother
      ON affectedgovernment.affectedtypeother = affectedtypeother.affectedtypeid
  WHERE affectedgovernment.government <> affectedgovernment.governmentaffected
    AND NOT (
      (
        affectedtypesame.affectedtypecreationdissolution = ''
        AND affectedtypeother.affectedtypecreationdissolution = ''
      ) OR (
        affectedtypesame.affectedtypecreationdissolution IN ('separate', 'subordinate')
        AND affectedgovernment.affectedtypesamewithin
      ) OR (
        affectedtypeother.affectedtypecreationdissolution IN ('separate', 'subordinate')
        AND affectedgovernment.affectedtypeotherwithin
      )
    )
    AND affectedtypesame.affectedtypecreationdissolution <> 'reference'
    AND affectedtypeother.affectedtypecreationdissolution <> 'reference'
  ORDER BY 1, 4, 5, 7;
$_$;


ALTER FUNCTION extra.ci_model_government_affectedgovernment(integer, character varying, character varying) OWNER TO postgres;

--
-- Name: ci_model_governmentabbreviation(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_governmentabbreviation(integer) RETURNS TABLE(governmentabbreviation text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

        SELECT * FROM extra.governmentabbreviation($1);
    
$_$;


ALTER FUNCTION extra.ci_model_governmentabbreviation(integer) OWNER TO postgres;

--
-- Name: ci_model_governmentabbreviationid(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_governmentabbreviationid(text) RETURNS TABLE(governmentabbreviationid integer)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

        SELECT * FROM extra.governmentabbreviationid(upper($1));
    
$_$;


ALTER FUNCTION extra.ci_model_governmentabbreviationid(text) OWNER TO postgres;

--
-- Name: ci_model_governmentidentifier_detail(text, text, text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_governmentidentifier_detail(text, text, text) RETURNS TABLE(governmentidentifiertypetype character varying, governmentidentifiertypeshort character varying, governmentidentifier text, governmentidentifiertypeurl text, governmentidentifierids integer[], governments text[])
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT governmentidentifiertype.governmentidentifiertypetype,
    governmentidentifiertype.governmentidentifiertypeshort,
    governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier AS governmentidentifier,
    replace(replace(governmentidentifiertype.governmentidentifiertypeurl, '<Identifier>', governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier), '<Language>', $3) AS governmentidentifiertypeurl,
    array_agg(DISTINCT governmentidentifier.governmentidentifierid ORDER BY governmentidentifier.governmentidentifierid) AS governmentidentifierids,
    string_to_array(array_to_string(array_agg(DISTINCT governmentidentifier.government ORDER BY governmentidentifier.government), '|'), '|') AS governments
   FROM geohistory.governmentidentifier
     JOIN geohistory.governmentidentifiertype
       ON governmentidentifier.governmentidentifiertype = governmentidentifiertype.governmentidentifiertypeid
       AND governmentidentifiertype.governmentidentifiertypeslug = $1
  WHERE lower(governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier) = lower($2)
  GROUP BY 1, 2, 3, 4;
 
$_$;


ALTER FUNCTION extra.ci_model_governmentidentifier_detail(text, text, text) OWNER TO postgres;

--
-- Name: ci_model_governmentidentifier_government(integer[], character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_governmentidentifier_government(integer[], character varying) RETURNS TABLE(governmentstatelink text, governmentlong text, governmentparentstatus text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
SELECT extra.governmentstatelink(governmentidentifier.government, '--', $2) governmentstatelink,
    extra.governmentlong(governmentidentifier.government, '--') AS governmentlong,
    governmentidentifier.governmentidentifierstatus AS governmentparentstatus
   FROM geohistory.governmentidentifier
  WHERE governmentidentifier.governmentidentifierid = ANY ($1);
$_$;


ALTER FUNCTION extra.ci_model_governmentidentifier_government(integer[], character varying) OWNER TO postgres;

--
-- Name: ci_model_governmentidentifier_related(integer[], integer[], text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_governmentidentifier_related(integer[], integer[], text) RETURNS TABLE(governmentidentifiertypetype character varying, governmentidentifiertypeslug text, governmentidentifiertypeshort character varying, governmentidentifier text, governmentidentifiertypeurl text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT DISTINCT governmentidentifiertype.governmentidentifiertypetype,
    governmentidentifiertype.governmentidentifiertypeslug,
    governmentidentifiertype.governmentidentifiertypeshort,
    governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier AS governmentidentifier,
    replace(replace(governmentidentifiertype.governmentidentifiertypeurl, '<Identifier>', governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier), '<Language>', $3) AS governmentidentifiertypeurl
   FROM geohistory.governmentidentifier
     JOIN geohistory.governmentidentifiertype
       ON governmentidentifier.governmentidentifiertype = governmentidentifiertype.governmentidentifiertypeid
  WHERE governmentidentifier.government = ANY ($1)
    AND governmentidentifier.governmentidentifierid <> ALL ($2);
 
$_$;


ALTER FUNCTION extra.ci_model_governmentidentifier_related(integer[], integer[], text) OWNER TO postgres;

--
-- Name: ci_model_governmentlong(integer, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_governmentlong(integer, character varying) RETURNS TABLE(governmentlong text)
    LANGUAGE sql STABLE
    AS $_$

        SELECT * FROM extra.governmentlong($1, upper($2));
    
$_$;


ALTER FUNCTION extra.ci_model_governmentlong(integer, character varying) OWNER TO postgres;

--
-- Name: ci_model_governmentrecording_detail(integer, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_governmentrecording_detail(integer, character varying) RETURNS TABLE(recordingoffice text, recordingdate character varying, volumetype character varying, recordingvolume text, recordingpage text, numbertype character varying, recordingnumber text, recordinglocation character varying, recordinglocationstart character varying, recordingsummary text, eventid integer)
    LANGUAGE sql STABLE
    AS $_$
 
 SELECT DISTINCT recordingofficetype.recordingofficetypeshort ||
        CASE
            WHEN recordingoffice.recordingofficedistrictcircuit <> '' THEN recordingoffice.recordingofficedistrictcircuit || '.'
            ELSE ''
        END AS recordingoffice,
    recording.recordingdate,
    volumetype.recordingtypeshort AS volumetype,
        CASE
            WHEN recording.recordingvolumeofficerinitials <> '' THEN recording.recordingvolumeofficerinitials || ' '
            ELSE ''
        END || recording.recordingvolume AS recordingvolume,
    recording.recordingpage || recording.recordingpagetext AS recordingpage,
    numbertype.recordingtypeshort AS numbertype,
    recording.recordingnumber || recording.recordingnumbertext AS recordingnumber,
    recording.recordingrepositoryitemnumber || CASE
	    WHEN recording.recordingrepositoryitemlocation <> '' THEN ' (' || recording.recordingrepositoryitemlocation || ')'
		ELSE ''
	END AS recordinglocation,
    recordingrepositoryitemfrom AS recordinglocationstart,
        CASE
            WHEN event.eventlong IS NOT NULL AND event.eventlong <> '*Dummy Record*' AND eventrelationship.eventrelationshipshort = 'direct' THEN event.eventlong
            WHEN event.eventlong IS NOT NULL AND event.eventlong <> '*Dummy Record*' THEN '^' || event.eventlong
            ELSE '~' || recording.recordingdescription
        END AS recordingsummary,
        CASE
            WHEN event.eventlong IS NOT NULL AND event.eventlong <> '*Dummy Record*' THEN event.eventid
            ELSE NULL
        END AS eventid
   FROM geohistory.recording
     JOIN geohistory.recordingoffice
       ON recording.recordingoffice = recordingoffice.recordingofficeid
     JOIN geohistory.recordingofficetype
       ON recordingoffice.recordingofficetype = recordingofficetype.recordingofficetypeid
     LEFT JOIN geohistory.recordingtype volumetype
       ON recording.recordingtype = volumetype.recordingtypeid
     LEFT JOIN geohistory.recordingtype numbertype
       ON recording.recordingnumbertype = numbertype.recordingtypeid
     LEFT JOIN geohistory.recordingevent
       ON recording.recordingid = recordingevent.recording
     LEFT JOIN geohistory.eventrelationship
       ON recordingevent.eventrelationship = eventrelationship.eventrelationshipid
     LEFT JOIN geohistory.event
       ON recordingevent.event = event.eventid
  WHERE recordingoffice.government = $1
  ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9;
 
$_$;


ALTER FUNCTION extra.ci_model_governmentrecording_detail(integer, character varying) OWNER TO postgres;

--
-- Name: ci_model_governmentsource_detail(integer, character varying, boolean, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_governmentsource_detail(integer, character varying, boolean, character varying) RETURNS TABLE(governmentsourceid integer, government text, governmentlong text, governmentsourcetype character varying, governmentsourcenumber character varying, governmentsourcetitle text, governmentsourcedate text, governmentsourcedatesort character varying, governmentsourceapproveddate text, governmentsourceapproveddatesort character varying, governmentsourceeffectivedate text, governmentsourceeffectivedatesort character varying, governmentsourcesort text, governmentsourcebody character varying, governmentsourceterm character varying, governmentsourceapproved boolean, governmentsourcelocation text, sourcecitationlocation text, sourceabbreviation character varying, sourcetype character varying, sourcefullcitation text, sourceid integer, linktype text)
    LANGUAGE sql STABLE
    AS $_$
SELECT DISTINCT governmentsource.governmentsourceid,
    extra.governmentstatelink(governmentsource.government, $2, $4) AS government,
    extra.governmentlong(governmentsource.government, upper($2)) AS governmentlong,
    governmentsource.governmentsourcetype,
    governmentsource.governmentsourcenumber,
        CASE
            WHEN (NOT $3) AND (governmentsource.governmentsourcetitle ~* '^[~#]' OR governmentsource.governmentsourcetitle ~~ '[Type %') THEN ''
            ELSE governmentsource.governmentsourcetitle
        END AS governmentsourcetitle,
    extra.shortdate(governmentsource.governmentsourcedate) AS governmentsourcedate,
    governmentsource.governmentsourcedate AS governmentsourcedatesort,
    extra.shortdate(governmentsource.governmentsourceapproveddate) AS governmentsourceapproveddate,
    governmentsource.governmentsourceapproveddate AS governmentsourceapproveddatesort,
    extra.shortdate(governmentsource.governmentsourceeffectivedate) AS governmentsourceeffectivedate,
    governmentsource.governmentsourceeffectivedate AS governmentsourceeffectivedatesort,
        CASE
            WHEN governmentsource.governmentsourceapproveddate <> '' THEN governmentsource.governmentsourceapproveddate
            WHEN governmentsource.governmentsourcedate <> '' THEN governmentsource.governmentsourcedate
            WHEN governmentsource.governmentsourceeffectivedate <> '' THEN governmentsource.governmentsourceeffectivedate
            ELSE ''
        END || governmentsource.governmentsourcetype || extra.zeropad(governmentsource.governmentsourcenumber, 5) AS governmentsourcesort,
    governmentsource.governmentsourcebody,
    governmentsource.governmentsourceterm,
    governmentsource.governmentsourceapproved,
    trim(CASE
        WHEN governmentsource.governmentsourcevolumetype = '' OR governmentsource.governmentsourcevolume = '' THEN ''
        ELSE governmentsource.governmentsourcevolumetype
    END ||
    CASE
        WHEN governmentsource.governmentsourcevolume = '' THEN ''
        ELSE ' v. ' || governmentsource.governmentsourcevolume
    END ||
    CASE
        WHEN governmentsource.governmentsourcevolume <> '' AND governmentsource.governmentsourcepagefrom <> '' AND governmentsource.governmentsourcepagefrom <> '0' THEN ', '
        ELSE ''
    END ||
    CASE
        WHEN governmentsource.governmentsourcepagefrom = '' OR governmentsource.governmentsourcepagefrom = '0' THEN ''
        ELSE ' p. ' || extra.rangefix(governmentsource.governmentsourcepagefrom, governmentsource.governmentsourcepageto)
    END) AS governmentsourcelocation,
    trim(CASE
        WHEN governmentsource.sourcecitationvolumetype = '' OR governmentsource.sourcecitationvolume = '' THEN ''
        ELSE governmentsource.sourcecitationvolumetype
    END ||
    CASE
        WHEN governmentsource.sourcecitationvolume = '' THEN ''
        ELSE ' v. ' || governmentsource.sourcecitationvolume
    END ||
    CASE
        WHEN governmentsource.sourcecitationvolume <> '' AND governmentsource.sourcecitationpagefrom <> '' AND governmentsource.sourcecitationpagefrom <> '0' THEN ', '
        ELSE ''
    END ||
    CASE
        WHEN governmentsource.sourcecitationpagefrom = '' OR governmentsource.sourcecitationpagefrom = '0' THEN ''
        ELSE ' p. ' || extra.rangefix(governmentsource.sourcecitationpagefrom, governmentsource.sourcecitationpageto)
    END) AS sourcecitationlocation,
    sourceextra.sourceabbreviation,
    source.sourcetype,
    sourceextra.sourcefullcitation,
    source.sourceid,
    'sourceitem' AS linktype
   FROM geohistory.governmentsource
   JOIN geohistory.source
     ON governmentsource.source = source.sourceid
   JOIN extra.sourceextra
     ON source.sourceid = sourceextra.sourceid
   WHERE governmentsource.governmentsourceid = $1;
   -- Add state filter
$_$;


ALTER FUNCTION extra.ci_model_governmentsource_detail(integer, character varying, boolean, character varying) OWNER TO postgres;

--
-- Name: ci_model_governmentsource_detail(text, character varying, boolean, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_governmentsource_detail(text, character varying, boolean, character varying) RETURNS TABLE(governmentsourceid integer, government text, governmentlong text, governmentsourcetype character varying, governmentsourcenumber character varying, governmentsourcetitle text, governmentsourcedate text, governmentsourcedatesort character varying, governmentsourceapproveddate text, governmentsourceapproveddatesort character varying, governmentsourceeffectivedate text, governmentsourceeffectivedatesort character varying, governmentsourcesort text, governmentsourcebody character varying, governmentsourceterm character varying, governmentsourceapproved boolean, governmentsourcelocation text, sourcecitationlocation text, sourceabbreviation character varying, sourcetype character varying, sourcefullcitation text, sourceid integer, linktype text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
SELECT * FROM extra.ci_model_governmentsource_detail(extra.governmentsourceslugid($1), $2, $3, $4);
$_$;


ALTER FUNCTION extra.ci_model_governmentsource_detail(text, character varying, boolean, character varying) OWNER TO postgres;

--
-- Name: ci_model_governmentsource_event(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_governmentsource_event(integer) RETURNS TABLE(eventslug text, eventtypeshort character varying, eventlong character varying, eventrange text, eventgranted character varying, eventeffective text, eventsortdate numeric)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT DISTINCT eventextracache.eventslug,
    eventtype.eventtypeshort,
    event.eventlong,
    extra.rangefix(event.eventfrom::text, event.eventto::text) AS eventrange,
    eventgranted.eventgrantedshort AS eventgranted,
    extra.shortdate(event.eventeffective) AS eventeffective,
    extra.eventsortdate(event.eventid) AS eventsortdate
   FROM geohistory.event
   JOIN geohistory.eventgranted
     ON event.eventgranted = eventgranted.eventgrantedid
   JOIN geohistory.eventtype
     ON event.eventtype = eventtype.eventtypeid
   JOIN extra.eventextracache
     ON event.eventid = eventextracache.eventid
     AND eventextracache.eventslugnew IS NULL
   JOIN geohistory.governmentsourceevent
     ON event.eventid = governmentsourceevent.event 
     AND governmentsourceevent.governmentsource = $1
  ORDER BY (extra.eventsortdate(event.eventid)), event.eventlong;
$_$;


ALTER FUNCTION extra.ci_model_governmentsource_event(integer) OWNER TO postgres;

--
-- Name: ci_model_governmentsource_url(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_governmentsource_url(integer) RETURNS TABLE(url text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT sourceitem.sourceitemurl ||
        CASE
            WHEN sourceitem.sourceitemurlcomplete THEN ''::text
            ELSE
            CASE
                WHEN sourcecitationpagefrom ~ '^\d+$' THEN sourceitempart.sourceitempartsequencecharacter::text || (sourceitempart.sourceitempartsequence + sourcecitationpagefrom::integer)
                ELSE lpad((sourceitempart.sourceitempartsequence + 0)::text, 4, '0'::text) || sourceitempart.sourceitempartsequencecharacter::text
            END || sourceitempart.sourceitempartsequencecharacterafter::text
        END AS url
   FROM geohistory.governmentsource
   JOIN geohistory.sourceitem
     ON sourceitem.source = ANY (extra.sourceurlid(governmentsource.source))
   JOIN geohistory.sourceitempart
     ON sourceitem.sourceitemid = sourceitempart.sourceitem
   WHERE (
     (sourceitempartfrom IS NULL AND sourceitempartto IS NULL) OR
     sourceitem.sourceitemurlcomplete OR
     (sourceitempartisbypage AND sourcecitationpagefrom ~ '^\d+$' AND sourcecitationpageto ~ '^\d+$' AND sourceitempartfrom <= sourcecitationpagefrom::integer AND sourceitempartto >= sourcecitationpagefrom::integer)
    ) AND (
      (sourcecitationvolume = '' AND governmentsourceterm = '' AND sourceitemvolume = '' AND sourceitemyear IS NULL) OR
      (sourcecitationvolume <> '' AND sourcecitationvolume = sourceitemvolume) OR
      (sourcecitationvolume = '' AND governmentsourceterm <> '' AND governmentsourceterm = sourceitemvolume) OR
      (sourcecitationvolume ~ '^\d{4}$' AND sourcecitationvolume::smallint = sourceitemyear) OR
      (sourcecitationvolume = '' AND governmentsourceterm ~ '^\d{4}$' AND governmentsourceterm::smallint = sourceitemyear)
    )
    AND governmentsource.governmentsourceid = $1;
 
$_$;


ALTER FUNCTION extra.ci_model_governmentsource_url(integer) OWNER TO postgres;

--
-- Name: ci_model_lastrefresh(); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_lastrefresh() RETURNS TABLE(fulldate text, sortdate text, sortdatetext text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$

  SELECT extra.fulldate(lastrefreshdate::text) AS fulldate,
    to_char(lastrefreshdate, 'J') AS sortdate,
    to_char(lastrefreshdate, 'Mon FMDD, YYYY') AS sortdatetext
  FROM extra.lastrefresh;
$$;


ALTER FUNCTION extra.ci_model_lastrefresh() OWNER TO postgres;

--
-- Name: ci_model_law_detail(integer, character varying, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_law_detail(integer, character varying, boolean) RETURNS TABLE(lawsectionid integer, lawsectionpagefrom integer, lawsectioncitation text, lawtitle text, url text, sourcetype character varying, sourceabbreviation character varying, sourcefullcitation text)
    LANGUAGE sql STABLE
    AS $_$

 SELECT DISTINCT lawsection.lawsectionid,
    lawsection.lawsectionpagefrom,
    extra.lawsectioncitation(lawsection.lawsectionid) AS lawsectioncitation,
    CASE
        WHEN (NOT $3) AND left(law.lawtitle, 1) = '~' THEN ''
        ELSE law.lawtitle
    END AS lawtitle,
    law.lawurl AS url,
    source.sourcetype,
    sourceextra.sourceabbreviation,
    sourceextra.sourcefullcitation
   FROM geohistory.source
   JOIN extra.sourceextra
     ON source.sourceid = sourceextra.sourceid
   JOIN geohistory.law
     ON source.sourceid = law.source
   JOIN geohistory.lawsection
     ON law.lawid = lawsection.law
     AND lawsection.lawsectionid = $1 
   LEFT JOIN extra.lawsectiongovernmentcache 
     ON lawsection.lawsectionid = lawsectiongovernmentcache.lawsectionid
  WHERE governmentrelationstate = upper($2)
    OR governmentrelationstate IS NULL;
 
$_$;


ALTER FUNCTION extra.ci_model_law_detail(integer, character varying, boolean) OWNER TO postgres;

--
-- Name: ci_model_law_detail(text, character varying, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_law_detail(text, character varying, boolean) RETURNS TABLE(lawsectionid integer, lawsectionpagefrom integer, lawsectioncitation text, lawtitle text, url text, sourcetype character varying, sourceabbreviation character varying, sourcefullcitation text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT * FROM extra.ci_model_law_detail(extra.lawsectionslugid($1), $2, $3);
 
$_$;


ALTER FUNCTION extra.ci_model_law_detail(text, character varying, boolean) OWNER TO postgres;

--
-- Name: ci_model_law_event(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_law_event(integer) RETURNS TABLE(eventslug text, eventtypeshort character varying, eventlong character varying, eventrange text, eventgranted character varying, eventeffective text, eventsortdate numeric, eventrelationship character varying, lawgrouplong character varying)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
SELECT DISTINCT eventextracache.eventslug,
    eventtype.eventtypeshort,
    event.eventlong,
    extra.rangefix(event.eventfrom::text, event.eventto::text) AS eventrange,
    eventgranted.eventgrantedshort AS eventgranted,
    extra.shortdate(event.eventeffective) AS eventeffective,
    extra.eventsortdate(event.eventid) AS eventsortdate,
    eventrelationship.eventrelationshipshort AS eventrelationship,
    lawgroup.lawgrouplong
   FROM geohistory.event
   JOIN geohistory.eventgranted
     ON event.eventgranted = eventgranted.eventgrantedid
   JOIN geohistory.eventtype
     ON event.eventtype = eventtype.eventtypeid
   JOIN extra.eventextracache
     ON event.eventid = eventextracache.eventid
     AND eventextracache.eventslugnew IS NULL
   JOIN geohistory.lawsectionevent
     ON event.eventid = lawsectionevent.event
     AND lawsectionevent.lawsection = $1
   JOIN geohistory.eventrelationship
     ON lawsectionevent.eventrelationship = eventrelationship.eventrelationshipid
   LEFT JOIN geohistory.lawgroup
     ON lawsectionevent.lawgroup = lawgroup.lawgroupid
  ORDER BY (extra.eventsortdate(event.eventid)), event.eventlong;
$_$;


ALTER FUNCTION extra.ci_model_law_event(integer) OWNER TO postgres;

--
-- Name: ci_model_law_related(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_law_related(integer) RETURNS TABLE(lawsectionslug text, lawapproved character varying, lawsectioncitation text, lawsectioneventrelationship character varying, lawsectionfrom character varying, lawnumberchapter smallint)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT DISTINCT lawsectionextracache.lawsectionslug,
    law.lawapproved,
    lawsectionextracache.lawsectioncitation,
    'Amends'::text AS lawsectioneventrelationship,
    lawsection.lawsectionfrom,
    law.lawnumberchapter
   FROM geohistory.law
   JOIN geohistory.lawsection
     ON law.lawid = lawsection.law
   JOIN extra.lawsectionextracache
     ON lawsection.lawsectionid = lawsectionextracache.lawsectionid     
   JOIN geohistory.lawsection currentlawsection
     ON lawsection.lawsectionid = currentlawsection.lawsectionamend
     AND currentlawsection.lawsectionid = $1
UNION
 SELECT DISTINCT lawsectionextracache.lawsectionslug,
    law.lawapproved,
    lawsectionextracache.lawsectioncitation,
    'Amended By'::text AS lawsectioneventrelationship,
    lawsection.lawsectionfrom,
    law.lawnumberchapter
   FROM geohistory.law
   JOIN geohistory.lawsection
     ON law.lawid = lawsection.law
     AND lawsection.lawsectionamend = $1
   JOIN extra.lawsectionextracache
     ON lawsection.lawsectionid = lawsectionextracache.lawsectionid
UNION
 SELECT DISTINCT lawalternatesectionextracache.lawsectionslug,
    law.lawapproved,
    lawalternatesectionextracache.lawsectioncitation,
    'Alternate'::text AS lawsectioneventrelationship,
    lawsection.lawsectionfrom,
    law.lawnumberchapter
   FROM geohistory.law
   JOIN geohistory.lawsection
     ON law.lawid = lawsection.law
   JOIN geohistory.lawalternatesection
     ON lawsection.lawsectionid = lawalternatesection.lawsection
     AND lawalternatesection.lawsection = $1
   JOIN extra.lawalternatesectionextracache
     ON lawalternatesection.lawalternatesectionid = lawalternatesectionextracache.lawsectionid
UNION
 SELECT DISTINCT NULL AS lawsectionslug,
    law.lawapproved,
    extra.lawcitation(law.lawid) AS lawsectioncitation,
    'Amended To Add ' || lawsection.lawsectionnewsymbol || CASE
        WHEN lawsection.lawsectionnewfrom <> lawsection.lawsectionnewto THEN lawsection.lawsectionnewsymbol
        ELSE ''
    END || ' ' || extra.rangefix(lawsection.lawsectionnewfrom, lawsection.lawsectionnewto) AS lawsectioneventrelationship,
    lawsection.lawsectionnewfrom AS lawsectionfrom,
    law.lawnumberchapter
   FROM geohistory.law
   JOIN geohistory.lawsection
     ON law.lawid = lawsection.lawsectionnewlaw
     AND lawsection.lawsectionid = $1
  ORDER BY 4, 3;
 
$_$;


ALTER FUNCTION extra.ci_model_law_related(integer) OWNER TO postgres;

--
-- Name: ci_model_law_url(integer, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_law_url(integer, boolean) RETURNS TABLE(url text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT sourceitem.sourceitemurl ||
        CASE
            WHEN sourceitem.sourceitemurlcomplete THEN ''
            ELSE (sourceitempart.sourceitempartsequencecharacter || extra.zeropad(sourceitempart.sourceitempartsequence +
            CASE
                WHEN sourceitempart.sourceitempartisbypage THEN lawsection.lawsectionpagefrom
                ELSE law.lawnumberchapter
            END, sourceitempart.sourceitempartzeropad)) || sourceitempart.sourceitempartsequencecharacterafter
        END AS url
   FROM geohistory.lawsection
   JOIN geohistory.law
     ON lawsection.law = law.lawid
   JOIN geohistory.sourceitem
     ON sourceitem.source = ANY (extra.sourceurlid(law.source))
   JOIN geohistory.sourceitempart
     ON sourceitem.sourceitemid = sourceitempart.sourceitem
   WHERE (
     (
        sourceitem.sourceitemvolume <> ''
          AND sourceitem.sourceitemyear IS NULL
		  AND (sourceitem.sourceitemvolume = law.lawvolume OR (law.lawvolume = '' AND sourceitem.sourceitemvolume = substring(law.lawapproved FOR 4)))
     ) OR (
        sourceitem.sourceitemvolume <> ''
          AND sourceitem.sourceitemyear IS NOT NULL
          AND sourceitem.sourceitemvolume = law.lawvolume
          AND sourceitem.sourceitemyear::character varying = substring(law.lawapproved FOR 4)
     ) OR (
        sourceitem.sourceitemvolume = ''
          AND sourceitem.sourceitemyear IS NOT NULL
          AND ((sourceitem.sourceitemyear::character varying = law.lawvolume) OR (law.lawvolume = '' AND sourceitem.sourceitemyear::character varying = substring(law.lawapproved FOR 4)))
     ) OR (
        sourceitem.sourceitemvolume = '' AND sourceitem.sourceitemyear IS NULL
     )
   ) AND (
     (sourceitempartfrom IS NULL AND sourceitempartto IS NULL) OR
     (sourceitempartisbypage AND sourceitempartfrom <= lawsectionpagefrom AND sourceitempartto >= lawsectionpagefrom) OR
     (NOT sourceitempartisbypage AND sourceitempartfrom <= lawnumberchapter AND sourceitempartto >= lawnumberchapter)
    ) AND lawsection.lawsectionid = $1
    AND ($2 OR NOT sourceitem.sourceitemlocal);
 
$_$;


ALTER FUNCTION extra.ci_model_law_url(integer, boolean) OWNER TO postgres;

--
-- Name: ci_model_lawalternate_detail(integer, character varying, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_lawalternate_detail(integer, character varying, boolean) RETURNS TABLE(lawsectionid integer, lawsectionpagefrom smallint, lawsectioncitation text, lawtitle text, url text, sourcetype character varying, sourceabbreviation character varying, sourcefullcitation text)
    LANGUAGE sql STABLE
    AS $_$

 SELECT DISTINCT lawalternatesection.lawalternatesectionid AS lawsectionid,
    lawalternatesection.lawalternatesectionpagefrom AS lawsectionpagefrom,
    extra.lawalternatesectioncitation(lawalternatesection.lawalternatesectionid) AS lawsectioncitation,
    CASE
        WHEN (NOT $3) AND left(law.lawtitle, 1) = '~' THEN ''
        ELSE law.lawtitle
    END AS lawtitle,
    '' AS url,
    source.sourcetype,
    sourceextra.sourceabbreviation,
    sourceextra.sourcefullcitation
   FROM geohistory.source
   JOIN extra.sourceextra
     ON source.sourceid = sourceextra.sourceid
   JOIN geohistory.lawalternate
     ON source.sourceid = lawalternate.source
   JOIN geohistory.law
     ON lawalternate.law = law.lawid
   JOIN geohistory.lawalternatesection
     ON lawalternate.lawalternateid = lawalternatesection.lawalternate
     AND lawalternatesection.lawalternatesectionid = $1
   LEFT JOIN extra.lawsectiongovernmentcache 
     ON lawalternatesection.lawsection = lawsectiongovernmentcache.lawsectionid
  WHERE governmentrelationstate = upper($2)
    OR governmentrelationstate IS NULL;
 
$_$;


ALTER FUNCTION extra.ci_model_lawalternate_detail(integer, character varying, boolean) OWNER TO postgres;

--
-- Name: ci_model_lawalternate_detail(text, character varying, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_lawalternate_detail(text, character varying, boolean) RETURNS TABLE(lawsectionid integer, lawsectionpagefrom smallint, lawsectioncitation text, lawtitle text, url text, sourcetype character varying, sourceabbreviation character varying, sourcefullcitation text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT * FROM extra.ci_model_lawalternate_detail(extra.lawalternatesectionslugid($1), $2, $3);
 
$_$;


ALTER FUNCTION extra.ci_model_lawalternate_detail(text, character varying, boolean) OWNER TO postgres;

--
-- Name: ci_model_lawalternate_event(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_lawalternate_event(integer) RETURNS TABLE(eventslug text, eventtypeshort character varying, eventlong character varying, eventrange text, eventgranted character varying, eventeffective text, eventsortdate numeric, eventrelationship character varying, lawgrouplong character varying)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
SELECT DISTINCT eventextracache.eventslug,
    eventtype.eventtypeshort,
    event.eventlong,
    extra.rangefix(event.eventfrom::text, event.eventto::text) AS eventrange,
    eventgranted.eventgrantedshort AS eventgranted,
    extra.shortdate(event.eventeffective) AS eventeffective,
    extra.eventsortdate(event.eventid) AS eventsortdate,
    eventrelationship.eventrelationshipshort AS eventrelationship,
    lawgroup.lawgrouplong
   FROM geohistory.event
   JOIN geohistory.eventgranted
     ON event.eventgranted = eventgranted.eventgrantedid
   JOIN geohistory.eventtype
     ON event.eventtype = eventtype.eventtypeid
   JOIN extra.eventextracache
     ON event.eventid = eventextracache.eventid
     AND eventextracache.eventslugnew IS NULL
   JOIN geohistory.lawsectionevent
     ON event.eventid = lawsectionevent.event
   JOIN geohistory.eventrelationship
     ON lawsectionevent.eventrelationship = eventrelationship.eventrelationshipid
   JOIN geohistory.lawalternatesection
     ON lawsectionevent.lawsection = lawalternatesection.lawsection
     AND lawalternatesection.lawalternatesectionid = $1
   LEFT JOIN geohistory.lawgroup
     ON lawsectionevent.lawgroup = lawgroup.lawgroupid
  ORDER BY (extra.eventsortdate(event.eventid)), event.eventlong;
$_$;


ALTER FUNCTION extra.ci_model_lawalternate_event(integer) OWNER TO postgres;

--
-- Name: ci_model_lawalternate_related(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_lawalternate_related(integer) RETURNS TABLE(lawsectionslug text, lawapproved character varying, lawsectioncitation text, lawsectioneventrelationship character varying, lawsectionfrom character varying, lawnumberchapter smallint)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT DISTINCT lawsectionextracache.lawsectionslug,
    law.lawapproved,
    lawsectionextracache.lawsectioncitation,
    'Amends'::text AS lawsectioneventrelationship,
    lawsection.lawsectionfrom,
    law.lawnumberchapter
   FROM geohistory.law
   JOIN geohistory.lawsection
     ON law.lawid = lawsection.law
   JOIN extra.lawsectionextracache
     ON lawsection.lawsectionid = lawsectionextracache.lawsectionid    
   JOIN geohistory.lawsection currentlawsection
     ON lawsection.lawsectionid = currentlawsection.lawsectionamend
   JOIN geohistory.lawalternatesection
     ON currentlawsection.lawsectionid = lawalternatesection.lawsection
     AND lawalternatesection.lawalternatesectionid = $1
UNION
 SELECT DISTINCT lawsectionextracache.lawsectionslug,
    law.lawapproved,
    lawsectionextracache.lawsectioncitation,
    'Amended By'::text AS lawsectioneventrelationship,
    lawsection.lawsectionfrom,
    law.lawnumberchapter
   FROM geohistory.law
   JOIN geohistory.lawsection
     ON law.lawid = lawsection.law
   JOIN geohistory.lawalternatesection
     ON lawsection.lawsectionamend = lawalternatesection.lawsection
     AND lawalternatesection.lawalternatesectionid = $1
   JOIN extra.lawsectionextracache
     ON lawsection.lawsectionid = lawsectionextracache.lawsectionid
UNION
 SELECT DISTINCT lawsectionextracache.lawsectionslug,
    law.lawapproved,
    lawsectionextracache.lawsectioncitation,
    'Lead'::text AS lawsectioneventrelationship,
    lawsection.lawsectionfrom,
    law.lawnumberchapter
   FROM geohistory.law
   JOIN geohistory.lawsection
     ON law.lawid = lawsection.law
   JOIN extra.lawsectionextracache
     ON lawsection.lawsectionid = lawsectionextracache.lawsectionid
   JOIN geohistory.lawalternatesection
     ON lawsection.lawsectionid = lawalternatesection.lawsection
     AND lawalternatesection.lawalternatesectionid = $1
UNION
 SELECT DISTINCT lawalternatesectionextracache.lawsectionslug,
    law.lawapproved,
    lawalternatesectionextracache.lawsectioncitation,
    'Alternate'::text AS lawsectioneventrelationship,
    lawsection.lawsectionfrom,
    law.lawnumberchapter
   FROM geohistory.law
   JOIN geohistory.lawsection
     ON law.lawid = lawsection.law
   JOIN geohistory.lawalternatesection
     ON lawsection.lawsectionid = lawalternatesection.lawsection
   JOIN geohistory.lawalternatesection currentlawsection
     ON lawalternatesection.lawsection = currentlawsection.lawsection
     AND lawalternatesection.lawalternatesectionid <> currentlawsection.lawalternatesectionid
     AND currentlawsection.lawalternatesectionid = $1
   JOIN extra.lawalternatesectionextracache
     ON lawalternatesection.lawalternatesectionid = lawalternatesectionextracache.lawsectionid
  ORDER BY 4, 3;
 
$_$;


ALTER FUNCTION extra.ci_model_lawalternate_related(integer) OWNER TO postgres;

--
-- Name: ci_model_lawalternate_url(integer, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_lawalternate_url(integer, boolean) RETURNS TABLE(url text)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT sourceitem.sourceitemurl ||
        CASE
            WHEN sourceitem.sourceitemurlcomplete THEN ''
            ELSE (sourceitempart.sourceitempartsequencecharacter || extra.zeropad(sourceitempart.sourceitempartsequence +
            CASE
                WHEN sourceitempart.sourceitempartisbypage THEN lawalternatesection.lawalternatesectionpagefrom
                ELSE lawalternate.lawalternatenumberchapter
            END, sourceitempart.sourceitempartzeropad)) || sourceitempart.sourceitempartsequencecharacterafter
        END AS url
   FROM geohistory.lawalternatesection
   JOIN geohistory.lawalternate
     ON lawalternatesection.lawalternate = lawalternate.lawalternateid
   JOIN geohistory.law
     ON lawalternate.law = law.lawid
   JOIN geohistory.sourceitem
     ON sourceitem.source = ANY (extra.sourceurlid(lawalternate.source))
   JOIN geohistory.sourceitempart
     ON sourceitem.sourceitemid = sourceitempart.sourceitem
   WHERE (
     (
        sourceitem.sourceitemvolume <> ''
          AND sourceitem.sourceitemyear IS NULL
		  AND (sourceitem.sourceitemvolume = lawalternate.lawalternatevolume OR (lawalternate.lawalternatevolume = '' AND sourceitem.sourceitemvolume = substring(law.lawapproved FOR 4)))
     ) OR (
        sourceitem.sourceitemvolume <> ''
          AND sourceitem.sourceitemyear IS NOT NULL
          AND sourceitem.sourceitemvolume = lawalternate.lawalternatevolume
          AND sourceitem.sourceitemyear::character varying = substring(law.lawapproved FOR 4)
     ) OR (
        sourceitem.sourceitemvolume = ''
          AND sourceitem.sourceitemyear IS NOT NULL
          AND ((sourceitem.sourceitemyear::character varying = lawalternate.lawalternatevolume) OR (lawalternate.lawalternatevolume = '' AND sourceitem.sourceitemyear::character varying = substring(law.lawapproved FOR 4)))
     ) OR (
        sourceitem.sourceitemvolume = '' AND sourceitem.sourceitemyear IS NULL
     )
   ) AND (
     (sourceitempartfrom IS NULL AND sourceitempartto IS NULL) OR
     (sourceitempartisbypage AND sourceitempartfrom <= lawalternatesectionpagefrom AND sourceitempartto >= lawalternatesectionpagefrom) OR
     (NOT sourceitempartisbypage AND sourceitempartfrom <= lawnumberchapter AND sourceitempartto >= lawnumberchapter)
    ) AND lawalternatesection.lawalternatesectionid = $1
    AND ($2 OR NOT sourceitem.sourceitemlocal);
 
$_$;


ALTER FUNCTION extra.ci_model_lawalternate_url(integer, boolean) OWNER TO postgres;

--
-- Name: ci_model_statistics_createddissolved_nation_part(character varying, integer, integer, character varying, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_statistics_createddissolved_nation_part(character varying, integer, integer, character varying, boolean) RETURNS TABLE(series text, xrow json, yrow json, ysum bigint)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 WITH eventdata AS (
         SELECT DISTINCT min(governmentidentifier.governmentidentifier) AS series,
            statistics_createddissolved.governmentstate AS actualseries,
            statistics_createddissolved.eventyear AS x,
            CASE
                WHEN $1 = 'created' THEN statistics_createddissolved.created::integer
                WHEN $1 = 'dissolved' THEN statistics_createddissolved.dissolved::integer
                WHEN $1 = 'net' THEN (statistics_createddissolved.created - statistics_createddissolved.dissolved)::integer
                ELSE 0::integer
            END AS y
           FROM extra.statistics_createddissolved
           JOIN geohistory.governmentidentifier
             ON statistics_createddissolved.governmentstate = extra.governmentabbreviation(governmentidentifier.government)
             AND governmentidentifier.governmentidentifiertype = 1
          WHERE statistics_createddissolved.governmenttype = 'state'
            AND statistics_createddissolved.grouptype = $4
            AND statistics_createddissolved.governmentstate = ANY (CASE
                WHEN $5 THEN ARRAY['DE', 'ME', 'MA', 'MD', 'MI', 'MN', 'NJ', 'NY', 'OH', 'PA']
                ELSE ARRAY['NJ', 'PA']
            END)
            AND statistics_createddissolved.eventyear >= $2
            AND statistics_createddissolved.eventyear <= $3
            AND CASE
                WHEN $1 = 'created' THEN statistics_createddissolved.created > 0
                WHEN $1 = 'dissolved' THEN statistics_createddissolved.dissolved > 0
                ELSE 0 = 0
            END
          GROUP BY 2, 3, 4
        ), xvalue AS (
          SELECT DISTINCT eventdata.series,
            generate_series(min(eventdata.x),max(eventdata.x)) AS x
          FROM eventdata
          GROUP BY 1
        )
 SELECT xvalue.series,
    array_to_json(array_agg(DISTINCT xvalue.x::text ORDER BY xvalue.x::text)) AS xrow,
    array_to_json(array_agg(
        CASE
            WHEN eventdata.y IS NULL THEN 0
            ELSE eventdata.y
        END ORDER BY xvalue.x)) AS yrow,
    sum(eventdata.y) AS ysum
   FROM xvalue
   LEFT JOIN eventdata
     ON xvalue.x = eventdata.x
     AND xvalue.series = eventdata.series
  GROUP BY 1
  ORDER BY 1;
 
$_$;


ALTER FUNCTION extra.ci_model_statistics_createddissolved_nation_part(character varying, integer, integer, character varying, boolean) OWNER TO postgres;

--
-- Name: ci_model_statistics_createddissolved_nation_whole(character varying, integer, integer, character varying, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_statistics_createddissolved_nation_whole(character varying, integer, integer, character varying, boolean) RETURNS TABLE(datarow json)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 WITH eventdata AS (
         SELECT DISTINCT statistics_createddissolved.eventyear AS x,
            (CASE
                WHEN $1 = 'created' THEN statistics_createddissolved.created::integer
                WHEN $1 = 'dissolved' THEN statistics_createddissolved.dissolved::integer
                WHEN $1 = 'net' THEN (statistics_createddissolved.created - statistics_createddissolved.dissolved)::integer
                ELSE 0::integer
            END)::text AS y
           FROM extra.statistics_createddissolved
          WHERE statistics_createddissolved.governmenttype = 'nation'
            AND statistics_createddissolved.grouptype = $4
            AND statistics_createddissolved.governmentstate = CASE
                WHEN $5 THEN 'development'
                ELSE 'production'
            END
            AND statistics_createddissolved.eventyear >= $2
            AND statistics_createddissolved.eventyear <= $3
            AND CASE
                WHEN $1 = 'created' THEN statistics_createddissolved.created > 0
                WHEN $1 = 'dissolved' THEN statistics_createddissolved.dissolved > 0
                ELSE 0 = 0
            END
        ), xvalue AS (
          SELECT DISTINCT generate_series(min(eventdata.x),max(eventdata.x)) AS x
          FROM eventdata
        )
 SELECT array_to_json(ARRAY['x'::text] || array_agg(DISTINCT xvalue.x::text ORDER BY xvalue.x::text)) AS datarow
   FROM xvalue
UNION ALL
 SELECT array_to_json(ARRAY['Whole'] || array_agg(
        CASE
            WHEN eventdata.y IS NULL THEN '0'::text
            ELSE eventdata.y
        END ORDER BY xvalue.x)) AS datarow
   FROM xvalue
   LEFT JOIN eventdata
     ON xvalue.x = eventdata.x;
 
$_$;


ALTER FUNCTION extra.ci_model_statistics_createddissolved_nation_whole(character varying, integer, integer, character varying, boolean) OWNER TO postgres;

--
-- Name: ci_model_statistics_createddissolved_state_part(character varying, integer, integer, character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_statistics_createddissolved_state_part(character varying, integer, integer, character varying, character varying) RETURNS TABLE(series integer, xrow json, yrow json, ysum bigint)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 WITH eventdata AS (
         SELECT DISTINCT statistics_createddissolved.governmentcounty AS series,
            statistics_createddissolved.eventyear AS x,
            CASE
                WHEN $1 = 'created' THEN statistics_createddissolved.created::integer
                WHEN $1 = 'dissolved' THEN statistics_createddissolved.dissolved::integer
                WHEN $1 = 'net' THEN (statistics_createddissolved.created - statistics_createddissolved.dissolved)::integer
                ELSE 0::integer
            END AS y
           FROM extra.statistics_createddissolved
          WHERE statistics_createddissolved.governmenttype = 'county'
            AND statistics_createddissolved.grouptype = $4
            AND statistics_createddissolved.governmentstate = upper($5)
            AND statistics_createddissolved.eventyear >= $2
            AND statistics_createddissolved.eventyear <= $3
            AND CASE
                WHEN $1 = 'created' THEN statistics_createddissolved.created > 0
                WHEN $1 = 'dissolved' THEN statistics_createddissolved.dissolved > 0
                ELSE 0 = 0
            END
        ), xvalue AS (
          SELECT DISTINCT eventdata.series,
            generate_series(min(eventdata.x),max(eventdata.x)) AS x
          FROM eventdata
          GROUP BY 1
        )
 SELECT xvalue.series,
    array_to_json(array_agg(DISTINCT xvalue.x::text ORDER BY xvalue.x::text)) AS xrow,
    array_to_json(array_agg(
        CASE
            WHEN eventdata.y IS NULL THEN 0
            ELSE eventdata.y
        END ORDER BY xvalue.x)) AS yrow,
    sum(eventdata.y) AS ysum
   FROM xvalue
   LEFT JOIN eventdata
     ON xvalue.x = eventdata.x
     AND xvalue.series = eventdata.series
  GROUP BY 1
  ORDER BY 1;
 
$_$;


ALTER FUNCTION extra.ci_model_statistics_createddissolved_state_part(character varying, integer, integer, character varying, character varying) OWNER TO postgres;

--
-- Name: ci_model_statistics_createddissolved_state_whole(character varying, integer, integer, character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_statistics_createddissolved_state_whole(character varying, integer, integer, character varying, character varying) RETURNS TABLE(datarow json)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 WITH eventdata AS (
         SELECT DISTINCT statistics_createddissolved.eventyear AS x,
            (CASE
                WHEN $1 = 'created' THEN statistics_createddissolved.created::integer
                WHEN $1 = 'dissolved' THEN statistics_createddissolved.dissolved::integer
                WHEN $1 = 'net' THEN (statistics_createddissolved.created - statistics_createddissolved.dissolved)::integer
                ELSE 0::integer
            END)::text AS y
           FROM extra.statistics_createddissolved
          WHERE statistics_createddissolved.governmenttype = 'state'
            AND statistics_createddissolved.grouptype = $4
            AND statistics_createddissolved.governmentstate = upper($5)
            AND statistics_createddissolved.eventyear >= $2
            AND statistics_createddissolved.eventyear <= $3
            AND CASE
                WHEN $1 = 'created' THEN statistics_createddissolved.created > 0
                WHEN $1 = 'dissolved' THEN statistics_createddissolved.dissolved > 0
                ELSE 0 = 0
            END
        ), xvalue AS (
          SELECT DISTINCT generate_series(min(eventdata.x),max(eventdata.x)) AS x
          FROM eventdata
        )
 SELECT array_to_json(ARRAY['x'::text] || array_agg(DISTINCT xvalue.x::text ORDER BY xvalue.x::text)) AS datarow
   FROM xvalue
UNION ALL
 SELECT array_to_json(ARRAY[upper($5)] || array_agg(
        CASE
            WHEN eventdata.y IS NULL THEN '0'::text
            ELSE eventdata.y
        END ORDER BY xvalue.x)) AS datarow
   FROM xvalue
   LEFT JOIN eventdata
     ON xvalue.x = eventdata.x;
 
$_$;


ALTER FUNCTION extra.ci_model_statistics_createddissolved_state_whole(character varying, integer, integer, character varying, character varying) OWNER TO postgres;

--
-- Name: ci_model_statistics_eventtype(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_statistics_eventtype(text) RETURNS TABLE(eventtypeshort text, eventtypeid integer)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
 SELECT DISTINCT eventtype.eventtypeshort,
    eventtype.eventtypeid
   FROM geohistory.eventtype
  WHERE eventtype.eventtypeshort = $1
    AND eventtype.eventtypeborders NOT IN ('documentation', 'ignore')
  ORDER BY 1, 2;
$_$;


ALTER FUNCTION extra.ci_model_statistics_eventtype(text) OWNER TO postgres;

--
-- Name: ci_model_statistics_eventtype_list(boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_statistics_eventtype_list(boolean) RETURNS TABLE(eventtypeshort text, eventtypeid integer)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT DISTINCT eventtype.eventtypeshort,
    eventtype.eventtypeid
   FROM geohistory.eventtype
     JOIN extra.statistics_eventtype
       ON eventtype.eventtypeid = statistics_eventtype.eventtype
       AND statistics_eventtype.governmentstate = ANY (CASE
           WHEN $1 THEN ARRAY['DE', 'ME', 'MA', 'MD', 'MI', 'MN', 'NJ', 'NY', 'OH', 'PA']
           ELSE ARRAY['NJ', 'PA']
        END)
  WHERE eventtype.eventtypeborders NOT IN ('documentation', 'ignore')
  ORDER BY 1, 2;
$_$;


ALTER FUNCTION extra.ci_model_statistics_eventtype_list(boolean) OWNER TO postgres;

--
-- Name: ci_model_statistics_eventtype_list(character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_statistics_eventtype_list(character varying) RETURNS TABLE(eventtypeshort text, eventtypeid integer)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 SELECT DISTINCT eventtype.eventtypeshort,
    eventtype.eventtypeid
   FROM geohistory.eventtype
     JOIN extra.statistics_eventtype
       ON eventtype.eventtypeid = statistics_eventtype.eventtype
       AND statistics_eventtype.governmentstate = upper($1)
  WHERE eventtype.eventtypeborders NOT IN ('documentation', 'ignore')
  ORDER BY 1, 2;
$_$;


ALTER FUNCTION extra.ci_model_statistics_eventtype_list(character varying) OWNER TO postgres;

--
-- Name: ci_model_statistics_eventtype_nation_part(text, integer, integer, character varying, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_statistics_eventtype_nation_part(text, integer, integer, character varying, boolean) RETURNS TABLE(series text, xrow json, yrow json, ysum bigint)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 WITH eventdata AS (
         SELECT DISTINCT min(governmentidentifier.governmentidentifier) AS series,
            statistics_eventtype.governmentstate AS actualseries,
            statistics_eventtype.eventyear AS x,
            statistics_eventtype.eventcount::integer AS y
           FROM extra.statistics_eventtype
           JOIN geohistory.eventtype
             ON statistics_eventtype.eventtype = eventtype.eventtypeid
             AND eventtype.eventtypeshort = $1
           JOIN geohistory.governmentidentifier
             ON statistics_eventtype.governmentstate = extra.governmentabbreviation(governmentidentifier.government)
             AND governmentidentifier.governmentidentifiertype = 1
          WHERE statistics_eventtype.governmenttype = 'state'
            AND statistics_eventtype.grouptype = $4
            AND statistics_eventtype.governmentstate = ANY (CASE
                WHEN $5 THEN ARRAY['DE', 'ME', 'MA', 'MD', 'MI', 'MN', 'NJ', 'NY', 'OH', 'PA']
                ELSE ARRAY['NJ', 'PA']
            END)
            AND statistics_eventtype.eventyear >= $2
            AND statistics_eventtype.eventyear <= $3
          GROUP BY 2, 3, 4
        ), xvalue AS (
          SELECT DISTINCT eventdata.series,
            generate_series(min(eventdata.x),max(eventdata.x)) AS x
          FROM eventdata
          GROUP BY 1
        )
 SELECT xvalue.series,
    array_to_json(array_agg(DISTINCT xvalue.x::text ORDER BY xvalue.x::text)) AS xrow,
    array_to_json(array_agg(
        CASE
            WHEN eventdata.y IS NULL THEN 0
            ELSE eventdata.y
        END ORDER BY xvalue.x)) AS yrow,
    sum(eventdata.y) AS ysum
   FROM xvalue
   LEFT JOIN eventdata
     ON xvalue.x = eventdata.x
     AND xvalue.series = eventdata.series
  GROUP BY 1
  ORDER BY 1;
 
$_$;


ALTER FUNCTION extra.ci_model_statistics_eventtype_nation_part(text, integer, integer, character varying, boolean) OWNER TO postgres;

--
-- Name: ci_model_statistics_eventtype_nation_whole(text, integer, integer, character varying, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_statistics_eventtype_nation_whole(text, integer, integer, character varying, boolean) RETURNS TABLE(datarow json)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 WITH eventdata AS (
         SELECT DISTINCT statistics_eventtype.eventyear AS x,
            statistics_eventtype.eventcount::text AS y
           FROM extra.statistics_eventtype
           JOIN geohistory.eventtype
             ON statistics_eventtype.eventtype = eventtype.eventtypeid
             AND eventtype.eventtypeshort = $1
          WHERE statistics_eventtype.governmenttype = 'nation'
            AND statistics_eventtype.grouptype = $4
            AND statistics_eventtype.governmentstate = CASE
                WHEN $5 THEN 'development'
                ELSE 'production'
            END
            AND statistics_eventtype.eventyear >= $2
            AND statistics_eventtype.eventyear <= $3
        ), xvalue AS (
          SELECT DISTINCT generate_series(min(eventdata.x),max(eventdata.x)) AS x
          FROM eventdata
        )
 SELECT array_to_json(ARRAY['x'::text] || array_agg(DISTINCT xvalue.x::text ORDER BY xvalue.x::text)) AS datarow
   FROM xvalue
UNION ALL
 SELECT array_to_json(ARRAY['Whole'] || array_agg(
        CASE
            WHEN eventdata.y IS NULL THEN '0'::text
            ELSE eventdata.y
        END ORDER BY xvalue.x)) AS datarow
   FROM xvalue
   LEFT JOIN eventdata
     ON xvalue.x = eventdata.x;
 
$_$;


ALTER FUNCTION extra.ci_model_statistics_eventtype_nation_whole(text, integer, integer, character varying, boolean) OWNER TO postgres;

--
-- Name: ci_model_statistics_eventtype_state_part(text, integer, integer, character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_statistics_eventtype_state_part(text, integer, integer, character varying, character varying) RETURNS TABLE(series integer, xrow json, yrow json, ysum bigint)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 WITH eventdata AS (
         SELECT DISTINCT statistics_eventtype.governmentcounty AS series,
            statistics_eventtype.eventyear AS x,
            statistics_eventtype.eventcount::integer AS y
           FROM extra.statistics_eventtype
           JOIN geohistory.eventtype
             ON statistics_eventtype.eventtype = eventtype.eventtypeid
             AND eventtype.eventtypeshort = $1
          WHERE statistics_eventtype.governmenttype = 'county'
            AND statistics_eventtype.grouptype = $4
            AND statistics_eventtype.governmentstate = upper($5)
            AND statistics_eventtype.eventyear >= $2
            AND statistics_eventtype.eventyear <= $3
        ), xvalue AS (
          SELECT DISTINCT eventdata.series,
            generate_series(min(eventdata.x),max(eventdata.x)) AS x
          FROM eventdata
          GROUP BY 1
        )
 SELECT xvalue.series,
    array_to_json(array_agg(DISTINCT xvalue.x::text ORDER BY xvalue.x::text)) AS xrow,
    array_to_json(array_agg(
        CASE
            WHEN eventdata.y IS NULL THEN 0
            ELSE eventdata.y
        END ORDER BY xvalue.x)) AS yrow,
    sum(eventdata.y) AS ysum
   FROM xvalue
   LEFT JOIN eventdata
     ON xvalue.x = eventdata.x
     AND xvalue.series = eventdata.series
  GROUP BY 1
  ORDER BY 1;
 
$_$;


ALTER FUNCTION extra.ci_model_statistics_eventtype_state_part(text, integer, integer, character varying, character varying) OWNER TO postgres;

--
-- Name: ci_model_statistics_eventtype_state_whole(text, integer, integer, character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_statistics_eventtype_state_whole(text, integer, integer, character varying, character varying) RETURNS TABLE(datarow json)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 WITH eventdata AS (
         SELECT DISTINCT statistics_eventtype.eventyear AS x,
            statistics_eventtype.eventcount::text AS y
           FROM extra.statistics_eventtype
           JOIN geohistory.eventtype
             ON statistics_eventtype.eventtype = eventtype.eventtypeid
             AND eventtype.eventtypeshort = $1
          WHERE statistics_eventtype.governmenttype = 'state'
            AND statistics_eventtype.grouptype = $4
            AND statistics_eventtype.governmentstate = upper($5)
            AND statistics_eventtype.eventyear >= $2
            AND statistics_eventtype.eventyear <= $3
        ), xvalue AS (
          SELECT DISTINCT generate_series(min(eventdata.x),max(eventdata.x)) AS x
          FROM eventdata
        )
 SELECT array_to_json(ARRAY['x'::text] || array_agg(DISTINCT xvalue.x::text ORDER BY xvalue.x::text)) AS datarow
   FROM xvalue
UNION ALL
 SELECT array_to_json(ARRAY[upper($5)] || array_agg(
        CASE
            WHEN eventdata.y IS NULL THEN '0'::text
            ELSE eventdata.y
        END ORDER BY xvalue.x)) AS datarow
   FROM xvalue
   LEFT JOIN eventdata
     ON xvalue.x = eventdata.x;
 
$_$;


ALTER FUNCTION extra.ci_model_statistics_eventtype_state_whole(text, integer, integer, character varying, character varying) OWNER TO postgres;

--
-- Name: ci_model_statistics_mapped_nation_part(character varying, integer, integer, character varying, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_statistics_mapped_nation_part(character varying, integer, integer, character varying, boolean) RETURNS TABLE(series text, xrow json, yrow json, ysum numeric)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 WITH eventdata AS (
         SELECT DISTINCT min(governmentidentifier.governmentidentifier) AS series,
            statistics_mapped.governmentstate AS actualseries,
            0 AS x,
            statistics_mapped.percentmapped::numeric AS y
           FROM extra.statistics_mapped
           JOIN geohistory.governmentidentifier
             ON statistics_mapped.governmentstate = extra.governmentabbreviation(governmentidentifier.government)
             AND governmentidentifier.governmentidentifiertype = 1
          WHERE statistics_mapped.governmenttype = 'state'
            AND statistics_mapped.grouptype = $4
            AND statistics_mapped.governmentstate = ANY (CASE
                WHEN $5 THEN ARRAY['DE', 'ME', 'MA', 'MD', 'MI', 'MN', 'NJ', 'NY', 'OH', 'PA']
                ELSE ARRAY['NJ', 'PA']
            END)
          GROUP BY 2, 3, 4
        ), xvalue AS (
          SELECT DISTINCT eventdata.series,
            generate_series(min(eventdata.x),max(eventdata.x)) AS x
          FROM eventdata
          GROUP BY 1
        )
 SELECT xvalue.series,
    array_to_json(array_agg(DISTINCT xvalue.x::text ORDER BY xvalue.x::text)) AS xrow,
    array_to_json(array_agg(
        CASE
            WHEN eventdata.y IS NULL THEN 0
            ELSE eventdata.y
        END ORDER BY xvalue.x)) AS yrow,
    sum(eventdata.y) AS ysum
   FROM xvalue
   LEFT JOIN eventdata
     ON xvalue.x = eventdata.x
     AND xvalue.series = eventdata.series
  GROUP BY 1
  ORDER BY 1;
 
$_$;


ALTER FUNCTION extra.ci_model_statistics_mapped_nation_part(character varying, integer, integer, character varying, boolean) OWNER TO postgres;

--
-- Name: ci_model_statistics_mapped_nation_whole(character varying, integer, integer, character varying, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_statistics_mapped_nation_whole(character varying, integer, integer, character varying, boolean) RETURNS TABLE(datarow json)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 WITH eventdata AS (
         SELECT DISTINCT 0 AS x,
            statistics_mapped.percentmapped::text AS y
           FROM extra.statistics_mapped
          WHERE statistics_mapped.governmenttype = 'nation'
            AND statistics_mapped.grouptype = $4
            AND statistics_mapped.governmentstate = CASE
                WHEN $5 THEN 'development'
                ELSE 'production'
            END
        ), xvalue AS (
          SELECT DISTINCT generate_series(min(eventdata.x),max(eventdata.x)) AS x
          FROM eventdata
        )
 SELECT array_to_json(ARRAY['x'::text] || array_agg(DISTINCT xvalue.x::text ORDER BY xvalue.x::text)) AS datarow
   FROM xvalue
UNION ALL
 SELECT array_to_json(ARRAY['Whole'] || array_agg(
        CASE
            WHEN eventdata.y IS NULL THEN '0'::text
            ELSE eventdata.y
        END ORDER BY xvalue.x)) AS datarow
   FROM xvalue
   LEFT JOIN eventdata
     ON xvalue.x = eventdata.x;
 
$_$;


ALTER FUNCTION extra.ci_model_statistics_mapped_nation_whole(character varying, integer, integer, character varying, boolean) OWNER TO postgres;

--
-- Name: ci_model_statistics_mapped_state_part(character varying, integer, integer, character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_statistics_mapped_state_part(character varying, integer, integer, character varying, character varying) RETURNS TABLE(series integer, xrow json, yrow json, ysum numeric)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 WITH eventdata AS (
         SELECT DISTINCT statistics_mapped.governmentcounty AS series,
            0 AS x,
            statistics_mapped.percentmapped::numeric AS y
           FROM extra.statistics_mapped
          WHERE statistics_mapped.governmenttype = 'county'
            AND statistics_mapped.grouptype = $4
            AND statistics_mapped.governmentstate = upper($5)
        ), xvalue AS (
          SELECT DISTINCT eventdata.series,
            generate_series(min(eventdata.x),max(eventdata.x)) AS x
          FROM eventdata
          GROUP BY 1
        )
 SELECT xvalue.series,
    array_to_json(array_agg(DISTINCT xvalue.x::text ORDER BY xvalue.x::text)) AS xrow,
    array_to_json(array_agg(
        CASE
            WHEN eventdata.y IS NULL THEN 0
            ELSE eventdata.y
        END ORDER BY xvalue.x)) AS yrow,
    sum(eventdata.y) AS ysum
   FROM xvalue
   LEFT JOIN eventdata
     ON xvalue.x = eventdata.x
     AND xvalue.series = eventdata.series
  GROUP BY 1
  ORDER BY 1;
 
$_$;


ALTER FUNCTION extra.ci_model_statistics_mapped_state_part(character varying, integer, integer, character varying, character varying) OWNER TO postgres;

--
-- Name: ci_model_statistics_mapped_state_whole(character varying, integer, integer, character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.ci_model_statistics_mapped_state_whole(character varying, integer, integer, character varying, character varying) RETURNS TABLE(datarow json)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$

 WITH eventdata AS (
         SELECT DISTINCT 0 AS x,
            statistics_mapped.percentmapped::text AS y
           FROM extra.statistics_mapped
          WHERE statistics_mapped.governmenttype = 'state'
            AND statistics_mapped.grouptype = $4
            AND statistics_mapped.governmentstate = upper($5)
        ), xvalue AS (
          SELECT DISTINCT generate_series(min(eventdata.x),max(eventdata.x)) AS x
          FROM eventdata
        )
 SELECT array_to_json(ARRAY['x'::text] || array_agg(DISTINCT xvalue.x::text ORDER BY xvalue.x::text)) AS datarow
   FROM xvalue
UNION ALL
 SELECT array_to_json(ARRAY[upper($5)] || array_agg(
        CASE
            WHEN eventdata.y IS NULL THEN '0'::text
            ELSE eventdata.y
        END ORDER BY xvalue.x)) AS datarow
   FROM xvalue
   LEFT JOIN eventdata
     ON xvalue.x = eventdata.x;
 
$_$;


ALTER FUNCTION extra.ci_model_statistics_mapped_state_whole(character varying, integer, integer, character varying, character varying) OWNER TO postgres;

--
-- Name: emptytonull(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.emptytonull(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$

        SELECT CASE WHEN $1 = ''
            THEN NULL::text ELSE $1 END AS emptytonull;
    
$_$;


ALTER FUNCTION extra.emptytonull(text) OWNER TO postgres;

--
-- Name: eventeffectivetype(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.eventeffectivetype(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT extra.eventeffectivetype(eventeffectivetype.eventeffectivetypegroup, eventeffectivetype.eventeffectivetypequalifier) AS eventeffectivetype
       FROM geohistory.eventeffectivetype
      WHERE eventeffectivetypeid = $1;
    
$_$;


ALTER FUNCTION extra.eventeffectivetype(integer) OWNER TO postgres;

--
-- Name: eventeffectivetype(character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.eventeffectivetype(eventeffectivetypegroup character varying, eventeffectivetypequalifier character varying) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
     SELECT
        eventeffectivetypegroup ||
            CASE
                WHEN eventeffectivetypequalifier <> '' THEN ': ' || eventeffectivetypequalifier
                ELSE ''
            END AS eventeffectivetype;
    $$;


ALTER FUNCTION extra.eventeffectivetype(eventeffectivetypegroup character varying, eventeffectivetypequalifier character varying) OWNER TO postgres;

--
-- Name: eventslug(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.eventslug(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

 SELECT lower(regexp_replace(regexp_replace(replace(event.eventlong, ', ', ' '), '[ʻ \/'',]', '-', 'g'), '[:\*\(\)\?\.\[\]]', '', 'g')) AS eventslug
   FROM geohistory.event
  WHERE event.eventid = $1;
     
$_$;


ALTER FUNCTION extra.eventslug(integer) OWNER TO postgres;

--
-- Name: eventslugidreplacement(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.eventslugidreplacement(text) RETURNS TABLE(eventid integer, eventslugnew text)
    LANGUAGE sql STABLE
    AS $_$
SELECT eventextracache.eventid,
  eventextracache.eventslugnew
   FROM extra.eventextracache
  WHERE eventextracache.eventslug = $1;
$_$;


ALTER FUNCTION extra.eventslugidreplacement(text) OWNER TO postgres;

--
-- Name: eventsortdate(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.eventsortdate(integer) RETURNS numeric
    LANGUAGE sql STABLE
    AS $_$

     SELECT extra.eventsortdate(event.eventeffective, event.eventfrom, event.eventto, event.eventeffectiveorder) AS eventsortdate
       FROM geohistory.event
       WHERE eventid = $1;
    
$_$;


ALTER FUNCTION extra.eventsortdate(integer) OWNER TO postgres;

--
-- Name: eventsortdate(character varying, smallint, smallint, integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.eventsortdate(eventeffective character varying, eventfrom smallint, eventto smallint, eventeffectiveorder integer) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $$

     SELECT
            to_char(CASE
                WHEN (calendar.historicdate(eventeffective)).gregorian IS NOT NULL THEN (calendar.historicdate(eventeffective)).gregorian
                ELSE make_date(CASE
                    WHEN eventto <> 0 THEN eventto
                    WHEN eventfrom <> 0 THEN eventfrom
                    ELSE 1
                END, 1, 1)
            END, 'J')::numeric + 0.01 * eventeffectiveorder AS eventsortdate;
    
$$;


ALTER FUNCTION extra.eventsortdate(eventeffective character varying, eventfrom smallint, eventto smallint, eventeffectiveorder integer) OWNER TO postgres;

--
-- Name: eventsortdatedate(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.eventsortdatedate(integer) RETURNS date
    LANGUAGE sql STABLE
    AS $_$

     SELECT extra.eventsortdatedate(event.eventeffective, event.eventfrom, event.eventto) AS eventsortdatedate
       FROM geohistory.event
       WHERE eventid = $1;
    
$_$;


ALTER FUNCTION extra.eventsortdatedate(integer) OWNER TO postgres;

--
-- Name: eventsortdatedate(character varying, smallint, smallint); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.eventsortdatedate(eventeffective character varying, eventfrom smallint, eventto smallint) RETURNS date
    LANGUAGE sql IMMUTABLE
    AS $$

     SELECT
            CASE
                WHEN (calendar.historicdate(eventeffective)).gregorian IS NOT NULL THEN (calendar.historicdate(eventeffective)).gregorian
                ELSE make_date(CASE
                    WHEN eventto <> 0 THEN eventto
                    WHEN eventfrom <> 0 THEN eventfrom
                    ELSE 1
                END, 1, 1)
            END AS eventsortdatedate;
    
$$;


ALTER FUNCTION extra.eventsortdatedate(eventeffective character varying, eventfrom smallint, eventto smallint) OWNER TO postgres;

--
-- Name: eventsortdateyear(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.eventsortdateyear(integer) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$

     SELECT extra.eventsortdateyear(event.eventeffective, event.eventfrom, event.eventto) AS eventsortdateyear
       FROM geohistory.event
       WHERE eventid = $1;
    
$_$;


ALTER FUNCTION extra.eventsortdateyear(integer) OWNER TO postgres;

--
-- Name: eventsortdateyear(character varying, smallint, smallint); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.eventsortdateyear(eventeffective character varying, eventfrom smallint, eventto smallint) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$

     SELECT
            (CASE
			    WHEN (calendar.historicdate(eventeffective)).gregorian IS NOT NULL THEN date_part('year', (calendar.historicdate(eventeffective)).gregorian)
                ELSE CASE
                    WHEN eventto <> 0 THEN eventto
                    WHEN eventfrom <> 0 THEN eventfrom
                    ELSE 1
                END
            END)::integer AS eventsortdateyear;
    
$$;


ALTER FUNCTION extra.eventsortdateyear(eventeffective character varying, eventfrom smallint, eventto smallint) OWNER TO postgres;

--
-- Name: eventtextshortdate(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.eventtextshortdate(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT extra.eventtextshortdate(event.eventeffective, event.eventfrom, event.eventto) AS eventtextdate
       FROM geohistory.event
       WHERE eventid = $1;
    
$_$;


ALTER FUNCTION extra.eventtextshortdate(integer) OWNER TO postgres;

--
-- Name: eventtextshortdate(character varying, smallint, smallint); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.eventtextshortdate(eventeffective character varying, eventfrom smallint, eventto smallint) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$

     SELECT
            CASE
                WHEN eventeffective = '' AND eventfrom IS NULL AND eventto IS NULL THEN '?'
                WHEN eventeffective::text <> ''::text THEN extra.shortdate(eventeffective)
                ELSE extra.rangefix(eventfrom::text, eventto::text)
            END AS eventtextdate;
    
$$;


ALTER FUNCTION extra.eventtextshortdate(eventeffective character varying, eventfrom smallint, eventto smallint) OWNER TO postgres;

--
-- Name: fulldate(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.fulldate(text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$

    BEGIN
        RETURN calendar.historicdatetextformat($1::calendar.historicdate, 'long', 'en');
    END
$_$;


ALTER FUNCTION extra.fulldate(text) OWNER TO postgres;

--
-- Name: governmentabbreviation(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentabbreviation(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
        SELECT governmentabbreviation
        FROM geohistory.government
        WHERE governmentid = $1;
    $_$;


ALTER FUNCTION extra.governmentabbreviation(integer) OWNER TO postgres;

--
-- Name: governmentabbreviation(integer, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentabbreviation(integer, character varying) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

        SELECT
            CASE WHEN extra.governmentlevel($1) > 2 AND extra.governmentabbreviation(extra.governmentcurrentleadstateid($1)) <> $2
                THEN extra.governmentabbreviation(extra.governmentcurrentleadstateid($1)) || '.'
                ELSE '' END 
         || governmentabbreviation AS governmentabbreviation
        FROM geohistory.government
        WHERE governmentid = $1;
    
$_$;


ALTER FUNCTION extra.governmentabbreviation(integer, character varying) OWNER TO postgres;

--
-- Name: governmentabbreviationid(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentabbreviationid(text) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$
        SELECT governmentid
        FROM geohistory.government
        WHERE governmentabbreviation = $1;
    $_$;


ALTER FUNCTION extra.governmentabbreviationid(text) OWNER TO postgres;

--
-- Name: governmentcurrentleadparent(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentcurrentleadparent(integer) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$
SELECT CASE
    WHEN parent.governmentsubstitute IS NOT NULL THEN parent.governmentsubstitute
	ELSE parent.governmentid
  END AS governmentcurrentleadparent
   FROM geohistory.government
   JOIN geohistory.government parent
     ON government.governmentcurrentleadparent = parent.governmentid
   WHERE government.governmentid = $1;
$_$;


ALTER FUNCTION extra.governmentcurrentleadparent(integer) OWNER TO postgres;

--
-- Name: governmentcurrentleadstateid(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentcurrentleadstateid(integer) RETURNS integer
    LANGUAGE plpgsql STABLE
    AS $_$
        DECLARE gid INTEGER;
        DECLARE glevel SMALLINT;
        DECLARE gparent INTEGER;
        BEGIN
            gparent := $1;
            LOOP
                SELECT
                    CASE
                        WHEN governmentsubstitute IS NOT NULL THEN governmentsubstitute
                        ELSE governmentid
                    END AS governmentid,
                governmentlevel,
                governmentcurrentleadparent
                INTO gid,
                glevel, 
                gparent
                FROM geohistory.government
                WHERE governmentid = gparent;
                EXIT WHEN glevel IS NULL OR glevel < 3;
            END LOOP;
            RETURN gid;
        END;
    $_$;


ALTER FUNCTION extra.governmentcurrentleadstateid(integer) OWNER TO postgres;

--
-- Name: governmentformlong(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentformlong(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

        SELECT governmentformlong
        FROM geohistory.governmentform
        WHERE governmentformid = $1;
    
$_$;


ALTER FUNCTION extra.governmentformlong(integer) OWNER TO postgres;

--
-- Name: governmentformlong(integer, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentformlong(integer, boolean) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

 SELECT CASE
        WHEN $2 THEN governmentform.governmentformlongextended
        ELSE governmentform.governmentformlong
    END AS governmentformlong
   FROM geohistory.governmentform
  WHERE governmentformid = $1;
 
$_$;


ALTER FUNCTION extra.governmentformlong(integer, boolean) OWNER TO postgres;

--
-- Name: governmentformlongreport(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentformlongreport(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

        SELECT governmentformlongreport
        FROM geohistory.governmentform
        WHERE governmentformid = $1;
    
$_$;


ALTER FUNCTION extra.governmentformlongreport(integer) OWNER TO postgres;

--
-- Name: governmentindigobook(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentindigobook(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
        SELECT CASE
            WHEN governmentindigobook = '' THEN governmentabbreviation || '.'
            ELSE 
        governmentindigobook END AS governmentindigobook
        FROM geohistory.government
        WHERE governmentid = $1;
    $_$;


ALTER FUNCTION extra.governmentindigobook(integer) OWNER TO postgres;

--
-- Name: governmentindigobook(integer, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentindigobook(integer, character varying) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT
            CASE
                WHEN extra.governmentindigobook($1) <> '' AND governmentlevel > 2 AND extra.governmentabbreviation(extra.governmentcurrentleadstateid(governmentid)) <> upper($2)
                THEN extra.governmentindigobook(extra.governmentcurrentleadstateid($1))
                ELSE ''::text
            END || extra.governmentindigobook($1) AS governmentindigobook
        FROM geohistory.government
        WHERE governmentid = $1;
    
$_$;


ALTER FUNCTION extra.governmentindigobook(integer, character varying) OWNER TO postgres;

--
-- Name: governmentlevel(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentlevel(integer) RETURNS smallint
    LANGUAGE sql STABLE
    AS $_$
        SELECT governmentlevel
        FROM geohistory.government
        WHERE governmentid = $1;
    $_$;


ALTER FUNCTION extra.governmentlevel(integer) OWNER TO postgres;

--
-- Name: governmentlong(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentlong(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

        SELECT CASE
                WHEN governmentname = '' THEN governmentnumber
                WHEN governmentnumber = '' THEN governmentname
                ELSE governmentname || ' (' || governmentnumber || ')'
            END || 
            CASE WHEN governmentlevel > 1
            THEN ', ' || CASE WHEN governmentstyle <> ''
                THEN governmentstyle ELSE governmenttype END || CASE
                    WHEN governmentconnectingarticle <> '' THEN ' ' || governmentconnectingarticle
                    WHEN locale IN ('de', 'nl') THEN ''
                    WHEN locale = 'fr' THEN ' de'
                    ELSE ' of'
                END ELSE '' END ||
            CASE WHEN governmentstatus <> '' OR governmentnotecurrentleadparent OR governmentnotecreation <> '' OR governmentnotedissolution <> ''
                THEN ' (' || 
                    CASE WHEN governmentnotecurrentleadparent
                        THEN extra.governmentname(extra.governmentcurrentleadparent(governmentid)) ELSE '' END ||
                    CASE WHEN governmentnotecurrentleadparent AND (governmentnotecreation <> '' OR governmentnotedissolution <> '')
                        THEN ', ' ELSE '' END ||
                    CASE WHEN governmentnotecreation <> '' AND governmentnotedissolution <> ''
                        THEN governmentnotecreation || '-' || governmentnotedissolution
                    WHEN governmentnotecreation <> ''
                        THEN 'since ' || governmentnotecreation
                    WHEN governmentnotedissolution <> ''
                        THEN 'thru ' || governmentnotedissolution ELSE '' END ||
                    CASE WHEN governmentstatus <> '' AND (governmentnotecurrentleadparent OR governmentnotecreation <> '' OR governmentnotedissolution <> '')
                        THEN ', ' ELSE '' END || 
                    governmentstatus || ')' 
                ELSE '' END AS governmentlong
            FROM geohistory.government
        WHERE governmentid = $1;
    
$_$;


ALTER FUNCTION extra.governmentlong(integer) OWNER TO postgres;

--
-- Name: governmentlong(integer, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentlong(integer, character varying) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

        SELECT extra.governmentlong($1) ||
            CASE WHEN extra.governmentlevel($1) > 2 AND extra.governmentabbreviation(extra.governmentcurrentleadstateid($1)) <> $2
                THEN ' (' || extra.governmentabbreviation(extra.governmentcurrentleadstateid($1)) || ')'
                ELSE '' END AS governmentlong;
    
$_$;


ALTER FUNCTION extra.governmentlong(integer, character varying) OWNER TO postgres;

--
-- Name: governmentname(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentname(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
        SELECT governmentname
        FROM geohistory.government
        WHERE governmentid = $1;
    $_$;


ALTER FUNCTION extra.governmentname(integer) OWNER TO postgres;

--
-- Name: governmentshapeslugid(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentshapeslugid(text) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$
 SELECT governmentshapeextracache.governmentshapeid
   FROM extra.governmentshapeextracache
  WHERE governmentshapeextracache.governmentshapeslug = $1;
     $_$;


ALTER FUNCTION extra.governmentshapeslugid(text) OWNER TO postgres;

--
-- Name: governmentshort(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentshort(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
        SELECT CASE
            WHEN governmentlevel = 2 AND governmenttype = 'District' THEN governmenttype || ' of '
            ELSE ''
        END || 
        CASE
            WHEN governmentname = '' THEN governmentnumber
            WHEN governmentnumber = '' THEN governmentname
            ELSE governmentname || ' (' || governmentnumber || ')'
        END || 
        CASE
            WHEN governmentlevel > 2  THEN ' ' || CASE
                WHEN governmentstyle <> '' THEN governmentstyle
                ELSE governmenttype
            END
            ELSE ''
        END AS governmentshort
            FROM geohistory.government
        WHERE governmentid = $1;
    $_$;


ALTER FUNCTION extra.governmentshort(integer) OWNER TO postgres;

--
-- Name: governmentshort(integer, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentshort(integer, character varying) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

        SELECT extra.governmentshort($1) ||
            CASE WHEN extra.governmentlevel($1) > 2 AND extra.governmentabbreviation(extra.governmentcurrentleadstateid($1)) <> $2
                THEN ' (' || extra.governmentabbreviation(extra.governmentcurrentleadstateid($1)) || ')'
                ELSE '' END AS governmentshort;
    
$_$;


ALTER FUNCTION extra.governmentshort(integer, character varying) OWNER TO postgres;

--
-- Name: governmentslug(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentslug(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

 SELECT CASE
     WHEN governmentextracache.governmentsubstituteslug IS NULL THEN governmentextracache.governmentslug
	 ELSE governmentextracache.governmentsubstituteslug
 END AS governmentslug
   FROM extra.governmentextracache
  WHERE governmentextracache.governmentid = $1;
     
$_$;


ALTER FUNCTION extra.governmentslug(integer) OWNER TO postgres;

--
-- Name: governmentslugalternate(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentslugalternate(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

 SELECT lower(replace(regexp_replace(regexp_replace(
        CASE
            WHEN government.governmentlevel < 3 AND government.governmentabbreviation <> '' THEN government.governmentabbreviation
            ELSE extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentid)) ||
            CASE
                WHEN government.governmentarticle <> '' THEN '-' || government.governmentarticle
                ELSE ''
            END ||
            CASE
                WHEN government.governmentname <> '' THEN '-' || government.governmentname
                ELSE ''
            END ||
            CASE
                WHEN government.governmentnumber <> '' THEN '-' || government.governmentnumber
                ELSE ''
            END ||
            CASE
                WHEN government.governmentlevel > 1 THEN '-' ||
                CASE
                    WHEN government.governmentstyle <> '' THEN government.governmentstyle
                    ELSE government.governmenttype
                END
                ELSE ''
            END ||
            CASE
                WHEN government.governmentstatus <> '' OR government.governmentnotecurrentleadparent OR government.governmentnotecreation <> '' OR government.governmentnotedissolution <> '' THEN '-' ||
                CASE
                    WHEN government.governmentnotecurrentleadparent THEN extra.governmentname(extra.governmentcurrentleadparent(government.governmentid))
                    ELSE ''
                END ||
                CASE
                    WHEN government.governmentnotecurrentleadparent AND (government.governmentnotecreation <> '' OR government.governmentnotedissolution <> '') THEN '-'
                    ELSE ''
                END ||
                CASE
                    WHEN government.governmentnotecreation <> '' AND government.governmentnotedissolution <> '' THEN (government.governmentnotecreation || '-') || government.governmentnotedissolution
                    WHEN government.governmentnotecreation <> '' THEN 'since-' || government.governmentnotecreation
                    WHEN government.governmentnotedissolution <> '' THEN 'thru-' || government.governmentnotedissolution
                    ELSE ''
                END ||
                CASE
                    WHEN government.governmentstatus <> '' AND (government.governmentnotecurrentleadparent OR government.governmentnotecreation <> '' OR government.governmentnotedissolution <> '') THEN '-'
                    ELSE ''
                END || government.governmentstatus
                ELSE ''
            END
        END, '[\(\)\,\.]', '', 'g'), '[ \/ʻ]', '-', 'g'), '''', '-')) AS governmentslug
   FROM geohistory.government
  WHERE government.governmentid = $1;
     
$_$;


ALTER FUNCTION extra.governmentslugalternate(integer) OWNER TO postgres;

--
-- Name: governmentslugid(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentslugid(text) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$

 SELECT governmentextracache.governmentid
   FROM extra.governmentextracache
  WHERE governmentextracache.governmentslug = $1;
     
$_$;


ALTER FUNCTION extra.governmentslugid(text) OWNER TO postgres;

--
-- Name: governmentsourceslugid(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentsourceslugid(text) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$

 SELECT governmentsourceextracache.governmentsourceid
   FROM extra.governmentsourceextracache
  WHERE governmentsourceextracache.governmentsourceslug = $1;
     
$_$;


ALTER FUNCTION extra.governmentsourceslugid(text) OWNER TO postgres;

--
-- Name: governmentstate(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentstate(integer) RETURNS text[]
    LANGUAGE sql STABLE
    AS $_$

 SELECT array_agg(DISTINCT governmentrelationcache.governmentrelationstate) AS governmentstates
   FROM extra.governmentrelationcache
  WHERE governmentrelationcache.governmentid = $1
    AND governmentrelationcache.governmentrelationstate <> '';
    
$_$;


ALTER FUNCTION extra.governmentstate(integer) OWNER TO postgres;

--
-- Name: governmentstatelink(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentstatelink(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

        SELECT CASE
            WHEN governmentstatus = 'placeholder' THEN ''
            ELSE '/en/' || lower(extra.governmentabbreviation(extra.governmentcurrentleadstateid($1)))
            || '/government/' || $1 || '/'
        END AS governmentstatelink
        FROM geohistory.government
        WHERE governmentid = $1;
    
$_$;


ALTER FUNCTION extra.governmentstatelink(integer) OWNER TO postgres;

--
-- Name: governmentstatelink(integer, character varying, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentstatelink(v_governmentid integer, v_state character varying, v_locale character varying) RETURNS text
    LANGUAGE sql STABLE
    AS $$
SELECT CASE
            WHEN governmentstatus = 'placeholder' THEN ''
            ELSE '/' || v_locale || '/' || CASE
                WHEN upper(v_state) = ANY (extra.governmentstate(v_governmentid)) THEN v_state
                ELSE lower(extra.governmentabbreviation(extra.governmentcurrentleadstateid(v_governmentid)))
            END || '/government/' || extra.governmentslug(v_governmentid) || '/'
        END AS governmentstatelink
        FROM geohistory.government
        WHERE governmentid = v_governmentid;
$$;


ALTER FUNCTION extra.governmentstatelink(v_governmentid integer, v_state character varying, v_locale character varying) OWNER TO postgres;

--
-- Name: governmentstatus(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentstatus(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
        SELECT governmentstatus
        FROM geohistory.government
        WHERE governmentid = $1;
    $_$;


ALTER FUNCTION extra.governmentstatus(integer) OWNER TO postgres;

--
-- Name: governmentsubstitutedcache(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmentsubstitutedcache(integer) RETURNS integer[]
    LANGUAGE sql STABLE
    AS $_$

    SELECT array_agg(DISTINCT governmentid ORDER BY governmentid)
    FROM extra.governmentsubstitutecache
    WHERE governmentsubstitute = $1;
    
$_$;


ALTER FUNCTION extra.governmentsubstitutedcache(integer) OWNER TO postgres;

--
-- Name: governmenttype(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.governmenttype(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
        SELECT governmenttype
        FROM geohistory.government
        WHERE governmentid = $1;
    $_$;


ALTER FUNCTION extra.governmenttype(integer) OWNER TO postgres;

--
-- Name: lawalternatecitation(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.lawalternatecitation(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT extra.lawalternatecitation($1, true);
    
$_$;


ALTER FUNCTION extra.lawalternatecitation(integer) OWNER TO postgres;

--
-- Name: lawalternatecitation(integer, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.lawalternatecitation(integer, boolean) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT source.sourcelawtype ||
            CASE
                WHEN lawalternate.lawalternatepage = 0 AND lawalternate.lawalternatenumberchapter = 0 THEN ' Unknown'
                ELSE
                CASE
                    WHEN law.lawapproved = '' THEN ''
                    ELSE ' of '
                END || CASE
                    WHEN $2 THEN extra.fulldate(law.lawapproved)
                    ELSE extra.shortdate(law.lawapproved)
                END || ' (' ||
                CASE
                    WHEN lawalternate.lawalternatevolume ~~ '%/%' THEN CASE
                        WHEN split_part(lawalternate.lawalternatevolume, '/', 3) <> '' THEN split_part(lawalternate.lawalternatevolume, '/', 3) || ', '
                        ELSE ''
                    END || split_part(lawalternate.lawalternatevolume, '/', 2) ||
                    CASE
                        WHEN split_part(lawalternate.lawalternatevolume, '/', 2) = '1' THEN 'st'
                        WHEN split_part(lawalternate.lawalternatevolume, '/', 2) = '2' THEN 'nd'
                        WHEN split_part(lawalternate.lawalternatevolume, '/', 2) = '3' THEN 'rd'
                        ELSE 'th'
                    END || ' ' || 
                    CASE
                        WHEN source.sourcelawhasspecialsession THEN 'Sp.'
                        ELSE ''
                    END || 'Sess., ' ||
                    CASE
                        WHEN left(law.lawapproved, 4) <> split_part(lawalternate.lawalternatevolume, '/', 1) THEN split_part(lawalternate.lawalternatevolume, '/', 1) || ' '
                        ELSE ''
                    END
                    ELSE CASE
                        WHEN lawalternate.lawalternatevolume = left(law.lawapproved, 4) OR lawalternate.lawalternatevolume = '' THEN ''
                        ELSE lawalternate.lawalternatevolume || ' '
                    END 
                END || source.sourceshort || ' ' ||
                CASE
                    WHEN lawalternate.lawalternatepage = 0 THEN '___'
                    ELSE lawalternate.lawalternatepage::text
                END || ', ' ||
                CASE
                    WHEN source.sourcelawisbynumber THEN 'No'
                    ELSE 'Ch'
                END || '. ' ||
                CASE
                    WHEN lawalternate.lawalternatenumberchapter = 0 THEN '___'
                    ELSE lawalternate.lawalternatenumberchapter::text
                END || ')'
            END AS lawalternatecitation
       FROM geohistory.lawalternate 
       JOIN geohistory.source
         ON lawalternate.source = source.sourceid
       JOIN geohistory.law
         ON lawalternate.law = law.lawid
      WHERE lawalternate.lawalternateid = $1;
    
$_$;


ALTER FUNCTION extra.lawalternatecitation(integer, boolean) OWNER TO postgres;

--
-- Name: lawalternatesectioncitation(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.lawalternatesectioncitation(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT extra.lawalternatesectioncitation($1, true);
    
$_$;


ALTER FUNCTION extra.lawalternatesectioncitation(integer) OWNER TO postgres;

--
-- Name: lawalternatesectioncitation(integer, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.lawalternatesectioncitation(integer, boolean) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT
        extra.lawalternatecitation(lawalternate.lawalternateid, $2) || ', ' || lawsection.lawsectionsymbol ||
            CASE
                WHEN lawsection.lawsectionfrom = '0' THEN '___'
                WHEN lawsection.lawsectionfrom = lawsection.lawsectionto THEN ' ' || lawsection.lawsectionfrom
                ELSE '§ ' || lawsection.lawsectionfrom || '-' || lawsection.lawsectionto
            END AS lawalternatesectioncitation
       FROM geohistory.lawalternatesection
       JOIN geohistory.lawalternate
         ON lawalternatesection.lawalternate = lawalternate.lawalternateid
       JOIN geohistory.lawsection
         ON lawalternatesection.lawsection = lawsection.lawsectionid
      WHERE lawalternatesection.lawalternatesectionid = $1;
    
$_$;


ALTER FUNCTION extra.lawalternatesectioncitation(integer, boolean) OWNER TO postgres;

--
-- Name: lawalternatesectionslug(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.lawalternatesectionslug(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

 SELECT lower(replace(replace(regexp_replace(regexp_replace(extra.lawalternatesectioncitation($1, false), '[,\.\[\]\(\)\'']', '', 'g'), '([ :\–\—\/]| of )', '-', 'g'), '§', 's'), '¶', 'p')) AS lawalternatesectionslug;
    
$_$;


ALTER FUNCTION extra.lawalternatesectionslug(integer) OWNER TO postgres;

--
-- Name: lawalternatesectionslugid(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.lawalternatesectionslugid(text) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$

 SELECT lawalternatesectionextracache.lawsectionid
   FROM extra.lawalternatesectionextracache
  WHERE lawalternatesectionextracache.lawsectionslug = $1;
     
$_$;


ALTER FUNCTION extra.lawalternatesectionslugid(text) OWNER TO postgres;

--
-- Name: lawcitation(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.lawcitation(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT extra.lawcitation($1, true);
    
$_$;


ALTER FUNCTION extra.lawcitation(integer) OWNER TO postgres;

--
-- Name: lawcitation(integer, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.lawcitation(integer, boolean) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT source.sourcelawtype ||
            CASE
                WHEN law.lawpage = 0 AND law.lawnumberchapter = 0 AND law.lawapproved = '' THEN ' Unknown'
                ELSE
                CASE
                    WHEN law.lawapproved = '' THEN ''
                    ELSE ' of '
                END || CASE
                    WHEN $2 THEN extra.fulldate(law.lawapproved)
                    ELSE extra.shortdate(law.lawapproved)
                END || ' (' ||
                CASE
                    WHEN law.lawvolume ~~ '%/%' THEN CASE
                        WHEN split_part(law.lawvolume, '/', 3) <> '' THEN split_part(law.lawvolume, '/', 3) || ', '
                        ELSE ''
                    END || split_part(law.lawvolume, '/', 2) ||
                    CASE
                        WHEN split_part(law.lawvolume, '/', 2) = '1' THEN 'st'
                        WHEN split_part(law.lawvolume, '/', 2) = '2' THEN 'nd'
                        WHEN split_part(law.lawvolume, '/', 2) = '3' THEN 'rd'
                        ELSE 'th'
                    END || ' ' || 
                    CASE
                        WHEN source.sourcelawhasspecialsession THEN 'Sp.'
                        ELSE ''
                    END || 'Sess., ' ||
                    CASE
                        WHEN left(law.lawapproved, 4) <> split_part(law.lawvolume, '/', 1) THEN split_part(law.lawvolume, '/', 1) || ' '
                        ELSE ''
                    END
                    ELSE CASE
                        WHEN law.lawvolume = left(law.lawapproved, 4) OR law.lawvolume = '' THEN ''
                        ELSE law.lawvolume || ' '
                    END 
                END || source.sourceshort || ' ' ||
                CASE
                    WHEN law.lawpage = 0 THEN '___'
                    ELSE law.lawpage::text
                END || ', ' ||
                CASE
                    WHEN source.sourcelawisbynumber THEN 'No'
                    ELSE 'Ch'
                END || '. ' ||
                CASE
                    WHEN law.lawnumberchapter = 0 THEN '___'
                    ELSE law.lawnumberchapter::text
                END ||
                CASE
                    WHEN law.lawpublished <> '' THEN ', ' || CASE
                        WHEN $2 THEN extra.fulldate(law.lawpublished)
                        ELSE extra.shortdate(law.lawpublished)
                    END 
                    ELSE ''
                END || ')'
            END AS lawcitation
       FROM geohistory.law
       JOIN geohistory.source
         ON law.source = source.sourceid
      WHERE law.lawid = $1;
    
$_$;


ALTER FUNCTION extra.lawcitation(integer, boolean) OWNER TO postgres;

--
-- Name: lawsectioncitation(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.lawsectioncitation(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT extra.lawsectioncitation($1, true);
    
$_$;


ALTER FUNCTION extra.lawsectioncitation(integer) OWNER TO postgres;

--
-- Name: lawsectioncitation(integer, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.lawsectioncitation(integer, boolean) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT
        extra.lawcitation(law.lawid, $2) || ', ' || lawsection.lawsectionsymbol ||
            CASE
                WHEN lawsection.lawsectionfrom = '0' THEN '___'
                WHEN lawsection.lawsectionfrom = lawsection.lawsectionto THEN ' ' || lawsection.lawsectionfrom
                ELSE '§ ' || lawsection.lawsectionfrom || '–' || lawsection.lawsectionto
            END AS lawsectioncitation
       FROM geohistory.lawsection
       JOIN geohistory.law
         ON lawsection.law = law.lawid
      WHERE lawsection.lawsectionid = $1;
    
$_$;


ALTER FUNCTION extra.lawsectioncitation(integer, boolean) OWNER TO postgres;

--
-- Name: lawsectionslug(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.lawsectionslug(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

 SELECT lower(replace(replace(regexp_replace(regexp_replace(extra.lawsectioncitation($1, false), '[,\.\[\]\(\)\'']', '', 'g'), '([ :\–\—\/]| of )', '-', 'g'), '§', 's'), '¶', 'p')) AS lawsectionslug;
    
$_$;


ALTER FUNCTION extra.lawsectionslug(integer) OWNER TO postgres;

--
-- Name: lawsectionslugid(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.lawsectionslugid(text) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$

 SELECT lawsectionextracache.lawsectionid
   FROM extra.lawsectionextracache
  WHERE lawsectionextracache.lawsectionslug = $1;
     
$_$;


ALTER FUNCTION extra.lawsectionslugid(text) OWNER TO postgres;

--
-- Name: metesdescriptionlong(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.metesdescriptionlong(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
 SELECT event.eventlong || CASE
    WHEN metesdescription.metesdescriptionname = '' THEN ''
    ELSE ': ' || metesdescription.metesdescriptionname
   END AS metesdescriptionlong
   FROM geohistory.metesdescription
   JOIN geohistory.event
     ON metesdescription.event = event.eventid
  WHERE metesdescription.metesdescriptionid = $1;
     $_$;


ALTER FUNCTION extra.metesdescriptionlong(integer) OWNER TO postgres;

--
-- Name: metesdescriptionslug(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.metesdescriptionslug(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

 SELECT extra.eventslug(metesdescription.event) || CASE
    WHEN metesdescription.metesdescriptionname = '' THEN ''
    ELSE '-' || lower(regexp_replace(regexp_replace(replace(metesdescription.metesdescriptionname, ', ', ' '), '[ \/'',"]', '-', 'g'), '[\(\)\?\.\[\]]', '', 'g'))
   END AS metesdescriptionslug
   FROM geohistory.metesdescription
  WHERE metesdescription.metesdescriptionid = $1;
     
$_$;


ALTER FUNCTION extra.metesdescriptionslug(integer) OWNER TO postgres;

--
-- Name: nulltoempty(integer[]); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.nulltoempty(integer[]) RETURNS integer[]
    LANGUAGE sql IMMUTABLE
    AS $_$
        SELECT CASE WHEN $1 IS NULL
            THEN ARRAY[]::integer[] ELSE $1 END AS nulltoempty;
    $_$;


ALTER FUNCTION extra.nulltoempty(integer[]) OWNER TO postgres;

--
-- Name: nulltoempty(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.nulltoempty(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
        SELECT CASE WHEN $1 IS NULL
            THEN '' ELSE $1 END AS nulltoempty;
    $_$;


ALTER FUNCTION extra.nulltoempty(text) OWNER TO postgres;

--
-- Name: nulltozero(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.nulltozero(integer) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $_$
        SELECT CASE WHEN $1 IS NULL
            THEN 0 ELSE $1 END AS nulltozero;
    $_$;


ALTER FUNCTION extra.nulltozero(integer) OWNER TO postgres;

--
-- Name: nulltozero(bigint); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.nulltozero(bigint) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $_$
        SELECT CASE WHEN $1 IS NULL
            THEN 0::integer ELSE $1::integer END AS nulltozero;
    $_$;


ALTER FUNCTION extra.nulltozero(bigint) OWNER TO postgres;

--
-- Name: plsstownshiplong(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.plsstownshiplong(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

        SELECT plsstownshipfull || ', ' || plssmeridian.plssmeridianlong || ', Township of (survey)'
        FROM geohistory.plsstownship
        JOIN geohistory.plssmeridian
          ON plsstownship.plssmeridian = plssmeridian.plssmeridianid
        WHERE plsstownshipid = $1;
    
$_$;


ALTER FUNCTION extra.plsstownshiplong(integer) OWNER TO postgres;

--
-- Name: plsstownshipshort(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.plsstownshipshort(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

        SELECT plsstownshipfull || ', ' || plssmeridian.plssmeridianlong
        FROM geohistory.plsstownship
        JOIN geohistory.plssmeridian
          ON plsstownship.plssmeridian = plssmeridian.plssmeridianid
        WHERE plsstownshipid = $1;
    
$_$;


ALTER FUNCTION extra.plsstownshipshort(integer) OWNER TO postgres;

--
-- Name: punctuationhyphen(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.punctuationhyphen(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$

  SELECT regexp_replace(
     regexp_replace(
        lower(
           public.unaccent($1)
        ), '[^a-z0-9]', '-', 'g'
     ), '[-]+', '-', 'g'
  );
    
$_$;


ALTER FUNCTION extra.punctuationhyphen(text) OWNER TO postgres;

--
-- Name: punctuationnone(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.punctuationnone(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$

  SELECT regexp_replace(
     lower(
        public.unaccent($1)
     ), '[^a-z0-9]', '', 'g'
  );
    
$_$;


ALTER FUNCTION extra.punctuationnone(text) OWNER TO postgres;

--
-- Name: punctuationnonefuzzy(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.punctuationnonefuzzy(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$

  SELECT regexp_replace(
     lower(
        public.unaccent($1)
     ), '[^a-z0-9]', '', 'g'
  ) || '%';
    
$_$;


ALTER FUNCTION extra.punctuationnonefuzzy(text) OWNER TO postgres;

--
-- Name: rangefix(text, text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.rangefix(text, text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$

    DECLARE fullrange TEXT;
    BEGIN
        $1 := extra.nulltoempty($1::text);
        $2 := extra.nulltoempty($2::text);
        IF $2 = '' OR $1 = $2 THEN
            fullrange := $1;
        ELSEIF $1 = '' THEN
            fullrange := '–' || $2;
        ELSEIF $2 = 'missing' THEN
            fullrange := $1 || ' (' || $2 || ')';
        ELSE
            fullrange := $1 || '–' || $2;
        END IF;
        RETURN fullrange;
    END
$_$;


ALTER FUNCTION extra.rangefix(text, text) OWNER TO postgres;

--
-- Name: refresh_sequence(); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.refresh_sequence() RETURNS void
    LANGUAGE plpgsql STABLE
    AS $_$

    DECLARE

        columncursor refcursor;
        tableschema text;
        tablename text;
        columnname text;
        columnsequence text;
        maxidvalue bigint;

    BEGIN

        OPEN columncursor FOR
        SELECT columns.table_schema::text,
           columns.table_name::text,
           columns.column_name::text,
           split_part(columns.column_default::text, '''', 2) AS column_sequence
          FROM information_schema.columns
         WHERE columns.table_schema::text = ANY (ARRAY['geohistory'::text, 'gis'::text])
           AND columns.column_default ~~ 'nextval(%'
         ORDER BY 1, 2;

        LOOP
        
          FETCH columncursor INTO tableschema, tablename, columnname, columnsequence;

          IF NOT FOUND THEN
            EXIT;
          END IF;

          EXECUTE format('SELECT COALESCE(max(%I.%I) + 1, 1) FROM %I.%I',
            tablename,
            columnname,
            tableschema,
            tablename)
          INTO maxidvalue;

		  EXECUTE 'SELECT pg_catalog.setval($1, $2, false)'
		  USING columnsequence,
		    maxidvalue;

        END LOOP;

    END;

$_$;


ALTER FUNCTION extra.refresh_sequence() OWNER TO postgres;

--
-- Name: refresh_view_long(); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.refresh_view_long() RETURNS void
    LANGUAGE plpgsql
    AS $$
  
  BEGIN
RAISE INFO '%', clock_timestamp();
    TRUNCATE gis.deleted_affectedgovernmentgis;
RAISE INFO '%', clock_timestamp();
    TRUNCATE gis.deleted_metesdescriptiongis;
RAISE INFO '%', clock_timestamp();
    UPDATE gis.governmentshape
     SET governmentshapereference = governmentshapeid
     WHERE governmentshapereference IS NULL OR (
       governmentshapereference IS NOT NULL AND governmentshapereference <> governmentshapeid
     );
RAISE INFO '%', clock_timestamp();
    DELETE FROM geohistory.affectedgovernmentgrouppart
    WHERE affectedgovernmentpart IN (
      SELECT DISTINCT affectedgovernmentpart.affectedgovernmentpartid
      FROM geohistory.affectedgovernmentpart
      WHERE affectedgovernmentpart.governmentfrom IS NULL
        AND affectedgovernmentpart.affectedtypefrom IS NULL
        AND affectedgovernmentpart.governmentto IS NULL
        AND affectedgovernmentpart.affectedtypeto IS NULL
        AND affectedgovernmentpart.governmentformto IS NULL
    );
RAISE INFO '%', clock_timestamp();
    DELETE FROM geohistory.affectedgovernmentpart
	WHERE affectedgovernmentpartid IN (
      SELECT DISTINCT affectedgovernmentpart.affectedgovernmentpartid
      FROM geohistory.affectedgovernmentpart
      LEFT JOIN geohistory.affectedgovernmentgrouppart
      ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
      WHERE affectedgovernmentgrouppart.affectedgovernmentpart IS NULL
	) AND affectedgovernmentpartid NOT IN (
      SELECT DISTINCT affectedgovernmentpart.affectedgovernmentpartid
      FROM geohistory.affectedgovernmentpart
      WHERE affectedgovernmentpart.governmentfrom IS NULL
        AND affectedgovernmentpart.affectedtypefrom IS NULL
        AND affectedgovernmentpart.governmentto IS NULL
        AND affectedgovernmentpart.affectedtypeto IS NULL
        AND affectedgovernmentpart.governmentformto IS NULL
    );
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.adjudicationgovernmentcache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.adjudicationsearchcache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.adjudicationsourcecitationsourcegovernmentcache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.affectedgovernment_reconstructed;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.affectedgovernmentformcache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.areagovernmentcache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.eventgovernmentcache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.giscache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.governmentchangecountcache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.governmentchangecountpartcache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.lastrefresh;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.lawsectiongovernmentcache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.sourcecitationgovernmentcache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.statistics_createddissolved;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.statistics_eventtype;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.statistics_mapped;
RAISE INFO '%', clock_timestamp();
  END
$$;


ALTER FUNCTION extra.refresh_view_long() OWNER TO postgres;

--
-- Name: refresh_view_quick(); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.refresh_view_quick() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.government
      SET governmentnotecurrentleadparent = TRUE
     WHERE NOT governmentnotecurrentleadparent
       AND governmentid IN (
      SELECT government.governmentid
        FROM geohistory.government
        JOIN (
         SELECT replace(lower(government.governmentname), ' ', '') AS governmentname,
           government.governmenttype,
           extra.governmentcurrentleadstateid(governmentid) AS governmentcurrentleadstateid
          FROM geohistory.government
          GROUP BY 1, 2, 3
          HAVING count(DISTINCT extra.governmentcurrentleadparent(government.governmentid)) > 1
        ) governmentgroup
        ON replace(lower(government.governmentname), ' ', '') = governmentgroup.governmentname
          AND government.governmenttype = governmentgroup.governmenttype
          AND extra.governmentcurrentleadstateid(governmentid) = governmentgroup.governmentcurrentleadstateid
          AND NOT government.governmentnotecurrentleadparent
     );
RAISE INFO '%', clock_timestamp();  
    UPDATE geohistory.government
      SET governmentnotecurrentleadparent = FALSE
     WHERE governmentnotecurrentleadparent AND governmentid IN (
      SELECT government.governmentid
        FROM geohistory.government
        JOIN (
         SELECT replace(lower(government.governmentname), ' ', '') AS governmentname,
           government.governmenttype,
           extra.governmentcurrentleadstateid(governmentid) AS governmentcurrentleadstateid
          FROM geohistory.government
          GROUP BY 1, 2, 3
          HAVING count(DISTINCT extra.governmentcurrentleadparent(government.governmentid)) = 1
        ) governmentgroup
        ON replace(lower(government.governmentname), ' ', '') = governmentgroup.governmentname
          AND government.governmenttype = governmentgroup.governmenttype
          AND extra.governmentcurrentleadstateid(governmentid) = governmentgroup.governmentcurrentleadstateid
          AND NOT government.governmentnotecurrentleadparent
     );
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.adjudicationextracache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.adjudicationsourcecitationextracache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.eventextracache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.governmentextracache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.governmenthasmappedeventcache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.governmentparentcache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.governmentrelationcache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.governmentshapeextracache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.governmentsourceextracache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.governmentsubstitutecache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.lawalternatesectionextracache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.lawsectionextracache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.metesdescriptionextracache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.sourcecitationextracache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW extra.tribunalgovernmentcache;
RAISE INFO '%', clock_timestamp();
  END
$$;


ALTER FUNCTION extra.refresh_view_quick() OWNER TO postgres;

--
-- Name: shortdate(text); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.shortdate(text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$

    BEGIN
        RETURN calendar.historicdatetextformat($1::calendar.historicdate, 'short', 'en');
    END
$_$;


ALTER FUNCTION extra.shortdate(text) OWNER TO postgres;

--
-- Name: sourceurlid(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.sourceurlid(integer) RETURNS integer[]
    LANGUAGE sql STABLE
    AS $_$
 SELECT ARRAY[source.sourceid, source.sourceurlsubstitute] AS sourceurlid
   FROM geohistory.source
  WHERE source.sourceid = $1;
     $_$;


ALTER FUNCTION extra.sourceurlid(integer) OWNER TO postgres;

--
-- Name: tribunalfilingoffice(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.tribunalfilingoffice(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT
            CASE
                WHEN tribunal.tribunalalternatefilingoffice::text <> ''::text THEN (((extra.governmentshort(tribunal.government) || ', '::text) || extra.governmentshort(extra.governmentcurrentleadstateid(tribunal.government))) || ' '::text) || tribunal.tribunalalternatefilingoffice::text
                ELSE (tribunaltype.tribunaltypefilingoffice::text || ' of '::text) ||
                CASE
                    WHEN tribunaltype.tribunaltypefilingofficerlevel THEN (extra.governmentshort(tribunal.government) || ', '::text) || extra.governmentshort(extra.governmentcurrentleadstateid(tribunal.government))
                    ELSE 'the '::text || extra.tribunallong(tribunal.tribunalid)
                END
            END AS tribunalfilingoffice
       FROM geohistory.tribunal,
        geohistory.tribunaltype
      WHERE tribunal.tribunaltype = tribunaltype.tribunaltypeid
      AND tribunalid = $1;
    
$_$;


ALTER FUNCTION extra.tribunalfilingoffice(integer) OWNER TO postgres;

--
-- Name: tribunalgovernmentshort(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.tribunalgovernmentshort(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT 
        extra.governmentindigobook(tribunal.government) ||
            CASE
                WHEN tribunal.tribunaldistrictcircuit::text <> ''::text THEN tribunal.tribunaldistrictcircuit::text || CASE
                    WHEN tribunal.tribunaldistrictcircuit::text = '1' THEN 'st'
                    WHEN tribunal.tribunaldistrictcircuit::text IN ('2', '3') THEN 'd'
                    WHEN tribunal.tribunaldistrictcircuit::text ~ '^\d+$' THEN 'th'
                    ELSE ''
                END || '.'::text
                ELSE ''::text
            END AS tribunalgovernmentshort
       FROM geohistory.tribunaltype
       JOIN geohistory.tribunal
         ON tribunal.tribunaltype = tribunaltype.tribunaltypeid
      WHERE tribunalid = $1;
    
$_$;


ALTER FUNCTION extra.tribunalgovernmentshort(integer) OWNER TO postgres;

--
-- Name: tribunalgovernmentshort(integer, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.tribunalgovernmentshort(integer, character varying) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT
            CASE
                WHEN extra.governmentlevel(tribunal.government) > 2 AND extra.governmentabbreviation(extra.governmentcurrentleadstateid(tribunal.government)) <> upper($2)
                THEN extra.governmentindigobook(extra.governmentcurrentleadstateid(tribunal.government))
                ELSE ''::text
            END || extra.tribunalgovernmentshort($1) AS tribunalgovernmentshort
       FROM geohistory.tribunal
      WHERE tribunal.tribunalid = $1;
    
$_$;


ALTER FUNCTION extra.tribunalgovernmentshort(integer, character varying) OWNER TO postgres;

--
-- Name: tribunalgovernmentshort(integer, character varying, boolean); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.tribunalgovernmentshort(integer, character varying, boolean) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT
            CASE
                WHEN extra.governmentlevel(tribunal.government) > 2 AND extra.governmentabbreviation(extra.governmentcurrentleadstateid(tribunal.government)) <> upper($2)
                THEN extra.governmentindigobook(extra.governmentcurrentleadstateid(tribunal.government))
                ELSE ''::text
            END || CASE
                WHEN $3 THEN extra.tribunalgovernmentshort($1)
                ELSE ''
            END AS tribunalgovernmentshort
       FROM geohistory.tribunal
      WHERE tribunal.tribunalid = $1;
    
$_$;


ALTER FUNCTION extra.tribunalgovernmentshort(integer, character varying, boolean) OWNER TO postgres;

--
-- Name: tribunallong(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.tribunallong(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT (tribunaltype.tribunaltypelong || ' of '::text) ||
            CASE
                WHEN tribunaltype.tribunaltypelevel > 2 THEN ((extra.governmentshort(tribunal.government) || ', '::text) || extra.governmentshort(extra.governmentcurrentleadstateid(tribunal.government))) ||
                CASE
                    WHEN tribunaltype.tribunaltypedivision::text <> ''::text THEN ' - '::text || tribunaltype.tribunaltypedivision::text
                    ELSE ''::text
                END
                WHEN tribunaltype.tribunaltypelevel = 2 THEN extra.governmentshort(tribunal.government) ||
                CASE
                    WHEN tribunal.tribunaldistrictcircuit::text = 'E'::text THEN ' - Eastern District'::text
                    WHEN tribunal.tribunaldistrictcircuit::text = 'M'::text THEN ' - Middle District'::text
                    WHEN tribunal.tribunaldistrictcircuit::text = 'W'::text THEN ' - Western District'::text
                    WHEN tribunal.tribunaldistrictcircuit::text = 'N'::text THEN ' - Northern District'::text
                    WHEN tribunal.tribunaldistrictcircuit::text = 'S'::text THEN ' - Southern District'::text
                    WHEN tribunal.tribunaldistrictcircuit::text = 'C'::text THEN ' - Central District'::text
                    ELSE ''::text
                END
                WHEN tribunaltype.tribunaltypelevel = 1 THEN
                CASE
                    WHEN tribunal.tribunaldistrictcircuit::text = 'E'::text THEN 'the Eastern District of '::text || extra.governmentshort(tribunal.government)
                    WHEN tribunal.tribunaldistrictcircuit::text = 'M'::text THEN 'the Middle District of '::text || extra.governmentshort(tribunal.government)
                    WHEN tribunal.tribunaldistrictcircuit::text = 'W'::text THEN 'the Western District of '::text || extra.governmentshort(tribunal.government)
                    WHEN tribunal.tribunaldistrictcircuit::text = 'N'::text THEN 'the Northern District of '::text || extra.governmentshort(tribunal.government)
                    WHEN tribunal.tribunaldistrictcircuit::text = 'S'::text THEN 'the Southern District of '::text || extra.governmentshort(tribunal.government)
                    WHEN tribunal.tribunaldistrictcircuit::text = 'C'::text THEN 'the Central District of '::text || extra.governmentshort(tribunal.government)
                    WHEN tribunal.tribunaldistrictcircuit::text = '1'::text THEN 'the First Circuit'::text
                    WHEN tribunal.tribunaldistrictcircuit::text = '2'::text THEN 'the Second Circuit'::text
                    WHEN tribunal.tribunaldistrictcircuit::text = '3'::text THEN 'the Third Circuit'::text
                    WHEN tribunal.tribunaldistrictcircuit::text = '4'::text THEN 'the Fourth Circuit'::text
                    WHEN tribunal.tribunaldistrictcircuit::text = '5'::text THEN 'the Fifth Circuit'::text
                    WHEN tribunal.tribunaldistrictcircuit::text = '6'::text THEN 'the Sixth Circuit'::text
                    WHEN tribunal.tribunaldistrictcircuit::text = '7'::text THEN 'the Seventh Circuit'::text
                    WHEN tribunal.tribunaldistrictcircuit::text = '8'::text THEN 'the Eighth Circuit'::text
                    WHEN tribunal.tribunaldistrictcircuit::text = '9'::text THEN 'the Ninth Circuit'::text
                    WHEN tribunal.tribunaldistrictcircuit::text = '10'::text THEN 'the Tenth Circuit'::text
                    WHEN tribunal.tribunaldistrictcircuit::text = '11'::text THEN 'the Eleventh Circuit'::text
                    WHEN extra.governmentlevel(tribunal.government) = 1 OR extra.governmentname(tribunal.government) = 'District of Columbia'::text THEN 'the '::text || extra.governmentshort(tribunal.government)
                    ELSE extra.governmentshort(tribunal.government)
                END
                ELSE ''::text
            END AS tribunallong
       FROM geohistory.tribunal,
        geohistory.tribunaltype
      WHERE tribunal.tribunaltype = tribunaltype.tribunaltypeid
      AND tribunalid = $1;
    
$_$;


ALTER FUNCTION extra.tribunallong(integer) OWNER TO postgres;

--
-- Name: tribunalshort(integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.tribunalshort(integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT 
        extra.tribunalgovernmentshort($1) || tribunaltype.tribunaltypeshort AS tribunalshort
       FROM geohistory.tribunaltype
       JOIN geohistory.tribunal
         ON tribunal.tribunaltype = tribunaltype.tribunaltypeid
      WHERE tribunalid = $1;
    
$_$;


ALTER FUNCTION extra.tribunalshort(integer) OWNER TO postgres;

--
-- Name: tribunalshort(integer, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.tribunalshort(integer, character varying) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

     SELECT
        extra.tribunalgovernmentshort($1, $2, false) || extra.tribunalshort($1) AS tribunalshort
       FROM geohistory.tribunal
      WHERE tribunal.tribunalid = $1;
    
$_$;


ALTER FUNCTION extra.tribunalshort(integer, character varying) OWNER TO postgres;

--
-- Name: tribunalshort(integer, integer, character varying); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.tribunalshort(integer, integer, character varying) RETURNS text
    LANGUAGE sql STABLE
    AS $_$

 SELECT
        CASE
            WHEN extra.governmentlevel(tribunal.government) > 2 AND tribunal.government = $2 THEN
            CASE
                WHEN tribunal.tribunaldistrictcircuit::text <> ''::text THEN tribunal.tribunaldistrictcircuit::text || CASE
                    WHEN tribunal.tribunaldistrictcircuit::text = '1' THEN 'st'
                    WHEN tribunal.tribunaldistrictcircuit::text IN ('2', '3') THEN 'd'
                    WHEN tribunal.tribunaldistrictcircuit::text ~ '^\d+$' THEN 'th'
                    ELSE ''
                END || '.'::text
                ELSE ''::text
            END || tribunaltype.tribunaltypeshort::text
            ELSE extra.tribunalshort($1, $3)
        END AS tribunalshort
   FROM geohistory.tribunaltype
   JOIN geohistory.tribunal
     ON tribunal.tribunaltype = tribunaltype.tribunaltypeid
  WHERE tribunal.tribunalid = $1;
    
$_$;


ALTER FUNCTION extra.tribunalshort(integer, integer, character varying) OWNER TO postgres;

--
-- Name: zeropad(integer, integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.zeropad(integer, integer) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
        SELECT repeat('0', $2 - length($1::text)) || $1;
    $_$;


ALTER FUNCTION extra.zeropad(integer, integer) OWNER TO postgres;

--
-- Name: zeropad(text, integer); Type: FUNCTION; Schema: extra; Owner: postgres
--

CREATE FUNCTION extra.zeropad(text, integer) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
        SELECT repeat('0', $2 - length($1)) || $1;
    $_$;


ALTER FUNCTION extra.zeropad(text, integer) OWNER TO postgres;

--
-- Name: government_insertupdate(); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.government_insertupdate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    governmentparentlevel integer;
BEGIN
    IF NEW.governmentlevel > 1 THEN
        SELECT government.governmentlevel INTO governmentparentlevel
        FROM geohistory.government
        WHERE government.governmentid = NEW.governmentcurrentleadparent;
    
        IF NEW.governmentlevel <= governmentparentlevel THEN
            RAISE EXCEPTION 'Government parent must be of higher level than government.';
        END IF;
    END IF;
    RETURN NEW;
END
$$;


ALTER FUNCTION geohistory.government_insertupdate() OWNER TO postgres;

--
-- Name: governmentothercurrentparent_insertupdate(); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.governmentothercurrentparent_insertupdate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    governmentcurrentleadparent integer;
    governmentlevel integer;
    governmentparentlevel integer;
BEGIN
    SELECT government.governmentcurrentleadparent,
    government.governmentlevel
    INTO governmentcurrentleadparent,
    governmentlevel
    FROM geohistory.government
    WHERE government.governmentid = NEW.government;

    SELECT government.governmentlevel INTO governmentparentlevel
    FROM geohistory.government
    WHERE government.governmentid = NEW.governmentothercurrentparent;
    
    IF NEW.governmentothercurrentparent = governmentcurrentleadparent THEN
        RAISE EXCEPTION 'Government parent link already exists.';
    END IF;

    IF governmentlevel < 2 THEN
        RAISE EXCEPTION 'Nation-level governments cannot have parent governments.';
    END IF;
    
    IF governmentlevel <= governmentparentlevel THEN
        RAISE EXCEPTION 'Government parent must be of higher level than government.';
    END IF;

    RETURN NEW;
END
$$;


ALTER FUNCTION geohistory.governmentothercurrentparent_insertupdate() OWNER TO postgres;

--
-- Name: law_insertupdate(); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.law_insertupdate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    sourcetypeislaw boolean;
BEGIN
    SELECT sourcetype.sourcetypeislaw INTO sourcetypeislaw
    FROM geohistory.sourcetype
    JOIN geohistory.source
      ON sourcetype.sourcetypeshort = source.sourcetype
      AND source.sourceid = NEW.source;
    
    IF NOT sourcetypeislaw THEN
      RAISE EXCEPTION 'Source type cannot be used for law.';
    END IF;
    RETURN NEW;
END
$$;


ALTER FUNCTION geohistory.law_insertupdate() OWNER TO postgres;

--
-- Name: lawalternate_update(); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.lawalternate_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    lawcount bigint;
BEGIN
    SELECT count(*) INTO lawcount
    FROM geohistory.lawalternatesection
    WHERE lawalternatesection.lawalternate = OLD.lawalternateid;
    
    IF lawcount > 0 THEN
        RAISE EXCEPTION 'Must remove alternate law reference from alternate law sections before changing law reference.';
    END IF;
    
    RETURN NEW;
END
$$;


ALTER FUNCTION geohistory.lawalternate_update() OWNER TO postgres;

--
-- Name: lawalternatesection_insertupdate(); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.lawalternatesection_insertupdate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    lawalternatelaw integer;
    lawsectionlaw integer;
BEGIN
    SELECT lawalternate.law INTO lawalternatelaw
    FROM geohistory.lawalternate
    WHERE lawalternate.lawalternateid = NEW.lawalternate;

    SELECT lawsection.law INTO lawsectionlaw
    FROM geohistory.lawsection
    WHERE lawsection.lawsectionid = NEW.lawsection;
    
    IF lawalternatelaw <> lawsectionlaw THEN
        RAISE EXCEPTION 'Law reference mismatch.';
    END IF;
    
    RETURN NEW;
END
$$;


ALTER FUNCTION geohistory.lawalternatesection_insertupdate() OWNER TO postgres;

--
-- Name: lawgroupsection_deleteupdate(); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.lawgroupsection_deleteupdate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    lawsectioneventidcheck integer;
BEGIN
    SELECT lawsectionevent.lawsectioneventid INTO lawsectioneventidcheck
    FROM geohistory.lawsectionevent
    WHERE lawsectionevent.lawgroup = OLD.lawgroup
      AND lawsectionevent.lawsection = OLD.lawsection
      AND (
        (
          OLD.eventrelationship IN (4, 6, 9)
            AND lawsectionevent.eventrelationship = 4
        ) OR (
          OLD.eventrelationship <> 7
          AND lawsectionevent.eventrelationship = 5
        )
      );

    IF lawsectioneventidcheck IS NULL THEN
      RAISE EXCEPTION 'Law section-law group match.';
    END IF;
    RETURN NEW;
END
$$;


ALTER FUNCTION geohistory.lawgroupsection_deleteupdate() OWNER TO postgres;

--
-- Name: lawsection_update(); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.lawsection_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    lawcount bigint;
BEGIN
    IF OLD.law <> NEW.law THEN
        SELECT count(*) INTO lawcount
        FROM geohistory.lawalternatesection
        WHERE lawalternatesection.lawsection = OLD.lawsectionid;
    
        IF lawcount > 0 THEN
            RAISE EXCEPTION 'Must remove alternate law reference from alternate law sections before changing law reference.';
        END IF;
	END IF;
    RETURN NEW;
END
$$;


ALTER FUNCTION geohistory.lawsection_update() OWNER TO postgres;

--
-- Name: lawsectionevent_insertupdate(); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.lawsectionevent_insertupdate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    lawgroupsectionidcheck integer;
BEGIN
    IF NEW.lawgroup IS NOT NULL THEN
        SELECT lawgroupsection.lawgroupsectionid INTO lawgroupsectionidcheck
        FROM geohistory.lawgroupsection
        WHERE lawgroupsection.lawgroup = NEW.lawgroup
          AND lawgroupsection.lawsection = NEW.lawsection
          AND (
            (
              lawgroupsection.eventrelationship IN (4, 6, 9)
                AND NEW.eventrelationship = 4
            ) OR (
              lawgroupsection.eventrelationship <> 7
              AND NEW.eventrelationship = 5
            )
          );
    
        IF lawgroupsectionidcheck IS NULL THEN
          RAISE EXCEPTION 'Law section-law group mismatch.';
        END IF;
    END IF;
    RETURN NEW;
END
$$;


ALTER FUNCTION geohistory.lawsectionevent_insertupdate() OWNER TO postgres;

--
-- Name: metesdescriptionline_insertupdate(); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.metesdescriptionline_insertupdate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    metesdescriptionlinenext integer;
BEGIN
    IF NEW.metesdescriptionline IS NULL THEN
      SELECT max(metesdescriptionline.metesdescriptionline) + 1 INTO metesdescriptionlinenext
      FROM geohistory.metesdescriptionline
      WHERE metesdescriptionline.metesdescription = NEW.metesdescription;
        
      IF metesdescriptionlinenext IS NULL THEN
        metesdescriptionlinenext := 1;
      END IF;
        
      NEW.metesdescriptionline := metesdescriptionlinenext;
    END IF;
    RETURN NEW;
END
$$;


ALTER FUNCTION geohistory.metesdescriptionline_insertupdate() OWNER TO postgres;

--
-- Name: source_insert(); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.source_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

   IF NEW.sourceurlsubstitute IS NULL THEN
     
      NEW.sourceurlsubstitute := NEW.sourceid;
   
   END IF;

   RETURN NEW;
END;
$$;


ALTER FUNCTION geohistory.source_insert() OWNER TO postgres;

--
-- Name: source_update(); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.source_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    oldsourcetypeislaw boolean;
    newsourcetypeislaw boolean;
    lawcount bigint;
BEGIN
    SELECT sourcetype.sourcetypeislaw INTO oldsourcetypeislaw
    FROM geohistory.sourcetype
    WHERE sourcetype.sourcetypeshort = OLD.sourcetype;

    SELECT sourcetype.sourcetypeislaw INTO newsourcetypeislaw
    FROM geohistory.sourcetype
    WHERE sourcetype.sourcetypeshort = NEW.sourcetype;

    IF oldsourcetypeislaw AND NOT newsourcetypeislaw THEN
      SELECT count(*) INTO lawcount
      FROM geohistory.law
      WHERE law.source = OLD.sourceid;
      
      IF lawcount > 0 THEN
        RAISE EXCEPTION 'Must remove source from laws before changing to non-law source type.';
      END IF;
    END IF;
    
    RETURN NEW;
END
$$;


ALTER FUNCTION geohistory.source_update() OWNER TO postgres;

--
-- Name: sourcetype_update(); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.sourcetype_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    lawcount bigint;
BEGIN
    IF OLD.sourcetypeislaw AND NOT NEW.sourcetypeislaw THEN
      SELECT count(*) INTO lawcount
      FROM geohistory.law
      JOIN geohistory.source
        ON law.source = source.sourceid
        AND (
          source.sourcetype = OLD.sourcetypeshort
          OR source.sourcetype = NEW.sourcetypeshort
        );
      
      IF lawcount > 0 THEN
        RAISE EXCEPTION 'Must remove sources of source type from laws before changing to non-law source type.';
      END IF;
    END IF;
    
    RETURN NEW;
END
$$;


ALTER FUNCTION geohistory.sourcetype_update() OWNER TO postgres;

--
-- Name: governmentshape_delete(); Type: FUNCTION; Schema: gis; Owner: postgres
--

CREATE FUNCTION gis.governmentshape_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN
   INSERT INTO gis.deleted_affectedgovernmentgis (
     affectedgovernment,
     governmentshape
   )
   SELECT
   affectedgovernment,
   OLD.governmentshapereference AS governmentshape
   FROM gis.affectedgovernmentgis
   WHERE governmentshape = OLD.governmentshapeid;

   DELETE FROM gis.affectedgovernmentgis
   WHERE governmentshape = OLD.governmentshapeid;

   INSERT INTO gis.deleted_metesdescriptiongis (
     metesdescription,
     governmentshape
   )
   SELECT
   metesdescription,
   OLD.governmentshapereference AS governmentshape
   FROM gis.metesdescriptiongis
   WHERE governmentshape = OLD.governmentshapeid;

   DELETE FROM gis.metesdescriptiongis
   WHERE governmentshape = OLD.governmentshapeid;

   RETURN OLD;
END;
$$;


ALTER FUNCTION gis.governmentshape_delete() OWNER TO postgres;

--
-- Name: governmentshape_insert(); Type: FUNCTION; Schema: gis; Owner: postgres
--

CREATE FUNCTION gis.governmentshape_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

   IF NEW.governmentshapereference IS NOT NULL THEN
      INSERT INTO gis.affectedgovernmentgis (
         affectedgovernment,
         governmentshape
      )
      SELECT DISTINCT
      affectedgovernment,
      NEW.governmentshapeid AS governmentshape
      FROM gis.deleted_affectedgovernmentgis
      WHERE governmentshape = NEW.governmentshapereference
      AND (now() - deletedat) < '3 seconds'::interval
      UNION DISTINCT
      SELECT DISTINCT
      affectedgovernment,
      NEW.governmentshapeid AS governmentshape
      FROM gis.affectedgovernmentgis
      WHERE governmentshape = NEW.governmentshapereference;

      INSERT INTO gis.metesdescriptiongis (
         metesdescription,
         governmentshape
      )
      SELECT DISTINCT
      metesdescription,
      NEW.governmentshapeid AS governmentshape
      FROM gis.deleted_metesdescriptiongis
      WHERE governmentshape = NEW.governmentshapereference
      AND (now() - deletedat) < '3 seconds'::interval
      UNION DISTINCT
      SELECT DISTINCT
      metesdescription,
      NEW.governmentshapeid AS governmentshape
      FROM gis.metesdescriptiongis
      WHERE governmentshape = NEW.governmentshapereference;

   END IF;
     
   UPDATE gis.governmentshape
   SET governmentshapereference = governmentshapeid
   WHERE governmentshapeid = NEW.governmentshapeid; 

   RETURN NEW;
END;
$$;


ALTER FUNCTION gis.governmentshape_insert() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: adjudication; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.adjudication (
    adjudicationid integer NOT NULL,
    adjudicationtype integer NOT NULL,
    adjudicationnumber character varying(11) DEFAULT ''::character varying NOT NULL,
    adjudicationterm character varying(15) DEFAULT ''::character varying NOT NULL,
    adjudicationlong text DEFAULT ''::text NOT NULL,
    adjudicationshort text DEFAULT ''::text NOT NULL,
    adjudicationnotes text DEFAULT ''::text NOT NULL,
    adjudicationstatus text DEFAULT ''::text NOT NULL
);


ALTER TABLE geohistory.adjudication OWNER TO postgres;

--
-- Name: COLUMN adjudication.adjudicationstatus; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.adjudication.adjudicationstatus IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: adjudicationtype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.adjudicationtype (
    adjudicationtypeid integer NOT NULL,
    tribunal integer NOT NULL,
    adjudicationtypeabbreviation character varying(45) NOT NULL,
    adjudicationtypelong character varying(45) NOT NULL,
    adjudicationtypeshort character varying(25) NOT NULL,
    CONSTRAINT adjudicationtype_check CHECK ((((adjudicationtypeabbreviation)::text <> ''::text) AND ((adjudicationtypelong)::text <> ''::text) AND ((adjudicationtypeshort)::text <> ''::text)))
);


ALTER TABLE geohistory.adjudicationtype OWNER TO postgres;

--
-- Name: COLUMN adjudicationtype.adjudicationtypeshort; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.adjudicationtype.adjudicationtypeshort IS 'Conform with new abbreviations as of 2018-01-31';


--
-- Name: tribunal; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.tribunal (
    tribunalid integer NOT NULL,
    government integer NOT NULL,
    tribunaltype integer NOT NULL,
    tribunaldistrictcircuit character varying(5) DEFAULT ''::character varying NOT NULL,
    tribunalalternatefilingoffice character varying(50) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE geohistory.tribunal OWNER TO postgres;

--
-- Name: tribunaltype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.tribunaltype (
    tribunaltypeid integer NOT NULL,
    tribunaltypelevel integer NOT NULL,
    tribunaltypeshort character varying(20) NOT NULL,
    tribunaltypelong text NOT NULL,
    tribunaltypedivision character varying(25) DEFAULT ''::character varying NOT NULL,
    tribunaltypefilingoffice character varying(50) NOT NULL,
    tribunaltypefilingofficerlevel boolean DEFAULT false NOT NULL,
    tribunaldescription text DEFAULT ''::text NOT NULL,
    tribunaltypesummary character varying(50) DEFAULT ''::character varying NOT NULL,
    CONSTRAINT tribunaltype_check CHECK ((((tribunaltypefilingoffice)::text <> ''::text) AND (tribunaltypelong <> ''::text) AND ((tribunaltypeshort)::text <> ''::text)))
);


ALTER TABLE geohistory.tribunaltype OWNER TO postgres;

--
-- Name: adjudicationextra; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.adjudicationextra AS
 WITH adjudicationslugs AS (
         SELECT adjudication.adjudicationid,
            lower(regexp_replace(regexp_replace(((((((extra.governmentslugalternate(tribunal.government) || '-'::text) || (tribunaltype.tribunaltypesummary)::text) ||
                CASE
                    WHEN ((adjudication.adjudicationnumber)::text = ''::text) THEN ''::text
                    ELSE ('-'::text || (adjudication.adjudicationnumber)::text)
                END) || '-'::text) || (adjudicationtype.adjudicationtypelong)::text) ||
                CASE
                    WHEN ((adjudication.adjudicationterm)::text = ''::text) THEN ''::text
                    ELSE ('-'::text || extra.shortdate(((adjudication.adjudicationterm)::text ||
                    CASE
                        WHEN (length((adjudication.adjudicationterm)::text) = 4) THEN '-~07-~28'::text
                        WHEN (length((adjudication.adjudicationterm)::text) = 7) THEN '-~28'::text
                        ELSE ''::text
                    END)))
                END), '[ ]'::text, '-'::text, 'g'::text), '[\/\,\.\(\)]'::text, ''::text, 'g'::text)) AS adjudicationpartslug,
            regexp_replace(regexp_replace(((((((extra.governmentshort(tribunal.government) || ' '::text) || (tribunaltype.tribunaltypesummary)::text) ||
                CASE
                    WHEN ((adjudication.adjudicationnumber)::text = ''::text) THEN ''::text
                    ELSE (' '::text || (adjudication.adjudicationnumber)::text)
                END) || ' '::text) || (adjudicationtype.adjudicationtypelong)::text) ||
                CASE
                    WHEN ((adjudication.adjudicationterm)::text = ''::text) THEN ''::text
                    ELSE (' '::text || extra.shortdate(((adjudication.adjudicationterm)::text ||
                    CASE
                        WHEN (length((adjudication.adjudicationterm)::text) = 4) THEN '-~07-~28'::text
                        WHEN (length((adjudication.adjudicationterm)::text) = 7) THEN '-~28'::text
                        ELSE ''::text
                    END)))
                END), '[ ]'::text, ' '::text, 'g'::text), '[\/\,\.\(\)]'::text, ''::text, 'g'::text) AS adjudicationtitle
           FROM (((geohistory.adjudication
             JOIN geohistory.adjudicationtype ON ((adjudication.adjudicationtype = adjudicationtype.adjudicationtypeid)))
             JOIN geohistory.tribunal ON ((adjudicationtype.tribunal = tribunal.tribunalid)))
             JOIN geohistory.tribunaltype ON ((tribunal.tribunaltype = tribunaltype.tribunaltypeid)))
        ), adjudicationslugcounts AS (
         SELECT count(*) AS rowct,
            adjudicationslugs_1.adjudicationpartslug
           FROM adjudicationslugs adjudicationslugs_1
          GROUP BY adjudicationslugs_1.adjudicationpartslug
        )
 SELECT adjudicationslugs.adjudicationid,
    (adjudicationslugs.adjudicationpartslug ||
        CASE
            WHEN (adjudicationslugcounts.rowct > 1) THEN ('-'::text || rank() OVER (PARTITION BY adjudicationslugs.adjudicationpartslug ORDER BY adjudicationslugs.adjudicationid))
            ELSE ''::text
        END) AS adjudicationslug,
    adjudicationslugs.adjudicationtitle
   FROM (adjudicationslugs
     JOIN adjudicationslugcounts ON ((adjudicationslugs.adjudicationpartslug = adjudicationslugcounts.adjudicationpartslug)))
  ORDER BY adjudicationslugs.adjudicationid;


ALTER VIEW extra.adjudicationextra OWNER TO postgres;

--
-- Name: adjudicationextracache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.adjudicationextracache AS
 SELECT adjudicationid,
    adjudicationslug,
    adjudicationtitle
   FROM extra.adjudicationextra
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.adjudicationextracache OWNER TO postgres;

--
-- Name: government; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.government (
    governmentid integer NOT NULL,
    governmentname character varying(75) NOT NULL,
    governmenttype character varying(30) NOT NULL,
    governmentstatus character varying(35) DEFAULT ''::character varying NOT NULL,
    governmentstatusdefacto boolean DEFAULT false NOT NULL,
    governmentstyle character varying(20) DEFAULT ''::character varying NOT NULL,
    governmentlevel smallint NOT NULL,
    governmentcurrentleadparent integer,
    governmentabbreviation character varying(10) DEFAULT ''::character varying NOT NULL,
    government1983stateplaneauthority character varying(100) DEFAULT ''::character varying NOT NULL,
    governmentlead1983stateplane character varying(2) DEFAULT ''::character varying NOT NULL,
    governmenthasmultiple1983stateplane boolean,
    governmentdefaultsrid integer,
    governmentnotecreation character varying(5) DEFAULT ''::character varying NOT NULL,
    governmentnotedissolution character varying(5) DEFAULT ''::character varying NOT NULL,
    governmentnotecurrentleadparent boolean DEFAULT false NOT NULL,
    governmentcharterstatus integer,
    governmentbooknote text[],
    governmentbookcomplete jsonb,
    governmentmultilevel boolean DEFAULT false NOT NULL,
    governmentindigobook character varying(20) DEFAULT ''::character varying NOT NULL,
    governmentsubstitute integer,
    governmentnumber character varying(3) DEFAULT ''::character varying NOT NULL,
    governmentmapstatus integer DEFAULT 1 NOT NULL,
    locale character varying(2) DEFAULT 'en'::character varying NOT NULL,
    governmentarticle character varying(10) DEFAULT ''::character varying NOT NULL,
    governmentconnectingarticle character varying(10) DEFAULT ''::character varying NOT NULL,
    governmentcurrentform integer,
    CONSTRAINT government_check CHECK (((((governmentstatus)::text = ANY (ARRAY['cadastral'::text, 'defunct'::text, 'nonfunctioning'::text, 'paper'::text, 'placeholder'::text, 'proposed'::text, 'unincorporated'::text, 'unknown'::text, ''::text])) OR (((governmentstatus)::text = ANY (ARRAY['alternate'::text, 'language'::text])) AND (governmentsubstitute IS NOT NULL))) AND (governmentlevel >= 1) AND (governmentlevel <= 5) AND ((governmentlevel = 2) OR ((governmentlevel <> 2) AND ((government1983stateplaneauthority)::text = ''::text))) AND ((governmentlevel = 3) OR ((governmentlevel <> 3) AND ((governmentlead1983stateplane)::text = ''::text))) AND ((governmentlevel = 3) OR ((governmentlevel <> 3) AND (governmenthasmultiple1983stateplane IS NULL))) AND (((governmentname)::text <> ''::text) OR ((governmentnumber)::text <> ''::text)) AND ((governmenttype)::text <> ''::text) AND ((locale)::text <> ''::text) AND (NOT (((governmentstatus)::text = ANY (ARRAY['placeholder'::text, 'proposed'::text, 'unincorporated'::text])) AND (governmentmapstatus <> 0))) AND (((governmentlevel = 1) AND (governmentcurrentleadparent IS NULL)) OR ((governmentlevel > 1) AND (governmentcurrentleadparent IS NOT NULL) AND (governmentid <> governmentcurrentleadparent)))))
);


ALTER TABLE geohistory.government OWNER TO postgres;

--
-- Name: COLUMN government.governmentstyle; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.government.governmentstyle IS 'Signifies if the government uses a government type in its formal name that is different than its actual government type.';


--
-- Name: COLUMN government.governmentlevel; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.government.governmentlevel IS '1 = Nation; 2 = State/Province; 3 = County/Parish; 4 = Township/Municipality; 5 = Unincorporated Ward/Populated Place. Generally = floor((OSM admin_level + 1)/2) or GeoNames administrative division order + 1';


--
-- Name: COLUMN government.government1983stateplaneauthority; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.government.government1983stateplaneauthority IS 'Last checked January 29, 2017.';


--
-- Name: COLUMN government.governmentlead1983stateplane; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.government.governmentlead1983stateplane IS 'Last checked January 29, 2017.';


--
-- Name: COLUMN government.governmenthasmultiple1983stateplane; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.government.governmenthasmultiple1983stateplane IS 'Last checked January 29, 2017.';


--
-- Name: COLUMN government.governmentcharterstatus; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.government.governmentcharterstatus IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN government.governmentbooknote; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.government.governmentbooknote IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN government.governmentbookcomplete; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.government.governmentbookcomplete IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN government.governmentmapstatus; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.government.governmentmapstatus IS 'The values have been simplified in open data to remove certain information used for internal tracking purposes.';


--
-- Name: governmentsubstitute; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.governmentsubstitute AS
 WITH RECURSIVE governmentsubstitutepart(governmentid, governmentsubstitute) AS (
         SELECT s1.governmentid,
            s1.governmentsubstitute,
            1 AS depth
           FROM geohistory.government s1
          WHERE (s1.governmentsubstitute IS NOT NULL)
        UNION
         SELECT s1.governmentid,
            s2.governmentsubstitute,
            (s1.depth + 1) AS depth
           FROM geohistory.government s2,
            governmentsubstitutepart s1
          WHERE ((s2.governmentid = s1.governmentsubstitute) AND (s2.governmentsubstitute IS NOT NULL) AND (s1.depth < 4))
        ), governmentsubstituterank AS (
         SELECT governmentsubstitutepart.governmentid,
            governmentsubstitutepart.governmentsubstitute,
            (row_number() OVER (PARTITION BY governmentsubstitutepart.governmentid ORDER BY governmentsubstitutepart.depth DESC) = 1) AS isgovernmentlead
           FROM governmentsubstitutepart
        ), governmentsubstitutemultiple AS (
         SELECT DISTINCT governmentsubstituterank.governmentsubstitute
           FROM (governmentsubstituterank
             JOIN geohistory.government ON (((governmentsubstituterank.governmentid = government.governmentid) AND ((government.governmentstatus)::text <> ALL (ARRAY[('alternate'::character varying)::text, ('language'::character varying)::text])))))
        ), governmentsubstitutecombine AS (
         SELECT governmentsubstituterank.governmentid,
            governmentsubstituterank.governmentsubstitute
           FROM governmentsubstituterank
          WHERE governmentsubstituterank.isgovernmentlead
        UNION
         SELECT government.governmentid,
            government.governmentid AS governmentsubstitute
           FROM geohistory.government
          WHERE (government.governmentsubstitute IS NULL)
        )
 SELECT governmentsubstitutecombine.governmentid,
    governmentsubstitutecombine.governmentsubstitute,
    (governmentsubstitutemultiple.governmentsubstitute IS NOT NULL) AS governmentsubstitutemultiple
   FROM (governmentsubstitutecombine
     LEFT JOIN governmentsubstitutemultiple ON ((governmentsubstitutecombine.governmentsubstitute = governmentsubstitutemultiple.governmentsubstitute)))
  ORDER BY governmentsubstitutecombine.governmentid, governmentsubstitutecombine.governmentsubstitute;


ALTER VIEW extra.governmentsubstitute OWNER TO postgres;

--
-- Name: adjudicationevent; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.adjudicationevent (
    adjudicationeventid integer NOT NULL,
    adjudication integer NOT NULL,
    event integer NOT NULL,
    eventrelationship integer NOT NULL,
    CONSTRAINT adjudicationevent_check CHECK ((eventrelationship <> ALL (ARRAY[2, 4, 6, 7, 9])))
);


ALTER TABLE geohistory.adjudicationevent OWNER TO postgres;

--
-- Name: adjudicationlocation; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.adjudicationlocation (
    adjudicationlocationid integer NOT NULL,
    adjudication integer NOT NULL,
    adjudicationlocationtype integer NOT NULL,
    adjudicationlocationvolume character varying(50) DEFAULT ''::text NOT NULL,
    adjudicationlocationpagefrom character varying(10) DEFAULT ''::text NOT NULL,
    adjudicationlocationpageto character varying(10) DEFAULT ''::text NOT NULL,
    adjudicationlocationrepositorylevel integer,
    adjudicationlocationrepositoryshort character varying(30) DEFAULT ''::text NOT NULL,
    adjudicationlocationrepositoryitemnumber character varying(10) DEFAULT ''::text NOT NULL,
    adjudicationlocationrepositoryitemfrom integer,
    adjudicationlocationrepositoryitemto integer,
    adjudicationlocationrepositoryitemlocation character varying(25) DEFAULT ''::character varying NOT NULL,
    adjudicationlocationrepositoryextractdate calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    adjudicationlocationrepositoryorder smallint,
    adjudicationlocationrepositoryentry character varying(75) DEFAULT ''::text NOT NULL,
    adjudicationlocationrepositoryseries character varying(50) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE geohistory.adjudicationlocation OWNER TO postgres;

--
-- Name: adjudicationlocationtype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.adjudicationlocationtype (
    adjudicationlocationtypeid integer NOT NULL,
    tribunal integer NOT NULL,
    adjudicationlocationtypearchivelevel integer,
    adjudicationlocationtypearchiveseries character varying(10) DEFAULT ''::character varying NOT NULL,
    adjudicationlocationtypetype character varying(20) DEFAULT 'Docket'::text NOT NULL,
    adjudicationlocationtypevolumetype character varying(15) DEFAULT 'Volume'::text NOT NULL,
    adjudicationlocationtypepagetype character varying(10) DEFAULT 'Page'::text NOT NULL,
    adjudicationlocationtypeabbreviation character varying(45) DEFAULT ''::character varying NOT NULL,
    adjudicationlocationtypelong character varying(60) DEFAULT ''::character varying NOT NULL,
    adjudicationlocationtypeshort character varying(25) NOT NULL,
    CONSTRAINT adjudicationlocationtype_check CHECK (((adjudicationlocationtypeshort)::text <> ''::text))
);


ALTER TABLE geohistory.adjudicationlocationtype OWNER TO postgres;

--
-- Name: COLUMN adjudicationlocationtype.adjudicationlocationtypeshort; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.adjudicationlocationtype.adjudicationlocationtypeshort IS 'Conform with new abbreviations as of 2018-01-31';


--
-- Name: affectedgovernmentgroup; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.affectedgovernmentgroup (
    affectedgovernmentgroupid integer NOT NULL,
    event integer NOT NULL
);


ALTER TABLE geohistory.affectedgovernmentgroup OWNER TO postgres;

--
-- Name: affectedgovernmentgrouppart; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.affectedgovernmentgrouppart (
    affectedgovernmentgrouppartid integer NOT NULL,
    affectedgovernmentgroup integer NOT NULL,
    affectedgovernmentpart integer NOT NULL,
    affectedgovernmentlevel integer NOT NULL
);


ALTER TABLE geohistory.affectedgovernmentgrouppart OWNER TO postgres;

--
-- Name: affectedgovernmentpart; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.affectedgovernmentpart (
    affectedgovernmentpartid integer NOT NULL,
    governmentfrom integer,
    affectedtypefrom integer,
    governmentto integer,
    affectedtypeto integer,
    governmentformto integer,
    CONSTRAINT affectedgovernmentpart_check CHECK (((((governmentfrom IS NOT NULL) AND (affectedtypefrom IS NOT NULL)) OR ((governmentfrom IS NULL) AND (affectedtypefrom IS NULL))) AND (((governmentto IS NOT NULL) AND (affectedtypeto IS NOT NULL)) OR ((governmentto IS NULL) AND (affectedtypeto IS NULL) AND (governmentformto IS NULL)))))
);


ALTER TABLE geohistory.affectedgovernmentpart OWNER TO postgres;

--
-- Name: currentgovernment; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.currentgovernment (
    currentgovernmentid integer NOT NULL,
    governmentsubmunicipality integer,
    governmentmunicipality integer NOT NULL,
    governmentcounty integer NOT NULL,
    governmentstate integer NOT NULL,
    event integer NOT NULL
);


ALTER TABLE geohistory.currentgovernment OWNER TO postgres;

--
-- Name: event; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.event (
    eventid integer NOT NULL,
    eventtype integer NOT NULL,
    eventmethod integer NOT NULL,
    eventlong character varying(500) NOT NULL,
    eventfrom smallint NOT NULL,
    eventto smallint NOT NULL,
    eventeffective calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    eventeffectivetypestatutory integer,
    eventeffectivetypepresumedsource integer,
    eventisrelevant character varying(1) DEFAULT ''::character varying NOT NULL,
    eventeffectiveorder integer DEFAULT 0 NOT NULL,
    eventismapped boolean DEFAULT false NOT NULL,
    eventismappedtype character varying(100) DEFAULT ''::character varying NOT NULL,
    government integer,
    eventgranted integer NOT NULL,
    CONSTRAINT event_check CHECK (((eventfrom <= eventto) AND ((eventlong)::text <> ''::text) AND (((eventgranted = 17) AND (government IS NOT NULL)) OR ((eventgranted <> 17) AND (government IS NULL)))))
);


ALTER TABLE geohistory.event OWNER TO postgres;

--
-- Name: COLUMN event.eventtype; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.event.eventtype IS 'Rows with foreign key field eventtypegroup "Placeholder" are omitted from open data.';


--
-- Name: COLUMN event.eventeffectivetypestatutory; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.event.eventeffectivetypestatutory IS 'This field is used for comparison purposes to determine events where the effective type could be improved, and is not included in open data.';


--
-- Name: COLUMN event.eventisrelevant; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.event.eventisrelevant IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN event.eventismappedtype; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.event.eventismappedtype IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: governmentsource; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.governmentsource (
    governmentsourceid integer NOT NULL,
    government integer NOT NULL,
    governmentsourcetype character varying(30) NOT NULL,
    governmentsourcebody character varying(25) DEFAULT ''::character varying NOT NULL,
    governmentsourcenumber character varying(20) DEFAULT ''::character varying NOT NULL,
    governmentsourceterm character varying(15) DEFAULT ''::character varying NOT NULL,
    governmentsourcetitle text DEFAULT ''::text NOT NULL,
    governmentsourcepagefrom character varying(5) DEFAULT ''::character varying NOT NULL,
    governmentsourcepageto character varying(5) DEFAULT ''::character varying NOT NULL,
    governmentsourcedate calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    governmentsourcepreliminarydate calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    governmentsourceapproveddate calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    governmentsourceeffectivedate calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    governmentsourceapproved boolean DEFAULT true NOT NULL,
    governmentsourceeffectivenotes text DEFAULT ''::text NOT NULL,
    governmentsourceadvertiseddate calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    source integer,
    governmentsourcevolume character varying(50) DEFAULT ''::character varying NOT NULL,
    sourcecitationvolumetype character varying(50) DEFAULT ''::character varying,
    governmentsourcevolumetype character varying(50) DEFAULT ''::character varying NOT NULL,
    sourcecitationvolume character varying(50) DEFAULT ''::character varying NOT NULL,
    sourcecitationpagefrom character varying(5) DEFAULT ''::character varying NOT NULL,
    sourcecitationpageto character varying(5) DEFAULT ''::character varying NOT NULL,
    CONSTRAINT governmentsource_check CHECK (((governmentsourcetype)::text <> ''::text))
);


ALTER TABLE geohistory.governmentsource OWNER TO postgres;

--
-- Name: COLUMN governmentsource.governmentsourcetitle; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.governmentsource.governmentsourcetitle IS 'Certain placeholder values in this field that are used for internal tracking purposes are omitted from open data.';


--
-- Name: COLUMN governmentsource.governmentsourceapproved; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.governmentsource.governmentsourceapproved IS 'This field was previously ordveto -- as part of the conversion process, the data was reversed as follows: true from no, unk, and N/A; and false from yes and poc. This field is by default true unless there is clear evidence that the matter was vetoed or rejected. If approval is unknown or ambiguous, true should be entered. True values are to be construed in conjunction with data in othergovernmentsourceapproveddate -- in the event the latter field is empty, the actual approval status is unknown.';


--
-- Name: governmentsourceevent; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.governmentsourceevent (
    governmentsourceeventid integer NOT NULL,
    governmentsource integer NOT NULL,
    event integer NOT NULL,
    governmentsourceeventinclude boolean,
    eventrelationship integer NOT NULL
);


ALTER TABLE geohistory.governmentsourceevent OWNER TO postgres;

--
-- Name: law; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.law (
    lawid integer NOT NULL,
    source integer NOT NULL,
    lawvolume character varying(20) DEFAULT ''::character varying NOT NULL,
    lawpage integer NOT NULL,
    lawnumberchapter smallint NOT NULL,
    lawtype character varying(20) DEFAULT ''::character varying NOT NULL,
    lawtitle text DEFAULT ''::text NOT NULL,
    lawapproved calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    laweffective calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    lawsovereign calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    lawurl text DEFAULT ''::text NOT NULL,
    lawdescriptiondone boolean DEFAULT false NOT NULL,
    lawnumberchaptertext character varying(10) DEFAULT ''::character varying NOT NULL,
    lawsession character varying(50) DEFAULT ''::character varying NOT NULL,
    lawsessiontype character varying(50) DEFAULT ''::character varying NOT NULL,
    lawpublished calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    lawissue integer
);


ALTER TABLE geohistory.law OWNER TO postgres;

--
-- Name: COLUMN law.lawtitle; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.law.lawtitle IS 'Certain placeholder values in this field that are used for internal tracking purposes are omitted from open data.';


--
-- Name: COLUMN law.lawdescriptiondone; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.law.lawdescriptiondone IS 'This field is used for internal tracking purposes, and is always reflected as FALSE in open data.';


--
-- Name: lawsection; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.lawsection (
    lawsectionid integer NOT NULL,
    law integer NOT NULL,
    lawsectionfrom character varying(45) DEFAULT ''::character varying NOT NULL,
    lawsectionpagefrom integer,
    lawsectionto character varying(45) DEFAULT ''::character varying NOT NULL,
    lawsectionpageto integer,
    eventtype integer NOT NULL,
    lawsectionamend integer,
    lawsectionnewfrom character varying(45) DEFAULT ''::character varying NOT NULL,
    lawsectionnewto character varying(45) DEFAULT ''::character varying NOT NULL,
    lawsectionnewlaw integer,
    lawsectionsymbol character varying(20) DEFAULT '§'::character varying NOT NULL,
    lawsectionnewsymbol character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE geohistory.lawsection OWNER TO postgres;

--
-- Name: lawsectionevent; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.lawsectionevent (
    lawsectioneventid integer NOT NULL,
    lawsection integer NOT NULL,
    event integer NOT NULL,
    lawsectioneventnotes text DEFAULT ''::text NOT NULL,
    lawgroup integer,
    eventrelationship integer NOT NULL,
    CONSTRAINT lawsectionevent_check CHECK ((eventrelationship <> ALL (ARRAY[6, 7, 9])))
);


ALTER TABLE geohistory.lawsectionevent OWNER TO postgres;

--
-- Name: COLUMN lawsectionevent.lawsectioneventnotes; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.lawsectionevent.lawsectioneventnotes IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: metesdescription; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.metesdescription (
    metesdescriptionid integer NOT NULL,
    metesdescriptiontype character varying(20) NOT NULL,
    metesdescriptionsource character varying(55) NOT NULL,
    metesdescriptionbeginningpoint text DEFAULT ''::text NOT NULL,
    metesdescriptionstateplane integer NOT NULL,
    metesdescriptionlongitude numeric(10,7) DEFAULT 0.0000000 NOT NULL,
    metesdescriptionlatitude numeric(10,7) DEFAULT 0.0000000 NOT NULL,
    metesdescriptionangle double precision DEFAULT (0)::double precision NOT NULL,
    metesdescriptionquality character varying(5) DEFAULT ''::character varying NOT NULL,
    metesdescriptionnotes text DEFAULT ''::text NOT NULL,
    metesdescriptionname character varying(500) DEFAULT ''::character varying NOT NULL,
    event integer NOT NULL,
    metesdescriptionacres double precision DEFAULT 0 NOT NULL,
    CONSTRAINT metesdescription_check CHECK (((metesdescriptionacres >= (0)::double precision) AND ((metesdescriptionsource)::text <> ''::text) AND ((metesdescriptiontype)::text <> ''::text)))
);


ALTER TABLE geohistory.metesdescription OWNER TO postgres;

--
-- Name: sourcegovernment; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.sourcegovernment (
    sourcegovernmentid integer NOT NULL,
    source integer NOT NULL,
    sourceorder integer DEFAULT 1 NOT NULL,
    government integer NOT NULL
);


ALTER TABLE geohistory.sourcegovernment OWNER TO postgres;

--
-- Name: affectedgovernmentgis; Type: TABLE; Schema: gis; Owner: postgres
--

CREATE TABLE gis.affectedgovernmentgis (
    affectedgovernmentgisid integer NOT NULL,
    affectedgovernment integer NOT NULL,
    governmentshape integer
);


ALTER TABLE gis.affectedgovernmentgis OWNER TO postgres;

--
-- Name: governmentshape; Type: TABLE; Schema: gis; Owner: postgres
--

CREATE TABLE gis.governmentshape (
    governmentshapeid integer NOT NULL,
    governmentsubmunicipality integer,
    governmentmunicipality integer NOT NULL,
    governmentcounty integer NOT NULL,
    governmentstate integer NOT NULL,
    governmentshapenotes text DEFAULT ''::text NOT NULL,
    governmentshapegeometry public.geometry(Polygon,4326),
    governmentshapereference integer,
    governmentshapetag text DEFAULT ''::text NOT NULL,
    governmentshapeplsstownship integer,
    governmentward integer,
    governmentschooldistrict integer
);
ALTER TABLE ONLY gis.governmentshape ALTER COLUMN governmentshapegeometry SET STORAGE EXTERNAL;


ALTER TABLE gis.governmentshape OWNER TO postgres;

--
-- Name: COLUMN governmentshape.governmentshapereference; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.governmentshape.governmentshapereference IS 'This column should always match governmentshapeid, and is used for tracking purposes in order to aid in inserting, updating, and deleting records in associative entities when splitting or merging records.';


--
-- Name: COLUMN governmentshape.governmentshapetag; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON COLUMN gis.governmentshape.governmentshapetag IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: metesdescriptiongis; Type: TABLE; Schema: gis; Owner: postgres
--

CREATE TABLE gis.metesdescriptiongis (
    metesdescriptiongisid integer NOT NULL,
    metesdescription integer NOT NULL,
    governmentshape integer
);


ALTER TABLE gis.metesdescriptiongis OWNER TO postgres;

--
-- Name: eventgovernment; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.eventgovernment AS
 WITH eg AS (
         SELECT DISTINCT currentgovernment.event,
            currentgovernment.governmentsubmunicipality AS government
           FROM geohistory.currentgovernment
          WHERE (currentgovernment.governmentsubmunicipality IS NOT NULL)
        UNION
         SELECT DISTINCT currentgovernment.event,
            currentgovernment.governmentmunicipality AS government
           FROM geohistory.currentgovernment
        UNION
         SELECT DISTINCT currentgovernment.event,
            currentgovernment.governmentcounty AS government
           FROM geohistory.currentgovernment
        UNION
         SELECT DISTINCT currentgovernment.event,
            currentgovernment.governmentstate AS government
           FROM geohistory.currentgovernment
        UNION
         SELECT DISTINCT affectedgovernmentgroup.event,
            affectedgovernmentpart.governmentfrom AS government
           FROM ((geohistory.affectedgovernmentgroup
             JOIN geohistory.affectedgovernmentgrouppart ON ((affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup)))
             JOIN geohistory.affectedgovernmentpart ON (((affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid) AND (affectedgovernmentpart.governmentfrom IS NOT NULL))))
        UNION
         SELECT DISTINCT affectedgovernmentgroup.event,
            affectedgovernmentpart.governmentto AS government
           FROM ((geohistory.affectedgovernmentgroup
             JOIN geohistory.affectedgovernmentgrouppart ON ((affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup)))
             JOIN geohistory.affectedgovernmentpart ON (((affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid) AND (affectedgovernmentpart.governmentto IS NOT NULL))))
        UNION
         SELECT DISTINCT lawsectionevent.event,
            sourcegovernment.government
           FROM geohistory.lawsectionevent,
            geohistory.lawsection,
            geohistory.law,
            geohistory.sourcegovernment
          WHERE ((lawsectionevent.lawsection = lawsection.lawsectionid) AND (lawsection.law = law.lawid) AND (law.source = sourcegovernment.source) AND (sourcegovernment.sourceorder = 1))
        UNION
         SELECT DISTINCT governmentsourceevent.event,
            governmentsource.government
           FROM geohistory.governmentsource,
            geohistory.governmentsourceevent
          WHERE (governmentsourceevent.governmentsource = governmentsource.governmentsourceid)
        UNION
         SELECT DISTINCT adjudicationevent.event,
            tribunal.government
           FROM geohistory.adjudicationevent,
            geohistory.adjudication,
            geohistory.adjudicationtype,
            geohistory.tribunal
          WHERE ((adjudicationevent.adjudication = adjudication.adjudicationid) AND (adjudication.adjudicationtype = adjudicationtype.adjudicationtypeid) AND (adjudicationtype.tribunal = tribunal.tribunalid))
        UNION
         SELECT DISTINCT adjudicationevent.event,
            tribunal.government
           FROM geohistory.adjudicationevent,
            geohistory.adjudicationlocation,
            geohistory.adjudicationlocationtype,
            geohistory.tribunal
          WHERE ((adjudicationevent.adjudication = adjudicationlocation.adjudication) AND (adjudicationlocation.adjudicationlocationtype = adjudicationlocationtype.adjudicationlocationtypeid) AND (adjudicationlocationtype.tribunal = tribunal.tribunalid))
        UNION
         SELECT DISTINCT affectedgovernmentgroup.event,
            governmentshape.governmentsubmunicipality AS government
           FROM geohistory.affectedgovernmentgroup,
            gis.affectedgovernmentgis,
            gis.governmentshape
          WHERE ((affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgis.affectedgovernment) AND (affectedgovernmentgis.governmentshape = governmentshape.governmentshapeid) AND (governmentshape.governmentsubmunicipality IS NOT NULL))
        UNION
         SELECT DISTINCT affectedgovernmentgroup.event,
            governmentshape.governmentmunicipality AS government
           FROM geohistory.affectedgovernmentgroup,
            gis.affectedgovernmentgis,
            gis.governmentshape
          WHERE ((affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgis.affectedgovernment) AND (affectedgovernmentgis.governmentshape = governmentshape.governmentshapeid))
        UNION
         SELECT DISTINCT affectedgovernmentgroup.event,
            governmentshape.governmentcounty AS government
           FROM geohistory.affectedgovernmentgroup,
            gis.affectedgovernmentgis,
            gis.governmentshape
          WHERE ((affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgis.affectedgovernment) AND (affectedgovernmentgis.governmentshape = governmentshape.governmentshapeid))
        UNION
         SELECT DISTINCT affectedgovernmentgroup.event,
            governmentshape.governmentstate AS government
           FROM geohistory.affectedgovernmentgroup,
            gis.affectedgovernmentgis,
            gis.governmentshape
          WHERE ((affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgis.affectedgovernment) AND (affectedgovernmentgis.governmentshape = governmentshape.governmentshapeid))
        UNION
         SELECT DISTINCT metesdescription.event,
            governmentshape.governmentsubmunicipality AS government
           FROM geohistory.metesdescription,
            gis.metesdescriptiongis,
            gis.governmentshape
          WHERE ((metesdescription.metesdescriptionid = metesdescriptiongis.metesdescription) AND (metesdescriptiongis.governmentshape = governmentshape.governmentshapeid) AND (governmentshape.governmentsubmunicipality IS NOT NULL))
        UNION
         SELECT DISTINCT metesdescription.event,
            governmentshape.governmentmunicipality AS government
           FROM geohistory.metesdescription,
            gis.metesdescriptiongis,
            gis.governmentshape
          WHERE ((metesdescription.metesdescriptionid = metesdescriptiongis.metesdescription) AND (metesdescriptiongis.governmentshape = governmentshape.governmentshapeid))
        UNION
         SELECT DISTINCT metesdescription.event,
            governmentshape.governmentcounty AS government
           FROM geohistory.metesdescription,
            gis.metesdescriptiongis,
            gis.governmentshape
          WHERE ((metesdescription.metesdescriptionid = metesdescriptiongis.metesdescription) AND (metesdescriptiongis.governmentshape = governmentshape.governmentshapeid))
        UNION
         SELECT DISTINCT metesdescription.event,
            governmentshape.governmentstate AS government
           FROM geohistory.metesdescription,
            gis.metesdescriptiongis,
            gis.governmentshape
          WHERE ((metesdescription.metesdescriptionid = metesdescriptiongis.metesdescription) AND (metesdescriptiongis.governmentshape = governmentshape.governmentshapeid))
        UNION
         SELECT DISTINCT event_1.eventid AS event,
            event_1.government
           FROM geohistory.event event_1
          WHERE (event_1.government IS NOT NULL)
        )
 SELECT DISTINCT event.eventid,
    governmentsubstitute.governmentsubstitute AS government
   FROM (((geohistory.event
     LEFT JOIN eg ON ((eg.event = event.eventid)))
     LEFT JOIN geohistory.government ON ((eg.government = government.governmentid)))
     LEFT JOIN extra.governmentsubstitute ON ((government.governmentid = governmentsubstitute.governmentid)))
  WHERE ((government.governmentlevel IS NULL) OR (government.governmentlevel <> 1))
  ORDER BY event.eventid, governmentsubstitute.governmentsubstitute;


ALTER VIEW extra.eventgovernment OWNER TO postgres;

--
-- Name: affectedgovernmentlevel; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.affectedgovernmentlevel (
    affectedgovernmentlevelid integer NOT NULL,
    affectedgovernmentlevelshort character varying(20) NOT NULL,
    affectedgovernmentlevellong character varying(20) NOT NULL,
    affectedgovernmentlevelgroup integer NOT NULL,
    affectedgovernmentleveldisplayorder integer NOT NULL
);


ALTER TABLE geohistory.affectedgovernmentlevel OWNER TO postgres;

--
-- Name: eventgranted; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.eventgranted (
    eventgrantedid integer NOT NULL,
    eventgrantedlong text NOT NULL,
    eventgrantedshort character varying(15) NOT NULL,
    eventgrantedsuccess boolean DEFAULT true NOT NULL,
    eventgrantedcertainty boolean DEFAULT false NOT NULL,
    eventgrantedplaceholder boolean DEFAULT false NOT NULL,
    eventgrantedpublicview boolean DEFAULT true NOT NULL,
    CONSTRAINT eventgranted_check CHECK (((eventgrantedlong <> ''::text) AND ((eventgrantedshort)::text <> ''::text)))
);


ALTER TABLE geohistory.eventgranted OWNER TO postgres;

--
-- Name: COLUMN eventgranted.eventgrantedpublicview; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.eventgranted.eventgrantedpublicview IS 'TRUE items are omitted from open data.';


--
-- Name: governmentothercurrentparent; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.governmentothercurrentparent (
    governmentothercurrentparentid integer NOT NULL,
    government integer NOT NULL,
    governmentothercurrentparent integer NOT NULL
);


ALTER TABLE geohistory.governmentothercurrentparent OWNER TO postgres;

--
-- Name: governmentparent; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.governmentparent AS
 SELECT government.governmentid,
    government.governmentcurrentleadparent AS governmentparent,
        CASE
            WHEN (((government.governmentstatus)::text = ''::text) AND (extra.governmentstatus(government.governmentcurrentleadparent) = ''::text)) THEN 'current'::text
            WHEN ((government.governmentstatus)::text = 'proposed'::text) THEN 'proposed'::text
            WHEN ((government.governmentstatus)::text = 'unincorporated'::text) THEN 'unincorporated'::text
            WHEN ((government.governmentstatus)::text = 'placeholder'::text) THEN 'placeholder'::text
            ELSE 'most recent'::text
        END AS governmentparentstatus
   FROM geohistory.government
UNION
 SELECT governmentothercurrentparent.government AS governmentid,
    governmentothercurrentparent.governmentothercurrentparent AS governmentparent,
        CASE
            WHEN ((extra.governmentstatus(governmentothercurrentparent.government) = ''::text) AND (extra.governmentstatus(governmentothercurrentparent.governmentothercurrentparent) = ''::text)) THEN 'current'::text
            WHEN (extra.governmentstatus(governmentothercurrentparent.government) = 'proposed'::text) THEN 'proposed'::text
            WHEN (extra.governmentstatus(governmentothercurrentparent.government) = 'unincorporated'::text) THEN 'unincorporated'::text
            ELSE 'most recent'::text
        END AS governmentparentstatus
   FROM geohistory.governmentothercurrentparent
UNION (
         SELECT totalgovernment.governmentid,
            totalgovernment.governmentparent,
                CASE
                    WHEN (max((totalgovernment.eventgrantedsuccess)::integer) = 1) THEN 'former'::text
                    ELSE 'proposed'::text
                END AS governmentparentstatus
           FROM ( SELECT DISTINCT affectedgovernmentpart.governmentfrom AS governmentid,
                    parentpart.governmentfrom AS governmentparent,
                    eventgranted.eventgrantedsuccess
                   FROM ((((((((geohistory.affectedgovernmentgroup
                     JOIN geohistory.event ON ((affectedgovernmentgroup.event = event.eventid)))
                     JOIN geohistory.eventgranted ON ((event.eventgranted = eventgranted.eventgrantedid)))
                     JOIN geohistory.affectedgovernmentgrouppart ON ((affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup)))
                     JOIN geohistory.affectedgovernmentlevel ON ((affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid)))
                     JOIN geohistory.affectedgovernmentgrouppart parentgrouppart ON ((affectedgovernmentgroup.affectedgovernmentgroupid = parentgrouppart.affectedgovernmentgroup)))
                     JOIN geohistory.affectedgovernmentlevel parentlevel ON (((parentgrouppart.affectedgovernmentlevel = parentlevel.affectedgovernmentlevelid) AND (parentlevel.affectedgovernmentlevelgroup < affectedgovernmentlevel.affectedgovernmentlevelgroup) AND (parentlevel.affectedgovernmentlevelgroup < 4))))
                     JOIN geohistory.affectedgovernmentpart ON (((affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid) AND (affectedgovernmentpart.governmentfrom IS NOT NULL))))
                     JOIN geohistory.affectedgovernmentpart parentpart ON (((parentgrouppart.affectedgovernmentpart = parentpart.affectedgovernmentpartid) AND (parentpart.governmentfrom IS NOT NULL))))
                UNION
                 SELECT DISTINCT affectedgovernmentpart.governmentto AS governmentid,
                    parentpart.governmentto AS governmentparent,
                    eventgranted.eventgrantedsuccess
                   FROM ((((((((geohistory.affectedgovernmentgroup
                     JOIN geohistory.event ON ((affectedgovernmentgroup.event = event.eventid)))
                     JOIN geohistory.eventgranted ON ((event.eventgranted = eventgranted.eventgrantedid)))
                     JOIN geohistory.affectedgovernmentgrouppart ON ((affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup)))
                     JOIN geohistory.affectedgovernmentlevel ON ((affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid)))
                     JOIN geohistory.affectedgovernmentgrouppart parentgrouppart ON ((affectedgovernmentgroup.affectedgovernmentgroupid = parentgrouppart.affectedgovernmentgroup)))
                     JOIN geohistory.affectedgovernmentlevel parentlevel ON (((parentgrouppart.affectedgovernmentlevel = parentlevel.affectedgovernmentlevelid) AND (parentlevel.affectedgovernmentlevelgroup < affectedgovernmentlevel.affectedgovernmentlevelgroup) AND (parentlevel.affectedgovernmentlevelgroup < 4))))
                     JOIN geohistory.affectedgovernmentpart ON (((affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid) AND (affectedgovernmentpart.governmentto IS NOT NULL))))
                     JOIN geohistory.affectedgovernmentpart parentpart ON (((parentgrouppart.affectedgovernmentpart = parentpart.affectedgovernmentpartid) AND (parentpart.governmentto IS NOT NULL))))
                UNION
                 SELECT currentgovernment.governmentsubmunicipality AS governmentid,
                    currentgovernment.governmentcounty AS governmentparent,
                    eventgranted.eventgrantedsuccess
                   FROM ((geohistory.currentgovernment
                     JOIN geohistory.event ON ((currentgovernment.event = event.eventid)))
                     JOIN geohistory.eventgranted ON ((event.eventgranted = eventgranted.eventgrantedid)))
                  WHERE (currentgovernment.governmentsubmunicipality IS NOT NULL)
                UNION
                 SELECT currentgovernment.governmentmunicipality AS governmentid,
                    currentgovernment.governmentcounty AS governmentparent,
                    eventgranted.eventgrantedsuccess
                   FROM ((geohistory.currentgovernment
                     JOIN geohistory.event ON ((currentgovernment.event = event.eventid)))
                     JOIN geohistory.eventgranted ON ((event.eventgranted = eventgranted.eventgrantedid)))
                UNION
                 SELECT currentgovernment.governmentcounty AS governmentid,
                    currentgovernment.governmentstate AS governmentparent,
                    eventgranted.eventgrantedsuccess
                   FROM ((geohistory.currentgovernment
                     JOIN geohistory.event ON ((currentgovernment.event = event.eventid)))
                     JOIN geohistory.eventgranted ON ((event.eventgranted = eventgranted.eventgrantedid)))) totalgovernment
          WHERE (NOT (totalgovernment.governmentid IN ( SELECT government.governmentid
                   FROM geohistory.government
                  WHERE ((government.governmentstatus)::text = 'placeholder'::text))))
          GROUP BY totalgovernment.governmentid, totalgovernment.governmentparent
        EXCEPT (
                 SELECT government.governmentid,
                    government.governmentcurrentleadparent AS governmentparent,
                    'former'::text AS governmentparentstatus
                   FROM geohistory.government
                UNION
                 SELECT governmentothercurrentparent.government AS governmentid,
                    governmentothercurrentparent.governmentothercurrentparent AS governmentparent,
                    'former'::text AS governmentparentstatus
                   FROM geohistory.governmentothercurrentparent
                UNION
                 SELECT government.governmentid,
                    government.governmentcurrentleadparent AS governmentparent,
                    'proposed'::text AS governmentparentstatus
                   FROM geohistory.government
                UNION
                 SELECT governmentothercurrentparent.government AS governmentid,
                    governmentothercurrentparent.governmentothercurrentparent AS governmentparent,
                    'proposed'::text AS governmentparentstatus
                   FROM geohistory.governmentothercurrentparent
        )
)
  ORDER BY 1, 2, 3;


ALTER VIEW extra.governmentparent OWNER TO postgres;

--
-- Name: governmentrelation; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.governmentrelation AS
 WITH RECURSIVE governmentparentpart(governmentparent, governmentid) AS (
         SELECT s1.governmentparent,
            s1.governmentid
           FROM extra.governmentparent s1
        UNION
         SELECT s2.governmentparent,
            s1.governmentid
           FROM extra.governmentparent s2,
            governmentparentpart s1
          WHERE (s2.governmentid = s1.governmentparent)
        ), governmentsubstitute AS (
         SELECT governmentsubstitute.governmentid,
            governmentsubstitute.governmentsubstitute,
            governmentsubstitute.governmentsubstitutemultiple
           FROM extra.governmentsubstitute
          WHERE (governmentsubstitute.governmentid <> governmentsubstitute.governmentsubstitute)
        )
 SELECT DISTINCT governmentparentpart.governmentid,
    extra.governmentlevel(governmentparentpart.governmentid) AS governmentlevel,
    extra.governmentshort(governmentparentpart.governmentid) AS governmentshort,
    extra.governmentlong(governmentparentpart.governmentid) AS governmentlong,
    extra.governmentlevel(governmentparentpart.governmentparent) AS governmentrelationlevel,
    governmentparentpart.governmentparent AS governmentrelation,
        CASE
            WHEN (extra.governmentlevel(governmentparentpart.governmentparent) = 2) THEN extra.governmentabbreviation(governmentparentpart.governmentparent)
            ELSE ''::text
        END AS governmentrelationstate
   FROM governmentparentpart
  WHERE (governmentparentpart.governmentparent IS NOT NULL)
UNION
 SELECT DISTINCT government.governmentid,
    government.governmentlevel,
    extra.governmentshort(government.governmentid) AS governmentshort,
    extra.governmentlong(government.governmentid) AS governmentlong,
    government.governmentlevel AS governmentrelationlevel,
    government.governmentid AS governmentrelation,
        CASE
            WHEN (government.governmentlevel = 2) THEN government.governmentabbreviation
            ELSE ''::character varying
        END AS governmentrelationstate
   FROM geohistory.government
UNION
 SELECT DISTINCT governmentparentpart.governmentid,
    extra.governmentlevel(governmentparentpart.governmentid) AS governmentlevel,
    extra.governmentshort(governmentparentpart.governmentid) AS governmentshort,
    extra.governmentlong(governmentparentpart.governmentid) AS governmentlong,
    extra.governmentlevel(governmentparentpart.governmentparent) AS governmentrelationlevel,
    governmentsubstitute.governmentsubstitute AS governmentrelation,
        CASE
            WHEN (extra.governmentlevel(governmentparentpart.governmentparent) = 2) THEN extra.governmentabbreviation(governmentsubstitute.governmentsubstitute)
            ELSE ''::text
        END AS governmentrelationstate
   FROM (governmentparentpart
     JOIN governmentsubstitute ON (((governmentparentpart.governmentparent = governmentsubstitute.governmentid) AND (governmentparentpart.governmentparent IS NOT NULL) AND (governmentsubstitute.governmentsubstitute IS NOT NULL))))
UNION
 SELECT DISTINCT government.governmentid,
    government.governmentlevel,
    extra.governmentshort(government.governmentid) AS governmentshort,
    extra.governmentlong(government.governmentid) AS governmentlong,
    government.governmentlevel AS governmentrelationlevel,
    government.governmentsubstitute AS governmentrelation,
        CASE
            WHEN (government.governmentlevel = 2) THEN (extra.governmentabbreviation(government.governmentsubstitute))::character varying
            ELSE ''::character varying
        END AS governmentrelationstate
   FROM geohistory.government
  WHERE (government.governmentsubstitute IS NOT NULL)
UNION
 SELECT government.governmentid,
    government.governmentlevel,
    extra.governmentshort(government.governmentid) AS governmentshort,
    extra.governmentlong(government.governmentid) AS governmentlong,
    2 AS governmentrelationlevel,
    NULL::integer AS governmentrelation,
    NULL::text AS governmentrelationstate
   FROM geohistory.government
  WHERE (government.governmentlevel = 1)
  ORDER BY 1, 5, 6;


ALTER VIEW extra.governmentrelation OWNER TO postgres;

--
-- Name: adjudicationgovernment; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.adjudicationgovernment AS
 SELECT DISTINCT adjudication.adjudicationid,
    ag2.governmentrelationstate
   FROM (geohistory.adjudication
     LEFT JOIN (( SELECT DISTINCT adjudication_1.adjudicationid AS adjudication,
            tribunal.government
           FROM geohistory.adjudication adjudication_1,
            geohistory.adjudicationtype,
            geohistory.tribunal
          WHERE ((adjudication_1.adjudicationtype = adjudicationtype.adjudicationtypeid) AND (adjudicationtype.tribunal = tribunal.tribunalid))
        UNION
         SELECT DISTINCT adjudicationlocation.adjudication,
            tribunal.government
           FROM geohistory.adjudicationlocation,
            geohistory.adjudicationlocationtype,
            geohistory.tribunal
          WHERE ((adjudicationlocation.adjudicationlocationtype = adjudicationlocationtype.adjudicationlocationtypeid) AND (adjudicationlocationtype.tribunal = tribunal.tribunalid))
        UNION
         SELECT DISTINCT adjudicationevent.adjudication,
            eventgovernment.government
           FROM geohistory.adjudicationevent,
            extra.eventgovernment
          WHERE (adjudicationevent.event = eventgovernment.eventid)) ag
     JOIN extra.governmentrelation ON (((ag.government = governmentrelation.governmentid) AND (governmentrelation.governmentrelationstate IS NOT NULL) AND (governmentrelation.governmentrelationstate <> ''::text)))) ag2 ON (((ag2.government IS NOT NULL) AND (extra.governmentlevel(ag2.government) <> 1) AND (ag2.adjudication = adjudication.adjudicationid))))
  ORDER BY ag2.governmentrelationstate, adjudication.adjudicationid;


ALTER VIEW extra.adjudicationgovernment OWNER TO postgres;

--
-- Name: adjudicationgovernmentcache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.adjudicationgovernmentcache AS
 SELECT adjudicationid,
    governmentrelationstate
   FROM extra.adjudicationgovernment
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.adjudicationgovernmentcache OWNER TO postgres;

--
-- Name: tribunalgovernment; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.tribunalgovernment AS
 SELECT DISTINCT tribunal.tribunalid,
    extra.governmentabbreviation(extra.governmentcurrentleadstateid(tribunal.government)) AS governmentrelationstate,
    extra.tribunalshort(tribunal.tribunalid) AS tribunalshort,
    extra.tribunalshort(tribunal.tribunalid, '--'::character varying) AS tribunalshortstate,
    extra.tribunallong(tribunal.tribunalid) AS tribunallong,
    extra.tribunalfilingoffice(tribunal.tribunalid) AS tribunalfilingoffice,
    count(DISTINCT adjudicationtype.adjudicationtypeid) AS adjudicationtypecount,
    count(DISTINCT adjudicationlocationtype.adjudicationlocationtypeid) AS adjudicationlocationtypecount
   FROM ((geohistory.tribunal
     LEFT JOIN geohistory.adjudicationtype ON ((tribunal.tribunalid = adjudicationtype.tribunal)))
     LEFT JOIN geohistory.adjudicationlocationtype ON ((tribunal.tribunalid = adjudicationlocationtype.tribunal)))
  GROUP BY tribunal.tribunalid, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(tribunal.government))), (extra.tribunalshort(tribunal.tribunalid)), (extra.tribunalshort(tribunal.tribunalid, '--'::character varying)), (extra.tribunallong(tribunal.tribunalid)), (extra.tribunalfilingoffice(tribunal.tribunalid))
  ORDER BY tribunal.tribunalid;


ALTER VIEW extra.tribunalgovernment OWNER TO postgres;

--
-- Name: tribunalgovernmentcache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.tribunalgovernmentcache AS
 SELECT tribunalid,
    governmentrelationstate,
    tribunalshort,
    tribunalshortstate,
    tribunallong,
    tribunalfilingoffice,
    adjudicationtypecount,
    adjudicationlocationtypecount
   FROM extra.tribunalgovernment
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.tribunalgovernmentcache OWNER TO postgres;

--
-- Name: adjudicationsearch; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.adjudicationsearch AS
 SELECT DISTINCT (lpad((adjudication.adjudicationid)::text, 6, '0'::text) || lpad((extra.nulltozero(adjudicationlocation.adjudicationlocationid))::text, 6, '0'::text)) AS adjudicationlocationid,
    lpad((adjudication.adjudicationid)::text, 6, '0'::text) AS adjudicationid,
    adjudication.adjudicationnumber,
    adjudication.adjudicationterm,
    btrim(((((adjudication.adjudicationlong || ' '::text) || adjudication.adjudicationshort) || ' '::text) || adjudication.adjudicationnotes)) AS adjudicationsummary,
        CASE
            WHEN ((adjudicationgovernmentcache.governmentrelationstate = a.governmentrelationstate) OR (adjudicationgovernmentcache.governmentrelationstate IS NULL)) THEN a.tribunalshort
            ELSE a.tribunalshortstate
        END AS adjudicationtribunal,
    adjudicationtype.adjudicationtypeshort,
    adjudicationtype.adjudicationtypeabbreviation,
    lpad((adjudicationtype.adjudicationtypeid)::text, 6, '0'::text) AS adjudicationtypeid,
    lpad(extra.nulltoempty((adjudicationlocationtype.adjudicationlocationtypeid)::text), 6, '0'::text) AS adjudicationlocationtypeid,
    extra.nulltoempty((adjudicationlocation.adjudicationlocationvolume)::text) AS adjudicationlocationvolume,
    extra.nulltoempty((adjudicationlocation.adjudicationlocationpagefrom)::text) AS adjudicationlocationpagefrom,
    extra.nulltoempty((adjudicationlocation.adjudicationlocationpageto)::text) AS adjudicationlocationpageto,
        CASE
            WHEN ((adjudicationgovernmentcache.governmentrelationstate = b.governmentrelationstate) OR (adjudicationgovernmentcache.governmentrelationstate IS NULL)) THEN b.tribunalshort
            ELSE extra.nulltoempty(b.tribunalshortstate)
        END AS adjudicationlocationtribunal,
    extra.nulltoempty((adjudicationlocationtype.adjudicationlocationtypeshort)::text) AS adjudicationlocationtypeshort,
    extra.nulltoempty((adjudicationlocationtype.adjudicationlocationtypeabbreviation)::text) AS adjudicationlocationtypeabbreviation,
        CASE
            WHEN (adjudicationgovernmentcache.governmentrelationstate IS NULL) THEN upper("left"(a.tribunalshortstate, 2))
            ELSE adjudicationgovernmentcache.governmentrelationstate
        END AS governmentrelationstate,
    adjudication.adjudicationlong,
    adjudication.adjudicationshort,
    adjudication.adjudicationnotes,
    adjudication.adjudicationstatus,
    adjudicationtype.tribunal AS adjudicationtribunalid,
    adjudicationlocationtype.tribunal AS adjudicationlocationtribunalid
   FROM ((((geohistory.adjudication
     LEFT JOIN extra.adjudicationgovernmentcache ON ((adjudication.adjudicationid = adjudicationgovernmentcache.adjudicationid)))
     JOIN geohistory.adjudicationtype ON ((adjudication.adjudicationtype = adjudicationtype.adjudicationtypeid)))
     JOIN extra.tribunalgovernmentcache a ON ((adjudicationtype.tribunal = a.tribunalid)))
     LEFT JOIN ((geohistory.adjudicationlocation
     JOIN geohistory.adjudicationlocationtype ON ((adjudicationlocation.adjudicationlocationtype = adjudicationlocationtype.adjudicationlocationtypeid)))
     JOIN extra.tribunalgovernmentcache b ON ((adjudicationlocationtype.tribunal = b.tribunalid))) ON ((adjudication.adjudicationid = adjudicationlocation.adjudication)))
  ORDER BY
        CASE
            WHEN (adjudicationgovernmentcache.governmentrelationstate IS NULL) THEN upper("left"(a.tribunalshortstate, 2))
            ELSE adjudicationgovernmentcache.governmentrelationstate
        END,
        CASE
            WHEN ((adjudicationgovernmentcache.governmentrelationstate = a.governmentrelationstate) OR (adjudicationgovernmentcache.governmentrelationstate IS NULL)) THEN a.tribunalshort
            ELSE a.tribunalshortstate
        END, adjudicationtype.adjudicationtypeshort, adjudication.adjudicationterm, adjudication.adjudicationnumber,
        CASE
            WHEN ((adjudicationgovernmentcache.governmentrelationstate = b.governmentrelationstate) OR (adjudicationgovernmentcache.governmentrelationstate IS NULL)) THEN b.tribunalshort
            ELSE extra.nulltoempty(b.tribunalshortstate)
        END, (extra.nulltoempty((adjudicationlocationtype.adjudicationlocationtypeshort)::text)), (extra.nulltoempty((adjudicationlocation.adjudicationlocationvolume)::text)), (extra.nulltoempty((adjudicationlocation.adjudicationlocationpagefrom)::text));


ALTER VIEW extra.adjudicationsearch OWNER TO postgres;

--
-- Name: adjudicationsearchcache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.adjudicationsearchcache AS
 SELECT adjudicationlocationid,
    adjudicationid,
    adjudicationnumber,
    adjudicationterm,
    adjudicationsummary,
    adjudicationtribunal,
    adjudicationtypeshort,
    adjudicationtypeabbreviation,
    adjudicationtypeid,
    adjudicationlocationtypeid,
    adjudicationlocationvolume,
    adjudicationlocationpagefrom,
    adjudicationlocationpageto,
    adjudicationlocationtribunal,
    adjudicationlocationtypeshort,
    adjudicationlocationtypeabbreviation,
    governmentrelationstate,
    adjudicationlong,
    adjudicationshort,
    adjudicationnotes,
    adjudicationstatus,
    adjudicationtribunalid,
    adjudicationlocationtribunalid
   FROM extra.adjudicationsearch
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.adjudicationsearchcache OWNER TO postgres;

--
-- Name: adjudicationsourcecitation; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.adjudicationsourcecitation (
    adjudicationsourcecitationid integer NOT NULL,
    source integer NOT NULL,
    adjudicationsourcecitationvolume smallint,
    adjudicationsourcecitationpagefrom smallint,
    adjudicationsourcecitationpageto smallint,
    adjudicationsourcecitationyear character varying(4) DEFAULT ''::character varying NOT NULL,
    adjudicationsourcecitationdate calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    adjudicationsourcecitationtitle text DEFAULT ''::text NOT NULL,
    adjudicationsourcecitationauthor character varying(45) DEFAULT ''::character varying NOT NULL,
    adjudicationsourcecitationjudge character varying(45) DEFAULT ''::character varying NOT NULL,
    adjudicationsourcecitationdissentjudge character varying(45) DEFAULT ''::character varying NOT NULL,
    adjudicationsourcecitationurl text DEFAULT ''::text NOT NULL,
    adjudication integer NOT NULL
);


ALTER TABLE geohistory.adjudicationsourcecitation OWNER TO postgres;

--
-- Name: source; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.source (
    sourceid integer NOT NULL,
    sourcetype character varying(25) NOT NULL,
    sourceshort character varying(50) DEFAULT ''::character varying NOT NULL,
    sourceshortpart character varying(50) DEFAULT ''::character varying NOT NULL,
    sourcebookshort character varying(20) DEFAULT ''::character varying NOT NULL,
    sourceurlsubstitute integer NOT NULL,
    sourcelawtype character varying(50) DEFAULT ''::character varying NOT NULL,
    sourceperson text DEFAULT ''::text NOT NULL,
    sourcesectiontitle text DEFAULT ''::text NOT NULL,
    sourcetitle text DEFAULT ''::text NOT NULL,
    sourceidentifier text DEFAULT ''::text NOT NULL,
    sourcepublisherlocation text DEFAULT ''::text NOT NULL,
    sourcepublisher text DEFAULT ''::text NOT NULL,
    sourcepublisheryear character varying(20) DEFAULT ''::text NOT NULL,
    sourcelawisbynumber boolean DEFAULT false NOT NULL,
    sourcelawhasspecialsession boolean DEFAULT false NOT NULL,
    sourceabbreviationverified boolean DEFAULT false NOT NULL,
    sourcetemporarynote text DEFAULT ''::text NOT NULL
);


ALTER TABLE geohistory.source OWNER TO postgres;

--
-- Name: COLUMN source.sourcetemporarynote; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.source.sourcetemporarynote IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: adjudicationsourcecitationextra; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.adjudicationsourcecitationextra AS
 WITH adjudicationsourcecitationslugs AS (
         SELECT adjudicationsourcecitation.adjudicationsourcecitationid,
            lower(replace(replace(replace((((
                CASE
                    WHEN (adjudicationsourcecitation.adjudicationsourcecitationvolume = 0) THEN ''::text
                    ELSE (adjudicationsourcecitation.adjudicationsourcecitationvolume || '-'::text)
                END || (source.sourceshort)::text) ||
                CASE
                    WHEN (adjudicationsourcecitation.adjudicationsourcecitationpagefrom = 0) THEN ''::text
                    ELSE ('-'::text || adjudicationsourcecitation.adjudicationsourcecitationpagefrom)
                END) ||
                CASE
                    WHEN (((adjudicationsourcecitation.adjudicationsourcecitationdate)::text = ''::text) OR ("left"((adjudicationsourcecitation.adjudicationsourcecitationdate)::text, 4) = '0000'::text)) THEN
                    CASE
                        WHEN ((adjudicationsourcecitation.adjudicationsourcecitationyear)::text = ''::text) THEN ''::text
                        ELSE ('-'::text || (adjudicationsourcecitation.adjudicationsourcecitationyear)::text)
                    END
                    ELSE ('-'::text || "left"((adjudicationsourcecitation.adjudicationsourcecitationdate)::text, 4))
                END), '.'::text, ''::text), '& '::text, ''::text), ' '::text, '-'::text)) AS adjudicationsourcecitationpartslug
           FROM (geohistory.adjudicationsourcecitation
             JOIN geohistory.source ON ((adjudicationsourcecitation.source = source.sourceid)))
        ), adjudicationsourcecitationslugcounts AS (
         SELECT count(*) AS rowct,
            adjudicationsourcecitationslugs_1.adjudicationsourcecitationpartslug
           FROM adjudicationsourcecitationslugs adjudicationsourcecitationslugs_1
          GROUP BY adjudicationsourcecitationslugs_1.adjudicationsourcecitationpartslug
        )
 SELECT adjudicationsourcecitationslugs.adjudicationsourcecitationid,
    (adjudicationsourcecitationslugs.adjudicationsourcecitationpartslug ||
        CASE
            WHEN (adjudicationsourcecitationslugcounts.rowct > 1) THEN ('-'::text || rank() OVER (PARTITION BY adjudicationsourcecitationslugcounts.adjudicationsourcecitationpartslug ORDER BY adjudicationsourcecitationslugs.adjudicationsourcecitationid))
            ELSE ''::text
        END) AS adjudicationsourcecitationslug
   FROM (adjudicationsourcecitationslugs
     JOIN adjudicationsourcecitationslugcounts ON ((adjudicationsourcecitationslugs.adjudicationsourcecitationpartslug = adjudicationsourcecitationslugcounts.adjudicationsourcecitationpartslug)))
  ORDER BY adjudicationsourcecitationslugs.adjudicationsourcecitationid;


ALTER VIEW extra.adjudicationsourcecitationextra OWNER TO postgres;

--
-- Name: adjudicationsourcecitationextracache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.adjudicationsourcecitationextracache AS
 SELECT adjudicationsourcecitationid,
    adjudicationsourcecitationslug
   FROM extra.adjudicationsourcecitationextra
  ORDER BY adjudicationsourcecitationid
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.adjudicationsourcecitationextracache OWNER TO postgres;

--
-- Name: adjudicationsourcecitationsourcegovernment; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.adjudicationsourcecitationsourcegovernment AS
 SELECT DISTINCT source.sourceshort,
    adjudicationgovernment.governmentrelationstate
   FROM ((geohistory.source
     JOIN geohistory.adjudicationsourcecitation ON ((source.sourceid = adjudicationsourcecitation.source)))
     LEFT JOIN extra.adjudicationgovernment ON ((adjudicationsourcecitation.adjudication = adjudicationgovernment.adjudicationid)))
  WHERE ((source.sourcetype)::text = 'court reporters'::text)
  ORDER BY adjudicationgovernment.governmentrelationstate, source.sourceshort;


ALTER VIEW extra.adjudicationsourcecitationsourcegovernment OWNER TO postgres;

--
-- Name: adjudicationsourcecitationsourcegovernmentcache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.adjudicationsourcecitationsourcegovernmentcache AS
 SELECT sourceshort,
    governmentrelationstate
   FROM extra.adjudicationsourcecitationsourcegovernment
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.adjudicationsourcecitationsourcegovernmentcache OWNER TO postgres;

--
-- Name: affectedgovernment_reconstructed; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.affectedgovernment_reconstructed AS
 SELECT DISTINCT affectedgovernmentgroup.affectedgovernmentgroupid AS affectedgovernmentid,
    affectedgovernmentgroup.event,
    municipalitypart.governmentfrom AS municipalityfrom,
    municipalitypart.affectedtypefrom AS affectedtypemunicipalityfrom,
    municipalitypart.governmentto AS municipalityto,
    municipalitypart.affectedtypeto AS affectedtypemunicipalityto,
    municipalitypart.governmentformto AS governmentformmunicipalityto,
    submunicipalitypart.governmentfrom AS submunicipalityfrom,
    submunicipalitypart.affectedtypefrom AS affectedtypesubmunicipalityfrom,
    submunicipalitypart.governmentto AS submunicipalityto,
    submunicipalitypart.affectedtypeto AS affectedtypesubmunicipalityto,
    submunicipalitypart.governmentformto AS governmentformsubmunicipalityto,
    countypart.governmentfrom AS countyfrom,
    countypart.affectedtypefrom AS affectedtypecountyfrom,
    countypart.governmentto AS countyto,
    countypart.affectedtypeto AS affectedtypecountyto,
    countypart.governmentformto AS governmentformcountyto,
    subcountypart.governmentfrom AS subcountyfrom,
    subcountypart.affectedtypefrom AS affectedtypesubcountyfrom,
    subcountypart.governmentto AS subcountyto,
    subcountypart.affectedtypeto AS affectedtypesubcountyto,
    subcountypart.governmentformto AS governmentformsubcountyto,
    statepart.governmentfrom AS statefrom,
    statepart.affectedtypefrom AS affectedtypestatefrom,
    statepart.governmentto AS stateto,
    statepart.affectedtypeto AS affectedtypestateto,
    statepart.governmentformto AS governmentformstateto
   FROM (((((((((((((((geohistory.affectedgovernmentgroup
     LEFT JOIN geohistory.affectedgovernmentlevel municipalitylevel ON (((municipalitylevel.affectedgovernmentlevelshort)::text = 'municipality'::text)))
     LEFT JOIN geohistory.affectedgovernmentgrouppart municipalitygrouppart ON (((affectedgovernmentgroup.affectedgovernmentgroupid = municipalitygrouppart.affectedgovernmentgroup) AND (municipalitygrouppart.affectedgovernmentlevel = municipalitylevel.affectedgovernmentlevelid))))
     LEFT JOIN geohistory.affectedgovernmentpart municipalitypart ON ((municipalitygrouppart.affectedgovernmentpart = municipalitypart.affectedgovernmentpartid)))
     LEFT JOIN geohistory.affectedgovernmentlevel submunicipalitylevel ON (((submunicipalitylevel.affectedgovernmentlevelshort)::text = 'submunicipality'::text)))
     LEFT JOIN geohistory.affectedgovernmentgrouppart submunicipalitygrouppart ON (((affectedgovernmentgroup.affectedgovernmentgroupid = submunicipalitygrouppart.affectedgovernmentgroup) AND (submunicipalitygrouppart.affectedgovernmentlevel = submunicipalitylevel.affectedgovernmentlevelid))))
     LEFT JOIN geohistory.affectedgovernmentpart submunicipalitypart ON ((submunicipalitygrouppart.affectedgovernmentpart = submunicipalitypart.affectedgovernmentpartid)))
     LEFT JOIN geohistory.affectedgovernmentlevel countylevel ON (((countylevel.affectedgovernmentlevelshort)::text = 'county'::text)))
     LEFT JOIN geohistory.affectedgovernmentgrouppart countygrouppart ON (((affectedgovernmentgroup.affectedgovernmentgroupid = countygrouppart.affectedgovernmentgroup) AND (countygrouppart.affectedgovernmentlevel = countylevel.affectedgovernmentlevelid))))
     LEFT JOIN geohistory.affectedgovernmentpart countypart ON ((countygrouppart.affectedgovernmentpart = countypart.affectedgovernmentpartid)))
     LEFT JOIN geohistory.affectedgovernmentlevel subcountylevel ON (((subcountylevel.affectedgovernmentlevelshort)::text = 'subcounty'::text)))
     LEFT JOIN geohistory.affectedgovernmentgrouppart subcountygrouppart ON (((affectedgovernmentgroup.affectedgovernmentgroupid = subcountygrouppart.affectedgovernmentgroup) AND (subcountygrouppart.affectedgovernmentlevel = subcountylevel.affectedgovernmentlevelid))))
     LEFT JOIN geohistory.affectedgovernmentpart subcountypart ON ((subcountygrouppart.affectedgovernmentpart = subcountypart.affectedgovernmentpartid)))
     LEFT JOIN geohistory.affectedgovernmentlevel statelevel ON (((statelevel.affectedgovernmentlevelshort)::text = 'state'::text)))
     LEFT JOIN geohistory.affectedgovernmentgrouppart stategrouppart ON (((affectedgovernmentgroup.affectedgovernmentgroupid = stategrouppart.affectedgovernmentgroup) AND (stategrouppart.affectedgovernmentlevel = statelevel.affectedgovernmentlevelid))))
     LEFT JOIN geohistory.affectedgovernmentpart statepart ON ((stategrouppart.affectedgovernmentpart = statepart.affectedgovernmentpartid)))
  ORDER BY affectedgovernmentgroup.affectedgovernmentgroupid
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.affectedgovernment_reconstructed OWNER TO postgres;

--
-- Name: affectedgovernmentform; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.affectedgovernmentform AS
 WITH governmentforms AS (
         SELECT DISTINCT affectedgovernmentpart.governmentto AS government,
            affectedgovernmentpart.governmentformto AS governmentform,
            affectedgovernmentgroup.event
           FROM ((geohistory.affectedgovernmentpart
             JOIN geohistory.affectedgovernmentgrouppart ON (((affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart) AND (affectedgovernmentpart.governmentformto IS NOT NULL) AND (affectedgovernmentpart.affectedtypeto <> 12))))
             JOIN geohistory.affectedgovernmentgroup ON ((affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid)))
        )
 SELECT extra.governmentabbreviation(extra.governmentcurrentleadstateid(governmentforms.government)) AS "State",
    governmentforms.government AS "ID",
    extra.governmentlong(governmentforms.government) AS "Name",
    extra.governmenttype(governmentforms.government) AS "Government Type",
    extra.governmentformlongreport(governmentforms.governmentform) AS "Form",
    extra.governmentformlong(governmentforms.governmentform, true) AS "Form Detailed",
    governmentforms.governmentform AS "Form ID",
    (('J'::text || trunc(extra.eventsortdate(governmentforms.event), 0)))::date AS "Date",
    governmentforms.event AS "Event",
    (extra.governmenttype(governmentforms.government) = split_part(replace(extra.governmentformlong(governmentforms.governmentform), ' '::text, ','::text), ','::text, 1)) AS "Type-Form Match",
    row_number() OVER (PARTITION BY governmentforms.government ORDER BY (('J'::text || trunc(extra.eventsortdate(governmentforms.event), 0)))::date DESC) AS "Recentness"
   FROM ((governmentforms
     JOIN geohistory.event ON ((governmentforms.event = event.eventid)))
     JOIN geohistory.eventgranted ON (((event.eventgranted = eventgranted.eventgrantedid) AND eventgranted.eventgrantedsuccess)))
  WHERE ((extra.governmentstatus(governmentforms.government) <> ALL (ARRAY['placeholder'::text, 'proposed'::text, 'unincorporated'::text])) AND (extra.governmenttype(governmentforms.government) <> 'Ward'::text))
  ORDER BY (extra.governmentabbreviation(extra.governmentcurrentleadstateid(governmentforms.government))), governmentforms.government, (('J'::text || trunc(extra.eventsortdate(governmentforms.event), 0)))::date;


ALTER VIEW extra.affectedgovernmentform OWNER TO postgres;

--
-- Name: affectedgovernmentformcache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.affectedgovernmentformcache AS
 SELECT "State",
    "ID",
    "Name",
    "Government Type",
    "Form",
    "Form Detailed",
    "Form ID",
    "Date",
    "Event",
    "Type-Form Match",
    "Recentness"
   FROM extra.affectedgovernmentform
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.affectedgovernmentformcache OWNER TO postgres;

--
-- Name: areagovernment; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.areagovernment AS
 SELECT DISTINCT governmentshape.governmentshapeid,
    ag2.governmentrelationstate
   FROM (gis.governmentshape
     LEFT JOIN (( SELECT DISTINCT governmentshape_1.governmentsubmunicipality AS government,
            governmentshape_1.governmentshapeid
           FROM gis.governmentshape governmentshape_1
          WHERE (governmentshape_1.governmentsubmunicipality IS NOT NULL)
        UNION
         SELECT DISTINCT governmentshape_1.governmentmunicipality AS government,
            governmentshape_1.governmentshapeid
           FROM gis.governmentshape governmentshape_1
        UNION
         SELECT DISTINCT governmentshape_1.governmentcounty AS government,
            governmentshape_1.governmentshapeid
           FROM gis.governmentshape governmentshape_1
        UNION
         SELECT DISTINCT governmentshape_1.governmentstate AS government,
            governmentshape_1.governmentshapeid
           FROM gis.governmentshape governmentshape_1
        UNION
         SELECT DISTINCT affectedgovernmentpart.governmentfrom AS government,
            affectedgovernmentgis.governmentshape AS governmentshapeid
           FROM ((geohistory.affectedgovernmentgrouppart
             JOIN gis.affectedgovernmentgis ON ((affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgis.affectedgovernment)))
             JOIN geohistory.affectedgovernmentpart ON ((affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid)))
          WHERE (affectedgovernmentpart.governmentfrom IS NOT NULL)
        UNION
         SELECT DISTINCT affectedgovernmentpart.governmentto AS government,
            affectedgovernmentgis.governmentshape AS governmentshapeid
           FROM ((geohistory.affectedgovernmentgrouppart
             JOIN gis.affectedgovernmentgis ON ((affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgis.affectedgovernment)))
             JOIN geohistory.affectedgovernmentpart ON ((affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid)))
          WHERE (affectedgovernmentpart.governmentto IS NOT NULL)) ag
     JOIN extra.governmentrelation ON (((ag.government = governmentrelation.governmentid) AND (governmentrelation.governmentrelationstate IS NOT NULL) AND (governmentrelation.governmentrelationstate <> ''::text)))) ag2 ON (((ag2.government IS NOT NULL) AND (extra.governmentlevel(ag2.government) <> 1) AND (governmentshape.governmentshapeid = ag2.governmentshapeid))))
  ORDER BY ag2.governmentrelationstate, governmentshape.governmentshapeid;


ALTER VIEW extra.areagovernment OWNER TO postgres;

--
-- Name: areagovernmentcache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.areagovernmentcache AS
 SELECT governmentshapeid,
    governmentrelationstate
   FROM extra.areagovernment
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.areagovernmentcache OWNER TO postgres;

--
-- Name: eventextra; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.eventextra AS
 SELECT eventid,
    extra.eventslug(eventid) AS eventslug
   FROM geohistory.event
  ORDER BY eventid;


ALTER VIEW extra.eventextra OWNER TO postgres;

--
-- Name: eventslugretired; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.eventslugretired (
    eventslugretiredid integer NOT NULL,
    eventid integer,
    eventslug text
);


ALTER TABLE geohistory.eventslugretired OWNER TO postgres;

--
-- Name: TABLE eventslugretired; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON TABLE geohistory.eventslugretired IS 'This table includes superseded slugs solely to prevent broken links on the production site, and is not included in open data.';


--
-- Name: eventextracache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.eventextracache AS
 SELECT DISTINCT eventextra.eventid,
    eventextra.eventslug,
    NULL::text AS eventslugnew
   FROM extra.eventextra
UNION
 SELECT DISTINCT eventextra.eventid,
    eventslugretired.eventslug,
    eventextra.eventslug AS eventslugnew
   FROM ((extra.eventextra
     JOIN geohistory.eventslugretired ON (((eventextra.eventid = eventslugretired.eventid) AND (eventextra.eventslug <> eventslugretired.eventslug))))
     LEFT JOIN extra.eventextra otherslug ON ((eventslugretired.eventslug = otherslug.eventslug)))
  WHERE (otherslug.eventslug IS NULL)
  ORDER BY 1
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.eventextracache OWNER TO postgres;

--
-- Name: eventgovernmentcache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.eventgovernmentcache AS
 SELECT eventid,
    government
   FROM extra.eventgovernment
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.eventgovernmentcache OWNER TO postgres;

--
-- Name: giscache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.giscache AS
 SELECT governmentshape2.government,
    public.st_buffer(public.st_collect(governmentshape2.governmentshapegeometry), (0)::double precision) AS geometry
   FROM (( SELECT governmentshape.governmentcounty AS government,
            governmentshape.governmentshapegeometry
           FROM gis.governmentshape
        UNION
         SELECT governmentshape.governmentmunicipality AS government,
            governmentshape.governmentshapegeometry
           FROM gis.governmentshape
        UNION
         SELECT governmentshape.governmentschooldistrict AS government,
            governmentshape.governmentshapegeometry
           FROM gis.governmentshape
          WHERE (governmentshape.governmentschooldistrict IS NOT NULL)
        UNION
         SELECT governmentshape.governmentshapeplsstownship AS government,
            governmentshape.governmentshapegeometry
           FROM gis.governmentshape
          WHERE (governmentshape.governmentshapeplsstownship IS NOT NULL)
        UNION
         SELECT governmentshape.governmentsubmunicipality AS government,
            governmentshape.governmentshapegeometry
           FROM gis.governmentshape
          WHERE (governmentshape.governmentsubmunicipality IS NOT NULL)
        UNION
         SELECT governmentshape.governmentward AS government,
            governmentshape.governmentshapegeometry
           FROM gis.governmentshape
          WHERE (governmentshape.governmentward IS NOT NULL)) governmentshape2
     JOIN geohistory.government ON (((governmentshape2.government = government.governmentid) AND ((government.governmentstatus)::text <> 'placeholder'::text))))
  GROUP BY governmentshape2.government
  ORDER BY governmentshape2.government
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.giscache OWNER TO postgres;

--
-- Name: giscountycache; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.giscountycache AS
 SELECT government,
    geometry
   FROM extra.giscache
  WHERE (government IN ( SELECT DISTINCT governmentshape.governmentcounty
           FROM gis.governmentshape))
  ORDER BY government;


ALTER VIEW extra.giscountycache OWNER TO postgres;

--
-- Name: gismunicipalitycache; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.gismunicipalitycache AS
 SELECT government,
    geometry
   FROM extra.giscache
  WHERE (government IN ( SELECT DISTINCT governmentshape.governmentmunicipality
           FROM gis.governmentshape))
  ORDER BY government;


ALTER VIEW extra.gismunicipalitycache OWNER TO postgres;

--
-- Name: gisplsstownshipcache; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.gisplsstownshipcache AS
 SELECT government,
    geometry
   FROM extra.giscache
  WHERE (government IN ( SELECT DISTINCT governmentshape.governmentshapeplsstownship
           FROM gis.governmentshape))
  ORDER BY government;


ALTER VIEW extra.gisplsstownshipcache OWNER TO postgres;

--
-- Name: gisschooldistrictcache; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.gisschooldistrictcache AS
 SELECT government,
    geometry
   FROM extra.giscache
  WHERE (government IN ( SELECT DISTINCT governmentshape.governmentschooldistrict
           FROM gis.governmentshape))
  ORDER BY government;


ALTER VIEW extra.gisschooldistrictcache OWNER TO postgres;

--
-- Name: gissubmunicipalitycache; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.gissubmunicipalitycache AS
 SELECT government,
    geometry
   FROM extra.giscache
  WHERE (government IN ( SELECT DISTINCT governmentshape.governmentsubmunicipality
           FROM gis.governmentshape))
  ORDER BY government;


ALTER VIEW extra.gissubmunicipalitycache OWNER TO postgres;

--
-- Name: giswardcache; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.giswardcache AS
 SELECT government,
    geometry
   FROM extra.giscache
  WHERE (government IN ( SELECT DISTINCT governmentshape.governmentward
           FROM gis.governmentshape))
  ORDER BY government;


ALTER VIEW extra.giswardcache OWNER TO postgres;

--
-- Name: affectedtype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.affectedtype (
    affectedtypeid integer NOT NULL,
    affectedtypelong text NOT NULL,
    affectedtypeshort character varying(20) NOT NULL,
    affectedtypecreationdissolution character varying(11) DEFAULT ''::character varying NOT NULL,
    affectedtypefromtoboth character varying(4) NOT NULL,
    affectedtypeequal boolean DEFAULT false NOT NULL,
    originalaffectedtypeid integer,
    CONSTRAINT affectedtype_check CHECK ((((affectedtypefromtoboth)::text <> ''::text) AND (affectedtypelong <> ''::text) AND ((affectedtypeshort)::text <> ''::text)))
);


ALTER TABLE geohistory.affectedtype OWNER TO postgres;

--
-- Name: COLUMN affectedtype.affectedtypelong; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.affectedtype.affectedtypelong IS 'Rewrite';


--
-- Name: COLUMN affectedtype.affectedtypefromtoboth; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.affectedtype.affectedtypefromtoboth IS 'Whether the value can appear in the `from` or `to` fields, or if it must appear in both.';


--
-- Name: COLUMN affectedtype.affectedtypeequal; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.affectedtype.affectedtypeequal IS 'Whether the `from` and `to` values must be equal.';


--
-- Name: eventeffectivetype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.eventeffectivetype (
    eventeffectivetypeid integer NOT NULL,
    eventeffectivetypegroup character varying(100) DEFAULT ''::character varying NOT NULL,
    eventeffectivetypequalifier character varying(100) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE geohistory.eventeffectivetype OWNER TO postgres;

--
-- Name: eventrelationship; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.eventrelationship (
    eventrelationshipid integer NOT NULL,
    eventrelationshiplong text NOT NULL,
    eventrelationshipshort character varying(10) NOT NULL,
    eventrelationshippublication boolean DEFAULT false NOT NULL,
    eventrelationshipreference boolean NOT NULL,
    eventrelationshipcertainty boolean DEFAULT false NOT NULL,
    eventrelationshipsufficient boolean DEFAULT false NOT NULL,
    CONSTRAINT eventrelationship_check CHECK (((eventrelationshiplong <> ''::text) AND ((eventrelationshipshort)::text <> ''::text)))
);


ALTER TABLE geohistory.eventrelationship OWNER TO postgres;

--
-- Name: governmentchangecount; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.governmentchangecount AS
 WITH affectedgovernmentsummary AS (
         SELECT DISTINCT affectedgovernmentgroup.event AS eventid,
            affectedgovernmentpart.governmentfrom AS governmentid,
            affectedgovernmentpart.affectedtypefrom AS affectedtypeid,
            'from'::text AS affectedside
           FROM ((geohistory.affectedgovernmentgroup
             JOIN geohistory.affectedgovernmentgrouppart ON ((affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup)))
             JOIN geohistory.affectedgovernmentpart ON (((affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid) AND (affectedgovernmentpart.governmentfrom IS NOT NULL))))
        UNION
         SELECT DISTINCT affectedgovernmentgroup.event AS eventid,
            affectedgovernmentpart.governmentto AS governmentid,
            affectedgovernmentpart.affectedtypeto AS affectedtypeid,
            'to'::text AS affectedside
           FROM ((geohistory.affectedgovernmentgroup
             JOIN geohistory.affectedgovernmentgrouppart ON ((affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup)))
             JOIN geohistory.affectedgovernmentpart ON (((affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid) AND (affectedgovernmentpart.governmentto IS NOT NULL))))
        ), affectedgovernmentsummaryeventpart AS (
         SELECT affectedgovernmentsummary.eventid,
            governmentsubstitute.governmentsubstitute AS governmentid,
            array_agg(DISTINCT governmentsubstitute.governmentid ORDER BY governmentsubstitute.governmentid) AS originalgovernmentid,
            affectedgovernmentsummary.affectedtypeid,
            affectedgovernmentsummary.affectedside,
            affectedtype.affectedtypecreationdissolution,
            extra.eventsortdatedate((event.eventeffective)::character varying, event.eventfrom, event.eventto) AS eventsortdatedate,
            extra.eventtextshortdate((event.eventeffective)::character varying, event.eventfrom, event.eventto) AS eventtextshortdate,
            initcap(((event.eventeffective)::calendar.historicdate)."precision") AS eventeffectiveprecision,
            extra.eventeffectivetype(eventeffectivetype.eventeffectivetypegroup, eventeffectivetype.eventeffectivetypequalifier) AS eventeffectivetype,
            sum(
                CASE
                    WHEN (eventrelationship.eventrelationshipid IS NOT NULL) THEN 1
                    ELSE 0
                END) AS lawsection
           FROM (((((((affectedgovernmentsummary
             JOIN geohistory.event ON ((affectedgovernmentsummary.eventid = event.eventid)))
             JOIN extra.governmentsubstitute ON ((affectedgovernmentsummary.governmentid = governmentsubstitute.governmentid)))
             LEFT JOIN geohistory.eventeffectivetype ON ((event.eventeffectivetypepresumedsource = eventeffectivetype.eventeffectivetypeid)))
             JOIN geohistory.eventgranted ON (((event.eventgranted = eventgranted.eventgrantedid) AND eventgranted.eventgrantedsuccess)))
             JOIN geohistory.affectedtype ON ((affectedgovernmentsummary.affectedtypeid = affectedtype.affectedtypeid)))
             LEFT JOIN geohistory.lawsectionevent ON ((event.eventid = lawsectionevent.event)))
             LEFT JOIN geohistory.eventrelationship ON (((lawsectionevent.eventrelationship = eventrelationship.eventrelationshipid) AND eventrelationship.eventrelationshipsufficient)))
          GROUP BY affectedgovernmentsummary.eventid, governmentsubstitute.governmentsubstitute, affectedgovernmentsummary.affectedtypeid, affectedgovernmentsummary.affectedside, affectedtype.affectedtypecreationdissolution, (extra.eventsortdatedate((event.eventeffective)::character varying, event.eventfrom, event.eventto)), (extra.eventtextshortdate((event.eventeffective)::character varying, event.eventfrom, event.eventto)), (extra.eventeffectivetype(eventeffectivetype.eventeffectivetypegroup, eventeffectivetype.eventeffectivetypequalifier)), event.eventeffective, event.eventfrom, event.eventto
        ), creationdissolution AS (
         SELECT DISTINCT creationaffectedgovernmentsummaryeventpart.governmentid,
            creationaffectedgovernmentsummaryeventpart.eventid
           FROM (affectedgovernmentsummaryeventpart creationaffectedgovernmentsummaryeventpart
             JOIN affectedgovernmentsummaryeventpart dissolutionaffectedgovernmentsummaryeventpart ON (((creationaffectedgovernmentsummaryeventpart.governmentid = dissolutionaffectedgovernmentsummaryeventpart.governmentid) AND (creationaffectedgovernmentsummaryeventpart.eventid = dissolutionaffectedgovernmentsummaryeventpart.eventid) AND ((creationaffectedgovernmentsummaryeventpart.affectedtypecreationdissolution)::text = 'begin'::text) AND ((dissolutionaffectedgovernmentsummaryeventpart.affectedtypecreationdissolution)::text = 'end'::text))))
        ), affectedgovernmentsummaryevent AS (
         SELECT DISTINCT affectedgovernmentsummaryeventpart.eventid,
            affectedgovernmentsummaryeventpart.governmentid,
            affectedgovernmentsummaryeventpart.originalgovernmentid,
            affectedgovernmentsummaryeventpart.affectedtypeid,
            affectedgovernmentsummaryeventpart.affectedside,
                CASE
                    WHEN (creationdissolution.eventid IS NOT NULL) THEN 'alter'::character varying
                    ELSE affectedgovernmentsummaryeventpart.affectedtypecreationdissolution
                END AS affectedtypecreationdissolution,
            affectedgovernmentsummaryeventpart.eventsortdatedate,
            affectedgovernmentsummaryeventpart.eventtextshortdate,
            affectedgovernmentsummaryeventpart.eventeffectiveprecision,
            affectedgovernmentsummaryeventpart.eventeffectivetype,
            affectedgovernmentsummaryeventpart.lawsection
           FROM (affectedgovernmentsummaryeventpart
             LEFT JOIN creationdissolution ON (((affectedgovernmentsummaryeventpart.eventid = creationdissolution.eventid) AND (affectedgovernmentsummaryeventpart.governmentid = creationdissolution.governmentid))))
        ), alterfrom AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            extra.nulltoempty(array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid)) AS eventid
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedside = 'from'::text) AND ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'alter'::text))
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), alterto AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            extra.nulltoempty(array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid)) AS eventid
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedside = 'to'::text) AND ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'alter'::text))
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), altertotal AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            extra.nulltoempty(array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid)) AS eventid
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'alter'::text)
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), creation AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            extra.array_combine(array_agg(affectedgovernmentsummaryevent.originalgovernmentid)) AS originalgovernmentid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid) AS eventid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventsortdatedate) AS eventsortdatedate,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventtextshortdate) AS eventtextshortdate,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectiveprecision) AS eventeffectiveprecision,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectivetype) AS eventeffectivetype,
            (sum(affectedgovernmentsummaryevent.lawsection) > (0)::numeric) AS lawsection
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'begin'::text)
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), dissolution AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            extra.array_combine(array_agg(affectedgovernmentsummaryevent.originalgovernmentid)) AS originalgovernmentid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid) AS eventid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventsortdatedate) AS eventsortdatedate,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventtextshortdate) AS eventtextshortdate,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectiveprecision) AS eventeffectiveprecision,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectivetype) AS eventeffectivetype,
            (sum(affectedgovernmentsummaryevent.lawsection) > (0)::numeric) AS lawsection
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'end'::text)
          GROUP BY affectedgovernmentsummaryevent.governmentid
        )
 SELECT extra.nulltoempty(extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentid))) AS governmentstate,
    government.governmentlevel,
    government.governmenttype,
    extra.nulltoempty(affectedgovernmentform."Form") AS currentform,
    extra.nulltoempty(affectedgovernmentform."Form Detailed") AS currentformdetailed,
        CASE
            WHEN (government.governmentlevel > 3) THEN extra.governmentname(government.governmentcurrentleadparent)
            ELSE ''::text
        END AS governmentleadparentcounty,
    government.governmentid,
    extra.governmentlong(government.governmentid) AS governmentlong,
    extra.nulltozero(array_length(creation.eventid, 1)) AS creation,
    creation.eventid AS creationevent,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN creation.eventtextshortdate[1]
            ELSE ''::text
        END AS creationtext,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN COALESCE(creation.eventeffectiveprecision[1], 'None'::text)
            ELSE 'None'::text
        END AS creationprecision,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN creation.eventsortdatedate[1]
            ELSE NULL::date
        END AS creationsort,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN extra.nulltoempty(creation.eventeffectivetype[1])
            ELSE ''::text
        END AS creationhow,
        CASE
            WHEN (creation.lawsection IS NULL) THEN false
            ELSE creation.lawsection
        END AS creationlawsection,
    creation.originalgovernmentid AS creationas,
    extra.nulltozero(array_length(alterfrom.eventid, 1)) AS alterfrom,
    extra.nulltozero(array_length(alterto.eventid, 1)) AS alterto,
    extra.nulltozero(array_length(altertotal.eventid, 1)) AS altertotal,
    extra.nulltozero(array_length(dissolution.eventid, 1)) AS dissolution,
    dissolution.eventid AS dissolutionevent,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN dissolution.eventtextshortdate[1]
            ELSE ''::text
        END AS dissolutiontext,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN COALESCE(dissolution.eventeffectiveprecision[1], 'None'::text)
            ELSE 'None'::text
        END AS dissolutionprecision,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN dissolution.eventsortdatedate[1]
            ELSE NULL::date
        END AS dissolutionsort,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN extra.nulltoempty(dissolution.eventeffectivetype[1])
            ELSE ''::text
        END AS dissolutionhow,
        CASE
            WHEN (dissolution.lawsection IS NULL) THEN false
            ELSE dissolution.lawsection
        END AS dissolutionlawsection,
    dissolution.originalgovernmentid AS dissolutionas
   FROM ((((((geohistory.government
     LEFT JOIN alterfrom ON ((government.governmentid = alterfrom.governmentid)))
     LEFT JOIN alterto ON ((government.governmentid = alterto.governmentid)))
     LEFT JOIN altertotal ON ((government.governmentid = altertotal.governmentid)))
     LEFT JOIN creation ON ((government.governmentid = creation.governmentid)))
     LEFT JOIN dissolution ON ((government.governmentid = dissolution.governmentid)))
     LEFT JOIN extra.affectedgovernmentform ON (((government.governmentid = affectedgovernmentform."ID") AND (affectedgovernmentform."Recentness" = 1))))
  WHERE (government.governmentsubstitute IS NULL)
  ORDER BY (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentid))), government.governmentlevel, government.governmenttype,
        CASE
            WHEN (government.governmentlevel > 3) THEN extra.governmentname(government.governmentcurrentleadparent)
            ELSE NULL::text
        END, (extra.governmentlong(government.governmentid)), government.governmentid;


ALTER VIEW extra.governmentchangecount OWNER TO postgres;

--
-- Name: governmentchangecountcache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.governmentchangecountcache AS
 SELECT governmentstate,
    governmentlevel,
    governmenttype,
    currentform,
    currentformdetailed,
    governmentleadparentcounty,
    governmentid,
    governmentlong,
    creation,
    creationevent,
    creationtext,
    creationprecision,
    creationsort,
    creationhow,
    creationlawsection,
    creationas,
    alterfrom,
    alterto,
    altertotal,
    dissolution,
    dissolutionevent,
    dissolutiontext,
    dissolutionprecision,
    dissolutionsort,
    dissolutionhow,
    dissolutionlawsection,
    dissolutionas
   FROM extra.governmentchangecount
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.governmentchangecountcache OWNER TO postgres;

--
-- Name: governmentchangecountpart; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.governmentchangecountpart AS
 WITH affectedgovernmentsummary AS (
         SELECT DISTINCT affectedgovernmentgroup.event AS eventid,
            affectedgovernmentpart.governmentfrom AS governmentid,
            affectedgovernmentpart.affectedtypefrom AS affectedtypeid,
            'from'::text AS affectedside
           FROM ((geohistory.affectedgovernmentgroup
             JOIN geohistory.affectedgovernmentgrouppart ON ((affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup)))
             JOIN geohistory.affectedgovernmentpart ON (((affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid) AND (affectedgovernmentpart.governmentfrom IS NOT NULL))))
        UNION
         SELECT DISTINCT affectedgovernmentgroup.event AS eventid,
            affectedgovernmentpart.governmentto AS governmentid,
            affectedgovernmentpart.affectedtypeto AS affectedtypeid,
            'to'::text AS affectedside
           FROM ((geohistory.affectedgovernmentgroup
             JOIN geohistory.affectedgovernmentgrouppart ON ((affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup)))
             JOIN geohistory.affectedgovernmentpart ON (((affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid) AND (affectedgovernmentpart.governmentto IS NOT NULL))))
        ), affectedgovernmentsummaryevent AS (
         SELECT affectedgovernmentsummary.eventid,
            affectedgovernmentsummary.governmentid,
            affectedgovernmentsummary.affectedtypeid,
            affectedgovernmentsummary.affectedside,
            affectedtype.affectedtypecreationdissolution,
            extra.eventsortdatedate((event.eventeffective)::character varying, event.eventfrom, event.eventto) AS eventsortdatedate,
            extra.eventtextshortdate((event.eventeffective)::character varying, event.eventfrom, event.eventto) AS eventtextshortdate,
            initcap(((event.eventeffective)::calendar.historicdate)."precision") AS eventeffectiveprecision,
            extra.eventeffectivetype(eventeffectivetype.eventeffectivetypegroup, eventeffectivetype.eventeffectivetypequalifier) AS eventeffectivetype,
            sum(
                CASE
                    WHEN (eventrelationship.eventrelationshipid IS NOT NULL) THEN 1
                    ELSE 0
                END) AS lawsection
           FROM ((((((affectedgovernmentsummary
             JOIN geohistory.event ON ((affectedgovernmentsummary.eventid = event.eventid)))
             LEFT JOIN geohistory.eventeffectivetype ON ((event.eventeffectivetypepresumedsource = eventeffectivetype.eventeffectivetypeid)))
             JOIN geohistory.eventgranted ON (((event.eventgranted = eventgranted.eventgrantedid) AND eventgranted.eventgrantedsuccess)))
             JOIN geohistory.affectedtype ON ((affectedgovernmentsummary.affectedtypeid = affectedtype.affectedtypeid)))
             LEFT JOIN geohistory.lawsectionevent ON ((event.eventid = lawsectionevent.event)))
             LEFT JOIN geohistory.eventrelationship ON (((lawsectionevent.eventrelationship = eventrelationship.eventrelationshipid) AND eventrelationship.eventrelationshipsufficient)))
          GROUP BY affectedgovernmentsummary.eventid, affectedgovernmentsummary.governmentid, affectedgovernmentsummary.affectedtypeid, affectedgovernmentsummary.affectedside, affectedtype.affectedtypecreationdissolution, (extra.eventsortdatedate((event.eventeffective)::character varying, event.eventfrom, event.eventto)), (extra.eventtextshortdate((event.eventeffective)::character varying, event.eventfrom, event.eventto)), (extra.eventeffectivetype(eventeffectivetype.eventeffectivetypegroup, eventeffectivetype.eventeffectivetypequalifier)), event.eventeffective, event.eventfrom, event.eventto
        ), alterfrom AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            extra.nulltoempty(array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid)) AS eventid
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedside = 'from'::text) AND ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'alter'::text))
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), alterto AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            extra.nulltoempty(array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid)) AS eventid
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedside = 'to'::text) AND ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'alter'::text))
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), altertotal AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            extra.nulltoempty(array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid)) AS eventid
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'alter'::text)
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), creation AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid) AS eventid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventsortdatedate) AS eventsortdatedate,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventtextshortdate) AS eventtextshortdate,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectiveprecision) AS eventeffectiveprecision,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectivetype) AS eventeffectivetype,
            (sum(affectedgovernmentsummaryevent.lawsection) > (0)::numeric) AS lawsection
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'begin'::text)
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), dissolution AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid) AS eventid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventsortdatedate) AS eventsortdatedate,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventtextshortdate) AS eventtextshortdate,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectiveprecision) AS eventeffectiveprecision,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectivetype) AS eventeffectivetype,
            (sum(affectedgovernmentsummaryevent.lawsection) > (0)::numeric) AS lawsection
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'end'::text)
          GROUP BY affectedgovernmentsummaryevent.governmentid
        )
 SELECT extra.nulltoempty(extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentid))) AS governmentstate,
    government.governmentlevel,
    government.governmenttype,
    extra.nulltoempty(affectedgovernmentform."Form") AS currentform,
    extra.nulltoempty(affectedgovernmentform."Form Detailed") AS currentformdetailed,
        CASE
            WHEN (government.governmentlevel > 3) THEN extra.governmentname(government.governmentcurrentleadparent)
            ELSE ''::text
        END AS governmentleadparentcounty,
    government.governmentid,
    extra.governmentlong(government.governmentid) AS governmentlong,
    extra.nulltozero(array_length(creation.eventid, 1)) AS creation,
    creation.eventid AS creationevent,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN creation.eventtextshortdate[1]
            ELSE ''::text
        END AS creationtext,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN COALESCE(creation.eventeffectiveprecision[1], 'None'::text)
            ELSE 'None'::text
        END AS creationprecision,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN creation.eventsortdatedate[1]
            ELSE NULL::date
        END AS creationsort,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN extra.nulltoempty(creation.eventeffectivetype[1])
            ELSE ''::text
        END AS creationhow,
        CASE
            WHEN (creation.lawsection IS NULL) THEN false
            ELSE creation.lawsection
        END AS creationlawsection,
    extra.nulltozero(array_length(alterfrom.eventid, 1)) AS alterfrom,
    extra.nulltozero(array_length(alterto.eventid, 1)) AS alterto,
    extra.nulltozero(array_length(altertotal.eventid, 1)) AS altertotal,
    extra.nulltozero(array_length(dissolution.eventid, 1)) AS dissolution,
    dissolution.eventid AS dissolutionevent,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN dissolution.eventtextshortdate[1]
            ELSE ''::text
        END AS dissolutiontext,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN COALESCE(dissolution.eventeffectiveprecision[1], 'None'::text)
            ELSE 'None'::text
        END AS dissolutionprecision,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN dissolution.eventsortdatedate[1]
            ELSE NULL::date
        END AS dissolutionsort,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN extra.nulltoempty(dissolution.eventeffectivetype[1])
            ELSE ''::text
        END AS dissolutionhow,
        CASE
            WHEN (dissolution.lawsection IS NULL) THEN false
            ELSE dissolution.lawsection
        END AS dissolutionlawsection,
    governmentsubstitute.governmentsubstitute AS governmentsubstituteid,
    extra.governmentlong(governmentsubstitute.governmentsubstitute) AS governmentsubstitutelong
   FROM (((((((geohistory.government
     LEFT JOIN alterfrom ON ((government.governmentid = alterfrom.governmentid)))
     LEFT JOIN alterto ON ((government.governmentid = alterto.governmentid)))
     LEFT JOIN altertotal ON ((government.governmentid = altertotal.governmentid)))
     LEFT JOIN creation ON ((government.governmentid = creation.governmentid)))
     LEFT JOIN dissolution ON ((government.governmentid = dissolution.governmentid)))
     LEFT JOIN extra.affectedgovernmentform ON (((government.governmentid = affectedgovernmentform."ID") AND (affectedgovernmentform."Recentness" = 1))))
     LEFT JOIN extra.governmentsubstitute ON (((government.governmentid = governmentsubstitute.governmentid) AND ((government.governmentstatus)::text <> ALL (ARRAY[('alternate'::character varying)::text, ('language'::character varying)::text, ('placeholder'::character varying)::text])))))
  ORDER BY (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentid))), government.governmentlevel, government.governmenttype,
        CASE
            WHEN (government.governmentlevel > 3) THEN extra.governmentname(government.governmentcurrentleadparent)
            ELSE NULL::text
        END, (extra.governmentlong(government.governmentid)), government.governmentid;


ALTER VIEW extra.governmentchangecountpart OWNER TO postgres;

--
-- Name: governmentchangecountpartcache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.governmentchangecountpartcache AS
 SELECT governmentstate,
    governmentlevel,
    governmenttype,
    currentform,
    currentformdetailed,
    governmentleadparentcounty,
    governmentid,
    governmentlong,
    creation,
    creationevent,
    creationtext,
    creationprecision,
    creationsort,
    creationhow,
    creationlawsection,
    alterfrom,
    alterto,
    altertotal,
    dissolution,
    dissolutionevent,
    dissolutiontext,
    dissolutionprecision,
    dissolutionsort,
    dissolutionhow,
    dissolutionlawsection,
    governmentsubstituteid,
    governmentsubstitutelong
   FROM extra.governmentchangecountpart
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.governmentchangecountpartcache OWNER TO postgres;

--
-- Name: governmentextra; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.governmentextra AS
 SELECT government.governmentid,
    extra.governmentslugalternate(government.governmentid) AS governmentslug,
    extra.governmentlong(government.governmentid, '--'::character varying) AS governmentlong,
    extra.governmentshort(government.governmentid) AS governmentshort,
    ((government.governmentstatus)::text = 'placeholder'::text) AS governmentisplaceholder,
    extra.governmentslugalternate(governmentsubstitute.governmentsubstitute) AS governmentsubstituteslug
   FROM (geohistory.government
     LEFT JOIN extra.governmentsubstitute ON (((government.governmentid = governmentsubstitute.governmentid) AND (governmentsubstitute.governmentid <> governmentsubstitute.governmentsubstitute))))
  ORDER BY government.governmentid;


ALTER VIEW extra.governmentextra OWNER TO postgres;

--
-- Name: governmentextracache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.governmentextracache AS
 SELECT governmentid,
    governmentslug,
    governmentlong,
    governmentshort,
    governmentisplaceholder,
    governmentsubstituteslug
   FROM extra.governmentextra
  ORDER BY governmentid
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.governmentextracache OWNER TO postgres;

--
-- Name: governmenthasmappedevent; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.governmenthasmappedevent AS
 SELECT DISTINCT governmentsubstitute.governmentsubstitute
   FROM (((geohistory.affectedgovernmentgrouppart
     JOIN gis.affectedgovernmentgis ON ((affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgis.affectedgovernment)))
     JOIN geohistory.affectedgovernmentpart ON ((affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid)))
     JOIN extra.governmentsubstitute ON ((affectedgovernmentpart.governmentfrom = governmentsubstitute.governmentid)))
UNION
 SELECT DISTINCT governmentsubstitute.governmentsubstitute
   FROM (((geohistory.affectedgovernmentgrouppart
     JOIN gis.affectedgovernmentgis ON ((affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgis.affectedgovernment)))
     JOIN geohistory.affectedgovernmentpart ON ((affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid)))
     JOIN extra.governmentsubstitute ON ((affectedgovernmentpart.governmentto = governmentsubstitute.governmentid)));


ALTER VIEW extra.governmenthasmappedevent OWNER TO postgres;

--
-- Name: governmenthasmappedeventcache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.governmenthasmappedeventcache AS
 SELECT governmentsubstitute
   FROM extra.governmenthasmappedevent
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.governmenthasmappedeventcache OWNER TO postgres;

--
-- Name: governmentparentcache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.governmentparentcache AS
 SELECT governmentid,
    governmentparent,
    governmentparentstatus
   FROM extra.governmentparent
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.governmentparentcache OWNER TO postgres;

--
-- Name: governmentrelationcache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.governmentrelationcache AS
 SELECT governmentid,
    governmentlevel,
    governmentshort,
    governmentlong,
    governmentrelationlevel,
    governmentrelation,
    governmentrelationstate
   FROM extra.governmentrelation
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.governmentrelationcache OWNER TO postgres;

--
-- Name: governmentshape_history; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.governmentshape_history AS
 WITH affectedgovernmentorder AS (
         SELECT affectedgovernmentgis.governmentshape AS governmentshapeid,
            affectedgovernment_reconstructed.affectedgovernmentid,
            row_number() OVER (PARTITION BY affectedgovernmentgis.governmentshape ORDER BY (extra.eventsortdate(event.eventid))) AS shapeorder,
            extra.eventsortdate(event.eventid) AS eventsortdate,
            affectedgovernment_reconstructed.submunicipalityto,
            affectedgovernment_reconstructed.municipalityto,
            affectedgovernment_reconstructed.subcountyto,
            affectedgovernment_reconstructed.countyto,
            affectedgovernment_reconstructed.stateto,
            governmentshape.governmentsubmunicipality,
            governmentshape.governmentmunicipality,
            governmentshape.governmentcounty,
            governmentshape.governmentstate
           FROM (((((gis.affectedgovernmentgis
             JOIN gis.governmentshape ON ((affectedgovernmentgis.governmentshape = governmentshape.governmentshapeid)))
             JOIN extra.affectedgovernment_reconstructed ON ((affectedgovernmentgis.affectedgovernment = affectedgovernment_reconstructed.affectedgovernmentid)))
             JOIN geohistory.event ON ((affectedgovernment_reconstructed.event = event.eventid)))
             JOIN extra.eventextracache ON ((event.eventid = eventextracache.eventid)))
             JOIN geohistory.eventgranted ON (((event.eventgranted = eventgranted.eventgrantedid) AND eventgranted.eventgrantedsuccess)))
        )
 SELECT currentorder.governmentshapeid,
    currentorder.eventsortdate AS startdate,
        CASE
            WHEN (nextorder.eventsortdate IS NULL) THEN (to_char((CURRENT_DATE)::timestamp with time zone, 'J'::text))::numeric
            ELSE nextorder.eventsortdate
        END AS enddate,
    currentorder.submunicipalityto,
    currentorder.municipalityto,
    currentorder.subcountyto,
    currentorder.countyto,
    currentorder.stateto,
    currentorder.governmentsubmunicipality,
    currentorder.governmentmunicipality,
    currentorder.governmentcounty,
    currentorder.governmentstate
   FROM (affectedgovernmentorder currentorder
     LEFT JOIN affectedgovernmentorder nextorder ON (((currentorder.governmentshapeid = nextorder.governmentshapeid) AND (currentorder.shapeorder = (nextorder.shapeorder - 1)))))
UNION
 SELECT affectedgovernmentorder.governmentshapeid,
    (0)::numeric AS startdate,
    affectedgovernmentorder.eventsortdate AS enddate,
    affectedgovernment_reconstructed.submunicipalityfrom AS submunicipalityto,
    affectedgovernment_reconstructed.municipalityfrom AS municipalityto,
    affectedgovernment_reconstructed.subcountyfrom AS subcountyto,
    affectedgovernment_reconstructed.countyfrom AS countyto,
    affectedgovernment_reconstructed.statefrom AS stateto,
    affectedgovernmentorder.governmentsubmunicipality,
    affectedgovernmentorder.governmentmunicipality,
    affectedgovernmentorder.governmentcounty,
    affectedgovernmentorder.governmentstate
   FROM (affectedgovernmentorder
     LEFT JOIN extra.affectedgovernment_reconstructed ON ((affectedgovernmentorder.affectedgovernmentid = affectedgovernment_reconstructed.affectedgovernmentid)))
  WHERE (affectedgovernmentorder.shapeorder = 1)
  ORDER BY 1, 2;


ALTER VIEW extra.governmentshape_history OWNER TO postgres;

--
-- Name: governmentshapeextra; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.governmentshapeextra AS
 WITH areaslugs AS (
         SELECT governmentshape.governmentshapeid,
            extra.governmentslugalternate(
                CASE
                    WHEN (governmentshape.governmentsubmunicipality IS NULL) THEN governmentshape.governmentmunicipality
                    ELSE governmentshape.governmentsubmunicipality
                END) AS areaslugpart
           FROM gis.governmentshape
        ), areaslugscounts AS (
         SELECT count(*) AS rowct,
            replace(areaslugs_1.areaslugpart, '.'::text, ''::text) AS areaslugpart
           FROM areaslugs areaslugs_1
          GROUP BY areaslugs_1.areaslugpart
        )
 SELECT areaslugs.governmentshapeid,
    (areaslugs.areaslugpart ||
        CASE
            WHEN (areaslugscounts.rowct > 1) THEN ('-'::text || rank() OVER (PARTITION BY areaslugs.areaslugpart ORDER BY areaslugs.governmentshapeid))
            ELSE ''::text
        END) AS governmentshapeslug
   FROM (areaslugs
     JOIN areaslugscounts ON ((areaslugs.areaslugpart = areaslugscounts.areaslugpart)))
  ORDER BY areaslugs.governmentshapeid;


ALTER VIEW extra.governmentshapeextra OWNER TO postgres;

--
-- Name: governmentshapeextracache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.governmentshapeextracache AS
 SELECT governmentshapeid,
    governmentshapeslug
   FROM extra.governmentshapeextra
  ORDER BY governmentshapeid
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.governmentshapeextracache OWNER TO postgres;

--
-- Name: governmentsourceextra; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.governmentsourceextra AS
 WITH governmentsourceslugs AS (
         SELECT governmentsource.governmentsourceid,
            btrim(lower(regexp_replace((((((((((((governmentextra.governmentslug || '-'::text) || (governmentsource.governmentsourcebody)::text) || '-'::text) || (governmentsource.governmentsourcetype)::text) || '-'::text) || (governmentsource.governmentsourcenumber)::text) || '-'::text) || (governmentsource.governmentsourceterm)::text) ||
                CASE
                    WHEN ((governmentsource.governmentsourcevolume)::text <> ''::text) THEN ('-v'::text || (governmentsource.governmentsourcevolume)::text)
                    ELSE ''::text
                END) || '-'::text) || extra.rangefix((governmentsource.governmentsourcepagefrom)::text, (governmentsource.governmentsourcepageto)::text)), '[\s\-\.\/''\(\);:,&"#§\?\[\]]+'::text, '-'::text, 'g'::text)), '-'::text) AS governmentsourcepartslug
           FROM (geohistory.governmentsource
             JOIN extra.governmentextra ON ((governmentsource.government = governmentextra.governmentid)))
          WHERE (governmentsource.source IS NOT NULL)
        ), governmentsourceslugcounts AS (
         SELECT count(*) AS rowct,
            governmentsourceslugs_1.governmentsourcepartslug
           FROM governmentsourceslugs governmentsourceslugs_1
          GROUP BY governmentsourceslugs_1.governmentsourcepartslug
        )
 SELECT governmentsourceslugs.governmentsourceid,
    (governmentsourceslugs.governmentsourcepartslug ||
        CASE
            WHEN (governmentsourceslugcounts.rowct > 1) THEN ('-'::text || rank() OVER (PARTITION BY governmentsourceslugcounts.governmentsourcepartslug ORDER BY governmentsourceslugs.governmentsourceid))
            ELSE ''::text
        END) AS governmentsourceslug
   FROM (governmentsourceslugs
     JOIN governmentsourceslugcounts ON ((governmentsourceslugs.governmentsourcepartslug = governmentsourceslugcounts.governmentsourcepartslug)))
  ORDER BY governmentsourceslugs.governmentsourceid;


ALTER VIEW extra.governmentsourceextra OWNER TO postgres;

--
-- Name: governmentsourceextracache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.governmentsourceextracache AS
 SELECT governmentsourceid,
    governmentsourceslug
   FROM extra.governmentsourceextra
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.governmentsourceextracache OWNER TO postgres;

--
-- Name: governmentsubstitutecache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.governmentsubstitutecache AS
 SELECT governmentid,
    governmentsubstitute,
    governmentsubstitutemultiple
   FROM extra.governmentsubstitute
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.governmentsubstitutecache OWNER TO postgres;

--
-- Name: lastrefresh; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.lastrefresh AS
 SELECT ('now'::text)::date AS lastrefreshdate
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.lastrefresh OWNER TO postgres;

--
-- Name: lawalternatesection; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.lawalternatesection (
    lawalternatesectionid integer NOT NULL,
    lawalternate integer NOT NULL,
    lawsection integer NOT NULL,
    lawalternatesectionpagefrom smallint,
    lawalternatesectionpageto smallint
);


ALTER TABLE geohistory.lawalternatesection OWNER TO postgres;

--
-- Name: lawalternatesectionextra; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.lawalternatesectionextra AS
 SELECT lawalternatesectionid AS lawsectionid,
    extra.lawalternatesectioncitation(lawalternatesectionid) AS lawsectioncitation,
    (extra.lawalternatesectionslug(lawalternatesectionid) || '-alternate'::text) AS lawsectionslug
   FROM geohistory.lawalternatesection
  ORDER BY lawalternatesectionid;


ALTER VIEW extra.lawalternatesectionextra OWNER TO postgres;

--
-- Name: lawalternatesectionextracache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.lawalternatesectionextracache AS
 SELECT lawsectionid,
    lawsectioncitation,
    lawsectionslug
   FROM extra.lawalternatesectionextra
  ORDER BY lawsectionid
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.lawalternatesectionextracache OWNER TO postgres;

--
-- Name: lawsectionextra; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.lawsectionextra AS
 WITH lawsections AS (
         SELECT lawsection.lawsectionid,
            extra.lawsectioncitation(lawsection.lawsectionid) AS lawsectioncitation,
            extra.lawsectionslug(lawsection.lawsectionid) AS lawsectionslug,
            row_number() OVER (PARTITION BY (extra.lawsectionslug(lawsection.lawsectionid)) ORDER BY lawsection.lawsectionid) AS row_number
           FROM geohistory.lawsection
        )
 SELECT lawsectionid,
    lawsectioncitation,
    (lawsectionslug ||
        CASE
            WHEN (row_number > 1) THEN ('-pt'::text || row_number)
            ELSE ''::text
        END) AS lawsectionslug
   FROM lawsections
  ORDER BY lawsectionid;


ALTER VIEW extra.lawsectionextra OWNER TO postgres;

--
-- Name: lawsectionextracache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.lawsectionextracache AS
 SELECT lawsectionid,
    lawsectioncitation,
    lawsectionslug
   FROM extra.lawsectionextra
  ORDER BY lawsectionid
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.lawsectionextracache OWNER TO postgres;

--
-- Name: lawsectiongovernment; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.lawsectiongovernment AS
 SELECT DISTINCT lawsection.lawsectionid,
    ag2.governmentrelationstate,
    extra.lawsectioncitation(lawsection.lawsectionid) AS lawsectioncitation
   FROM (geohistory.lawsection
     LEFT JOIN (( SELECT DISTINCT lawsection_1.lawsectionid AS lawsection,
            sourcegovernment.government
           FROM ((geohistory.sourcegovernment
             JOIN geohistory.law ON ((sourcegovernment.source = law.source)))
             JOIN geohistory.lawsection lawsection_1 ON ((law.lawid = lawsection_1.law)))
          WHERE (sourcegovernment.sourceorder = 1)
        UNION
         SELECT DISTINCT lawsectionevent.lawsection,
            eventgovernment.government
           FROM (geohistory.lawsectionevent
             JOIN extra.eventgovernment ON (((lawsectionevent.event = eventgovernment.eventid) AND (NOT (eventgovernment.eventid IN ( SELECT event.eventid
                   FROM (geohistory.event
                     JOIN geohistory.eventgranted ON (((event.eventgranted = eventgranted.eventgrantedid) AND eventgranted.eventgrantedplaceholder)))))))))) ag
     JOIN extra.governmentrelation ON (((ag.government = governmentrelation.governmentid) AND (governmentrelation.governmentrelationstate IS NOT NULL) AND (governmentrelation.governmentrelationstate <> ''::text)))) ag2 ON (((ag2.government IS NOT NULL) AND (extra.governmentlevel(ag2.government) <> 1) AND (ag2.lawsection = lawsection.lawsectionid))))
  ORDER BY ag2.governmentrelationstate, lawsection.lawsectionid;


ALTER VIEW extra.lawsectiongovernment OWNER TO postgres;

--
-- Name: lawsectiongovernmentcache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.lawsectiongovernmentcache AS
 SELECT lawsectionid,
    governmentrelationstate,
    lawsectioncitation
   FROM extra.lawsectiongovernment
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.lawsectiongovernmentcache OWNER TO postgres;

--
-- Name: metesdescriptionextra; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.metesdescriptionextra AS
 SELECT metesdescriptionid,
    extra.metesdescriptionlong(metesdescriptionid) AS metesdescriptionlong,
    extra.metesdescriptionslug(metesdescriptionid) AS metesdescriptionslug
   FROM geohistory.metesdescription
  ORDER BY metesdescriptionid;


ALTER VIEW extra.metesdescriptionextra OWNER TO postgres;

--
-- Name: metesdescriptionextracache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.metesdescriptionextracache AS
 SELECT metesdescriptionid,
    metesdescriptionlong,
    metesdescriptionslug
   FROM extra.metesdescriptionextra
  ORDER BY metesdescriptionid
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.metesdescriptionextracache OWNER TO postgres;

--
-- Name: sourcecitation; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.sourcecitation (
    sourcecitationid integer NOT NULL,
    source integer,
    sourcecitationdate calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    sourcecitationdatetype character varying(50) DEFAULT ''::character varying NOT NULL,
    sourcecitationdaterange calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    sourcecitationdaterangetype character varying(50) DEFAULT ''::character varying NOT NULL,
    sourcecitationvolume character varying(20) DEFAULT ''::character varying NOT NULL,
    sourcecitationpagefrom character varying(7) DEFAULT ''::character varying NOT NULL,
    sourcecitationpageto character varying(7) DEFAULT ''::character varying NOT NULL,
    sourcecitationurl text DEFAULT ''::text NOT NULL,
    sourcecitationtypetitle text DEFAULT ''::text NOT NULL,
    sourcecitationperson text DEFAULT ''::text NOT NULL,
    sourcecitationgovernmentreferences text DEFAULT ''::text NOT NULL,
    sourcecitationarchiveslotfilm character varying(25) DEFAULT ''::character varying NOT NULL,
    sourcecitationarchivecarton character varying(15) DEFAULT ''::character varying NOT NULL,
    sourcecitationstatus character varying(1) DEFAULT ''::character varying NOT NULL,
    sourcecitationissue character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE geohistory.sourcecitation OWNER TO postgres;

--
-- Name: COLUMN sourcecitation.sourcecitationstatus; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.sourcecitation.sourcecitationstatus IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: sourcecitationextra; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.sourcecitationextra AS
 WITH sourcecitationslugs AS (
         SELECT sourcecitation.sourcecitationid,
            lower(regexp_replace(regexp_replace(btrim((((((source.sourceshort)::text || ' '::text) || btrim(btrim(((btrim(((split_part(sourcecitation.sourcecitationtypetitle, ' '::text, 1) || ' '::text) || split_part(sourcecitation.sourcecitationtypetitle, ' '::text, 2))) || ' '::text) || btrim(((split_part(regexp_replace(sourcecitation.sourcecitationgovernmentreferences, '[;]+'::text, ' '::text, 'g'::text), ' '::text, 1) || ' '::text) || split_part(regexp_replace(sourcecitation.sourcecitationgovernmentreferences, '[;]+'::text, ' '::text, 'g'::text), ' '::text, 2))))))) || ' '::text) || (sourcecitation.sourcecitationpagefrom)::text)), '[ –—]'::text, '-'::text, 'g'::text), '[\.\/''\(\);:,&"#§\?\[\]]'::text, ''::text, 'g'::text)) AS sourcecitationpartslug
           FROM (geohistory.sourcecitation
             JOIN geohistory.source ON ((sourcecitation.source = source.sourceid)))
        ), sourcecitationslugcounts AS (
         SELECT count(*) AS rowct,
            sourcecitationslugs_1.sourcecitationpartslug
           FROM sourcecitationslugs sourcecitationslugs_1
          GROUP BY sourcecitationslugs_1.sourcecitationpartslug
        )
 SELECT sourcecitationslugs.sourcecitationid,
    (sourcecitationslugs.sourcecitationpartslug ||
        CASE
            WHEN (sourcecitationslugcounts.rowct > 1) THEN ('-'::text || rank() OVER (PARTITION BY sourcecitationslugcounts.sourcecitationpartslug ORDER BY sourcecitationslugs.sourcecitationid))
            ELSE ''::text
        END) AS sourcecitationslug
   FROM (sourcecitationslugs
     JOIN sourcecitationslugcounts ON ((sourcecitationslugs.sourcecitationpartslug = sourcecitationslugcounts.sourcecitationpartslug)))
  ORDER BY sourcecitationslugs.sourcecitationid;


ALTER VIEW extra.sourcecitationextra OWNER TO postgres;

--
-- Name: sourcecitationextracache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.sourcecitationextracache AS
 SELECT sourcecitationid,
    sourcecitationslug
   FROM extra.sourcecitationextra
  ORDER BY sourcecitationid
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.sourcecitationextracache OWNER TO postgres;

--
-- Name: sourcecitationevent; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.sourcecitationevent (
    sourcecitationeventid integer NOT NULL,
    sourcecitation integer NOT NULL,
    event integer NOT NULL,
    sourcecitationeventinclude boolean
);


ALTER TABLE geohistory.sourcecitationevent OWNER TO postgres;

--
-- Name: sourcecitationgovernment; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.sourcecitationgovernment AS
 SELECT DISTINCT sourcecitation.sourcecitationid,
    ag2.governmentrelationstate
   FROM (geohistory.sourcecitation
     LEFT JOIN (( SELECT DISTINCT sourcecitation_1.sourcecitationid AS sourcecitation,
            sourcegovernment.government
           FROM geohistory.sourcegovernment,
            geohistory.sourcecitation sourcecitation_1
          WHERE ((sourcegovernment.source = sourcecitation_1.source) AND (sourcegovernment.sourceorder = 1))
        UNION
         SELECT DISTINCT sourcecitationevent.sourcecitation,
            eventgovernment.government
           FROM geohistory.sourcecitationevent,
            extra.eventgovernment
          WHERE (sourcecitationevent.event = eventgovernment.eventid)) ag
     JOIN extra.governmentrelation ON (((ag.government = governmentrelation.governmentid) AND (governmentrelation.governmentrelationstate IS NOT NULL) AND (governmentrelation.governmentrelationstate <> ''::text)))) ag2 ON (((ag2.government IS NOT NULL) AND (extra.governmentlevel(ag2.government) <> 1) AND (ag2.sourcecitation = sourcecitation.sourcecitationid))))
  ORDER BY ag2.governmentrelationstate, sourcecitation.sourcecitationid;


ALTER VIEW extra.sourcecitationgovernment OWNER TO postgres;

--
-- Name: sourcecitationgovernmentcache; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.sourcecitationgovernmentcache AS
 SELECT sourcecitationid,
    governmentrelationstate
   FROM extra.sourcecitationgovernment
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.sourcecitationgovernmentcache OWNER TO postgres;

--
-- Name: sourceextra; Type: VIEW; Schema: extra; Owner: postgres
--

CREATE VIEW extra.sourceextra AS
 SELECT sourceid,
    ((sourceshort)::text ||
        CASE
            WHEN ((sourceshortpart)::text <> ''::text) THEN (' '::text || (sourceshortpart)::text)
            ELSE ''::text
        END) AS sourceabbreviation,
    array_to_string(ARRAY[
        CASE
            WHEN (sourceperson = ''::text) THEN NULL::text
            ELSE (sourceperson ||
            CASE
                WHEN ("right"(sourceperson, 1) = '.'::text) THEN ''::text
                ELSE '.'::text
            END)
        END,
        CASE
            WHEN (sourcesectiontitle = ''::text) THEN NULL::text
            ELSE (('&quot;'::text || sourcesectiontitle) || '.&quot;'::text)
        END,
        CASE
            WHEN (sourcetitle = ''::text) THEN NULL::text
            ELSE (('<span style="font-style: italic;">'::text || sourcetitle) || '</span>.'::text)
        END,
        CASE
            WHEN (sourceidentifier = ''::text) THEN NULL::text
            ELSE (sourceidentifier || '.'::text)
        END,
        CASE
            WHEN ((sourcepublisherlocation = ''::text) AND (sourcepublisher <> ''::text)) THEN '?:'::text
            WHEN (sourcepublisherlocation = ''::text) THEN NULL::text
            ELSE (((
            CASE
                WHEN ((sourcetype)::text = 'newspapers'::text) THEN '('::text
                ELSE ''::text
            END || sourcepublisherlocation) ||
            CASE
                WHEN ((sourcetype)::text = 'newspapers'::text) THEN ')'::text
                ELSE ''::text
            END) ||
            CASE
                WHEN (sourcepublisher <> ''::text) THEN ':'::text
                WHEN ((sourcepublisheryear)::text <> ''::text) THEN ','::text
                WHEN (("right"(sourcepublisherlocation, 1) = '.'::text) AND ((sourcetype)::text <> 'newspapers'::text)) THEN ''::text
                ELSE '.'::text
            END)
        END,
        CASE
            WHEN (sourcepublisher = ''::text) THEN NULL::text
            ELSE (sourcepublisher ||
            CASE
                WHEN ((sourcepublisheryear)::text <> ''::text) THEN ','::text
                WHEN ("right"(sourcepublisher, 1) = '.'::text) THEN ''::text
                ELSE '.'::text
            END)
        END,
        CASE
            WHEN ((sourcepublisheryear)::text = ''::text) THEN NULL::text
            ELSE ((sourcepublisheryear)::text || '.'::text)
        END], ' '::text) AS sourcefullcitation
   FROM geohistory.source
  ORDER BY sourceid;


ALTER VIEW extra.sourceextra OWNER TO postgres;

--
-- Name: governmentidentifier; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.governmentidentifier (
    governmentidentifierid integer NOT NULL,
    government integer,
    governmentidentifiertype integer NOT NULL,
    governmentidentifierprefix character varying(20) DEFAULT ''::character varying NOT NULL,
    governmentidentifier character varying(20) DEFAULT ''::character varying NOT NULL,
    governmentidentifiernote text DEFAULT ''::text NOT NULL,
    governmentidentifiermatchtype character varying(30) DEFAULT ''::character varying NOT NULL,
    governmentidentifiermatchdate date,
    governmentidentifierlead boolean GENERATED ALWAYS AS ((((governmentidentifiermatchtype)::text ~~ 'current%'::text) OR ((governmentidentifiermatchtype)::text = 'full'::text) OR ((governmentidentifiermatchtype)::text ~~ '%lead'::text))) STORED,
    governmentidentifierstatus text GENERATED ALWAYS AS (
CASE
    WHEN (((governmentidentifiermatchtype)::text ~~ 'current%'::text) OR ((governmentidentifiermatchtype)::text = 'full'::text) OR ((governmentidentifiermatchtype)::text ~~ '%lead'::text)) THEN 'Lead'::text
    WHEN ((governmentidentifiermatchtype)::text = ANY (ARRAY[('historic-successor'::character varying)::text, ('reference'::character varying)::text])) THEN 'Reference'::text
    WHEN ((governmentidentifiermatchtype)::text ~~ 'historic%'::text) THEN 'Historic'::text
    WHEN ((governmentidentifiermatchtype)::text = ''::text) THEN ''::text
    ELSE 'Other'::text
END) STORED
);


ALTER TABLE geohistory.governmentidentifier OWNER TO postgres;

--
-- Name: COLUMN governmentidentifier.governmentidentifiermatchtype; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.governmentidentifier.governmentidentifiermatchtype IS 'current-alternate: Current government with correct spelling shown as USGS alternate.
current-obsolete: Current government with obsolete USGS spelling.
current-spelling: Current government with USGS spelling mismatch.
current-status: Current government with USGS historic flag.
delete: Should be merged into another feature ID.
full: Spelling and status match.
historic-alternate: Historic government with correct spelling shown as USGS alternate.
historic-county: Temporary historic government created after county division.
historic-match: Secondary records with spelling match.
historic-missing: Successor current government does not list as USGS alternate (name change).
historic-obsolete: Historic government with USGS spelling match.
historic-spelling: Historic government with USGS alternate spelling mismatch.
historic-status: Historic government missing USGS historic flag.
historic-successor: Successor current government does not list as USGS alternate (merger-consolidation).

Entries other than current-* or full can also be combined with -lead flag.';


--
-- Name: statistics_createddissolved; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.statistics_createddissolved AS
 WITH countyevents AS (
         SELECT DISTINCT affectedgovernment_reconstructed.event,
            affectedtype.affectedtypecreationdissolution,
            affectedgovernment_reconstructed.municipalityto AS governmentid,
                CASE
                    WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
                    ELSE (governmentidentifier.governmentidentifier)::integer
                END AS governmentcounty,
            extra.governmentabbreviation(
                CASE
                    WHEN (stategovernment.governmentsubstitute IS NOT NULL) THEN stategovernment.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.stateto
                END) AS governmentstate
           FROM (((((extra.affectedgovernment_reconstructed
             JOIN geohistory.government stategovernment ON (((affectedgovernment_reconstructed.stateto = stategovernment.governmentid) AND ((stategovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government countygovernment ON (((affectedgovernment_reconstructed.countyto = countygovernment.governmentid) AND ((countygovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government municipalgovernment ON (((affectedgovernment_reconstructed.municipalityto = municipalgovernment.governmentid) AND ((municipalgovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])) AND (municipalgovernment.governmentlevel = 4))))
             JOIN geohistory.affectedtype ON (((affectedgovernment_reconstructed.affectedtypemunicipalityto = affectedtype.affectedtypeid) AND ((affectedtype.affectedtypecreationdissolution)::text = 'begin'::text))))
             LEFT JOIN geohistory.governmentidentifier ON (((countygovernment.governmentid = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
        UNION
         SELECT DISTINCT affectedgovernment_reconstructed.event,
            affectedtype.affectedtypecreationdissolution,
            affectedgovernment_reconstructed.municipalityto AS governmentid,
                CASE
                    WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
                    ELSE (governmentidentifier.governmentidentifier)::integer
                END AS governmentcounty,
            extra.governmentabbreviation(
                CASE
                    WHEN (stategovernment.governmentsubstitute IS NOT NULL) THEN stategovernment.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.stateto
                END) AS governmentstate
           FROM (((((extra.affectedgovernment_reconstructed
             JOIN geohistory.government stategovernment ON (((affectedgovernment_reconstructed.stateto = stategovernment.governmentid) AND ((stategovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government countygovernment ON (((affectedgovernment_reconstructed.subcountyto = countygovernment.governmentid) AND ((countygovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government municipalgovernment ON (((affectedgovernment_reconstructed.municipalityto = municipalgovernment.governmentid) AND ((municipalgovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])) AND (municipalgovernment.governmentlevel = 4))))
             JOIN geohistory.affectedtype ON (((affectedgovernment_reconstructed.affectedtypemunicipalityto = affectedtype.affectedtypeid) AND ((affectedtype.affectedtypecreationdissolution)::text = 'begin'::text))))
             LEFT JOIN geohistory.governmentidentifier ON (((countygovernment.governmentid = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
        UNION
         SELECT DISTINCT affectedgovernment_reconstructed.event,
            affectedtype.affectedtypecreationdissolution,
            affectedgovernment_reconstructed.submunicipalityto AS governmentid,
                CASE
                    WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
                    ELSE (governmentidentifier.governmentidentifier)::integer
                END AS governmentcounty,
            extra.governmentabbreviation(
                CASE
                    WHEN (stategovernment.governmentsubstitute IS NOT NULL) THEN stategovernment.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.stateto
                END) AS governmentstate
           FROM (((((extra.affectedgovernment_reconstructed
             JOIN geohistory.government stategovernment ON (((affectedgovernment_reconstructed.stateto = stategovernment.governmentid) AND ((stategovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government countygovernment ON (((affectedgovernment_reconstructed.countyto = countygovernment.governmentid) AND ((countygovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government municipalgovernment ON (((affectedgovernment_reconstructed.submunicipalityto = municipalgovernment.governmentid) AND ((municipalgovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])) AND (municipalgovernment.governmentlevel = 4))))
             JOIN geohistory.affectedtype ON (((affectedgovernment_reconstructed.affectedtypesubmunicipalityto = affectedtype.affectedtypeid) AND ((affectedtype.affectedtypecreationdissolution)::text = 'begin'::text))))
             LEFT JOIN geohistory.governmentidentifier ON (((countygovernment.governmentid = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
        UNION
         SELECT DISTINCT affectedgovernment_reconstructed.event,
            affectedtype.affectedtypecreationdissolution,
            affectedgovernment_reconstructed.submunicipalityto AS governmentid,
                CASE
                    WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
                    ELSE (governmentidentifier.governmentidentifier)::integer
                END AS governmentcounty,
            extra.governmentabbreviation(
                CASE
                    WHEN (stategovernment.governmentsubstitute IS NOT NULL) THEN stategovernment.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.stateto
                END) AS governmentstate
           FROM (((((extra.affectedgovernment_reconstructed
             JOIN geohistory.government stategovernment ON (((affectedgovernment_reconstructed.stateto = stategovernment.governmentid) AND ((stategovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government countygovernment ON (((affectedgovernment_reconstructed.subcountyto = countygovernment.governmentid) AND ((countygovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government municipalgovernment ON (((affectedgovernment_reconstructed.submunicipalityto = municipalgovernment.governmentid) AND ((municipalgovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])) AND (municipalgovernment.governmentlevel = 4))))
             JOIN geohistory.affectedtype ON (((affectedgovernment_reconstructed.affectedtypesubmunicipalityto = affectedtype.affectedtypeid) AND ((affectedtype.affectedtypecreationdissolution)::text = 'begin'::text))))
             LEFT JOIN geohistory.governmentidentifier ON (((countygovernment.governmentid = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
        UNION
         SELECT DISTINCT affectedgovernment_reconstructed.event,
            affectedtype.affectedtypecreationdissolution,
            affectedgovernment_reconstructed.municipalityfrom AS governmentid,
                CASE
                    WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
                    ELSE (governmentidentifier.governmentidentifier)::integer
                END AS governmentcounty,
            extra.governmentabbreviation(
                CASE
                    WHEN (stategovernment.governmentsubstitute IS NOT NULL) THEN stategovernment.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.statefrom
                END) AS governmentstate
           FROM (((((extra.affectedgovernment_reconstructed
             JOIN geohistory.government stategovernment ON (((affectedgovernment_reconstructed.statefrom = stategovernment.governmentid) AND ((stategovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government countygovernment ON (((affectedgovernment_reconstructed.countyfrom = countygovernment.governmentid) AND ((countygovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government municipalgovernment ON (((affectedgovernment_reconstructed.municipalityfrom = municipalgovernment.governmentid) AND ((municipalgovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])) AND (municipalgovernment.governmentlevel = 4))))
             JOIN geohistory.affectedtype ON (((affectedgovernment_reconstructed.affectedtypemunicipalityfrom = affectedtype.affectedtypeid) AND ((affectedtype.affectedtypecreationdissolution)::text = 'end'::text))))
             LEFT JOIN geohistory.governmentidentifier ON (((countygovernment.governmentid = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
        UNION
         SELECT DISTINCT affectedgovernment_reconstructed.event,
            affectedtype.affectedtypecreationdissolution,
            affectedgovernment_reconstructed.municipalityfrom AS governmentid,
                CASE
                    WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
                    ELSE (governmentidentifier.governmentidentifier)::integer
                END AS governmentcounty,
            extra.governmentabbreviation(
                CASE
                    WHEN (stategovernment.governmentsubstitute IS NOT NULL) THEN stategovernment.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.statefrom
                END) AS governmentstate
           FROM (((((extra.affectedgovernment_reconstructed
             JOIN geohistory.government stategovernment ON (((affectedgovernment_reconstructed.statefrom = stategovernment.governmentid) AND ((stategovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government countygovernment ON (((affectedgovernment_reconstructed.subcountyfrom = countygovernment.governmentid) AND ((countygovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government municipalgovernment ON (((affectedgovernment_reconstructed.municipalityfrom = municipalgovernment.governmentid) AND ((municipalgovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])) AND (municipalgovernment.governmentlevel = 4))))
             JOIN geohistory.affectedtype ON (((affectedgovernment_reconstructed.affectedtypemunicipalityfrom = affectedtype.affectedtypeid) AND ((affectedtype.affectedtypecreationdissolution)::text = 'end'::text))))
             LEFT JOIN geohistory.governmentidentifier ON (((countygovernment.governmentid = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
        UNION
         SELECT DISTINCT affectedgovernment_reconstructed.event,
            affectedtype.affectedtypecreationdissolution,
            affectedgovernment_reconstructed.submunicipalityfrom AS governmentid,
                CASE
                    WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
                    ELSE (governmentidentifier.governmentidentifier)::integer
                END AS governmentcounty,
            extra.governmentabbreviation(
                CASE
                    WHEN (stategovernment.governmentsubstitute IS NOT NULL) THEN stategovernment.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.statefrom
                END) AS governmentstate
           FROM (((((extra.affectedgovernment_reconstructed
             JOIN geohistory.government stategovernment ON (((affectedgovernment_reconstructed.statefrom = stategovernment.governmentid) AND ((stategovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government countygovernment ON (((affectedgovernment_reconstructed.countyfrom = countygovernment.governmentid) AND ((countygovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government municipalgovernment ON (((affectedgovernment_reconstructed.submunicipalityfrom = municipalgovernment.governmentid) AND ((municipalgovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])) AND (municipalgovernment.governmentlevel = 4))))
             JOIN geohistory.affectedtype ON (((affectedgovernment_reconstructed.affectedtypesubmunicipalityfrom = affectedtype.affectedtypeid) AND ((affectedtype.affectedtypecreationdissolution)::text = 'end'::text))))
             LEFT JOIN geohistory.governmentidentifier ON (((countygovernment.governmentid = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
        UNION
         SELECT DISTINCT affectedgovernment_reconstructed.event,
            affectedtype.affectedtypecreationdissolution,
            affectedgovernment_reconstructed.submunicipalityfrom AS governmentid,
                CASE
                    WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
                    ELSE (governmentidentifier.governmentidentifier)::integer
                END AS governmentcounty,
            extra.governmentabbreviation(
                CASE
                    WHEN (stategovernment.governmentsubstitute IS NOT NULL) THEN stategovernment.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.statefrom
                END) AS governmentstate
           FROM (((((extra.affectedgovernment_reconstructed
             JOIN geohistory.government stategovernment ON (((affectedgovernment_reconstructed.statefrom = stategovernment.governmentid) AND ((stategovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government countygovernment ON (((affectedgovernment_reconstructed.subcountyfrom = countygovernment.governmentid) AND ((countygovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government municipalgovernment ON (((affectedgovernment_reconstructed.submunicipalityfrom = municipalgovernment.governmentid) AND ((municipalgovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])) AND (municipalgovernment.governmentlevel = 4))))
             JOIN geohistory.affectedtype ON (((affectedgovernment_reconstructed.affectedtypesubmunicipalityfrom = affectedtype.affectedtypeid) AND ((affectedtype.affectedtypecreationdissolution)::text = 'end'::text))))
             LEFT JOIN geohistory.governmentidentifier ON (((countygovernment.governmentid = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
        ), stateevents AS (
         SELECT DISTINCT affectedgovernment_reconstructed.event,
            affectedtype.affectedtypecreationdissolution,
            affectedgovernment_reconstructed.municipalityto AS governmentid,
            extra.governmentabbreviation(
                CASE
                    WHEN (government.governmentsubstitute IS NOT NULL) THEN government.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.stateto
                END) AS governmentstate
           FROM (((extra.affectedgovernment_reconstructed
             JOIN geohistory.government ON (((affectedgovernment_reconstructed.stateto = government.governmentid) AND ((government.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government municipalgovernment ON (((affectedgovernment_reconstructed.municipalityto = municipalgovernment.governmentid) AND ((municipalgovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])) AND (municipalgovernment.governmentlevel = 4))))
             JOIN geohistory.affectedtype ON (((affectedgovernment_reconstructed.affectedtypemunicipalityto = affectedtype.affectedtypeid) AND ((affectedtype.affectedtypecreationdissolution)::text = 'begin'::text))))
        UNION
         SELECT DISTINCT affectedgovernment_reconstructed.event,
            affectedtype.affectedtypecreationdissolution,
            affectedgovernment_reconstructed.submunicipalityto AS governmentid,
            extra.governmentabbreviation(
                CASE
                    WHEN (government.governmentsubstitute IS NOT NULL) THEN government.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.stateto
                END) AS governmentstate
           FROM (((extra.affectedgovernment_reconstructed
             JOIN geohistory.government ON (((affectedgovernment_reconstructed.stateto = government.governmentid) AND ((government.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government municipalgovernment ON (((affectedgovernment_reconstructed.submunicipalityto = municipalgovernment.governmentid) AND ((municipalgovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])) AND (municipalgovernment.governmentlevel = 4))))
             JOIN geohistory.affectedtype ON (((affectedgovernment_reconstructed.affectedtypesubmunicipalityto = affectedtype.affectedtypeid) AND ((affectedtype.affectedtypecreationdissolution)::text = 'begin'::text))))
        UNION
         SELECT DISTINCT affectedgovernment_reconstructed.event,
            affectedtype.affectedtypecreationdissolution,
            affectedgovernment_reconstructed.municipalityfrom AS governmentid,
            extra.governmentabbreviation(
                CASE
                    WHEN (government.governmentsubstitute IS NOT NULL) THEN government.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.statefrom
                END) AS governmentstate
           FROM (((extra.affectedgovernment_reconstructed
             JOIN geohistory.government ON (((affectedgovernment_reconstructed.statefrom = government.governmentid) AND ((government.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government municipalgovernment ON (((affectedgovernment_reconstructed.municipalityfrom = municipalgovernment.governmentid) AND ((municipalgovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])) AND (municipalgovernment.governmentlevel = 4))))
             JOIN geohistory.affectedtype ON (((affectedgovernment_reconstructed.affectedtypemunicipalityfrom = affectedtype.affectedtypeid) AND ((affectedtype.affectedtypecreationdissolution)::text = 'end'::text))))
        UNION
         SELECT DISTINCT affectedgovernment_reconstructed.event,
            affectedtype.affectedtypecreationdissolution,
            affectedgovernment_reconstructed.submunicipalityfrom AS governmentid,
            extra.governmentabbreviation(
                CASE
                    WHEN (government.governmentsubstitute IS NOT NULL) THEN government.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.statefrom
                END) AS governmentstate
           FROM (((extra.affectedgovernment_reconstructed
             JOIN geohistory.government ON (((affectedgovernment_reconstructed.statefrom = government.governmentid) AND ((government.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government municipalgovernment ON (((affectedgovernment_reconstructed.submunicipalityfrom = municipalgovernment.governmentid) AND ((municipalgovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])) AND (municipalgovernment.governmentlevel = 4))))
             JOIN geohistory.affectedtype ON (((affectedgovernment_reconstructed.affectedtypesubmunicipalityfrom = affectedtype.affectedtypeid) AND ((affectedtype.affectedtypecreationdissolution)::text = 'end'::text))))
        ), eventstates AS (
         SELECT DISTINCT stateevents.event,
            stateevents.affectedtypecreationdissolution,
            stateevents.governmentid,
            array_agg(DISTINCT stateevents.governmentstate) AS governmentstates
           FROM stateevents
          GROUP BY stateevents.event, stateevents.affectedtypecreationdissolution, stateevents.governmentid
        ), summary AS (
         SELECT 'historic'::text AS grouptype,
            'county'::text AS governmenttype,
            countyevents.governmentstate,
            countyevents.governmentcounty,
            extra.eventsortdateyear(event.eventid) AS eventyear,
            countyevents.affectedtypecreationdissolution,
            (count(DISTINCT countyevents.governmentid))::integer AS governmentcount
           FROM ((geohistory.event
             JOIN countyevents ON ((event.eventid = countyevents.event)))
             JOIN geohistory.eventgranted ON (((event.eventgranted = eventgranted.eventgrantedid) AND eventgranted.eventgrantedsuccess)))
          GROUP BY 'historic'::text, 'county'::text, countyevents.governmentstate, countyevents.governmentcounty, (extra.eventsortdateyear(event.eventid)), countyevents.affectedtypecreationdissolution
        UNION
         SELECT 'historic'::text AS grouptype,
            'state'::text AS governmenttype,
            stateevents.governmentstate,
            NULL::integer AS governmentcounty,
            extra.eventsortdateyear(event.eventid) AS eventyear,
            stateevents.affectedtypecreationdissolution,
            count(DISTINCT stateevents.governmentid) AS governmentcount
           FROM ((geohistory.event
             JOIN stateevents ON ((event.eventid = stateevents.event)))
             JOIN geohistory.eventgranted ON (((event.eventgranted = eventgranted.eventgrantedid) AND eventgranted.eventgrantedsuccess)))
          GROUP BY 'historic'::text, 'state'::text, stateevents.governmentstate, NULL::integer, (extra.eventsortdateyear(event.eventid)), stateevents.affectedtypecreationdissolution
        UNION
         SELECT 'historic'::text AS grouptype,
            'nation'::text AS governmenttype,
            'production'::text AS governmentstate,
            NULL::integer AS governmentcounty,
            extra.eventsortdateyear(event.eventid) AS eventyear,
            eventstates.affectedtypecreationdissolution,
            count(DISTINCT eventstates.governmentid) AS governmentcount
           FROM ((geohistory.event
             JOIN eventstates ON (((event.eventid = eventstates.event) AND (eventstates.governmentstates && ARRAY['NJ'::text, 'PA'::text]))))
             JOIN geohistory.eventgranted ON (((event.eventgranted = eventgranted.eventgrantedid) AND eventgranted.eventgrantedsuccess)))
          GROUP BY 'historic'::text, 'nation'::text, 'production'::text, NULL::integer, (extra.eventsortdateyear(event.eventid)), eventstates.affectedtypecreationdissolution
        UNION
         SELECT 'historic'::text AS grouptype,
            'nation'::text AS governmenttype,
            'development'::text AS governmentstate,
            NULL::integer AS governmentcounty,
            extra.eventsortdateyear(event.eventid) AS eventyear,
            eventstates.affectedtypecreationdissolution,
            count(DISTINCT eventstates.governmentid) AS governmentcount
           FROM ((geohistory.event
             JOIN eventstates ON (((event.eventid = eventstates.event) AND (eventstates.governmentstates && ARRAY['DE'::text, 'ME'::text, 'MA'::text, 'MD'::text, 'MI'::text, 'MN'::text, 'NJ'::text, 'NY'::text, 'OH'::text, 'PA'::text]))))
             JOIN geohistory.eventgranted ON (((event.eventgranted = eventgranted.eventgrantedid) AND eventgranted.eventgrantedsuccess)))
          GROUP BY 'historic'::text, 'nation'::text, 'development'::text, NULL::integer, (extra.eventsortdateyear(event.eventid)), eventstates.affectedtypecreationdissolution
        )
 SELECT DISTINCT summary.grouptype,
    summary.governmenttype,
    summary.governmentstate,
    summary.governmentcounty,
    summary.eventyear,
        CASE
            WHEN (creation.governmentcount IS NULL) THEN (0)::bigint
            ELSE creation.governmentcount
        END AS created,
        CASE
            WHEN (dissolution.governmentcount IS NULL) THEN (0)::bigint
            ELSE dissolution.governmentcount
        END AS dissolved
   FROM ((summary
     LEFT JOIN summary creation ON (((summary.grouptype = creation.grouptype) AND (summary.governmenttype = creation.governmenttype) AND (summary.governmentstate = creation.governmentstate) AND (((summary.governmentcounty IS NULL) AND (creation.governmentcounty IS NULL)) OR (summary.governmentcounty = creation.governmentcounty)) AND (summary.eventyear = creation.eventyear) AND ((creation.affectedtypecreationdissolution)::text = 'begin'::text))))
     LEFT JOIN summary dissolution ON (((summary.grouptype = dissolution.grouptype) AND (summary.governmenttype = dissolution.governmenttype) AND (summary.governmentstate = dissolution.governmentstate) AND (((summary.governmentcounty IS NULL) AND (dissolution.governmentcounty IS NULL)) OR (summary.governmentcounty = dissolution.governmentcounty)) AND (summary.eventyear = dissolution.eventyear) AND ((dissolution.affectedtypecreationdissolution)::text = 'end'::text))))
  ORDER BY summary.grouptype, summary.governmenttype, summary.governmentstate, summary.governmentcounty, summary.eventyear
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.statistics_createddissolved OWNER TO postgres;

--
-- Name: statistics_eventtype; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.statistics_eventtype AS
 WITH countyevents AS (
         SELECT DISTINCT affectedgovernment_reconstructed.event,
                CASE
                    WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
                    ELSE (governmentidentifier.governmentidentifier)::integer
                END AS governmentcounty,
            extra.governmentabbreviation(
                CASE
                    WHEN (stategovernment.governmentsubstitute IS NOT NULL) THEN stategovernment.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.statefrom
                END) AS governmentstate
           FROM (((extra.affectedgovernment_reconstructed
             JOIN geohistory.government stategovernment ON (((affectedgovernment_reconstructed.statefrom = stategovernment.governmentid) AND ((stategovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government countygovernment ON (((affectedgovernment_reconstructed.countyfrom = countygovernment.governmentid) AND ((countygovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             LEFT JOIN geohistory.governmentidentifier ON (((countygovernment.governmentid = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
          WHERE (affectedgovernment_reconstructed.affectedtypecountyfrom <> 12)
        UNION
         SELECT DISTINCT affectedgovernment_reconstructed.event,
                CASE
                    WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
                    ELSE (governmentidentifier.governmentidentifier)::integer
                END AS governmentcounty,
            extra.governmentabbreviation(
                CASE
                    WHEN (stategovernment.governmentsubstitute IS NOT NULL) THEN stategovernment.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.stateto
                END) AS governmentstate
           FROM (((extra.affectedgovernment_reconstructed
             JOIN geohistory.government stategovernment ON (((affectedgovernment_reconstructed.stateto = stategovernment.governmentid) AND ((stategovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government countygovernment ON (((affectedgovernment_reconstructed.countyto = countygovernment.governmentid) AND ((countygovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             LEFT JOIN geohistory.governmentidentifier ON (((countygovernment.governmentid = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
          WHERE (affectedgovernment_reconstructed.affectedtypecountyto <> 12)
        UNION
         SELECT DISTINCT affectedgovernment_reconstructed.event,
                CASE
                    WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
                    ELSE (governmentidentifier.governmentidentifier)::integer
                END AS governmentcounty,
            extra.governmentabbreviation(
                CASE
                    WHEN (stategovernment.governmentsubstitute IS NOT NULL) THEN stategovernment.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.statefrom
                END) AS governmentstate
           FROM (((extra.affectedgovernment_reconstructed
             JOIN geohistory.government stategovernment ON (((affectedgovernment_reconstructed.statefrom = stategovernment.governmentid) AND ((stategovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government countygovernment ON (((affectedgovernment_reconstructed.subcountyfrom = countygovernment.governmentid) AND ((countygovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             LEFT JOIN geohistory.governmentidentifier ON (((countygovernment.governmentid = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
          WHERE (affectedgovernment_reconstructed.affectedtypesubcountyfrom <> 12)
        UNION
         SELECT DISTINCT affectedgovernment_reconstructed.event,
                CASE
                    WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
                    ELSE (governmentidentifier.governmentidentifier)::integer
                END AS governmentcounty,
            extra.governmentabbreviation(
                CASE
                    WHEN (stategovernment.governmentsubstitute IS NOT NULL) THEN stategovernment.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.stateto
                END) AS governmentstate
           FROM (((extra.affectedgovernment_reconstructed
             JOIN geohistory.government stategovernment ON (((affectedgovernment_reconstructed.stateto = stategovernment.governmentid) AND ((stategovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             JOIN geohistory.government countygovernment ON (((affectedgovernment_reconstructed.subcountyto = countygovernment.governmentid) AND ((countygovernment.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
             LEFT JOIN geohistory.governmentidentifier ON (((countygovernment.governmentid = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
          WHERE (affectedgovernment_reconstructed.affectedtypesubcountyto <> 12)
        ), stateevents AS (
         SELECT DISTINCT affectedgovernment_reconstructed.event,
            extra.governmentabbreviation(
                CASE
                    WHEN (government.governmentsubstitute IS NOT NULL) THEN government.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.statefrom
                END) AS governmentstate
           FROM (extra.affectedgovernment_reconstructed
             JOIN geohistory.government ON (((affectedgovernment_reconstructed.statefrom = government.governmentid) AND ((government.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
          WHERE (affectedgovernment_reconstructed.affectedtypestatefrom <> 12)
        UNION
         SELECT DISTINCT affectedgovernment_reconstructed.event,
            extra.governmentabbreviation(
                CASE
                    WHEN (government.governmentsubstitute IS NOT NULL) THEN government.governmentsubstitute
                    ELSE affectedgovernment_reconstructed.stateto
                END) AS governmentstate
           FROM (extra.affectedgovernment_reconstructed
             JOIN geohistory.government ON (((affectedgovernment_reconstructed.stateto = government.governmentid) AND ((government.governmentstatus)::text <> ALL (ARRAY[('placeholder'::character varying)::text, ('proposed'::character varying)::text, ('unincorporated'::character varying)::text])))))
          WHERE (affectedgovernment_reconstructed.affectedtypestateto <> 12)
        ), eventstates AS (
         SELECT DISTINCT stateevents.event,
            array_agg(DISTINCT stateevents.governmentstate) AS governmentstates
           FROM stateevents
          GROUP BY stateevents.event
        )
 SELECT 'historic'::text AS grouptype,
    'county'::text AS governmenttype,
    countyevents.governmentstate,
    countyevents.governmentcounty,
    event.eventtype,
    extra.eventsortdateyear(event.eventid) AS eventyear,
    (count(DISTINCT event.eventid))::integer AS eventcount,
    array_agg(DISTINCT event.eventid ORDER BY event.eventid) AS eventlist
   FROM ((geohistory.event
     JOIN countyevents ON ((event.eventid = countyevents.event)))
     JOIN geohistory.eventgranted ON (((event.eventgranted = eventgranted.eventgrantedid) AND eventgranted.eventgrantedsuccess)))
  GROUP BY 'county'::text, countyevents.governmentstate, countyevents.governmentcounty, event.eventtype, (extra.eventsortdateyear(event.eventid))
UNION
 SELECT 'historic'::text AS grouptype,
    'state'::text AS governmenttype,
    stateevents.governmentstate,
    NULL::integer AS governmentcounty,
    event.eventtype,
    extra.eventsortdateyear(event.eventid) AS eventyear,
    count(DISTINCT event.eventid) AS eventcount,
    array_agg(DISTINCT event.eventid ORDER BY event.eventid) AS eventlist
   FROM ((geohistory.event
     JOIN stateevents ON ((event.eventid = stateevents.event)))
     JOIN geohistory.eventgranted ON (((event.eventgranted = eventgranted.eventgrantedid) AND eventgranted.eventgrantedsuccess)))
  GROUP BY 'state'::text, stateevents.governmentstate, NULL::integer, event.eventtype, (extra.eventsortdateyear(event.eventid))
UNION
 SELECT 'historic'::text AS grouptype,
    'nation'::text AS governmenttype,
    'production'::text AS governmentstate,
    NULL::integer AS governmentcounty,
    event.eventtype,
    extra.eventsortdateyear(event.eventid) AS eventyear,
    count(DISTINCT event.eventid) AS eventcount,
    array_agg(DISTINCT event.eventid ORDER BY event.eventid) AS eventlist
   FROM ((geohistory.event
     JOIN eventstates ON (((event.eventid = eventstates.event) AND (eventstates.governmentstates && ARRAY['NJ'::text, 'PA'::text]))))
     JOIN geohistory.eventgranted ON (((event.eventgranted = eventgranted.eventgrantedid) AND eventgranted.eventgrantedsuccess)))
  GROUP BY 'state'::text, 'production'::text, NULL::integer, event.eventtype, (extra.eventsortdateyear(event.eventid))
UNION
 SELECT 'historic'::text AS grouptype,
    'nation'::text AS governmenttype,
    'development'::text AS governmentstate,
    NULL::integer AS governmentcounty,
    event.eventtype,
    extra.eventsortdateyear(event.eventid) AS eventyear,
    count(DISTINCT event.eventid) AS eventcount,
    array_agg(DISTINCT event.eventid ORDER BY event.eventid) AS eventlist
   FROM ((geohistory.event
     JOIN eventstates ON (((event.eventid = eventstates.event) AND (eventstates.governmentstates && ARRAY['DE'::text, 'ME'::text, 'MA'::text, 'MD'::text, 'MI'::text, 'MN'::text, 'NJ'::text, 'NY'::text, 'OH'::text, 'PA'::text]))))
     JOIN geohistory.eventgranted ON (((event.eventgranted = eventgranted.eventgrantedid) AND eventgranted.eventgrantedsuccess)))
  GROUP BY 'state'::text, 'development'::text, NULL::integer, event.eventtype, (extra.eventsortdateyear(event.eventid))
  ORDER BY 1, 2, 3, 4, 5
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.statistics_eventtype OWNER TO postgres;

--
-- Name: governmentmapstatus; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.governmentmapstatus (
    governmentmapstatusid integer NOT NULL,
    governmentmapstatusshort character varying(20) NOT NULL,
    governmentmapstatuslong text NOT NULL,
    governmentmapstatusreviewed boolean DEFAULT false NOT NULL,
    governmentmapstatusfurtherresearch boolean DEFAULT false NOT NULL,
    governmentmapstatustimelapse boolean DEFAULT false NOT NULL,
    governmentmapstatusomit boolean DEFAULT false NOT NULL,
    CONSTRAINT governmentmapstatus_check CHECK (((governmentmapstatusshort)::text <> ''::text))
);


ALTER TABLE geohistory.governmentmapstatus OWNER TO postgres;

--
-- Name: TABLE governmentmapstatus; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON TABLE geohistory.governmentmapstatus IS 'The rows in the table have been simplified in open data to remove certain information used for internal tracking purposes.';


--
-- Name: COLUMN governmentmapstatus.governmentmapstatusfurtherresearch; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.governmentmapstatus.governmentmapstatusfurtherresearch IS 'This field is used for internal tracking purposes, and is always shown as the default value in open data.';


--
-- Name: statistics_mapped; Type: MATERIALIZED VIEW; Schema: extra; Owner: postgres
--

CREATE MATERIALIZED VIEW extra.statistics_mapped AS
 SELECT 'incorporated'::text AS grouptype,
    'county'::text AS governmenttype,
    extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) AS governmentstate,
        CASE
            WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
            ELSE (governmentidentifier.governmentidentifier)::integer
        END AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatustimelapse THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM ((geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
     LEFT JOIN geohistory.governmentidentifier ON (((government.governmentcurrentleadparent = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Hundred'::text, 'Independent School District'::text, 'Place'::text, 'School District'::text, 'Township'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])))
  GROUP BY 'incorporated'::text, 'county'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), government.governmentcurrentleadparent, governmentidentifier.governmentidentifier
UNION
 SELECT 'total'::text AS grouptype,
    'county'::text AS governmenttype,
    extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) AS governmentstate,
        CASE
            WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
            ELSE (governmentidentifier.governmentidentifier)::integer
        END AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatustimelapse THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM ((geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
     LEFT JOIN geohistory.governmentidentifier ON (((government.governmentcurrentleadparent = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Independent School District'::text, 'Place'::text, 'School District'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])))
  GROUP BY 'total'::text, 'county'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), government.governmentcurrentleadparent, governmentidentifier.governmentidentifier
UNION
 SELECT 'incorporated'::text AS grouptype,
    'state'::text AS governmenttype,
    extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) AS governmentstate,
    0 AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatustimelapse THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM (geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Hundred'::text, 'Independent School District'::text, 'Place'::text, 'School District'::text, 'Township'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])))
  GROUP BY 'incorporated'::text, 'state'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), 0::integer
UNION
 SELECT 'total'::text AS grouptype,
    'state'::text AS governmenttype,
    extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) AS governmentstate,
    0 AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatustimelapse THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM (geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Independent School District'::text, 'Place'::text, 'School District'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])))
  GROUP BY 'total'::text, 'state'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), 0::integer
UNION
 SELECT 'incorporated'::text AS grouptype,
    'nation'::text AS governmenttype,
    'development'::text AS governmentstate,
    0 AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatustimelapse THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM (geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Hundred'::text, 'Independent School District'::text, 'Place'::text, 'School District'::text, 'Township'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])) AND (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) = ANY (ARRAY['DE'::text, 'ME'::text, 'MA'::text, 'MD'::text, 'MI'::text, 'MN'::text, 'NJ'::text, 'NJ'::text, 'OH'::text, 'PA'::text])))
  GROUP BY 'incorporated'::text, 'state'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), 0::integer
UNION
 SELECT 'total'::text AS grouptype,
    'nation'::text AS governmenttype,
    'development'::text AS governmentstate,
    0 AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatustimelapse THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM (geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Independent School District'::text, 'Place'::text, 'School District'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])) AND (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) = ANY (ARRAY['DE'::text, 'ME'::text, 'MA'::text, 'MD'::text, 'MI'::text, 'MN'::text, 'NJ'::text, 'NJ'::text, 'OH'::text, 'PA'::text])))
  GROUP BY 'total'::text, 'state'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), 0::integer
UNION
 SELECT 'incorporated'::text AS grouptype,
    'nation'::text AS governmenttype,
    'development'::text AS governmentstate,
    0 AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatustimelapse THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM (geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Hundred'::text, 'Independent School District'::text, 'Place'::text, 'School District'::text, 'Township'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])) AND (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) = ANY (ARRAY['NJ'::text, 'PA'::text])))
  GROUP BY 'incorporated'::text, 'state'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), 0::integer
UNION
 SELECT 'total'::text AS grouptype,
    'nation'::text AS governmenttype,
    'development'::text AS governmentstate,
    0 AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatustimelapse THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM (geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Independent School District'::text, 'Place'::text, 'School District'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])) AND (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) = ANY (ARRAY['NJ'::text, 'PA'::text])))
  GROUP BY 'total'::text, 'state'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), 0::integer
UNION
 SELECT 'incorporated_review'::text AS grouptype,
    'county'::text AS governmenttype,
    extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) AS governmentstate,
        CASE
            WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
            ELSE (governmentidentifier.governmentidentifier)::integer
        END AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatusreviewed THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM ((geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
     LEFT JOIN geohistory.governmentidentifier ON (((government.governmentcurrentleadparent = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Hundred'::text, 'Independent School District'::text, 'Place'::text, 'School District'::text, 'Township'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])))
  GROUP BY 'incorporated_review'::text, 'county'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), government.governmentcurrentleadparent, governmentidentifier.governmentidentifier
UNION
 SELECT 'total_review'::text AS grouptype,
    'county'::text AS governmenttype,
    extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) AS governmentstate,
        CASE
            WHEN (governmentidentifier.governmentidentifier IS NULL) THEN 0
            ELSE (governmentidentifier.governmentidentifier)::integer
        END AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatusreviewed THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM ((geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
     LEFT JOIN geohistory.governmentidentifier ON (((government.governmentcurrentleadparent = governmentidentifier.government) AND (governmentidentifier.governmentidentifiertype = 1))))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Independent School District'::text, 'Place'::text, 'School District'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])))
  GROUP BY 'total_review'::text, 'county'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), government.governmentcurrentleadparent, governmentidentifier.governmentidentifier
UNION
 SELECT 'incorporated_review'::text AS grouptype,
    'state'::text AS governmenttype,
    extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) AS governmentstate,
    0 AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatusreviewed THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM (geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Hundred'::text, 'Independent School District'::text, 'Place'::text, 'School District'::text, 'Township'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])))
  GROUP BY 'incorporated_review'::text, 'state'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), 0::integer
UNION
 SELECT 'total_review'::text AS grouptype,
    'state'::text AS governmenttype,
    extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) AS governmentstate,
    0 AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatusreviewed THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM (geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Independent School District'::text, 'Place'::text, 'School District'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])))
  GROUP BY 'total_review'::text, 'state'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), 0::integer
UNION
 SELECT 'incorporated_review'::text AS grouptype,
    'nation'::text AS governmenttype,
    'development'::text AS governmentstate,
    0 AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatusreviewed THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM (geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Hundred'::text, 'Independent School District'::text, 'Place'::text, 'School District'::text, 'Township'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])) AND (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) = ANY (ARRAY['DE'::text, 'ME'::text, 'MA'::text, 'MD'::text, 'MI'::text, 'MN'::text, 'NJ'::text, 'NJ'::text, 'OH'::text, 'PA'::text])))
  GROUP BY 'incorporated_review'::text, 'state'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), 0::integer
UNION
 SELECT 'total_review'::text AS grouptype,
    'nation'::text AS governmenttype,
    'development'::text AS governmentstate,
    0 AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatusreviewed THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM (geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Independent School District'::text, 'Place'::text, 'School District'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])) AND (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) = ANY (ARRAY['DE'::text, 'ME'::text, 'MA'::text, 'MD'::text, 'MI'::text, 'MN'::text, 'NJ'::text, 'NJ'::text, 'OH'::text, 'PA'::text])))
  GROUP BY 'total_review'::text, 'state'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), 0::integer
UNION
 SELECT 'incorporated_review'::text AS grouptype,
    'nation'::text AS governmenttype,
    'development'::text AS governmentstate,
    0 AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatusreviewed THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM (geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Hundred'::text, 'Independent School District'::text, 'Place'::text, 'School District'::text, 'Township'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])) AND (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) = ANY (ARRAY['NJ'::text, 'PA'::text])))
  GROUP BY 'incorporated_review'::text, 'state'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), 0::integer
UNION
 SELECT 'total_review'::text AS grouptype,
    'nation'::text AS governmenttype,
    'development'::text AS governmentstate,
    0 AS governmentcounty,
    round((((sum(
        CASE
            WHEN governmentmapstatus.governmentmapstatusreviewed THEN 1
            ELSE 0
        END))::numeric / (COALESCE(count(*), (1)::bigint))::numeric) * (100)::numeric), 2) AS percentmapped
   FROM (geohistory.government
     JOIN geohistory.governmentmapstatus ON ((government.governmentmapstatus = governmentmapstatus.governmentmapstatusid)))
  WHERE ((government.governmentsubstitute IS NULL) AND (government.governmentlevel = 4) AND ((government.governmenttype)::text <> ALL (ARRAY['Independent School District'::text, 'Place'::text, 'School District'::text, 'Ward'::text])) AND ((government.governmentstatus)::text = ANY (ARRAY[('defunct'::character varying)::text, 'nonfunctioning'::text, 'paper'::text, 'unknown'::text, (''::character varying)::text])) AND (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent)) = ANY (ARRAY['NJ'::text, 'PA'::text])))
  GROUP BY 'total_review'::text, 'state'::text, (extra.governmentabbreviation(extra.governmentcurrentleadstateid(government.governmentcurrentleadparent))), 0::integer
  ORDER BY 1, 2, 3, 4
  WITH NO DATA;


ALTER MATERIALIZED VIEW extra.statistics_mapped OWNER TO postgres;

--
-- Name: eventtype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.eventtype (
    eventtypeid integer NOT NULL,
    eventtypelong text NOT NULL,
    eventtypeshort character varying(50) NOT NULL,
    eventtypeborders character varying(15) DEFAULT ''::character varying NOT NULL,
    eventtypeinclude boolean DEFAULT false NOT NULL,
    eventtypecreate character varying(1) DEFAULT 'n'::text NOT NULL,
    eventtypegroup character varying(20),
    CONSTRAINT eventtype_check CHECK (((eventtypelong <> ''::text) AND ((eventtypeshort)::text <> ''::text)))
);


ALTER TABLE geohistory.eventtype OWNER TO postgres;

--
-- Name: COLUMN eventtype.eventtypelong; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.eventtype.eventtypelong IS 'Rewrite';


--
-- Name: COLUMN eventtype.eventtypecreate; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.eventtype.eventtypecreate IS 'c = only events affecting counties included; 
n = no events included;
s = separate/subordinate events are included for townships and all events included for all other types;
t = begin/end events are included for townships and all events included for all other types;
y = all events included';


--
-- Name: COLUMN eventtype.eventtypegroup; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.eventtype.eventtypegroup IS '"Omit" items are omitted from open data, and events with foreign key "Placeholder" are omitted from open data.';


--
-- Name: governmentform; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.governmentform (
    governmentformid integer NOT NULL,
    governmentstate integer NOT NULL,
    governmentformpublication boolean DEFAULT true NOT NULL,
    recategorize boolean DEFAULT false NOT NULL,
    governmentformpublicationdate boolean DEFAULT false NOT NULL,
    governmentformtype text DEFAULT ''::text NOT NULL,
    governmentformclass text DEFAULT ''::text NOT NULL,
    governmentformqualifier text DEFAULT ''::text NOT NULL,
    governmentformqualifierinclude boolean DEFAULT true NOT NULL,
    governmentformextended text DEFAULT ''::text NOT NULL,
    governmentformlong text GENERATED ALWAYS AS (((governmentformtype ||
CASE
    WHEN (governmentformclass <> ''::text) THEN (', '::text || governmentformclass)
    ELSE ''::text
END) ||
CASE
    WHEN (governmentformqualifier <> ''::text) THEN ((' ('::text || governmentformqualifier) || ')'::text)
    ELSE ''::text
END)) STORED,
    governmentformlongreport text GENERATED ALWAYS AS (((governmentformtype ||
CASE
    WHEN (governmentformclass <> ''::text) THEN (', '::text || governmentformclass)
    ELSE ''::text
END) ||
CASE
    WHEN (governmentformqualifierinclude AND (governmentformqualifier <> ''::text)) THEN ((' ('::text || governmentformqualifier) || ')'::text)
    ELSE ''::text
END)) STORED,
    governmentformlongextended text GENERATED ALWAYS AS ((((governmentformtype ||
CASE
    WHEN (governmentformclass <> ''::text) THEN (', '::text || governmentformclass)
    ELSE ''::text
END) ||
CASE
    WHEN (governmentformqualifier <> ''::text) THEN ((' ('::text || governmentformqualifier) || ')'::text)
    ELSE ''::text
END) ||
CASE
    WHEN (governmentformextended <> ''::text) THEN (': '::text || governmentformextended)
    ELSE ''::text
END)) STORED
);


ALTER TABLE geohistory.governmentform OWNER TO postgres;

--
-- Name: COLUMN governmentform.governmentformpublication; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.governmentform.governmentformpublication IS 'Whether this record should be included in book publication form. This field is used for internal tracking purposes, and is always shown as the default value in open data.';


--
-- Name: COLUMN governmentform.recategorize; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.governmentform.recategorize IS 'This field is used for internal tracking purposes, and is always shown as the default value in open data.';


--
-- Name: COLUMN governmentform.governmentformpublicationdate; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.governmentform.governmentformpublicationdate IS 'This field is used for internal tracking purposes, and is always shown as the default value in open data.';


--
-- Name: COLUMN governmentform.governmentformextended; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.governmentform.governmentformextended IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: metesdescriptionline; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.metesdescriptionline (
    metesdescriptionlineid integer NOT NULL,
    metesdescription integer NOT NULL,
    metesdescriptionline smallint NOT NULL,
    thencepoint text DEFAULT ''::text NOT NULL,
    northsouth character varying(1) DEFAULT ''::character varying NOT NULL,
    degree double precision,
    eastwest character varying(1) DEFAULT ''::character varying NOT NULL,
    foot double precision,
    topoint text DEFAULT ''::text NOT NULL,
    curveleftright character varying(5) DEFAULT ''::character varying NOT NULL,
    curveradiusfoot double precision,
    curvetangent smallint DEFAULT (0)::smallint NOT NULL,
    manualxchange double precision,
    manualychange double precision,
    metesdescriptionlinenotes text DEFAULT ''::text NOT NULL,
    curveinternalangle double precision,
    CONSTRAINT metesdescriptionline_curvetangent_check CHECK (((curvetangent = 0) OR (curvetangent = 1) OR (curvetangent = '-1'::integer))),
    CONSTRAINT metesdescriptionline_degree_check CHECK ((degree <> (0)::double precision)),
    CONSTRAINT metesdescriptionline_eastwest_check CHECK (((eastwest)::text = ANY (ARRAY[('E'::character varying)::text, ('W'::character varying)::text, (''::character varying)::text]))),
    CONSTRAINT metesdescriptionline_manualxchange_check CHECK ((manualxchange <> (0)::double precision)),
    CONSTRAINT metesdescriptionline_northsouth_check CHECK (((northsouth)::text = ANY (ARRAY[('N'::character varying)::text, ('S'::character varying)::text, (''::character varying)::text])))
);


ALTER TABLE geohistory.metesdescriptionline OWNER TO postgres;

--
-- Name: researchlog; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.researchlog (
    researchlogid integer NOT NULL,
    government integer NOT NULL,
    researchlogtype integer NOT NULL,
    researchlogdate calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    researchlogvolumefrom character varying(100) DEFAULT ''::character varying NOT NULL,
    researchlogfrom character varying(5) DEFAULT ''::character varying NOT NULL,
    researchlogvolumeto character varying(100) DEFAULT ''::character varying NOT NULL,
    researchlogto character varying(5) DEFAULT ''::character varying NOT NULL,
    researchlogismissing boolean DEFAULT false NOT NULL,
    researchlognotes text DEFAULT ''::text NOT NULL,
    researchlogdisposition character varying(2) DEFAULT ''::character varying NOT NULL,
    event integer,
    CONSTRAINT researchlog_check CHECK (((((researchlogfrom)::text = ''::text) AND ((researchlogto)::text = ''::text)) OR (((researchlogfrom)::text <> ''::text) AND ((researchlogto)::text <> ''::text) AND ((researchlogvolumefrom)::text = ''::text) AND ((researchlogvolumeto)::text = ''::text)) OR (((researchlogvolumefrom)::text <> ''::text) AND ((researchlogvolumeto)::text <> ''::text))))
);


ALTER TABLE geohistory.researchlog OWNER TO postgres;

--
-- Name: COLUMN researchlog.researchlogismissing; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.researchlog.researchlogismissing IS 'Rows with TRUE values are used for internal tracking purposes, and are not included in open data.';


--
-- Name: COLUMN researchlog.researchlogdisposition; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.researchlog.researchlogdisposition IS 'This field is used for internal tracking purposes, and is not included in open data. Request response dispositions:
d = Agency denied request; 
i = Some records requested received; 
n = No records requested received; 
r = Agency refused to respond to request; 
w = Request withdrawn; 
y = All records requested received.
Record status dispositions:
a = All remaining records obtained from alternate sources; 
c = All ordinances in code obtained, or good faith investigation through 1974 or through other sources done; 
o = No follow-up necessary; 
p = Some records obtained from alternate sources; 
x = No records obtained from alternate sources.';


--
-- Name: COLUMN researchlog.event; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.researchlog.event IS 'Items where this field is populated are not included in open data.';


--
-- Name: researchlogtype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.researchlogtype (
    researchlogtypeid integer NOT NULL,
    researchlogtypelong character varying(80) NOT NULL,
    researchlogtypelongpart text DEFAULT ''::text NOT NULL,
    researchlogtypeisrecord boolean DEFAULT false NOT NULL,
    researchlogtypeisspecificdate boolean DEFAULT false NOT NULL,
    CONSTRAINT researchlogtype_check CHECK (((researchlogtypelong)::text <> ''::text))
);


ALTER TABLE geohistory.researchlogtype OWNER TO postgres;

--
-- Name: COLUMN researchlogtype.researchlogtypelongpart; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.researchlogtype.researchlogtypelongpart IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN researchlogtype.researchlogtypeisrecord; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.researchlogtype.researchlogtypeisrecord IS 'Rows with FALSE values are used for internal tracking purposes, and are not included in open data.';


--
-- Name: recording; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.recording (
    recordingid integer NOT NULL,
    recordingoffice integer NOT NULL,
    recordingvolume character varying(50) DEFAULT ''::character varying NOT NULL,
    recordingpage bigint,
    recordingpagetext character varying(25) DEFAULT ''::character varying NOT NULL,
    recordingdescription text DEFAULT ''::character varying NOT NULL,
    recordingdate calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    recordingrepositorylevel integer,
    recordingrepositoryshort character varying(30) DEFAULT ''::text NOT NULL,
    recordingrepositoryitemnumber character varying(10) DEFAULT ''::text NOT NULL,
    recordingrepositoryitemfrom integer,
    recordingrepositoryitemto integer,
    recordingrepositoryitemlocation character varying(25) DEFAULT ''::character varying NOT NULL,
    recordingrepositoryextractdate calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    recordingrepositoryorder smallint,
    recordingrepositoryentry character varying(75) DEFAULT ''::text NOT NULL,
    recordingisrelevant character varying(1) DEFAULT ''::character varying NOT NULL,
    recordingobtainedcopy character varying(1) DEFAULT ''::character varying NOT NULL,
    recordingtype integer,
    recordingnumbertype integer,
    recordingnumber bigint,
    recordingnumbertext character varying(25) DEFAULT ''::character varying NOT NULL,
    recordingvolumeofficerinitials character varying(10) DEFAULT ''::character varying NOT NULL,
    recordingrepositoryseries character varying(50) DEFAULT ''::character varying NOT NULL,
    recordingrepositorycontainer character varying(50) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE geohistory.recording OWNER TO postgres;

--
-- Name: COLUMN recording.recordingdescription; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.recording.recordingdescription IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN recording.recordingrepositoryshort; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.recording.recordingrepositoryshort IS 'Conform with new abbreviations as of 2018-01-31';


--
-- Name: COLUMN recording.recordingrepositoryitemfrom; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.recording.recordingrepositoryitemfrom IS 'For instances where this field is used for internal tracking purposes, particular values may be omitted in open data.';


--
-- Name: COLUMN recording.recordingrepositoryitemto; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.recording.recordingrepositoryitemto IS 'For instances where this field is used for internal tracking purposes, particular values may be omitted in open data.';


--
-- Name: COLUMN recording.recordingisrelevant; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.recording.recordingisrelevant IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN recording.recordingobtainedcopy; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.recording.recordingobtainedcopy IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: recordingevent; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.recordingevent (
    recordingeventid integer NOT NULL,
    event integer NOT NULL,
    recording integer NOT NULL,
    recordingeventinclude boolean,
    eventrelationship integer NOT NULL,
    CONSTRAINT recordingevent_check CHECK ((eventrelationship <> ALL (ARRAY[6, 7, 9])))
);


ALTER TABLE geohistory.recordingevent OWNER TO postgres;

--
-- Name: recordingoffice; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.recordingoffice (
    recordingofficeid integer NOT NULL,
    government integer NOT NULL,
    recordingofficetype integer NOT NULL,
    recordingofficedistrictcircuit character varying(2) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE geohistory.recordingoffice OWNER TO postgres;

--
-- Name: recordingtype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.recordingtype (
    recordingtypeid integer NOT NULL,
    recordingtypetype character varying(20) DEFAULT 'Book'::text NOT NULL,
    recordingtypeabbreviation character varying(45) NOT NULL,
    recordingtypelong character varying(45) NOT NULL,
    recordingtypeshort character varying(25) NOT NULL,
    recordingtypevolumetype character varying(15) DEFAULT 'Volume'::text NOT NULL,
    recordingtypepagetype character varying(10) DEFAULT 'Page'::text NOT NULL,
    recordingisnumber boolean DEFAULT false NOT NULL,
    CONSTRAINT recordingtype_check CHECK ((((recordingtypeabbreviation)::text <> ''::text) AND ((recordingtypelong)::text <> ''::text) AND ((recordingtypeshort)::text <> ''::text)))
);


ALTER TABLE geohistory.recordingtype OWNER TO postgres;

--
-- Name: sourcecitationnote; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.sourcecitationnote (
    sourcecitationnoteid integer NOT NULL,
    sourcecitation integer NOT NULL,
    sourcecitationnotegroup integer,
    sourcecitationnotetype integer NOT NULL,
    sourcecitationnotetext text NOT NULL
);


ALTER TABLE geohistory.sourcecitationnote OWNER TO postgres;

--
-- Name: sourcecitationnotetype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.sourcecitationnotetype (
    sourcecitationnotetypeid integer NOT NULL,
    source integer,
    sourcecitationnotetypeisdetail boolean DEFAULT true NOT NULL,
    sourcecitationnotetypetext text NOT NULL
);


ALTER TABLE geohistory.sourcecitationnotetype OWNER TO postgres;

--
-- Name: COLUMN sourcecitationnotetype.sourcecitationnotetypeisdetail; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.sourcecitationnotetype.sourcecitationnotetypeisdetail IS 'Rows with FALSE values are used for internal tracking purposes, and are not included in open data.';


--
-- Name: lawgroup; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.lawgroup (
    lawgroupid integer NOT NULL,
    government integer NOT NULL,
    lawgrouplong character varying(100) NOT NULL,
    lawgroupfrom integer NOT NULL,
    lawgroupto integer DEFAULT 9999 NOT NULL,
    eventeffectivetype integer DEFAULT 61 NOT NULL,
    lawgroupcourtname character varying(100) DEFAULT ''::character varying NOT NULL,
    lawgrouprecording boolean,
    lawgroupsecretaryofstate boolean,
    lawgroupplanningagency boolean,
    lawgroupprocedure text DEFAULT ''::text NOT NULL,
    lawgroupgroup text DEFAULT ''::text NOT NULL,
    lawgroupsectionlead text DEFAULT ''::text NOT NULL
);


ALTER TABLE geohistory.lawgroup OWNER TO postgres;

--
-- Name: COLUMN lawgroup.eventeffectivetype; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.lawgroup.eventeffectivetype IS 'This field is used for internal tracking purposes, and only a placeholder value is included in open data.';


--
-- Name: COLUMN lawgroup.lawgroupcourtname; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.lawgroup.lawgroupcourtname IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN lawgroup.lawgrouprecording; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.lawgroup.lawgrouprecording IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN lawgroup.lawgroupsecretaryofstate; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.lawgroup.lawgroupsecretaryofstate IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN lawgroup.lawgroupplanningagency; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.lawgroup.lawgroupplanningagency IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN lawgroup.lawgroupprocedure; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.lawgroup.lawgroupprocedure IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN lawgroup.lawgroupgroup; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.lawgroup.lawgroupgroup IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN lawgroup.lawgroupsectionlead; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.lawgroup.lawgroupsectionlead IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: lawgroupsection; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.lawgroupsection (
    lawgroupsectionid integer NOT NULL,
    lawgroupsectionorder integer NOT NULL,
    lawgroup integer NOT NULL,
    lawsection integer NOT NULL,
    eventrelationship integer NOT NULL,
    CONSTRAINT lawgroupsection_check CHECK ((eventrelationship <> ALL (ARRAY[1, 2, 3])))
);


ALTER TABLE geohistory.lawgroupsection OWNER TO postgres;

--
-- Name: lawgroupgovernmenttype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.lawgroupgovernmenttype (
    lawgroupgovernmenttypeid integer NOT NULL,
    lawgroup integer NOT NULL,
    governmenttype character varying(30) NOT NULL,
    CONSTRAINT lawgroupgovernmenttype_check CHECK (((governmenttype)::text = ANY ('{All,Borough,City,County,Plantation,Town,Township,Village}'::text[])))
);


ALTER TABLE geohistory.lawgroupgovernmenttype OWNER TO postgres;

--
-- Name: adjudication_adjudicationid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.adjudication_adjudicationid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.adjudication_adjudicationid_seq OWNER TO postgres;

--
-- Name: adjudication_adjudicationid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.adjudication_adjudicationid_seq OWNED BY geohistory.adjudication.adjudicationid;


--
-- Name: adjudicationevent_adjudicationeventid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.adjudicationevent_adjudicationeventid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.adjudicationevent_adjudicationeventid_seq OWNER TO postgres;

--
-- Name: adjudicationevent_adjudicationeventid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.adjudicationevent_adjudicationeventid_seq OWNED BY geohistory.adjudicationevent.adjudicationeventid;


--
-- Name: adjudicationlocation_adjudicationlocationid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.adjudicationlocation_adjudicationlocationid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.adjudicationlocation_adjudicationlocationid_seq OWNER TO postgres;

--
-- Name: adjudicationlocation_adjudicationlocationid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.adjudicationlocation_adjudicationlocationid_seq OWNED BY geohistory.adjudicationlocation.adjudicationlocationid;


--
-- Name: adjudicationlocationtype_adjudicationlocationtypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.adjudicationlocationtype_adjudicationlocationtypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.adjudicationlocationtype_adjudicationlocationtypeid_seq OWNER TO postgres;

--
-- Name: adjudicationlocationtype_adjudicationlocationtypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.adjudicationlocationtype_adjudicationlocationtypeid_seq OWNED BY geohistory.adjudicationlocationtype.adjudicationlocationtypeid;


--
-- Name: adjudicationsourcecitation_adjudicationsourcecitationid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.adjudicationsourcecitation_adjudicationsourcecitationid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.adjudicationsourcecitation_adjudicationsourcecitationid_seq OWNER TO postgres;

--
-- Name: adjudicationsourcecitation_adjudicationsourcecitationid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.adjudicationsourcecitation_adjudicationsourcecitationid_seq OWNED BY geohistory.adjudicationsourcecitation.adjudicationsourcecitationid;


--
-- Name: adjudicationtype_adjudicationtypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.adjudicationtype_adjudicationtypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.adjudicationtype_adjudicationtypeid_seq OWNER TO postgres;

--
-- Name: adjudicationtype_adjudicationtypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.adjudicationtype_adjudicationtypeid_seq OWNED BY geohistory.adjudicationtype.adjudicationtypeid;


--
-- Name: affectedgovernmentgroup_affectedgovernmentgroupid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.affectedgovernmentgroup_affectedgovernmentgroupid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.affectedgovernmentgroup_affectedgovernmentgroupid_seq OWNER TO postgres;

--
-- Name: affectedgovernmentgroup_affectedgovernmentgroupid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.affectedgovernmentgroup_affectedgovernmentgroupid_seq OWNED BY geohistory.affectedgovernmentgroup.affectedgovernmentgroupid;


--
-- Name: affectedgovernmentgrouppart_affectedgovernmentgrouppartid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.affectedgovernmentgrouppart_affectedgovernmentgrouppartid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.affectedgovernmentgrouppart_affectedgovernmentgrouppartid_seq OWNER TO postgres;

--
-- Name: affectedgovernmentgrouppart_affectedgovernmentgrouppartid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.affectedgovernmentgrouppart_affectedgovernmentgrouppartid_seq OWNED BY geohistory.affectedgovernmentgrouppart.affectedgovernmentgrouppartid;


--
-- Name: affectedgovernmentlevel_affectedgovernmentlevelid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.affectedgovernmentlevel_affectedgovernmentlevelid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.affectedgovernmentlevel_affectedgovernmentlevelid_seq OWNER TO postgres;

--
-- Name: affectedgovernmentlevel_affectedgovernmentlevelid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.affectedgovernmentlevel_affectedgovernmentlevelid_seq OWNED BY geohistory.affectedgovernmentlevel.affectedgovernmentlevelid;


--
-- Name: affectedgovernmentpart_affectedgovernmentpartid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.affectedgovernmentpart_affectedgovernmentpartid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.affectedgovernmentpart_affectedgovernmentpartid_seq OWNER TO postgres;

--
-- Name: affectedgovernmentpart_affectedgovernmentpartid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.affectedgovernmentpart_affectedgovernmentpartid_seq OWNED BY geohistory.affectedgovernmentpart.affectedgovernmentpartid;


--
-- Name: affectedtype_affectedtypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.affectedtype_affectedtypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.affectedtype_affectedtypeid_seq OWNER TO postgres;

--
-- Name: affectedtype_affectedtypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.affectedtype_affectedtypeid_seq OWNED BY geohistory.affectedtype.affectedtypeid;


--
-- Name: censusmap; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.censusmap (
    censusmapid integer NOT NULL,
    censusmapyear smallint NOT NULL,
    government integer NOT NULL,
    censusmapgovernmentname character varying(50) DEFAULT ''::character varying NOT NULL,
    censusmapexamined boolean DEFAULT false NOT NULL,
    censusmapmin boolean DEFAULT false NOT NULL,
    censusmapmax boolean DEFAULT false NOT NULL,
    censusmap1950pertinent boolean DEFAULT false NOT NULL,
    censusmap1960pertinent boolean DEFAULT false NOT NULL,
    censusmap1970pertinent boolean DEFAULT false NOT NULL
);


ALTER TABLE geohistory.censusmap OWNER TO postgres;

--
-- Name: COLUMN censusmap.censusmapexamined; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.censusmap.censusmapexamined IS 'This field is used for internal tracking purposes, and is always shown as the default value in open data.';


--
-- Name: COLUMN censusmap.censusmap1950pertinent; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.censusmap.censusmap1950pertinent IS 'This field is used for internal tracking purposes, and is always shown as the default value in open data.';


--
-- Name: COLUMN censusmap.censusmap1960pertinent; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.censusmap.censusmap1960pertinent IS 'This field is used for internal tracking purposes, and is always shown as the default value in open data.';


--
-- Name: COLUMN censusmap.censusmap1970pertinent; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.censusmap.censusmap1970pertinent IS 'This field is used for internal tracking purposes, and is always shown as the default value in open data.';


--
-- Name: censusmap_censusmapid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.censusmap_censusmapid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.censusmap_censusmapid_seq OWNER TO postgres;

--
-- Name: censusmap_censusmapid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.censusmap_censusmapid_seq OWNED BY geohistory.censusmap.censusmapid;


--
-- Name: currentgovernment_currentgovernmentid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.currentgovernment_currentgovernmentid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.currentgovernment_currentgovernmentid_seq OWNER TO postgres;

--
-- Name: currentgovernment_currentgovernmentid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.currentgovernment_currentgovernmentid_seq OWNED BY geohistory.currentgovernment.currentgovernmentid;


--
-- Name: documentation; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.documentation (
    documentationid integer NOT NULL,
    documentationtype character varying(30) NOT NULL,
    documentationshort character varying(15) NOT NULL,
    documentationlong text NOT NULL,
    documentationcolor character varying(40) DEFAULT ''::character varying NOT NULL,
    documentationlocale character varying(2) DEFAULT 'en'::character varying NOT NULL,
    CONSTRAINT documentation_check CHECK ((((documentationtype)::text <> ''::text) AND (documentationlong <> ''::text)))
);


ALTER TABLE geohistory.documentation OWNER TO postgres;

--
-- Name: documentation_documentationid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.documentation_documentationid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.documentation_documentationid_seq OWNER TO postgres;

--
-- Name: documentation_documentationid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.documentation_documentationid_seq OWNED BY geohistory.documentation.documentationid;


--
-- Name: event_eventid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.event_eventid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.event_eventid_seq OWNER TO postgres;

--
-- Name: event_eventid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.event_eventid_seq OWNED BY geohistory.event.eventid;


--
-- Name: eventeffectivetype_eventeffectivetypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.eventeffectivetype_eventeffectivetypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.eventeffectivetype_eventeffectivetypeid_seq OWNER TO postgres;

--
-- Name: eventeffectivetype_eventeffectivetypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.eventeffectivetype_eventeffectivetypeid_seq OWNED BY geohistory.eventeffectivetype.eventeffectivetypeid;


--
-- Name: eventgranted_eventgrantedid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.eventgranted_eventgrantedid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.eventgranted_eventgrantedid_seq OWNER TO postgres;

--
-- Name: eventgranted_eventgrantedid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.eventgranted_eventgrantedid_seq OWNED BY geohistory.eventgranted.eventgrantedid;


--
-- Name: eventmethod; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.eventmethod (
    eventmethodid integer NOT NULL,
    eventmethodlong character varying(60) NOT NULL,
    CONSTRAINT eventmethod_check CHECK (((eventmethodlong)::text <> ''::text))
);


ALTER TABLE geohistory.eventmethod OWNER TO postgres;

--
-- Name: eventmethod_eventmethodid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.eventmethod_eventmethodid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.eventmethod_eventmethodid_seq OWNER TO postgres;

--
-- Name: eventmethod_eventmethodid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.eventmethod_eventmethodid_seq OWNED BY geohistory.eventmethod.eventmethodid;


--
-- Name: eventrelationship_eventrelationshipid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.eventrelationship_eventrelationshipid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.eventrelationship_eventrelationshipid_seq OWNER TO postgres;

--
-- Name: eventrelationship_eventrelationshipid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.eventrelationship_eventrelationshipid_seq OWNED BY geohistory.eventrelationship.eventrelationshipid;


--
-- Name: eventslugretired_eventslugretiredid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.eventslugretired_eventslugretiredid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.eventslugretired_eventslugretiredid_seq OWNER TO postgres;

--
-- Name: eventslugretired_eventslugretiredid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.eventslugretired_eventslugretiredid_seq OWNED BY geohistory.eventslugretired.eventslugretiredid;


--
-- Name: eventtype_eventtypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.eventtype_eventtypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.eventtype_eventtypeid_seq OWNER TO postgres;

--
-- Name: eventtype_eventtypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.eventtype_eventtypeid_seq OWNED BY geohistory.eventtype.eventtypeid;


--
-- Name: filing; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.filing (
    filingid integer NOT NULL,
    filingtype integer NOT NULL,
    filingspecific text DEFAULT ''::text NOT NULL,
    filingnotpresent character varying(30) DEFAULT ''::character varying NOT NULL,
    filingdate calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    filingfiled calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    filingother calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    filingothertype character varying(50) DEFAULT ''::character varying NOT NULL,
    filingnotes text DEFAULT ''::text NOT NULL,
    adjudication integer NOT NULL
);


ALTER TABLE geohistory.filing OWNER TO postgres;

--
-- Name: COLUMN filing.filingnotpresent; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.filing.filingnotpresent IS 'Rows with this field populated are used for internal tracking purposes, and are not included in open data.';


--
-- Name: filing_filingid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.filing_filingid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.filing_filingid_seq OWNER TO postgres;

--
-- Name: filing_filingid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.filing_filingid_seq OWNED BY geohistory.filing.filingid;


--
-- Name: filingtype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.filingtype (
    filingtypeid integer NOT NULL,
    filingtypelong character varying(200) NOT NULL,
    filingtypefinalrecording boolean DEFAULT false NOT NULL,
    CONSTRAINT filingtype_check CHECK (((filingtypelong)::text <> ''::text))
);


ALTER TABLE geohistory.filingtype OWNER TO postgres;

--
-- Name: filingtype_filingtypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.filingtype_filingtypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.filingtype_filingtypeid_seq OWNER TO postgres;

--
-- Name: filingtype_filingtypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.filingtype_filingtypeid_seq OWNED BY geohistory.filingtype.filingtypeid;


--
-- Name: government_governmentid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.government_governmentid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.government_governmentid_seq OWNER TO postgres;

--
-- Name: government_governmentid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.government_governmentid_seq OWNED BY geohistory.government.governmentid;


--
-- Name: governmentform_governmentformid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.governmentform_governmentformid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.governmentform_governmentformid_seq OWNER TO postgres;

--
-- Name: governmentform_governmentformid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.governmentform_governmentformid_seq OWNED BY geohistory.governmentform.governmentformid;


--
-- Name: governmentformgovernment; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.governmentformgovernment (
    governmentformgovernmentid integer NOT NULL,
    government integer NOT NULL,
    governmentform integer,
    governmentformgovernmentyear integer NOT NULL,
    governmentformgovernmentpage character varying(4) DEFAULT ''::character varying NOT NULL,
    governmentformgovernmentnotes text DEFAULT ''::text NOT NULL,
    governmentformgovernmenteffective calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL
);


ALTER TABLE geohistory.governmentformgovernment OWNER TO postgres;

--
-- Name: COLUMN governmentformgovernment.governmentformgovernmentnotes; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.governmentformgovernment.governmentformgovernmentnotes IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: governmentformgovernment_governmentformgovernmentid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.governmentformgovernment_governmentformgovernmentid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.governmentformgovernment_governmentformgovernmentid_seq OWNER TO postgres;

--
-- Name: governmentformgovernment_governmentformgovernmentid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.governmentformgovernment_governmentformgovernmentid_seq OWNED BY geohistory.governmentformgovernment.governmentformgovernmentid;


--
-- Name: governmentidentifier_governmentidentifierid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.governmentidentifier_governmentidentifierid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.governmentidentifier_governmentidentifierid_seq OWNER TO postgres;

--
-- Name: governmentidentifier_governmentidentifierid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.governmentidentifier_governmentidentifierid_seq OWNED BY geohistory.governmentidentifier.governmentidentifierid;


--
-- Name: governmentidentifiertype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.governmentidentifiertype (
    governmentidentifiertypeid integer NOT NULL,
    governmentidentifiertypetype character varying(20) NOT NULL,
    governmentidentifiertypeshort character varying(200) NOT NULL,
    source integer,
    isinteger boolean DEFAULT true NOT NULL,
    governmentidentifiertypeurl text DEFAULT ''::text NOT NULL,
    governmentidentifiertypeslug text,
    governmentidentifiertypeprefixdelimiter character varying(1) DEFAULT ''::character varying NOT NULL,
    governmentidentifiertypenote text DEFAULT ''::text NOT NULL,
    governmentidentifiertypeprefixlengthfrom integer,
    governmentidentifiertypeprefixlengthto integer,
    governmentidentifiertypelengthfrom integer,
    governmentidentifiertypelengthto integer,
    CONSTRAINT governmentidentifiertype_check CHECK (((governmentidentifiertypeshort)::text <> ''::text))
);


ALTER TABLE geohistory.governmentidentifiertype OWNER TO postgres;

--
-- Name: governmentidentifiertype_governmentidentifiertypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.governmentidentifiertype_governmentidentifiertypeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.governmentidentifiertype_governmentidentifiertypeid_seq OWNER TO postgres;

--
-- Name: governmentidentifiertype_governmentidentifiertypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.governmentidentifiertype_governmentidentifiertypeid_seq OWNED BY geohistory.governmentidentifiertype.governmentidentifiertypeid;


--
-- Name: governmentmapstatus_governmentmapstatusid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.governmentmapstatus_governmentmapstatusid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.governmentmapstatus_governmentmapstatusid_seq OWNER TO postgres;

--
-- Name: governmentmapstatus_governmentmapstatusid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.governmentmapstatus_governmentmapstatusid_seq OWNED BY geohistory.governmentmapstatus.governmentmapstatusid;


--
-- Name: governmentothercurrentparent_governmentothercurrentparentid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.governmentothercurrentparent_governmentothercurrentparentid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.governmentothercurrentparent_governmentothercurrentparentid_seq OWNER TO postgres;

--
-- Name: governmentothercurrentparent_governmentothercurrentparentid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.governmentothercurrentparent_governmentothercurrentparentid_seq OWNED BY geohistory.governmentothercurrentparent.governmentothercurrentparentid;


--
-- Name: governmentsource_governmentsourceid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.governmentsource_governmentsourceid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.governmentsource_governmentsourceid_seq OWNER TO postgres;

--
-- Name: governmentsource_governmentsourceid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.governmentsource_governmentsourceid_seq OWNED BY geohistory.governmentsource.governmentsourceid;


--
-- Name: governmentsourceevent_governmentsourceeventid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.governmentsourceevent_governmentsourceeventid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.governmentsourceevent_governmentsourceeventid_seq OWNER TO postgres;

--
-- Name: governmentsourceevent_governmentsourceeventid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.governmentsourceevent_governmentsourceeventid_seq OWNED BY geohistory.governmentsourceevent.governmentsourceeventid;


--
-- Name: law_lawid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.law_lawid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.law_lawid_seq OWNER TO postgres;

--
-- Name: law_lawid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.law_lawid_seq OWNED BY geohistory.law.lawid;


--
-- Name: lawalternate; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.lawalternate (
    lawalternateid integer NOT NULL,
    law integer NOT NULL,
    source integer NOT NULL,
    lawalternatevolume character varying(20) DEFAULT ''::character varying NOT NULL,
    lawalternatepage smallint NOT NULL,
    lawalternatenumberchapter smallint NOT NULL,
    lawalternatetype character varying(20) DEFAULT ''::character varying NOT NULL,
    lawalternateurl text DEFAULT ''::text NOT NULL
);


ALTER TABLE geohistory.lawalternate OWNER TO postgres;

--
-- Name: lawalternate_lawalternateid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.lawalternate_lawalternateid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.lawalternate_lawalternateid_seq OWNER TO postgres;

--
-- Name: lawalternate_lawalternateid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.lawalternate_lawalternateid_seq OWNED BY geohistory.lawalternate.lawalternateid;


--
-- Name: lawalternatesection_lawalternatesectionid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.lawalternatesection_lawalternatesectionid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.lawalternatesection_lawalternatesectionid_seq OWNER TO postgres;

--
-- Name: lawalternatesection_lawalternatesectionid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.lawalternatesection_lawalternatesectionid_seq OWNED BY geohistory.lawalternatesection.lawalternatesectionid;


--
-- Name: lawgroup_lawgroupid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.lawgroup_lawgroupid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.lawgroup_lawgroupid_seq OWNER TO postgres;

--
-- Name: lawgroup_lawgroupid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.lawgroup_lawgroupid_seq OWNED BY geohistory.lawgroup.lawgroupid;


--
-- Name: lawgroupeventtype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.lawgroupeventtype (
    lawgroupeventtypeid integer NOT NULL,
    lawgroup integer NOT NULL,
    eventtype integer NOT NULL
);


ALTER TABLE geohistory.lawgroupeventtype OWNER TO postgres;

--
-- Name: lawgroupeventtype_lawgroupeventtypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.lawgroupeventtype_lawgroupeventtypeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.lawgroupeventtype_lawgroupeventtypeid_seq OWNER TO postgres;

--
-- Name: lawgroupeventtype_lawgroupeventtypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.lawgroupeventtype_lawgroupeventtypeid_seq OWNED BY geohistory.lawgroupeventtype.lawgroupeventtypeid;


--
-- Name: lawgroupgovernmenttype_lawgroupgovernmenttypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.lawgroupgovernmenttype_lawgroupgovernmenttypeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.lawgroupgovernmenttype_lawgroupgovernmenttypeid_seq OWNER TO postgres;

--
-- Name: lawgroupgovernmenttype_lawgroupgovernmenttypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.lawgroupgovernmenttype_lawgroupgovernmenttypeid_seq OWNED BY geohistory.lawgroupgovernmenttype.lawgroupgovernmenttypeid;


--
-- Name: lawgroupsection_lawgroupsectionid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.lawgroupsection_lawgroupsectionid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.lawgroupsection_lawgroupsectionid_seq OWNER TO postgres;

--
-- Name: lawgroupsection_lawgroupsectionid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.lawgroupsection_lawgroupsectionid_seq OWNED BY geohistory.lawgroupsection.lawgroupsectionid;


--
-- Name: lawsection_lawsectionid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.lawsection_lawsectionid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.lawsection_lawsectionid_seq OWNER TO postgres;

--
-- Name: lawsection_lawsectionid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.lawsection_lawsectionid_seq OWNED BY geohistory.lawsection.lawsectionid;


--
-- Name: lawsectionevent_lawsectioneventid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.lawsectionevent_lawsectioneventid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.lawsectionevent_lawsectioneventid_seq OWNER TO postgres;

--
-- Name: lawsectionevent_lawsectioneventid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.lawsectionevent_lawsectioneventid_seq OWNED BY geohistory.lawsectionevent.lawsectioneventid;


--
-- Name: locale; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.locale (
    localeid character varying(2) NOT NULL,
    localename text NOT NULL,
    localenameenglish text NOT NULL,
    localesupported boolean DEFAULT false NOT NULL
);


ALTER TABLE geohistory.locale OWNER TO postgres;

--
-- Name: metesdescription_metesdescriptionid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.metesdescription_metesdescriptionid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.metesdescription_metesdescriptionid_seq OWNER TO postgres;

--
-- Name: metesdescription_metesdescriptionid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.metesdescription_metesdescriptionid_seq OWNED BY geohistory.metesdescription.metesdescriptionid;


--
-- Name: metesdescriptionline_metesdescriptionlineid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.metesdescriptionline_metesdescriptionlineid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.metesdescriptionline_metesdescriptionlineid_seq OWNER TO postgres;

--
-- Name: metesdescriptionline_metesdescriptionlineid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.metesdescriptionline_metesdescriptionlineid_seq OWNED BY geohistory.metesdescriptionline.metesdescriptionlineid;


--
-- Name: nationalarchives; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.nationalarchives (
    nationalarchivesid integer NOT NULL,
    source integer NOT NULL,
    government integer NOT NULL,
    nationalarchivesgovernmentname text DEFAULT ''::character varying NOT NULL,
    nationalarchivesgovernmenttype character varying(20) DEFAULT ''::character varying NOT NULL,
    nationalarchivesunit integer NOT NULL,
    nationalarchivesunitfrom integer NOT NULL,
    nationalarchivesunitto integer NOT NULL,
    nationalarchivesexamined boolean DEFAULT false NOT NULL,
    nationalarchivesset character varying(10) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE geohistory.nationalarchives OWNER TO postgres;

--
-- Name: nationalarchives_nationalarchivesid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.nationalarchives_nationalarchivesid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.nationalarchives_nationalarchivesid_seq OWNER TO postgres;

--
-- Name: nationalarchives_nationalarchivesid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.nationalarchives_nationalarchivesid_seq OWNED BY geohistory.nationalarchives.nationalarchivesid;


--
-- Name: plss; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.plss (
    plssid integer NOT NULL,
    plsstownship integer NOT NULL,
    plssfirstdivision integer,
    plssfirstdivisionnumber character varying(10) DEFAULT ''::character varying NOT NULL,
    plssfirstdivisionduplicate character varying(1) DEFAULT '0'::character varying NOT NULL,
    plssfirstdivisionpart text DEFAULT ''::text NOT NULL,
    plssseconddivision integer,
    plssseconddivisionnumber character varying(50) DEFAULT ''::character varying NOT NULL,
    plssseconddivisionsuffix character varying(10) DEFAULT ''::character varying NOT NULL,
    plssseconddivisionnote character varying(50) DEFAULT ''::character varying NOT NULL,
    plssspecialsurvey integer,
    plssspecialsurveynumber character varying(50) DEFAULT ''::character varying NOT NULL,
    plssspecialsurveysuffix character varying(5) DEFAULT ''::character varying NOT NULL,
    plssspecialsurveynote character varying(50) DEFAULT ''::character varying NOT NULL,
    plssspecialsurveydivision character varying(50) DEFAULT ''::character varying NOT NULL,
    event integer NOT NULL,
    plssrelationship character varying(10) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE geohistory.plss OWNER TO postgres;

--
-- Name: COLUMN plss.plssfirstdivision; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.plss.plssfirstdivision IS 'These fields are typically used to indicate Sections.';


--
-- Name: COLUMN plss.plssseconddivision; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.plss.plssseconddivision IS 'These fields are typically used to indicate Quarter Sections.';


--
-- Name: plss_plssid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.plss_plssid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.plss_plssid_seq OWNER TO postgres;

--
-- Name: plss_plssid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.plss_plssid_seq OWNED BY geohistory.plss.plssid;


--
-- Name: plssfirstdivision; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.plssfirstdivision (
    plssfirstdivisionid integer NOT NULL,
    plssfirstdivisionshort character varying(4) NOT NULL,
    plssfirstdivisionlong character varying(200) NOT NULL,
    plssfirstdivisionisdefault boolean DEFAULT false NOT NULL,
    plssfirstdivisionnotes text NOT NULL,
    CONSTRAINT plssfirstdivision_check CHECK ((((plssfirstdivisionlong)::text <> ''::text) AND ((plssfirstdivisionshort)::text <> ''::text) AND (plssfirstdivisionnotes <> ''::text)))
);


ALTER TABLE geohistory.plssfirstdivision OWNER TO postgres;

--
-- Name: TABLE plssfirstdivision; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON TABLE geohistory.plssfirstdivision IS 'Lookup|Derived from "PLSS CadNSDI Standard Domains of Values, October 2014 - Updated May 2015," available on March 21, 2017, at http://nationalcad.org/download/PLSS_CadNSDI_Standard_Domains_of_Values.pdf';


--
-- Name: plssfirstdivision_plssfirstdivisionid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.plssfirstdivision_plssfirstdivisionid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.plssfirstdivision_plssfirstdivisionid_seq OWNER TO postgres;

--
-- Name: plssfirstdivision_plssfirstdivisionid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.plssfirstdivision_plssfirstdivisionid_seq OWNED BY geohistory.plssfirstdivision.plssfirstdivisionid;


--
-- Name: plssfirstdivisionpart; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.plssfirstdivisionpart (
    plssfirstdivisionpartid integer NOT NULL,
    plssfirstdivisionpartshort character varying(10) NOT NULL,
    CONSTRAINT plssfirstdivisionpart_check CHECK (((plssfirstdivisionpartshort)::text <> ''::text))
);


ALTER TABLE geohistory.plssfirstdivisionpart OWNER TO postgres;

--
-- Name: TABLE plssfirstdivisionpart; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON TABLE geohistory.plssfirstdivisionpart IS 'Lookup|This is not derived from PLSS CadNSDI data. These are designed to help standardize input in the plssfirstdivisionpart field.';


--
-- Name: plssfirstdivisionpart_plssfirstdivisionpartid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.plssfirstdivisionpart_plssfirstdivisionpartid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.plssfirstdivisionpart_plssfirstdivisionpartid_seq OWNER TO postgres;

--
-- Name: plssfirstdivisionpart_plssfirstdivisionpartid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.plssfirstdivisionpart_plssfirstdivisionpartid_seq OWNED BY geohistory.plssfirstdivisionpart.plssfirstdivisionpartid;


--
-- Name: plssmeridian; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.plssmeridian (
    plssmeridianid integer NOT NULL,
    plssmeridianshort character varying(7) NOT NULL,
    plssmeridianlong character varying(200) NOT NULL,
    plssmeridianisspecialsurvey boolean DEFAULT false NOT NULL,
    plssmeridianomitdescription boolean DEFAULT false NOT NULL,
    CONSTRAINT plssmeridian_check CHECK ((((plssmeridianlong)::text <> ''::text) AND ((plssmeridianshort)::text <> ''::text)))
);


ALTER TABLE geohistory.plssmeridian OWNER TO postgres;

--
-- Name: TABLE plssmeridian; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON TABLE geohistory.plssmeridian IS 'Lookup|Derived from "PLSS CadNSDI Standard Domains of Values, October 2014 - Updated May 2015," available on March 21, 2017, at http://nationalcad.org/download/PLSS_CadNSDI_Standard_Domains_of_Values.pdf, and from Maine "Township Listing and Map Reference," available on March 21, 2017, at http://www.maine.gov/revenue/propertytax/unorganizedterritory/township_map.htm';


--
-- Name: plssmeridian_plssmeridianid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.plssmeridian_plssmeridianid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.plssmeridian_plssmeridianid_seq OWNER TO postgres;

--
-- Name: plssmeridian_plssmeridianid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.plssmeridian_plssmeridianid_seq OWNED BY geohistory.plssmeridian.plssmeridianid;


--
-- Name: plssseconddivision; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.plssseconddivision (
    plssseconddivisionid integer NOT NULL,
    plssseconddivisionshort character varying(4) NOT NULL,
    plssseconddivisionlong character varying(200) NOT NULL,
    plssseconddivisionisdefault boolean DEFAULT false NOT NULL,
    plssseconddivisionnotes text NOT NULL,
    CONSTRAINT plssseconddivision_check CHECK ((((plssseconddivisionlong)::text <> ''::text) AND ((plssseconddivisionshort)::text <> ''::text) AND (plssseconddivisionnotes <> ''::text)))
);


ALTER TABLE geohistory.plssseconddivision OWNER TO postgres;

--
-- Name: TABLE plssseconddivision; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON TABLE geohistory.plssseconddivision IS 'Lookup|Derived from "PLSS CadNSDI Standard Domains of Values, October 2014 - Updated May 2015," available on March 21, 2017, at http://nationalcad.org/download/PLSS_CadNSDI_Standard_Domains_of_Values.pdf';


--
-- Name: plssseconddivision_plssseconddivisionid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.plssseconddivision_plssseconddivisionid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.plssseconddivision_plssseconddivisionid_seq OWNER TO postgres;

--
-- Name: plssseconddivision_plssseconddivisionid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.plssseconddivision_plssseconddivisionid_seq OWNED BY geohistory.plssseconddivision.plssseconddivisionid;


--
-- Name: plssspecialsurvey; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.plssspecialsurvey (
    plssspecialsurveyid integer NOT NULL,
    plssspecialsurveyshort character varying(4) NOT NULL,
    plssspecialsurveylong character varying(200) NOT NULL,
    plssspecialsurveynotes text NOT NULL,
    CONSTRAINT plssspecialsurvey_check CHECK ((((plssspecialsurveylong)::text <> ''::text) AND ((plssspecialsurveyshort)::text <> ''::text) AND (plssspecialsurveynotes <> ''::text)))
);


ALTER TABLE geohistory.plssspecialsurvey OWNER TO postgres;

--
-- Name: TABLE plssspecialsurvey; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON TABLE geohistory.plssspecialsurvey IS 'Lookup|Derived from "PLSS CadNSDI Standard Domains of Values, October 2014 - Updated May 2015," available on March 21, 2017, at http://nationalcad.org/download/PLSS_CadNSDI_Standard_Domains_of_Values.pdf';


--
-- Name: plssspecialsurvey_plssspecialsurveyid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.plssspecialsurvey_plssspecialsurveyid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.plssspecialsurvey_plssspecialsurveyid_seq OWNER TO postgres;

--
-- Name: plssspecialsurvey_plssspecialsurveyid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.plssspecialsurvey_plssspecialsurveyid_seq OWNED BY geohistory.plssspecialsurvey.plssspecialsurveyid;


--
-- Name: plsstownship; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.plsstownship (
    plsstownshipid integer NOT NULL,
    governmentstate integer DEFAULT 1 NOT NULL,
    plssmeridian integer DEFAULT 99 NOT NULL,
    plsstownshipnumber smallint DEFAULT '-1'::integer NOT NULL,
    plsstownshipfraction character varying(10) DEFAULT '0'::character varying NOT NULL,
    plsstownshipdirection character varying(1) DEFAULT '0'::character varying NOT NULL,
    plssrangenumber smallint DEFAULT '-1'::integer NOT NULL,
    plssrangefraction character varying(10) DEFAULT '0'::character varying NOT NULL,
    plssrangedirection character varying(1) DEFAULT '0'::character varying NOT NULL,
    plsstownshipduplicate character varying(1) DEFAULT '0'::character varying NOT NULL,
    plsstownshipfull text GENERATED ALWAYS AS (((((
CASE
    WHEN (plsstownshipnumber = 0) THEN ''::text
    ELSE (plsstownshipnumber)::text
END || (
CASE
    WHEN ((plsstownshipfraction)::text = '2'::text) THEN '.5'::character varying
    WHEN ((plsstownshipfraction)::text = '0'::text) THEN ''::character varying
    ELSE plsstownshipfraction
END)::text) ||
CASE
    WHEN ((plsstownshipdirection)::text = '0'::text) THEN ''::text
    ELSE (' '::text ||
    CASE
        WHEN ((plsstownshipdirection)::text = 'N'::text) THEN 'North'::text
        WHEN ((plsstownshipdirection)::text = 'S'::text) THEN 'South'::text
        WHEN ((plsstownshipdirection)::text = 'E'::text) THEN 'East'::text
        ELSE ''::text
    END)
END) ||
CASE
    WHEN (NOT ((plssrangenumber = 0) AND ((plssrangefraction)::text = '0'::text) AND ((plssrangedirection)::text = '0'::text))) THEN (((', Range '::text ||
    CASE
        WHEN (plssrangenumber = 0) THEN ''::text
        ELSE (plssrangenumber)::text
    END) || (
    CASE
        WHEN ((plssrangefraction)::text = '2'::text) THEN '.5'::character varying
        WHEN ((plssrangefraction)::text = '0'::text) THEN ''::character varying
        ELSE plssrangefraction
    END)::text) ||
    CASE
        WHEN ((plssrangedirection)::text = '0'::text) THEN ''::text
        ELSE (' '::text ||
        CASE
            WHEN ((plssrangedirection)::text = 'E'::text) THEN 'East'::text
            WHEN ((plssrangedirection)::text = 'W'::text) THEN 'West'::text
            WHEN ((plssrangedirection)::text = 'N'::text) THEN 'North'::text
            ELSE ''::text
        END)
    END)
    ELSE ''::text
END) ||
CASE
    WHEN ((plsstownshipduplicate)::text = '0'::text) THEN ''::text
    ELSE (' '::text || (plsstownshipduplicate)::text)
END)) STORED,
    plsstownshipsummary text GENERATED ALWAYS AS (((((
CASE
    WHEN (plsstownshipnumber = 0) THEN ''::text
    ELSE (plsstownshipnumber)::text
END || (
CASE
    WHEN ((plsstownshipfraction)::text = '2'::text) THEN '.5'::character varying
    WHEN ((plsstownshipfraction)::text = '0'::text) THEN ''::character varying
    ELSE plsstownshipfraction
END)::text) || (
CASE
    WHEN ((plsstownshipdirection)::text = '0'::text) THEN ''::character varying
    ELSE plsstownshipdirection
END)::text) ||
CASE
    WHEN (NOT ((plssrangenumber = 0) AND ((plssrangefraction)::text = '0'::text) AND ((plssrangedirection)::text = '0'::text))) THEN (((' R'::text ||
    CASE
        WHEN (plssrangenumber = 0) THEN ''::text
        ELSE (plssrangenumber)::text
    END) || (
    CASE
        WHEN ((plssrangefraction)::text = '2'::text) THEN '.5'::character varying
        WHEN ((plssrangefraction)::text = '0'::text) THEN ''::character varying
        ELSE plssrangefraction
    END)::text) || (
    CASE
        WHEN ((plssrangedirection)::text = '0'::text) THEN ''::character varying
        ELSE plssrangedirection
    END)::text)
    ELSE ''::text
END) ||
CASE
    WHEN ((plsstownshipduplicate)::text = '0'::text) THEN ''::text
    ELSE (' '::text || (plsstownshipduplicate)::text)
END)) STORED
);


ALTER TABLE geohistory.plsstownship OWNER TO postgres;

--
-- Name: COLUMN plsstownship.plsstownshipid; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.plsstownship.plsstownshipid IS 'This id must always match the corresponding governmentid record (which is not linked via foreign key).';


--
-- Name: COLUMN plsstownship.plsstownshipfraction; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.plsstownship.plsstownshipfraction IS 'In Maine, this field used for letter townships.';


--
-- Name: plsstownship_plsstownshipid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.plsstownship_plsstownshipid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.plsstownship_plsstownshipid_seq OWNER TO postgres;

--
-- Name: plsstownship_plsstownshipid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.plsstownship_plsstownshipid_seq OWNED BY geohistory.plsstownship.plsstownshipid;


--
-- Name: recording_recordingid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.recording_recordingid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.recording_recordingid_seq OWNER TO postgres;

--
-- Name: recording_recordingid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.recording_recordingid_seq OWNED BY geohistory.recording.recordingid;


--
-- Name: recordingevent_recordingeventid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.recordingevent_recordingeventid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.recordingevent_recordingeventid_seq OWNER TO postgres;

--
-- Name: recordingevent_recordingeventid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.recordingevent_recordingeventid_seq OWNED BY geohistory.recordingevent.recordingeventid;


--
-- Name: recordingoffice_recordingofficeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.recordingoffice_recordingofficeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.recordingoffice_recordingofficeid_seq OWNER TO postgres;

--
-- Name: recordingoffice_recordingofficeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.recordingoffice_recordingofficeid_seq OWNED BY geohistory.recordingoffice.recordingofficeid;


--
-- Name: recordingofficetype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.recordingofficetype (
    recordingofficetypeid integer NOT NULL,
    recordingofficetypelevel integer NOT NULL,
    recordingofficetypeshort character varying(25) DEFAULT ''::character varying NOT NULL,
    recordingofficetypelong text NOT NULL,
    recordingofficetypedivision character varying(50) DEFAULT ''::character varying NOT NULL,
    recordingofficetypeisaftergovernment boolean DEFAULT false NOT NULL,
    abbreviationverified boolean DEFAULT false NOT NULL,
    CONSTRAINT recordingofficetype_check CHECK ((recordingofficetypelong <> ''::text))
);


ALTER TABLE geohistory.recordingofficetype OWNER TO postgres;

--
-- Name: recordingofficetype_recordingofficetypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.recordingofficetype_recordingofficetypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.recordingofficetype_recordingofficetypeid_seq OWNER TO postgres;

--
-- Name: recordingofficetype_recordingofficetypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.recordingofficetype_recordingofficetypeid_seq OWNED BY geohistory.recordingofficetype.recordingofficetypeid;


--
-- Name: recordingtype_recordingtypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.recordingtype_recordingtypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.recordingtype_recordingtypeid_seq OWNER TO postgres;

--
-- Name: recordingtype_recordingtypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.recordingtype_recordingtypeid_seq OWNED BY geohistory.recordingtype.recordingtypeid;


--
-- Name: researchlog_researchlogid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.researchlog_researchlogid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.researchlog_researchlogid_seq OWNER TO postgres;

--
-- Name: researchlog_researchlogid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.researchlog_researchlogid_seq OWNED BY geohistory.researchlog.researchlogid;


--
-- Name: researchlogtype_researchlogtypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.researchlogtype_researchlogtypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.researchlogtype_researchlogtypeid_seq OWNER TO postgres;

--
-- Name: researchlogtype_researchlogtypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.researchlogtype_researchlogtypeid_seq OWNED BY geohistory.researchlogtype.researchlogtypeid;


--
-- Name: shorttype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.shorttype (
    shorttypeid integer NOT NULL,
    shorttypeisform boolean DEFAULT false NOT NULL,
    shorttypelong character varying(50) NOT NULL,
    shorttypeshort character varying(50) NOT NULL,
    CONSTRAINT shorttype_check CHECK ((((shorttypelong)::text <> ''::text) AND ((shorttypeshort)::text <> ''::text)))
);


ALTER TABLE geohistory.shorttype OWNER TO postgres;

--
-- Name: shorttype_shorttypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.shorttype_shorttypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.shorttype_shorttypeid_seq OWNER TO postgres;

--
-- Name: shorttype_shorttypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.shorttype_shorttypeid_seq OWNED BY geohistory.shorttype.shorttypeid;


--
-- Name: source_sourceid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.source_sourceid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.source_sourceid_seq OWNER TO postgres;

--
-- Name: source_sourceid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.source_sourceid_seq OWNED BY geohistory.source.sourceid;


--
-- Name: sourcecitation_sourcecitationid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.sourcecitation_sourcecitationid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.sourcecitation_sourcecitationid_seq OWNER TO postgres;

--
-- Name: sourcecitation_sourcecitationid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.sourcecitation_sourcecitationid_seq OWNED BY geohistory.sourcecitation.sourcecitationid;


--
-- Name: sourcecitationevent_sourcecitationeventid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.sourcecitationevent_sourcecitationeventid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.sourcecitationevent_sourcecitationeventid_seq OWNER TO postgres;

--
-- Name: sourcecitationevent_sourcecitationeventid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.sourcecitationevent_sourcecitationeventid_seq OWNED BY geohistory.sourcecitationevent.sourcecitationeventid;


--
-- Name: sourcecitationnote_sourcecitationnoteid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.sourcecitationnote_sourcecitationnoteid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.sourcecitationnote_sourcecitationnoteid_seq OWNER TO postgres;

--
-- Name: sourcecitationnote_sourcecitationnoteid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.sourcecitationnote_sourcecitationnoteid_seq OWNED BY geohistory.sourcecitationnote.sourcecitationnoteid;


--
-- Name: sourcecitationnotetype_sourcecitationnotetypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.sourcecitationnotetype_sourcecitationnotetypeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.sourcecitationnotetype_sourcecitationnotetypeid_seq OWNER TO postgres;

--
-- Name: sourcecitationnotetype_sourcecitationnotetypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.sourcecitationnotetype_sourcecitationnotetypeid_seq OWNED BY geohistory.sourcecitationnotetype.sourcecitationnotetypeid;


--
-- Name: sourcegovernment_sourcegovernmentid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.sourcegovernment_sourcegovernmentid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.sourcegovernment_sourcegovernmentid_seq OWNER TO postgres;

--
-- Name: sourcegovernment_sourcegovernmentid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.sourcegovernment_sourcegovernmentid_seq OWNED BY geohistory.sourcegovernment.sourcegovernmentid;


--
-- Name: sourceitem; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.sourceitem (
    sourceitemid integer NOT NULL,
    source integer NOT NULL,
    sourceitemedition character varying(3) DEFAULT ''::character varying NOT NULL,
    sourceitemvolume character varying(20) DEFAULT ''::character varying NOT NULL,
    sourceitemyear smallint,
    sourceitemurl text DEFAULT ''::text NOT NULL,
    sourceitemurlcomplete boolean DEFAULT false NOT NULL,
    sourceitemurlcompletepart boolean DEFAULT true NOT NULL,
    sourceitempublicdomain boolean,
    sourceitempublicdomainreason text DEFAULT ''::text NOT NULL,
    sourceitemreferenceyearfrom smallint,
    sourceitemreferenceyearto smallint,
    sourceitemreferencevolume character varying(20) DEFAULT ''::character varying NOT NULL,
    sourceitemurlafter text DEFAULT ''::text NOT NULL,
    sourceitemlocal boolean DEFAULT false NOT NULL
);


ALTER TABLE geohistory.sourceitem OWNER TO postgres;

--
-- Name: COLUMN sourceitem.sourceitemurlcomplete; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.sourceitem.sourceitemurlcomplete IS 'URL is complete and never requires URL part from sourceitempart table.';


--
-- Name: COLUMN sourceitem.sourceitemurlcompletepart; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.sourceitem.sourceitemurlcompletepart IS 'URL can be accessed without URL part from sourceitempart table.';


--
-- Name: COLUMN sourceitem.sourceitempublicdomain; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.sourceitem.sourceitempublicdomain IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN sourceitem.sourceitempublicdomainreason; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.sourceitem.sourceitempublicdomainreason IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN sourceitem.sourceitemlocal; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.sourceitem.sourceitemlocal IS 'Rows with a TRUE value are omitted from open data, as they reference paths to resources on the local network.';


--
-- Name: sourceitem_sourceitemid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.sourceitem_sourceitemid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.sourceitem_sourceitemid_seq OWNER TO postgres;

--
-- Name: sourceitem_sourceitemid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.sourceitem_sourceitemid_seq OWNED BY geohistory.sourceitem.sourceitemid;


--
-- Name: sourceitemcategory; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.sourceitemcategory (
    sourceitemcategoryid integer NOT NULL,
    sourceitemcategoryshort text DEFAULT ''::text NOT NULL,
    sourceitemcategorydomain text DEFAULT ''::text NOT NULL
);


ALTER TABLE geohistory.sourceitemcategory OWNER TO postgres;

--
-- Name: sourceitemcategory_sourceitemcategoryid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.sourceitemcategory_sourceitemcategoryid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.sourceitemcategory_sourceitemcategoryid_seq OWNER TO postgres;

--
-- Name: sourceitemcategory_sourceitemcategoryid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.sourceitemcategory_sourceitemcategoryid_seq OWNED BY geohistory.sourceitemcategory.sourceitemcategoryid;


--
-- Name: sourceitempart; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.sourceitempart (
    sourceitempartid integer NOT NULL,
    sourceitem integer NOT NULL,
    sourceitempartisbypage boolean DEFAULT true NOT NULL,
    sourceitempartfrom integer,
    sourceitempartto integer,
    sourceitempartsequencecharacter character varying(200) DEFAULT ''::character varying NOT NULL,
    sourceitempartsequence integer DEFAULT 0 NOT NULL,
    sourceitempartsequenceverified boolean DEFAULT false NOT NULL,
    sourceitempartsequencecharacterafter character varying(200) DEFAULT ''::character varying NOT NULL,
    sourceitempartzeropad smallint DEFAULT 0 NOT NULL
);


ALTER TABLE geohistory.sourceitempart OWNER TO postgres;

--
-- Name: sourceitempart_sourceitempartid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.sourceitempart_sourceitempartid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.sourceitempart_sourceitempartid_seq OWNER TO postgres;

--
-- Name: sourceitempart_sourceitempartid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.sourceitempart_sourceitempartid_seq OWNED BY geohistory.sourceitempart.sourceitempartid;


--
-- Name: sourcetype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.sourcetype (
    sourcetypeid integer NOT NULL,
    sourcetypeshort text NOT NULL,
    sourcetypeislaw boolean DEFAULT false NOT NULL
);


ALTER TABLE geohistory.sourcetype OWNER TO postgres;

--
-- Name: sourcetype_sourcetypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.sourcetype_sourcetypeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.sourcetype_sourcetypeid_seq OWNER TO postgres;

--
-- Name: sourcetype_sourcetypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.sourcetype_sourcetypeid_seq OWNED BY geohistory.sourcetype.sourcetypeid;


--
-- Name: tribunal_tribunalid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.tribunal_tribunalid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.tribunal_tribunalid_seq OWNER TO postgres;

--
-- Name: tribunal_tribunalid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.tribunal_tribunalid_seq OWNED BY geohistory.tribunal.tribunalid;


--
-- Name: tribunaltype_tribunaltypeid_seq; Type: SEQUENCE; Schema: geohistory; Owner: postgres
--

CREATE SEQUENCE geohistory.tribunaltype_tribunaltypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geohistory.tribunaltype_tribunaltypeid_seq OWNER TO postgres;

--
-- Name: tribunaltype_tribunaltypeid_seq; Type: SEQUENCE OWNED BY; Schema: geohistory; Owner: postgres
--

ALTER SEQUENCE geohistory.tribunaltype_tribunaltypeid_seq OWNED BY geohistory.tribunaltype.tribunaltypeid;


--
-- Name: affectedgovernmentgis_affectedgovernmentgisid_seq; Type: SEQUENCE; Schema: gis; Owner: postgres
--

CREATE SEQUENCE gis.affectedgovernmentgis_affectedgovernmentgisid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE gis.affectedgovernmentgis_affectedgovernmentgisid_seq OWNER TO postgres;

--
-- Name: affectedgovernmentgis_affectedgovernmentgisid_seq; Type: SEQUENCE OWNED BY; Schema: gis; Owner: postgres
--

ALTER SEQUENCE gis.affectedgovernmentgis_affectedgovernmentgisid_seq OWNED BY gis.affectedgovernmentgis.affectedgovernmentgisid;


--
-- Name: deleted_affectedgovernmentgis; Type: TABLE; Schema: gis; Owner: postgres
--

CREATE TABLE gis.deleted_affectedgovernmentgis (
    deleted_affectedgovernmentgisid integer NOT NULL,
    affectedgovernment integer NOT NULL,
    governmentshape integer,
    deletedat timestamp with time zone DEFAULT now()
);


ALTER TABLE gis.deleted_affectedgovernmentgis OWNER TO postgres;

--
-- Name: TABLE deleted_affectedgovernmentgis; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON TABLE gis.deleted_affectedgovernmentgis IS 'This table is only a temporary data store, and will have no data to export to open data.';


--
-- Name: deleted_affectedgovernmentgis_deleted_affectedgovernmentgis_seq; Type: SEQUENCE; Schema: gis; Owner: postgres
--

CREATE SEQUENCE gis.deleted_affectedgovernmentgis_deleted_affectedgovernmentgis_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE gis.deleted_affectedgovernmentgis_deleted_affectedgovernmentgis_seq OWNER TO postgres;

--
-- Name: deleted_affectedgovernmentgis_deleted_affectedgovernmentgis_seq; Type: SEQUENCE OWNED BY; Schema: gis; Owner: postgres
--

ALTER SEQUENCE gis.deleted_affectedgovernmentgis_deleted_affectedgovernmentgis_seq OWNED BY gis.deleted_affectedgovernmentgis.deleted_affectedgovernmentgisid;


--
-- Name: deleted_metesdescriptiongis; Type: TABLE; Schema: gis; Owner: postgres
--

CREATE TABLE gis.deleted_metesdescriptiongis (
    deleted_metesdescriptiongisid integer NOT NULL,
    metesdescription integer NOT NULL,
    governmentshape integer,
    deletedat timestamp with time zone DEFAULT now()
);


ALTER TABLE gis.deleted_metesdescriptiongis OWNER TO postgres;

--
-- Name: TABLE deleted_metesdescriptiongis; Type: COMMENT; Schema: gis; Owner: postgres
--

COMMENT ON TABLE gis.deleted_metesdescriptiongis IS 'This table is only a temporary data store, and will have no data to export to open data.';


--
-- Name: deleted_metesdescriptiongis_deleted_metesdescriptiongisid_seq; Type: SEQUENCE; Schema: gis; Owner: postgres
--

CREATE SEQUENCE gis.deleted_metesdescriptiongis_deleted_metesdescriptiongisid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE gis.deleted_metesdescriptiongis_deleted_metesdescriptiongisid_seq OWNER TO postgres;

--
-- Name: deleted_metesdescriptiongis_deleted_metesdescriptiongisid_seq; Type: SEQUENCE OWNED BY; Schema: gis; Owner: postgres
--

ALTER SEQUENCE gis.deleted_metesdescriptiongis_deleted_metesdescriptiongisid_seq OWNED BY gis.deleted_metesdescriptiongis.deleted_metesdescriptiongisid;


--
-- Name: governmentshape_governmentshapeid_seq; Type: SEQUENCE; Schema: gis; Owner: postgres
--

CREATE SEQUENCE gis.governmentshape_governmentshapeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE gis.governmentshape_governmentshapeid_seq OWNER TO postgres;

--
-- Name: governmentshape_governmentshapeid_seq; Type: SEQUENCE OWNED BY; Schema: gis; Owner: postgres
--

ALTER SEQUENCE gis.governmentshape_governmentshapeid_seq OWNED BY gis.governmentshape.governmentshapeid;


--
-- Name: metesdescriptiongis_metesdescriptiongisid_seq; Type: SEQUENCE; Schema: gis; Owner: postgres
--

CREATE SEQUENCE gis.metesdescriptiongis_metesdescriptiongisid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE gis.metesdescriptiongis_metesdescriptiongisid_seq OWNER TO postgres;

--
-- Name: metesdescriptiongis_metesdescriptiongisid_seq; Type: SEQUENCE OWNED BY; Schema: gis; Owner: postgres
--

ALTER SEQUENCE gis.metesdescriptiongis_metesdescriptiongisid_seq OWNED BY gis.metesdescriptiongis.metesdescriptiongisid;


--
-- Name: adjudication adjudicationid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudication ALTER COLUMN adjudicationid SET DEFAULT nextval('geohistory.adjudication_adjudicationid_seq'::regclass);


--
-- Name: adjudicationevent adjudicationeventid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationevent ALTER COLUMN adjudicationeventid SET DEFAULT nextval('geohistory.adjudicationevent_adjudicationeventid_seq'::regclass);


--
-- Name: adjudicationlocation adjudicationlocationid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationlocation ALTER COLUMN adjudicationlocationid SET DEFAULT nextval('geohistory.adjudicationlocation_adjudicationlocationid_seq'::regclass);


--
-- Name: adjudicationlocationtype adjudicationlocationtypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationlocationtype ALTER COLUMN adjudicationlocationtypeid SET DEFAULT nextval('geohistory.adjudicationlocationtype_adjudicationlocationtypeid_seq'::regclass);


--
-- Name: adjudicationsourcecitation adjudicationsourcecitationid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationsourcecitation ALTER COLUMN adjudicationsourcecitationid SET DEFAULT nextval('geohistory.adjudicationsourcecitation_adjudicationsourcecitationid_seq'::regclass);


--
-- Name: adjudicationtype adjudicationtypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationtype ALTER COLUMN adjudicationtypeid SET DEFAULT nextval('geohistory.adjudicationtype_adjudicationtypeid_seq'::regclass);


--
-- Name: affectedgovernmentgroup affectedgovernmentgroupid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentgroup ALTER COLUMN affectedgovernmentgroupid SET DEFAULT nextval('geohistory.affectedgovernmentgroup_affectedgovernmentgroupid_seq'::regclass);


--
-- Name: affectedgovernmentgrouppart affectedgovernmentgrouppartid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentgrouppart ALTER COLUMN affectedgovernmentgrouppartid SET DEFAULT nextval('geohistory.affectedgovernmentgrouppart_affectedgovernmentgrouppartid_seq'::regclass);


--
-- Name: affectedgovernmentlevel affectedgovernmentlevelid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentlevel ALTER COLUMN affectedgovernmentlevelid SET DEFAULT nextval('geohistory.affectedgovernmentlevel_affectedgovernmentlevelid_seq'::regclass);


--
-- Name: affectedgovernmentpart affectedgovernmentpartid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentpart ALTER COLUMN affectedgovernmentpartid SET DEFAULT nextval('geohistory.affectedgovernmentpart_affectedgovernmentpartid_seq'::regclass);


--
-- Name: affectedtype affectedtypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedtype ALTER COLUMN affectedtypeid SET DEFAULT nextval('geohistory.affectedtype_affectedtypeid_seq'::regclass);


--
-- Name: censusmap censusmapid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.censusmap ALTER COLUMN censusmapid SET DEFAULT nextval('geohistory.censusmap_censusmapid_seq'::regclass);


--
-- Name: currentgovernment currentgovernmentid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.currentgovernment ALTER COLUMN currentgovernmentid SET DEFAULT nextval('geohistory.currentgovernment_currentgovernmentid_seq'::regclass);


--
-- Name: documentation documentationid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.documentation ALTER COLUMN documentationid SET DEFAULT nextval('geohistory.documentation_documentationid_seq'::regclass);


--
-- Name: event eventid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.event ALTER COLUMN eventid SET DEFAULT nextval('geohistory.event_eventid_seq'::regclass);


--
-- Name: eventeffectivetype eventeffectivetypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventeffectivetype ALTER COLUMN eventeffectivetypeid SET DEFAULT nextval('geohistory.eventeffectivetype_eventeffectivetypeid_seq'::regclass);


--
-- Name: eventgranted eventgrantedid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventgranted ALTER COLUMN eventgrantedid SET DEFAULT nextval('geohistory.eventgranted_eventgrantedid_seq'::regclass);


--
-- Name: eventmethod eventmethodid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventmethod ALTER COLUMN eventmethodid SET DEFAULT nextval('geohistory.eventmethod_eventmethodid_seq'::regclass);


--
-- Name: eventrelationship eventrelationshipid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventrelationship ALTER COLUMN eventrelationshipid SET DEFAULT nextval('geohistory.eventrelationship_eventrelationshipid_seq'::regclass);


--
-- Name: eventslugretired eventslugretiredid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventslugretired ALTER COLUMN eventslugretiredid SET DEFAULT nextval('geohistory.eventslugretired_eventslugretiredid_seq'::regclass);


--
-- Name: eventtype eventtypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventtype ALTER COLUMN eventtypeid SET DEFAULT nextval('geohistory.eventtype_eventtypeid_seq'::regclass);


--
-- Name: filing filingid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.filing ALTER COLUMN filingid SET DEFAULT nextval('geohistory.filing_filingid_seq'::regclass);


--
-- Name: filingtype filingtypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.filingtype ALTER COLUMN filingtypeid SET DEFAULT nextval('geohistory.filingtype_filingtypeid_seq'::regclass);


--
-- Name: government governmentid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.government ALTER COLUMN governmentid SET DEFAULT nextval('geohistory.government_governmentid_seq'::regclass);


--
-- Name: governmentform governmentformid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentform ALTER COLUMN governmentformid SET DEFAULT nextval('geohistory.governmentform_governmentformid_seq'::regclass);


--
-- Name: governmentformgovernment governmentformgovernmentid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentformgovernment ALTER COLUMN governmentformgovernmentid SET DEFAULT nextval('geohistory.governmentformgovernment_governmentformgovernmentid_seq'::regclass);


--
-- Name: governmentidentifier governmentidentifierid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentidentifier ALTER COLUMN governmentidentifierid SET DEFAULT nextval('geohistory.governmentidentifier_governmentidentifierid_seq'::regclass);


--
-- Name: governmentidentifiertype governmentidentifiertypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentidentifiertype ALTER COLUMN governmentidentifiertypeid SET DEFAULT nextval('geohistory.governmentidentifiertype_governmentidentifiertypeid_seq'::regclass);


--
-- Name: governmentmapstatus governmentmapstatusid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentmapstatus ALTER COLUMN governmentmapstatusid SET DEFAULT nextval('geohistory.governmentmapstatus_governmentmapstatusid_seq'::regclass);


--
-- Name: governmentothercurrentparent governmentothercurrentparentid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentothercurrentparent ALTER COLUMN governmentothercurrentparentid SET DEFAULT nextval('geohistory.governmentothercurrentparent_governmentothercurrentparentid_seq'::regclass);


--
-- Name: governmentsource governmentsourceid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentsource ALTER COLUMN governmentsourceid SET DEFAULT nextval('geohistory.governmentsource_governmentsourceid_seq'::regclass);


--
-- Name: governmentsourceevent governmentsourceeventid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentsourceevent ALTER COLUMN governmentsourceeventid SET DEFAULT nextval('geohistory.governmentsourceevent_governmentsourceeventid_seq'::regclass);


--
-- Name: law lawid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.law ALTER COLUMN lawid SET DEFAULT nextval('geohistory.law_lawid_seq'::regclass);


--
-- Name: lawalternate lawalternateid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawalternate ALTER COLUMN lawalternateid SET DEFAULT nextval('geohistory.lawalternate_lawalternateid_seq'::regclass);


--
-- Name: lawalternatesection lawalternatesectionid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawalternatesection ALTER COLUMN lawalternatesectionid SET DEFAULT nextval('geohistory.lawalternatesection_lawalternatesectionid_seq'::regclass);


--
-- Name: lawgroup lawgroupid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroup ALTER COLUMN lawgroupid SET DEFAULT nextval('geohistory.lawgroup_lawgroupid_seq'::regclass);


--
-- Name: lawgroupeventtype lawgroupeventtypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupeventtype ALTER COLUMN lawgroupeventtypeid SET DEFAULT nextval('geohistory.lawgroupeventtype_lawgroupeventtypeid_seq'::regclass);


--
-- Name: lawgroupgovernmenttype lawgroupgovernmenttypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupgovernmenttype ALTER COLUMN lawgroupgovernmenttypeid SET DEFAULT nextval('geohistory.lawgroupgovernmenttype_lawgroupgovernmenttypeid_seq'::regclass);


--
-- Name: lawgroupsection lawgroupsectionid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupsection ALTER COLUMN lawgroupsectionid SET DEFAULT nextval('geohistory.lawgroupsection_lawgroupsectionid_seq'::regclass);


--
-- Name: lawsection lawsectionid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawsection ALTER COLUMN lawsectionid SET DEFAULT nextval('geohistory.lawsection_lawsectionid_seq'::regclass);


--
-- Name: lawsectionevent lawsectioneventid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawsectionevent ALTER COLUMN lawsectioneventid SET DEFAULT nextval('geohistory.lawsectionevent_lawsectioneventid_seq'::regclass);


--
-- Name: metesdescription metesdescriptionid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.metesdescription ALTER COLUMN metesdescriptionid SET DEFAULT nextval('geohistory.metesdescription_metesdescriptionid_seq'::regclass);


--
-- Name: metesdescriptionline metesdescriptionlineid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.metesdescriptionline ALTER COLUMN metesdescriptionlineid SET DEFAULT nextval('geohistory.metesdescriptionline_metesdescriptionlineid_seq'::regclass);


--
-- Name: nationalarchives nationalarchivesid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.nationalarchives ALTER COLUMN nationalarchivesid SET DEFAULT nextval('geohistory.nationalarchives_nationalarchivesid_seq'::regclass);


--
-- Name: plss plssid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plss ALTER COLUMN plssid SET DEFAULT nextval('geohistory.plss_plssid_seq'::regclass);


--
-- Name: plssfirstdivision plssfirstdivisionid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plssfirstdivision ALTER COLUMN plssfirstdivisionid SET DEFAULT nextval('geohistory.plssfirstdivision_plssfirstdivisionid_seq'::regclass);


--
-- Name: plssfirstdivisionpart plssfirstdivisionpartid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plssfirstdivisionpart ALTER COLUMN plssfirstdivisionpartid SET DEFAULT nextval('geohistory.plssfirstdivisionpart_plssfirstdivisionpartid_seq'::regclass);


--
-- Name: plssmeridian plssmeridianid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plssmeridian ALTER COLUMN plssmeridianid SET DEFAULT nextval('geohistory.plssmeridian_plssmeridianid_seq'::regclass);


--
-- Name: plssseconddivision plssseconddivisionid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plssseconddivision ALTER COLUMN plssseconddivisionid SET DEFAULT nextval('geohistory.plssseconddivision_plssseconddivisionid_seq'::regclass);


--
-- Name: plssspecialsurvey plssspecialsurveyid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plssspecialsurvey ALTER COLUMN plssspecialsurveyid SET DEFAULT nextval('geohistory.plssspecialsurvey_plssspecialsurveyid_seq'::regclass);


--
-- Name: plsstownship plsstownshipid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plsstownship ALTER COLUMN plsstownshipid SET DEFAULT nextval('geohistory.plsstownship_plsstownshipid_seq'::regclass);


--
-- Name: recording recordingid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recording ALTER COLUMN recordingid SET DEFAULT nextval('geohistory.recording_recordingid_seq'::regclass);


--
-- Name: recordingevent recordingeventid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recordingevent ALTER COLUMN recordingeventid SET DEFAULT nextval('geohistory.recordingevent_recordingeventid_seq'::regclass);


--
-- Name: recordingoffice recordingofficeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recordingoffice ALTER COLUMN recordingofficeid SET DEFAULT nextval('geohistory.recordingoffice_recordingofficeid_seq'::regclass);


--
-- Name: recordingofficetype recordingofficetypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recordingofficetype ALTER COLUMN recordingofficetypeid SET DEFAULT nextval('geohistory.recordingofficetype_recordingofficetypeid_seq'::regclass);


--
-- Name: recordingtype recordingtypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recordingtype ALTER COLUMN recordingtypeid SET DEFAULT nextval('geohistory.recordingtype_recordingtypeid_seq'::regclass);


--
-- Name: researchlog researchlogid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.researchlog ALTER COLUMN researchlogid SET DEFAULT nextval('geohistory.researchlog_researchlogid_seq'::regclass);


--
-- Name: researchlogtype researchlogtypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.researchlogtype ALTER COLUMN researchlogtypeid SET DEFAULT nextval('geohistory.researchlogtype_researchlogtypeid_seq'::regclass);


--
-- Name: shorttype shorttypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.shorttype ALTER COLUMN shorttypeid SET DEFAULT nextval('geohistory.shorttype_shorttypeid_seq'::regclass);


--
-- Name: source sourceid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.source ALTER COLUMN sourceid SET DEFAULT nextval('geohistory.source_sourceid_seq'::regclass);


--
-- Name: sourcecitation sourcecitationid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitation ALTER COLUMN sourcecitationid SET DEFAULT nextval('geohistory.sourcecitation_sourcecitationid_seq'::regclass);


--
-- Name: sourcecitationevent sourcecitationeventid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitationevent ALTER COLUMN sourcecitationeventid SET DEFAULT nextval('geohistory.sourcecitationevent_sourcecitationeventid_seq'::regclass);


--
-- Name: sourcecitationnote sourcecitationnoteid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitationnote ALTER COLUMN sourcecitationnoteid SET DEFAULT nextval('geohistory.sourcecitationnote_sourcecitationnoteid_seq'::regclass);


--
-- Name: sourcecitationnotetype sourcecitationnotetypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitationnotetype ALTER COLUMN sourcecitationnotetypeid SET DEFAULT nextval('geohistory.sourcecitationnotetype_sourcecitationnotetypeid_seq'::regclass);


--
-- Name: sourcegovernment sourcegovernmentid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcegovernment ALTER COLUMN sourcegovernmentid SET DEFAULT nextval('geohistory.sourcegovernment_sourcegovernmentid_seq'::regclass);


--
-- Name: sourceitem sourceitemid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourceitem ALTER COLUMN sourceitemid SET DEFAULT nextval('geohistory.sourceitem_sourceitemid_seq'::regclass);


--
-- Name: sourceitemcategory sourceitemcategoryid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourceitemcategory ALTER COLUMN sourceitemcategoryid SET DEFAULT nextval('geohistory.sourceitemcategory_sourceitemcategoryid_seq'::regclass);


--
-- Name: sourceitempart sourceitempartid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourceitempart ALTER COLUMN sourceitempartid SET DEFAULT nextval('geohistory.sourceitempart_sourceitempartid_seq'::regclass);


--
-- Name: sourcetype sourcetypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcetype ALTER COLUMN sourcetypeid SET DEFAULT nextval('geohistory.sourcetype_sourcetypeid_seq'::regclass);


--
-- Name: tribunal tribunalid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.tribunal ALTER COLUMN tribunalid SET DEFAULT nextval('geohistory.tribunal_tribunalid_seq'::regclass);


--
-- Name: tribunaltype tribunaltypeid; Type: DEFAULT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.tribunaltype ALTER COLUMN tribunaltypeid SET DEFAULT nextval('geohistory.tribunaltype_tribunaltypeid_seq'::regclass);


--
-- Name: affectedgovernmentgis affectedgovernmentgisid; Type: DEFAULT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.affectedgovernmentgis ALTER COLUMN affectedgovernmentgisid SET DEFAULT nextval('gis.affectedgovernmentgis_affectedgovernmentgisid_seq'::regclass);


--
-- Name: deleted_affectedgovernmentgis deleted_affectedgovernmentgisid; Type: DEFAULT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.deleted_affectedgovernmentgis ALTER COLUMN deleted_affectedgovernmentgisid SET DEFAULT nextval('gis.deleted_affectedgovernmentgis_deleted_affectedgovernmentgis_seq'::regclass);


--
-- Name: deleted_metesdescriptiongis deleted_metesdescriptiongisid; Type: DEFAULT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.deleted_metesdescriptiongis ALTER COLUMN deleted_metesdescriptiongisid SET DEFAULT nextval('gis.deleted_metesdescriptiongis_deleted_metesdescriptiongisid_seq'::regclass);


--
-- Name: governmentshape governmentshapeid; Type: DEFAULT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.governmentshape ALTER COLUMN governmentshapeid SET DEFAULT nextval('gis.governmentshape_governmentshapeid_seq'::regclass);


--
-- Name: metesdescriptiongis metesdescriptiongisid; Type: DEFAULT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.metesdescriptiongis ALTER COLUMN metesdescriptiongisid SET DEFAULT nextval('gis.metesdescriptiongis_metesdescriptiongisid_seq'::regclass);


--
-- Name: adjudication adjudication_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudication
    ADD CONSTRAINT adjudication_pk PRIMARY KEY (adjudicationid);


--
-- Name: adjudicationevent adjudicationevent_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationevent
    ADD CONSTRAINT adjudicationevent_pk PRIMARY KEY (adjudicationeventid);


--
-- Name: adjudicationevent adjudicationevent_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationevent
    ADD CONSTRAINT adjudicationevent_unique UNIQUE (adjudication, event);


--
-- Name: adjudicationlocation adjudicationlocation_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationlocation
    ADD CONSTRAINT adjudicationlocation_pk PRIMARY KEY (adjudicationlocationid);


--
-- Name: adjudicationlocationtype adjudicationlocationtype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationlocationtype
    ADD CONSTRAINT adjudicationlocationtype_pk PRIMARY KEY (adjudicationlocationtypeid);


--
-- Name: adjudicationsourcecitation adjudicationsourcecitation_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationsourcecitation
    ADD CONSTRAINT adjudicationsourcecitation_pk PRIMARY KEY (adjudicationsourcecitationid);


--
-- Name: adjudicationtype adjudicationtype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationtype
    ADD CONSTRAINT adjudicationtype_pk PRIMARY KEY (adjudicationtypeid);


--
-- Name: affectedgovernmentgroup affectedgovernmentgroup_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentgroup
    ADD CONSTRAINT affectedgovernmentgroup_pk PRIMARY KEY (affectedgovernmentgroupid);


--
-- Name: affectedgovernmentgrouppart affectedgovernmentgrouppart_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentgrouppart
    ADD CONSTRAINT affectedgovernmentgrouppart_pk PRIMARY KEY (affectedgovernmentgrouppartid);


--
-- Name: affectedgovernmentgrouppart affectedgovernmentgrouppart_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentgrouppart
    ADD CONSTRAINT affectedgovernmentgrouppart_unique UNIQUE (affectedgovernmentgroup, affectedgovernmentlevel);


--
-- Name: affectedgovernmentlevel affectedgovernmentlevel_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentlevel
    ADD CONSTRAINT affectedgovernmentlevel_pk PRIMARY KEY (affectedgovernmentlevelid);


--
-- Name: affectedgovernmentpart affectedgovernmentpart_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentpart
    ADD CONSTRAINT affectedgovernmentpart_pk PRIMARY KEY (affectedgovernmentpartid);


--
-- Name: affectedgovernmentpart affectedgovernmentpart_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentpart
    ADD CONSTRAINT affectedgovernmentpart_unique UNIQUE (governmentfrom, affectedtypefrom, governmentto, affectedtypeto, governmentformto);


--
-- Name: affectedtype affectedtype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedtype
    ADD CONSTRAINT affectedtype_pk PRIMARY KEY (affectedtypeid);


--
-- Name: affectedtype affectedtype_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedtype
    ADD CONSTRAINT affectedtype_unique UNIQUE (affectedtypeshort);


--
-- Name: censusmap censusmap_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.censusmap
    ADD CONSTRAINT censusmap_pk PRIMARY KEY (censusmapid);


--
-- Name: currentgovernment currentgovernment_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.currentgovernment
    ADD CONSTRAINT currentgovernment_pk PRIMARY KEY (currentgovernmentid);


--
-- Name: documentation documentation_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.documentation
    ADD CONSTRAINT documentation_pk PRIMARY KEY (documentationid);


--
-- Name: event event_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.event
    ADD CONSTRAINT event_pk PRIMARY KEY (eventid);


--
-- Name: event event_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.event
    ADD CONSTRAINT event_unique UNIQUE (eventlong);


--
-- Name: eventeffectivetype eventeffectivetype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventeffectivetype
    ADD CONSTRAINT eventeffectivetype_pk PRIMARY KEY (eventeffectivetypeid);


--
-- Name: eventgranted eventgranted_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventgranted
    ADD CONSTRAINT eventgranted_pk PRIMARY KEY (eventgrantedid);


--
-- Name: eventgranted eventgranted_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventgranted
    ADD CONSTRAINT eventgranted_unique UNIQUE (eventgrantedshort);


--
-- Name: eventmethod eventmethod_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventmethod
    ADD CONSTRAINT eventmethod_pk PRIMARY KEY (eventmethodid);


--
-- Name: eventmethod eventmethod_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventmethod
    ADD CONSTRAINT eventmethod_unique UNIQUE (eventmethodlong);


--
-- Name: eventrelationship eventrelationship_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventrelationship
    ADD CONSTRAINT eventrelationship_pk PRIMARY KEY (eventrelationshipid);


--
-- Name: eventrelationship eventrelationship_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventrelationship
    ADD CONSTRAINT eventrelationship_unique UNIQUE (eventrelationshipshort);


--
-- Name: eventslugretired eventslugretired_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventslugretired
    ADD CONSTRAINT eventslugretired_pk PRIMARY KEY (eventslugretiredid);


--
-- Name: eventtype eventtype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventtype
    ADD CONSTRAINT eventtype_pk PRIMARY KEY (eventtypeid);


--
-- Name: eventtype eventtype_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.eventtype
    ADD CONSTRAINT eventtype_unique UNIQUE (eventtypeshort);


--
-- Name: filing filing_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.filing
    ADD CONSTRAINT filing_pk PRIMARY KEY (filingid);


--
-- Name: filingtype filingtype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.filingtype
    ADD CONSTRAINT filingtype_pk PRIMARY KEY (filingtypeid);


--
-- Name: filingtype filingtype_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.filingtype
    ADD CONSTRAINT filingtype_unique UNIQUE (filingtypelong, filingtypefinalrecording);


--
-- Name: government government_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.government
    ADD CONSTRAINT government_pk PRIMARY KEY (governmentid);


--
-- Name: governmentform governmentform_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentform
    ADD CONSTRAINT governmentform_pk PRIMARY KEY (governmentformid);


--
-- Name: governmentformgovernment governmentformgovernment_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentformgovernment
    ADD CONSTRAINT governmentformgovernment_pk PRIMARY KEY (governmentformgovernmentid);


--
-- Name: governmentidentifier governmentidentifier_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentidentifier
    ADD CONSTRAINT governmentidentifier_pk PRIMARY KEY (governmentidentifierid);


--
-- Name: governmentidentifiertype governmentidentifiertype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentidentifiertype
    ADD CONSTRAINT governmentidentifiertype_pk PRIMARY KEY (governmentidentifiertypeid);


--
-- Name: governmentmapstatus governmentmapstatus_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentmapstatus
    ADD CONSTRAINT governmentmapstatus_pk PRIMARY KEY (governmentmapstatusid);


--
-- Name: governmentmapstatus governmentmapstatus_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentmapstatus
    ADD CONSTRAINT governmentmapstatus_unique UNIQUE (governmentmapstatusshort);


--
-- Name: governmentothercurrentparent governmentothercurrentparent_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentothercurrentparent
    ADD CONSTRAINT governmentothercurrentparent_pk PRIMARY KEY (governmentothercurrentparentid);


--
-- Name: governmentothercurrentparent governmentothercurrentparent_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentothercurrentparent
    ADD CONSTRAINT governmentothercurrentparent_unique UNIQUE (government, governmentothercurrentparent);


--
-- Name: governmentsource governmentsource_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentsource
    ADD CONSTRAINT governmentsource_pk PRIMARY KEY (governmentsourceid);


--
-- Name: governmentsourceevent governmentsourceevent_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentsourceevent
    ADD CONSTRAINT governmentsourceevent_pk PRIMARY KEY (governmentsourceeventid);


--
-- Name: governmentsourceevent governmentsourceevent_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentsourceevent
    ADD CONSTRAINT governmentsourceevent_unique UNIQUE (governmentsource, event);


--
-- Name: law law_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.law
    ADD CONSTRAINT law_pk PRIMARY KEY (lawid);


--
-- Name: lawalternate lawalternate_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawalternate
    ADD CONSTRAINT lawalternate_pk PRIMARY KEY (lawalternateid);


--
-- Name: lawalternatesection lawalternatesection_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawalternatesection
    ADD CONSTRAINT lawalternatesection_pk PRIMARY KEY (lawalternatesectionid);


--
-- Name: lawgroup lawgroup_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroup
    ADD CONSTRAINT lawgroup_pk PRIMARY KEY (lawgroupid);


--
-- Name: lawgroup lawgroup_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroup
    ADD CONSTRAINT lawgroup_unique UNIQUE (lawgrouplong);


--
-- Name: lawgroupeventtype lawgroupeventtype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupeventtype
    ADD CONSTRAINT lawgroupeventtype_pk PRIMARY KEY (lawgroupeventtypeid);


--
-- Name: lawgroupeventtype lawgroupeventtype_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupeventtype
    ADD CONSTRAINT lawgroupeventtype_unique UNIQUE (lawgroup, eventtype);


--
-- Name: lawgroupgovernmenttype lawgroupgovernmenttype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupgovernmenttype
    ADD CONSTRAINT lawgroupgovernmenttype_pk PRIMARY KEY (lawgroupgovernmenttypeid);


--
-- Name: lawgroupgovernmenttype lawgroupgovernmenttype_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupgovernmenttype
    ADD CONSTRAINT lawgroupgovernmenttype_unique UNIQUE (lawgroup, governmenttype);


--
-- Name: lawgroupsection lawgroupsection_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupsection
    ADD CONSTRAINT lawgroupsection_pk PRIMARY KEY (lawgroupsectionid);


--
-- Name: lawgroupsection lawgroupsection_unique_order; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupsection
    ADD CONSTRAINT lawgroupsection_unique_order UNIQUE (lawgroup, lawgroupsectionorder);


--
-- Name: lawgroupsection lawgroupsection_unique_section; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupsection
    ADD CONSTRAINT lawgroupsection_unique_section UNIQUE (lawgroup, lawsection);


--
-- Name: lawsection lawsection_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawsection
    ADD CONSTRAINT lawsection_pk PRIMARY KEY (lawsectionid);


--
-- Name: lawsectionevent lawsectionevent_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawsectionevent
    ADD CONSTRAINT lawsectionevent_pk PRIMARY KEY (lawsectioneventid);


--
-- Name: lawsectionevent lawsectionevent_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawsectionevent
    ADD CONSTRAINT lawsectionevent_unique UNIQUE (lawsection, event, eventrelationship);


--
-- Name: locale locale_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.locale
    ADD CONSTRAINT locale_pk PRIMARY KEY (localeid);


--
-- Name: metesdescription metesdescription_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.metesdescription
    ADD CONSTRAINT metesdescription_pk PRIMARY KEY (metesdescriptionid);


--
-- Name: metesdescription metesdescription_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.metesdescription
    ADD CONSTRAINT metesdescription_unique UNIQUE (metesdescriptionname, event);


--
-- Name: metesdescriptionline metesdescriptionline_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.metesdescriptionline
    ADD CONSTRAINT metesdescriptionline_pk PRIMARY KEY (metesdescriptionlineid);


--
-- Name: nationalarchives nationalarchives_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.nationalarchives
    ADD CONSTRAINT nationalarchives_pk PRIMARY KEY (nationalarchivesid);


--
-- Name: plss plss_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plss
    ADD CONSTRAINT plss_pk PRIMARY KEY (plssid);


--
-- Name: plssfirstdivision plssfirstdivision_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plssfirstdivision
    ADD CONSTRAINT plssfirstdivision_pk PRIMARY KEY (plssfirstdivisionid);


--
-- Name: plssfirstdivisionpart plssfirstdivisionpart_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plssfirstdivisionpart
    ADD CONSTRAINT plssfirstdivisionpart_pk PRIMARY KEY (plssfirstdivisionpartid);


--
-- Name: plssmeridian plssmeridian_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plssmeridian
    ADD CONSTRAINT plssmeridian_pk PRIMARY KEY (plssmeridianid);


--
-- Name: plssseconddivision plssseconddivision_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plssseconddivision
    ADD CONSTRAINT plssseconddivision_pk PRIMARY KEY (plssseconddivisionid);


--
-- Name: plssspecialsurvey plssspecialsurvey_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plssspecialsurvey
    ADD CONSTRAINT plssspecialsurvey_pk PRIMARY KEY (plssspecialsurveyid);


--
-- Name: plsstownship plsstownship_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plsstownship
    ADD CONSTRAINT plsstownship_pk PRIMARY KEY (plsstownshipid);


--
-- Name: recording recording_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recording
    ADD CONSTRAINT recording_pk PRIMARY KEY (recordingid);


--
-- Name: recordingevent recordingevent_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recordingevent
    ADD CONSTRAINT recordingevent_pk PRIMARY KEY (recordingeventid);


--
-- Name: recordingevent recordingevent_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recordingevent
    ADD CONSTRAINT recordingevent_unique UNIQUE (recording, event);


--
-- Name: recordingoffice recordingoffice_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recordingoffice
    ADD CONSTRAINT recordingoffice_pk PRIMARY KEY (recordingofficeid);


--
-- Name: recordingofficetype recordingofficetype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recordingofficetype
    ADD CONSTRAINT recordingofficetype_pk PRIMARY KEY (recordingofficetypeid);


--
-- Name: recordingtype recordingtype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recordingtype
    ADD CONSTRAINT recordingtype_pk PRIMARY KEY (recordingtypeid);


--
-- Name: recordingtype recordingtype_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recordingtype
    ADD CONSTRAINT recordingtype_unique UNIQUE (recordingtypeabbreviation);


--
-- Name: researchlog researchlog_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.researchlog
    ADD CONSTRAINT researchlog_pk PRIMARY KEY (researchlogid);


--
-- Name: researchlogtype researchlogtype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.researchlogtype
    ADD CONSTRAINT researchlogtype_pk PRIMARY KEY (researchlogtypeid);


--
-- Name: researchlogtype researchlogtype_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.researchlogtype
    ADD CONSTRAINT researchlogtype_unique UNIQUE (researchlogtypelong, researchlogtypelongpart);


--
-- Name: shorttype shorttype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.shorttype
    ADD CONSTRAINT shorttype_pk PRIMARY KEY (shorttypeid);


--
-- Name: shorttype shorttype_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.shorttype
    ADD CONSTRAINT shorttype_unique UNIQUE (shorttypeshort);


--
-- Name: source source_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.source
    ADD CONSTRAINT source_pk PRIMARY KEY (sourceid);


--
-- Name: sourcecitation sourcecitation_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitation
    ADD CONSTRAINT sourcecitation_pk PRIMARY KEY (sourcecitationid);


--
-- Name: sourcecitationevent sourcecitationevent_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitationevent
    ADD CONSTRAINT sourcecitationevent_pk PRIMARY KEY (sourcecitationeventid);


--
-- Name: sourcecitationevent sourcecitationevent_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitationevent
    ADD CONSTRAINT sourcecitationevent_unique UNIQUE (sourcecitation, event);


--
-- Name: sourcecitationnote sourcecitationnote_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitationnote
    ADD CONSTRAINT sourcecitationnote_pk PRIMARY KEY (sourcecitationnoteid);


--
-- Name: sourcecitationnote sourcecitationnote_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitationnote
    ADD CONSTRAINT sourcecitationnote_unique UNIQUE (sourcecitation, sourcecitationnotegroup, sourcecitationnotetype);


--
-- Name: sourcecitationnotetype sourcecitationnotetype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitationnotetype
    ADD CONSTRAINT sourcecitationnotetype_pk PRIMARY KEY (sourcecitationnotetypeid);


--
-- Name: sourcecitationnotetype sourcecitationnotetype_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitationnotetype
    ADD CONSTRAINT sourcecitationnotetype_unique UNIQUE (source, sourcecitationnotetypeisdetail, sourcecitationnotetypetext);


--
-- Name: sourcegovernment sourcegovernment_government_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcegovernment
    ADD CONSTRAINT sourcegovernment_government_unique UNIQUE (source, government);


--
-- Name: sourcegovernment sourcegovernment_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcegovernment
    ADD CONSTRAINT sourcegovernment_pk PRIMARY KEY (sourcegovernmentid);


--
-- Name: sourcegovernment sourcegovernment_sourceorder_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcegovernment
    ADD CONSTRAINT sourcegovernment_sourceorder_unique UNIQUE (source, sourceorder);


--
-- Name: sourceitem sourceitem_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourceitem
    ADD CONSTRAINT sourceitem_pk PRIMARY KEY (sourceitemid);


--
-- Name: sourceitemcategory sourceitemcategory_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourceitemcategory
    ADD CONSTRAINT sourceitemcategory_pk PRIMARY KEY (sourceitemcategoryid);


--
-- Name: sourceitemcategory sourceitemcategory_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourceitemcategory
    ADD CONSTRAINT sourceitemcategory_unique UNIQUE (sourceitemcategorydomain);


--
-- Name: sourceitempart sourceitempart_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourceitempart
    ADD CONSTRAINT sourceitempart_pk PRIMARY KEY (sourceitempartid);


--
-- Name: sourcetype sourcetype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcetype
    ADD CONSTRAINT sourcetype_pk PRIMARY KEY (sourcetypeid);


--
-- Name: sourcetype sourcetype_unique; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcetype
    ADD CONSTRAINT sourcetype_unique UNIQUE (sourcetypeshort);


--
-- Name: tribunal tribunal_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.tribunal
    ADD CONSTRAINT tribunal_pk PRIMARY KEY (tribunalid);


--
-- Name: tribunaltype tribunaltype_pk; Type: CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.tribunaltype
    ADD CONSTRAINT tribunaltype_pk PRIMARY KEY (tribunaltypeid);


--
-- Name: affectedgovernmentgis affectedgovernmentgis_pk; Type: CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.affectedgovernmentgis
    ADD CONSTRAINT affectedgovernmentgis_pk PRIMARY KEY (affectedgovernmentgisid);


--
-- Name: deleted_affectedgovernmentgis deleted_affectedgovernmentgis_pk; Type: CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.deleted_affectedgovernmentgis
    ADD CONSTRAINT deleted_affectedgovernmentgis_pk PRIMARY KEY (deleted_affectedgovernmentgisid);


--
-- Name: deleted_metesdescriptiongis deleted_metesdescriptiongis_pk; Type: CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.deleted_metesdescriptiongis
    ADD CONSTRAINT deleted_metesdescriptiongis_pk PRIMARY KEY (deleted_metesdescriptiongisid);


--
-- Name: governmentshape governmentshape_pk; Type: CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.governmentshape
    ADD CONSTRAINT governmentshape_pk PRIMARY KEY (governmentshapeid);


--
-- Name: metesdescriptiongis metesdescriptiongis_pk; Type: CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.metesdescriptiongis
    ADD CONSTRAINT metesdescriptiongis_pk PRIMARY KEY (metesdescriptiongisid);


--
-- Name: adjudicationextracache_adjudicationid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX adjudicationextracache_adjudicationid_idx ON extra.adjudicationextracache USING btree (adjudicationid);


--
-- Name: adjudicationextracache_adjudicationslug_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX adjudicationextracache_adjudicationslug_idx ON extra.adjudicationextracache USING btree (adjudicationslug);


--
-- Name: adjudicationgovernmentcache_adjudicationid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX adjudicationgovernmentcache_adjudicationid_idx ON extra.adjudicationgovernmentcache USING btree (adjudicationid);


--
-- Name: adjudicationgovernmentcache_governmentrelationstate_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX adjudicationgovernmentcache_governmentrelationstate_idx ON extra.adjudicationgovernmentcache USING btree (governmentrelationstate);


--
-- Name: adjudicationsourcecitationextracache_id_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX adjudicationsourcecitationextracache_id_idx ON extra.adjudicationsourcecitationextracache USING btree (adjudicationsourcecitationid);


--
-- Name: adjudicationsourcecitationextracache_slug_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX adjudicationsourcecitationextracache_slug_idx ON extra.adjudicationsourcecitationextracache USING btree (adjudicationsourcecitationslug);


--
-- Name: areagovernmentcache_governmentrelationstate_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX areagovernmentcache_governmentrelationstate_idx ON extra.areagovernmentcache USING btree (governmentrelationstate);


--
-- Name: areagovernmentcache_governmentshapeid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX areagovernmentcache_governmentshapeid_idx ON extra.areagovernmentcache USING btree (governmentshapeid);


--
-- Name: eventextracache_eventid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX eventextracache_eventid_idx ON extra.eventextracache USING btree (eventid);


--
-- Name: eventextracache_eventslug_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX eventextracache_eventslug_idx ON extra.eventextracache USING btree (eventslug);


--
-- Name: eventgovernmentcache_eventid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX eventgovernmentcache_eventid_idx ON extra.eventgovernmentcache USING btree (eventid);


--
-- Name: eventgovernmentcache_government_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX eventgovernmentcache_government_idx ON extra.eventgovernmentcache USING btree (government);


--
-- Name: giscache_geometry_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX giscache_geometry_idx ON extra.giscache USING gist (geometry);


--
-- Name: governmentextracache_governmentid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX governmentextracache_governmentid_idx ON extra.governmentextracache USING btree (governmentid);


--
-- Name: governmentextracache_governmentslug_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX governmentextracache_governmentslug_idx ON extra.governmentextracache USING btree (governmentslug);


--
-- Name: governmentparentcache_governmentid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX governmentparentcache_governmentid_idx ON extra.governmentparentcache USING btree (governmentid);


--
-- Name: governmentparentcache_governmentparent_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX governmentparentcache_governmentparent_idx ON extra.governmentparentcache USING btree (governmentparent);


--
-- Name: governmentrelationcache_governmentid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX governmentrelationcache_governmentid_idx ON extra.governmentrelationcache USING btree (governmentid);


--
-- Name: governmentrelationcache_governmentrelation_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX governmentrelationcache_governmentrelation_idx ON extra.governmentrelationcache USING btree (governmentrelation);


--
-- Name: governmentrelationcache_governmentrelationstate_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX governmentrelationcache_governmentrelationstate_idx ON extra.governmentrelationcache USING btree (governmentrelationstate);


--
-- Name: governmentrelationcache_governmentshort_idx1; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX governmentrelationcache_governmentshort_idx1 ON extra.governmentrelationcache USING btree (governmentshort);


--
-- Name: governmentrelationcache_governmentshort_idx2; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX governmentrelationcache_governmentshort_idx2 ON extra.governmentrelationcache USING btree (extra.punctuationnone(governmentshort));


--
-- Name: governmentshapeextracache_governmentshapeid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX governmentshapeextracache_governmentshapeid_idx ON extra.governmentshapeextracache USING btree (governmentshapeid);


--
-- Name: governmentshapeextracache_governmentshapeslug_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX governmentshapeextracache_governmentshapeslug_idx ON extra.governmentshapeextracache USING btree (governmentshapeslug);


--
-- Name: governmentsubstitutecache_governmentid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX governmentsubstitutecache_governmentid_idx ON extra.governmentsubstitutecache USING btree (governmentid);


--
-- Name: governmentsubstitutecache_governmentsubstitute_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX governmentsubstitutecache_governmentsubstitute_idx ON extra.governmentsubstitutecache USING btree (governmentsubstitute);


--
-- Name: lawalternatesectionextracache_lawsectionid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX lawalternatesectionextracache_lawsectionid_idx ON extra.lawalternatesectionextracache USING btree (lawsectionid);


--
-- Name: lawalternatesectionextracache_lawsectionslug_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX lawalternatesectionextracache_lawsectionslug_idx ON extra.lawalternatesectionextracache USING btree (lawsectionslug);


--
-- Name: lawsectionextracache_lawsectionid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX lawsectionextracache_lawsectionid_idx ON extra.lawsectionextracache USING btree (lawsectionid);


--
-- Name: lawsectionextracache_lawsectionslug_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX lawsectionextracache_lawsectionslug_idx ON extra.lawsectionextracache USING btree (lawsectionslug);


--
-- Name: lawsectiongovernmentcache_governmentrelationstate_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX lawsectiongovernmentcache_governmentrelationstate_idx ON extra.lawsectiongovernmentcache USING btree (governmentrelationstate);


--
-- Name: lawsectiongovernmentcache_lawsectionid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX lawsectiongovernmentcache_lawsectionid_idx ON extra.lawsectiongovernmentcache USING btree (lawsectionid);


--
-- Name: metesdescriptionextracache_metesdescriptionid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX metesdescriptionextracache_metesdescriptionid_idx ON extra.metesdescriptionextracache USING btree (metesdescriptionid);


--
-- Name: metesdescriptionextracache_metesdescriptionslug_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX metesdescriptionextracache_metesdescriptionslug_idx ON extra.metesdescriptionextracache USING btree (metesdescriptionslug);


--
-- Name: sourcecitationextracache_sourcecitationid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX sourcecitationextracache_sourcecitationid_idx ON extra.sourcecitationextracache USING btree (sourcecitationid);


--
-- Name: sourcecitationextracache_sourcecitationslug_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX sourcecitationextracache_sourcecitationslug_idx ON extra.sourcecitationextracache USING btree (sourcecitationslug);


--
-- Name: sourcecitationgovernmentcache_governmentrelationstate_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX sourcecitationgovernmentcache_governmentrelationstate_idx ON extra.sourcecitationgovernmentcache USING btree (governmentrelationstate);


--
-- Name: sourcecitationgovernmentcache_sourcecitationid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX sourcecitationgovernmentcache_sourcecitationid_idx ON extra.sourcecitationgovernmentcache USING btree (sourcecitationid);


--
-- Name: tribunalgovernmentcache_governmentrelationstate_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX tribunalgovernmentcache_governmentrelationstate_idx ON extra.tribunalgovernmentcache USING btree (governmentrelationstate);


--
-- Name: tribunalgovernmentcache_tribunalid_idx; Type: INDEX; Schema: extra; Owner: postgres
--

CREATE INDEX tribunalgovernmentcache_tribunalid_idx ON extra.tribunalgovernmentcache USING btree (tribunalid);


--
-- Name: adjudication_adjudicationtype_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX adjudication_adjudicationtype_idx ON geohistory.adjudication USING btree (adjudicationtype);


--
-- Name: adjudicationevent_adjudication_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX adjudicationevent_adjudication_idx ON geohistory.adjudicationevent USING btree (adjudication);


--
-- Name: adjudicationevent_event_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX adjudicationevent_event_idx ON geohistory.adjudicationevent USING btree (event);


--
-- Name: adjudicationlocation_adjudication_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX adjudicationlocation_adjudication_idx ON geohistory.adjudicationlocation USING btree (adjudication);


--
-- Name: adjudicationlocation_adjudicationlocationtype_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX adjudicationlocation_adjudicationlocationtype_idx ON geohistory.adjudicationlocation USING btree (adjudicationlocationtype);


--
-- Name: adjudicationlocationtype_tribunal_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX adjudicationlocationtype_tribunal_idx ON geohistory.adjudicationlocationtype USING btree (tribunal);


--
-- Name: adjudicationsourcecitation_adjudication_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX adjudicationsourcecitation_adjudication_idx ON geohistory.adjudicationsourcecitation USING btree (adjudication);


--
-- Name: adjudicationsourcecitation_source_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX adjudicationsourcecitation_source_idx ON geohistory.adjudicationsourcecitation USING btree (source);


--
-- Name: adjudicationtype_tribunal_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX adjudicationtype_tribunal_idx ON geohistory.adjudicationtype USING btree (tribunal);


--
-- Name: affectedgovernmentgroup_event_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX affectedgovernmentgroup_event_idx ON geohistory.affectedgovernmentgroup USING btree (event);


--
-- Name: affectedgovernmentgrouppart_affectedgovernmentgrouppart_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX affectedgovernmentgrouppart_affectedgovernmentgrouppart_idx ON geohistory.affectedgovernmentgrouppart USING btree (affectedgovernmentgroup);


--
-- Name: affectedgovernmentpart_affectedgovernmentpart_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX affectedgovernmentpart_affectedgovernmentpart_idx ON geohistory.affectedgovernmentgrouppart USING btree (affectedgovernmentpart);


--
-- Name: affectedgovernmentpart_governmentfrom_idx1; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX affectedgovernmentpart_governmentfrom_idx1 ON geohistory.affectedgovernmentpart USING btree (governmentfrom);


--
-- Name: affectedgovernmentpart_governmentfrom_idx2; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX affectedgovernmentpart_governmentfrom_idx2 ON geohistory.affectedgovernmentpart USING btree (COALESCE(governmentfrom, 0));


--
-- Name: affectedgovernmentpart_governmentto_idx1; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX affectedgovernmentpart_governmentto_idx1 ON geohistory.affectedgovernmentpart USING btree (governmentto);


--
-- Name: affectedgovernmentpart_governmentto_idx2; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX affectedgovernmentpart_governmentto_idx2 ON geohistory.affectedgovernmentpart USING btree (COALESCE(governmentto, 0));


--
-- Name: censusmap_government_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX censusmap_government_idx ON geohistory.censusmap USING btree (government);


--
-- Name: currentgovernment_event_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX currentgovernment_event_idx ON geohistory.currentgovernment USING btree (event);


--
-- Name: currentgovernment_governmentcounty_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX currentgovernment_governmentcounty_idx ON geohistory.currentgovernment USING btree (governmentcounty);


--
-- Name: currentgovernment_governmentmunicipality_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX currentgovernment_governmentmunicipality_idx ON geohistory.currentgovernment USING btree (governmentmunicipality);


--
-- Name: currentgovernment_governmentstate_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX currentgovernment_governmentstate_idx ON geohistory.currentgovernment USING btree (governmentstate);


--
-- Name: currentgovernment_governmentsubmunicipality_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX currentgovernment_governmentsubmunicipality_idx ON geohistory.currentgovernment USING btree (governmentsubmunicipality);


--
-- Name: event_eventmethod_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX event_eventmethod_idx ON geohistory.event USING btree (eventmethod);


--
-- Name: event_eventtype_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX event_eventtype_idx ON geohistory.event USING btree (eventtype);


--
-- Name: event_government_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE UNIQUE INDEX event_government_idx ON geohistory.event USING btree (government);


--
-- Name: eventgranted_eventgrantedshort_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX eventgranted_eventgrantedshort_idx ON geohistory.eventgranted USING btree (eventgrantedshort);


--
-- Name: eventrelationship_eventrelationshipshort_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX eventrelationship_eventrelationshipshort_idx ON geohistory.eventrelationship USING btree (eventrelationshipshort);


--
-- Name: filing_adjudication_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX filing_adjudication_idx ON geohistory.filing USING btree (adjudication);


--
-- Name: filing_filingtype_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX filing_filingtype_idx ON geohistory.filing USING btree (filingtype);


--
-- Name: fki_government_governmentform_fk; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX fki_government_governmentform_fk ON geohistory.government USING btree (governmentcurrentform);


--
-- Name: fki_government_locale_fk; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX fki_government_locale_fk ON geohistory.government USING btree (locale);


--
-- Name: fki_plss_plsstownship_fk; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX fki_plss_plsstownship_fk ON geohistory.plss USING btree (plsstownship);


--
-- Name: fki_sourcecitationnote_sourcecitationnotetype_fk; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX fki_sourcecitationnote_sourcecitationnotetype_fk ON geohistory.sourcecitationnote USING btree (sourcecitationnotetype);


--
-- Name: government_governmentcurrentleadparent_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX government_governmentcurrentleadparent_idx ON geohistory.government USING btree (governmentcurrentleadparent);


--
-- Name: government_governmentlevel_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX government_governmentlevel_idx ON geohistory.government USING btree (governmentlevel);


--
-- Name: government_governmentname_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX government_governmentname_idx ON geohistory.government USING btree (governmentname);


--
-- Name: government_governmentstatus_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX government_governmentstatus_idx ON geohistory.government USING btree (governmentstatus);


--
-- Name: governmentform_governmentstate_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX governmentform_governmentstate_idx ON geohistory.governmentform USING btree (governmentstate);


--
-- Name: governmentformgovernment_government_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX governmentformgovernment_government_idx ON geohistory.governmentformgovernment USING btree (government);


--
-- Name: governmentformgovernment_governmentform_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX governmentformgovernment_governmentform_idx ON geohistory.governmentformgovernment USING btree (governmentform);


--
-- Name: governmentidentifier_government_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX governmentidentifier_government_idx ON geohistory.governmentidentifier USING btree (government);


--
-- Name: governmentothercurrentparent_government_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX governmentothercurrentparent_government_idx ON geohistory.governmentothercurrentparent USING btree (government);


--
-- Name: governmentothercurrentparent_governmentothercurrentparent_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX governmentothercurrentparent_governmentothercurrentparent_idx ON geohistory.governmentothercurrentparent USING btree (governmentothercurrentparent);


--
-- Name: governmentsource_government_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX governmentsource_government_idx ON geohistory.governmentsource USING btree (government);


--
-- Name: governmentsource_source_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX governmentsource_source_idx ON geohistory.governmentsource USING btree (source);


--
-- Name: governmentsourceevent_event_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX governmentsourceevent_event_idx ON geohistory.governmentsourceevent USING btree (event);


--
-- Name: governmentsourceevent_governmentsource_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX governmentsourceevent_governmentsource_idx ON geohistory.governmentsourceevent USING btree (governmentsource);


--
-- Name: law_source_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX law_source_idx ON geohistory.law USING btree (source);


--
-- Name: lawalternate_law_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawalternate_law_idx ON geohistory.lawalternate USING btree (law);


--
-- Name: lawalternate_source_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawalternate_source_idx ON geohistory.lawalternate USING btree (source);


--
-- Name: lawalternatesection_lawalternate_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawalternatesection_lawalternate_idx ON geohistory.lawalternatesection USING btree (lawalternate);


--
-- Name: lawalternatesection_lawsection_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawalternatesection_lawsection_idx ON geohistory.lawalternatesection USING btree (lawsection);


--
-- Name: lawgroup_eventeffectivetype_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawgroup_eventeffectivetype_idx ON geohistory.lawgroup USING btree (eventeffectivetype);


--
-- Name: lawgroupsection_lawgroup_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawgroupsection_lawgroup_idx ON geohistory.lawgroupsection USING btree (lawgroup);


--
-- Name: lawgroupsection_lawsection_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawgroupsection_lawsection_idx ON geohistory.lawgroupsection USING btree (lawsection);


--
-- Name: lawsection_eventtype_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawsection_eventtype_idx ON geohistory.lawsection USING btree (eventtype);


--
-- Name: lawsection_law_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawsection_law_idx ON geohistory.lawsection USING btree (law);


--
-- Name: lawsection_lawsectionamend_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawsection_lawsectionamend_idx ON geohistory.lawsection USING btree (lawsectionamend);


--
-- Name: lawsection_lawsectionnewlaw_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawsection_lawsectionnewlaw_idx ON geohistory.lawsection USING btree (lawsectionnewlaw);


--
-- Name: lawsectionevent_event_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawsectionevent_event_idx ON geohistory.lawsectionevent USING btree (event);


--
-- Name: lawsectionevent_lawgroup_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawsectionevent_lawgroup_idx ON geohistory.lawsectionevent USING btree (lawgroup);


--
-- Name: lawsectionevent_lawsection_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawsectionevent_lawsection_idx ON geohistory.lawsectionevent USING btree (lawsection);


--
-- Name: metesdescription_event_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX metesdescription_event_idx ON geohistory.metesdescription USING btree (event);


--
-- Name: metesdescriptionline_metesdescription_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX metesdescriptionline_metesdescription_idx ON geohistory.metesdescriptionline USING btree (metesdescription);


--
-- Name: nationalarchives_government_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX nationalarchives_government_idx ON geohistory.nationalarchives USING btree (government);


--
-- Name: plss_event_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX plss_event_idx ON geohistory.plss USING btree (event);


--
-- Name: plss_plssmeridian_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX plss_plssmeridian_idx ON geohistory.plss USING btree (plsstownship);


--
-- Name: plsstownship_governmentstate_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX plsstownship_governmentstate_idx ON geohistory.plsstownship USING btree (governmentstate);


--
-- Name: plsstownship_plssmeridian_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX plsstownship_plssmeridian_idx ON geohistory.plsstownship USING btree (plssmeridian);


--
-- Name: recording_government_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX recording_government_idx ON geohistory.recording USING btree (recordingoffice);


--
-- Name: recordingevent_event_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX recordingevent_event_idx ON geohistory.recordingevent USING btree (event);


--
-- Name: recordingevent_recording_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX recordingevent_recording_idx ON geohistory.recordingevent USING btree (recording);


--
-- Name: recordingoffice_government_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX recordingoffice_government_idx ON geohistory.recordingoffice USING btree (government);


--
-- Name: recordingoffice_recordingofficetype_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX recordingoffice_recordingofficetype_idx ON geohistory.recordingoffice USING btree (recordingofficetype);


--
-- Name: researchlog_government_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX researchlog_government_idx ON geohistory.researchlog USING btree (government);


--
-- Name: researchlog_researchlogtype_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX researchlog_researchlogtype_idx ON geohistory.researchlog USING btree (researchlogtype);


--
-- Name: source_sourcetype_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX source_sourcetype_idx ON geohistory.source USING btree (sourcetype);


--
-- Name: source_sourceurlsubstitute_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX source_sourceurlsubstitute_idx ON geohistory.source USING btree (sourceurlsubstitute);


--
-- Name: sourcecitation_source_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX sourcecitation_source_idx ON geohistory.sourcecitation USING btree (source);


--
-- Name: sourcecitationevent_event_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX sourcecitationevent_event_idx ON geohistory.sourcecitationevent USING btree (event);


--
-- Name: sourcecitationevent_sourcecitation_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX sourcecitationevent_sourcecitation_idx ON geohistory.sourcecitationevent USING btree (sourcecitation);


--
-- Name: sourceitem_source_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX sourceitem_source_idx ON geohistory.sourceitem USING btree (source);


--
-- Name: sourceitempart_sourceitem_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX sourceitempart_sourceitem_idx ON geohistory.sourceitempart USING btree (sourceitem);


--
-- Name: tribunal_government_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX tribunal_government_idx ON geohistory.tribunal USING btree (government);


--
-- Name: tribunal_tribunaltype_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX tribunal_tribunaltype_idx ON geohistory.tribunal USING btree (tribunaltype);


--
-- Name: fki_governmentshape_governmentshapeplsstownship_fk; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX fki_governmentshape_governmentshapeplsstownship_fk ON gis.governmentshape USING btree (governmentshapeplsstownship);


--
-- Name: governmentshape_idx; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX governmentshape_idx ON gis.governmentshape USING gist (governmentshapegeometry);


--
-- Name: governmentshape_municipality_idx; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX governmentshape_municipality_idx ON gis.governmentshape USING btree (governmentsubmunicipality, governmentmunicipality);


--
-- Name: government government_insertupdate_trigger; Type: TRIGGER; Schema: geohistory; Owner: postgres
--

CREATE TRIGGER government_insertupdate_trigger BEFORE INSERT OR UPDATE OF governmentcurrentleadparent, governmentlevel ON geohistory.government FOR EACH ROW EXECUTE FUNCTION geohistory.government_insertupdate();


--
-- Name: governmentothercurrentparent governmentothercurrentparent_insertupdate_trigger; Type: TRIGGER; Schema: geohistory; Owner: postgres
--

CREATE TRIGGER governmentothercurrentparent_insertupdate_trigger BEFORE INSERT OR UPDATE ON geohistory.governmentothercurrentparent FOR EACH ROW EXECUTE FUNCTION geohistory.governmentothercurrentparent_insertupdate();


--
-- Name: law law_insertupdate_trigger; Type: TRIGGER; Schema: geohistory; Owner: postgres
--

CREATE TRIGGER law_insertupdate_trigger BEFORE INSERT OR UPDATE OF source ON geohistory.law FOR EACH ROW EXECUTE FUNCTION geohistory.law_insertupdate();


--
-- Name: lawalternate lawalternate_update_trigger; Type: TRIGGER; Schema: geohistory; Owner: postgres
--

CREATE TRIGGER lawalternate_update_trigger BEFORE UPDATE OF law ON geohistory.lawalternate FOR EACH ROW EXECUTE FUNCTION geohistory.lawalternate_update();


--
-- Name: lawalternatesection lawalternatesection_insertupdate_trigger; Type: TRIGGER; Schema: geohistory; Owner: postgres
--

CREATE TRIGGER lawalternatesection_insertupdate_trigger BEFORE INSERT OR UPDATE OF lawalternate, lawsection ON geohistory.lawalternatesection FOR EACH ROW EXECUTE FUNCTION geohistory.lawalternatesection_insertupdate();


--
-- Name: lawgroupsection lawgroupsection_deleteupdate_trigger; Type: TRIGGER; Schema: geohistory; Owner: postgres
--

CREATE TRIGGER lawgroupsection_deleteupdate_trigger BEFORE DELETE OR UPDATE OF lawgroup, lawsection, eventrelationship ON geohistory.lawgroupsection FOR EACH ROW EXECUTE FUNCTION geohistory.lawgroupsection_deleteupdate();


--
-- Name: lawsection lawsection_update_trigger; Type: TRIGGER; Schema: geohistory; Owner: postgres
--

CREATE TRIGGER lawsection_update_trigger BEFORE UPDATE OF law ON geohistory.lawsection FOR EACH ROW EXECUTE FUNCTION geohistory.lawsection_update();


--
-- Name: lawsectionevent lawsectionevent_insertupdate_trigger; Type: TRIGGER; Schema: geohistory; Owner: postgres
--

CREATE TRIGGER lawsectionevent_insertupdate_trigger BEFORE INSERT OR UPDATE OF lawsection, eventrelationship, lawgroup ON geohistory.lawsectionevent FOR EACH ROW EXECUTE FUNCTION geohistory.lawsectionevent_insertupdate();


--
-- Name: metesdescriptionline metesdescriptionline_insertupdate_trigger; Type: TRIGGER; Schema: geohistory; Owner: postgres
--

CREATE TRIGGER metesdescriptionline_insertupdate_trigger BEFORE INSERT OR UPDATE OF metesdescriptionline ON geohistory.metesdescriptionline FOR EACH ROW EXECUTE FUNCTION geohistory.metesdescriptionline_insertupdate();


--
-- Name: source source_insert_trigger; Type: TRIGGER; Schema: geohistory; Owner: postgres
--

CREATE TRIGGER source_insert_trigger BEFORE INSERT ON geohistory.source FOR EACH ROW EXECUTE FUNCTION geohistory.source_insert();


--
-- Name: source source_update_trigger; Type: TRIGGER; Schema: geohistory; Owner: postgres
--

CREATE TRIGGER source_update_trigger BEFORE UPDATE OF sourcetype ON geohistory.source FOR EACH ROW EXECUTE FUNCTION geohistory.source_update();


--
-- Name: sourcetype sourcetype_update_trigger; Type: TRIGGER; Schema: geohistory; Owner: postgres
--

CREATE TRIGGER sourcetype_update_trigger BEFORE UPDATE OF sourcetypeislaw ON geohistory.sourcetype FOR EACH ROW EXECUTE FUNCTION geohistory.sourcetype_update();


--
-- Name: governmentshape governmentshape_delete_trigger; Type: TRIGGER; Schema: gis; Owner: postgres
--

CREATE TRIGGER governmentshape_delete_trigger BEFORE DELETE ON gis.governmentshape FOR EACH ROW EXECUTE FUNCTION gis.governmentshape_delete();


--
-- Name: governmentshape governmentshape_insert_trigger; Type: TRIGGER; Schema: gis; Owner: postgres
--

CREATE TRIGGER governmentshape_insert_trigger AFTER INSERT ON gis.governmentshape FOR EACH ROW EXECUTE FUNCTION gis.governmentshape_insert();


--
-- Name: adjudication adjudication_adjudicationtype_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudication
    ADD CONSTRAINT adjudication_adjudicationtype_fk FOREIGN KEY (adjudicationtype) REFERENCES geohistory.adjudicationtype(adjudicationtypeid) DEFERRABLE;


--
-- Name: adjudicationevent adjudicationevent_adjudication_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationevent
    ADD CONSTRAINT adjudicationevent_adjudication_fk FOREIGN KEY (adjudication) REFERENCES geohistory.adjudication(adjudicationid) DEFERRABLE;


--
-- Name: adjudicationevent adjudicationevent_event_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationevent
    ADD CONSTRAINT adjudicationevent_event_fk FOREIGN KEY (event) REFERENCES geohistory.event(eventid) DEFERRABLE;


--
-- Name: adjudicationevent adjudicationevent_eventrelationship_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationevent
    ADD CONSTRAINT adjudicationevent_eventrelationship_fk FOREIGN KEY (eventrelationship) REFERENCES geohistory.eventrelationship(eventrelationshipid) DEFERRABLE;


--
-- Name: adjudicationlocation adjudicationlocation_adjudication_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationlocation
    ADD CONSTRAINT adjudicationlocation_adjudication_fk FOREIGN KEY (adjudication) REFERENCES geohistory.adjudication(adjudicationid) DEFERRABLE;


--
-- Name: adjudicationlocation adjudicationlocation_adjudicationlocationtype_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationlocation
    ADD CONSTRAINT adjudicationlocation_adjudicationlocationtype_fk FOREIGN KEY (adjudicationlocationtype) REFERENCES geohistory.adjudicationlocationtype(adjudicationlocationtypeid) DEFERRABLE;


--
-- Name: adjudicationlocationtype adjudicationlocationtype_tribunal_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationlocationtype
    ADD CONSTRAINT adjudicationlocationtype_tribunal_fk FOREIGN KEY (tribunal) REFERENCES geohistory.tribunal(tribunalid) DEFERRABLE;


--
-- Name: adjudicationsourcecitation adjudicationsourcecitation_adjudication_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationsourcecitation
    ADD CONSTRAINT adjudicationsourcecitation_adjudication_fk FOREIGN KEY (adjudication) REFERENCES geohistory.adjudication(adjudicationid) DEFERRABLE;


--
-- Name: adjudicationsourcecitation adjudicationsourcecitation_source_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationsourcecitation
    ADD CONSTRAINT adjudicationsourcecitation_source_fk FOREIGN KEY (source) REFERENCES geohistory.source(sourceid) DEFERRABLE;


--
-- Name: adjudicationtype adjudicationtype_tribunal_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.adjudicationtype
    ADD CONSTRAINT adjudicationtype_tribunal_fk FOREIGN KEY (tribunal) REFERENCES geohistory.tribunal(tribunalid) DEFERRABLE;


--
-- Name: affectedgovernmentgroup affectedgovernmentgroup_event_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentgroup
    ADD CONSTRAINT affectedgovernmentgroup_event_fk FOREIGN KEY (event) REFERENCES geohistory.event(eventid) DEFERRABLE;


--
-- Name: affectedgovernmentgrouppart affectedgovernmentgrouppart_affectedgovernmentgroup_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentgrouppart
    ADD CONSTRAINT affectedgovernmentgrouppart_affectedgovernmentgroup_fk FOREIGN KEY (affectedgovernmentgroup) REFERENCES geohistory.affectedgovernmentgroup(affectedgovernmentgroupid) DEFERRABLE;


--
-- Name: affectedgovernmentgrouppart affectedgovernmentgrouppart_affectedgovernmentlevel_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentgrouppart
    ADD CONSTRAINT affectedgovernmentgrouppart_affectedgovernmentlevel_fk FOREIGN KEY (affectedgovernmentlevel) REFERENCES geohistory.affectedgovernmentlevel(affectedgovernmentlevelid) DEFERRABLE;


--
-- Name: affectedgovernmentgrouppart affectedgovernmentgrouppart_affectedgovernmentpart_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentgrouppart
    ADD CONSTRAINT affectedgovernmentgrouppart_affectedgovernmentpart_fk FOREIGN KEY (affectedgovernmentpart) REFERENCES geohistory.affectedgovernmentpart(affectedgovernmentpartid) DEFERRABLE;


--
-- Name: affectedgovernmentpart affectedgovernmentpart_affectedtypefrom_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentpart
    ADD CONSTRAINT affectedgovernmentpart_affectedtypefrom_fk FOREIGN KEY (affectedtypefrom) REFERENCES geohistory.affectedtype(affectedtypeid) DEFERRABLE;


--
-- Name: affectedgovernmentpart affectedgovernmentpart_affectedtypeto_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentpart
    ADD CONSTRAINT affectedgovernmentpart_affectedtypeto_fk FOREIGN KEY (affectedtypeto) REFERENCES geohistory.affectedtype(affectedtypeid) DEFERRABLE;


--
-- Name: affectedgovernmentpart affectedgovernmentpart_governmentformto_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentpart
    ADD CONSTRAINT affectedgovernmentpart_governmentformto_fk FOREIGN KEY (governmentformto) REFERENCES geohistory.governmentform(governmentformid) DEFERRABLE;


--
-- Name: affectedgovernmentpart affectedgovernmentpart_governmentfrom_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentpart
    ADD CONSTRAINT affectedgovernmentpart_governmentfrom_fk FOREIGN KEY (governmentfrom) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: affectedgovernmentpart affectedgovernmentpart_governmentto_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.affectedgovernmentpart
    ADD CONSTRAINT affectedgovernmentpart_governmentto_fk FOREIGN KEY (governmentto) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: censusmap censusmap_government_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.censusmap
    ADD CONSTRAINT censusmap_government_fk FOREIGN KEY (government) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: currentgovernment currentgovernment_event_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.currentgovernment
    ADD CONSTRAINT currentgovernment_event_fk FOREIGN KEY (event) REFERENCES geohistory.event(eventid) DEFERRABLE;


--
-- Name: currentgovernment currentgovernment_governmentcounty_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.currentgovernment
    ADD CONSTRAINT currentgovernment_governmentcounty_fk FOREIGN KEY (governmentcounty) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: currentgovernment currentgovernment_governmentmunicipality_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.currentgovernment
    ADD CONSTRAINT currentgovernment_governmentmunicipality_fk FOREIGN KEY (governmentmunicipality) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: currentgovernment currentgovernment_governmentstate_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.currentgovernment
    ADD CONSTRAINT currentgovernment_governmentstate_fk FOREIGN KEY (governmentstate) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: currentgovernment currentgovernment_governmentsubmunicipality_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.currentgovernment
    ADD CONSTRAINT currentgovernment_governmentsubmunicipality_fk FOREIGN KEY (governmentsubmunicipality) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: event event_eventeffectivetypepresumedsource_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.event
    ADD CONSTRAINT event_eventeffectivetypepresumedsource_fk FOREIGN KEY (eventeffectivetypepresumedsource) REFERENCES geohistory.eventeffectivetype(eventeffectivetypeid) DEFERRABLE;


--
-- Name: event event_eventeffectivetypestatutory_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.event
    ADD CONSTRAINT event_eventeffectivetypestatutory_fk FOREIGN KEY (eventeffectivetypestatutory) REFERENCES geohistory.eventeffectivetype(eventeffectivetypeid) DEFERRABLE;


--
-- Name: event event_eventgranted_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.event
    ADD CONSTRAINT event_eventgranted_fk FOREIGN KEY (eventgranted) REFERENCES geohistory.eventgranted(eventgrantedid) DEFERRABLE;


--
-- Name: event event_eventmethod_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.event
    ADD CONSTRAINT event_eventmethod_fk FOREIGN KEY (eventmethod) REFERENCES geohistory.eventmethod(eventmethodid) DEFERRABLE;


--
-- Name: event event_eventtype_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.event
    ADD CONSTRAINT event_eventtype_fk FOREIGN KEY (eventtype) REFERENCES geohistory.eventtype(eventtypeid) DEFERRABLE;


--
-- Name: filing filing_adjudication_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.filing
    ADD CONSTRAINT filing_adjudication_fk FOREIGN KEY (adjudication) REFERENCES geohistory.adjudication(adjudicationid) DEFERRABLE;


--
-- Name: filing filing_filingtype_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.filing
    ADD CONSTRAINT filing_filingtype_fk FOREIGN KEY (filingtype) REFERENCES geohistory.filingtype(filingtypeid) DEFERRABLE;


--
-- Name: government government_governmentcurrentform_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.government
    ADD CONSTRAINT government_governmentcurrentform_fk FOREIGN KEY (governmentcurrentform) REFERENCES geohistory.governmentform(governmentformid) DEFERRABLE;


--
-- Name: government government_governmentcurrentleadparent_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.government
    ADD CONSTRAINT government_governmentcurrentleadparent_fk FOREIGN KEY (governmentcurrentleadparent) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: government government_governmentmapstatus_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.government
    ADD CONSTRAINT government_governmentmapstatus_fk FOREIGN KEY (governmentmapstatus) REFERENCES geohistory.governmentmapstatus(governmentmapstatusid) DEFERRABLE;


--
-- Name: government government_locale_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.government
    ADD CONSTRAINT government_locale_fk FOREIGN KEY (locale) REFERENCES geohistory.locale(localeid) DEFERRABLE;


--
-- Name: governmentform governmentform_governmentstate_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentform
    ADD CONSTRAINT governmentform_governmentstate_fk FOREIGN KEY (governmentstate) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: governmentformgovernment governmentformgovernment_government_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentformgovernment
    ADD CONSTRAINT governmentformgovernment_government_fk FOREIGN KEY (government) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: governmentformgovernment governmentformgovernment_governmentform_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentformgovernment
    ADD CONSTRAINT governmentformgovernment_governmentform_fk FOREIGN KEY (governmentform) REFERENCES geohistory.governmentform(governmentformid) DEFERRABLE;


--
-- Name: governmentidentifier governmentidentifier_government_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentidentifier
    ADD CONSTRAINT governmentidentifier_government_fk FOREIGN KEY (government) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: governmentidentifier governmentidentifier_governmentidentifiertype_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentidentifier
    ADD CONSTRAINT governmentidentifier_governmentidentifiertype_fk FOREIGN KEY (governmentidentifiertype) REFERENCES geohistory.governmentidentifiertype(governmentidentifiertypeid) DEFERRABLE;


--
-- Name: governmentothercurrentparent governmentothercurrentparent_government_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentothercurrentparent
    ADD CONSTRAINT governmentothercurrentparent_government_fk FOREIGN KEY (government) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: governmentothercurrentparent governmentothercurrentparent_governmentothercurrentparent_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentothercurrentparent
    ADD CONSTRAINT governmentothercurrentparent_governmentothercurrentparent_fk FOREIGN KEY (governmentothercurrentparent) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: governmentsource governmentsource_government_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentsource
    ADD CONSTRAINT governmentsource_government_fk FOREIGN KEY (government) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: governmentsource governmentsource_source_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentsource
    ADD CONSTRAINT governmentsource_source_fk FOREIGN KEY (source) REFERENCES geohistory.source(sourceid) DEFERRABLE;


--
-- Name: governmentsourceevent governmentsourceevent_event_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentsourceevent
    ADD CONSTRAINT governmentsourceevent_event_fk FOREIGN KEY (event) REFERENCES geohistory.event(eventid) DEFERRABLE;


--
-- Name: governmentsourceevent governmentsourceevent_eventrelationship_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentsourceevent
    ADD CONSTRAINT governmentsourceevent_eventrelationship_fk FOREIGN KEY (eventrelationship) REFERENCES geohistory.eventrelationship(eventrelationshipid) DEFERRABLE;


--
-- Name: governmentsourceevent governmentsourceevent_governmentsource_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.governmentsourceevent
    ADD CONSTRAINT governmentsourceevent_governmentsource_fk FOREIGN KEY (governmentsource) REFERENCES geohistory.governmentsource(governmentsourceid) DEFERRABLE;


--
-- Name: law law_source_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.law
    ADD CONSTRAINT law_source_fk FOREIGN KEY (source) REFERENCES geohistory.source(sourceid) DEFERRABLE;


--
-- Name: lawalternate lawalternate_law_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawalternate
    ADD CONSTRAINT lawalternate_law_fk FOREIGN KEY (law) REFERENCES geohistory.law(lawid) DEFERRABLE;


--
-- Name: lawalternate lawalternate_source_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawalternate
    ADD CONSTRAINT lawalternate_source_fk FOREIGN KEY (source) REFERENCES geohistory.source(sourceid) DEFERRABLE;


--
-- Name: lawalternatesection lawalternatesection_lawalternate_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawalternatesection
    ADD CONSTRAINT lawalternatesection_lawalternate_fk FOREIGN KEY (lawalternate) REFERENCES geohistory.lawalternate(lawalternateid) DEFERRABLE;


--
-- Name: lawalternatesection lawalternatesection_lawsection_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawalternatesection
    ADD CONSTRAINT lawalternatesection_lawsection_fk FOREIGN KEY (lawsection) REFERENCES geohistory.lawsection(lawsectionid) DEFERRABLE;


--
-- Name: lawgroup lawgroup_eventeffectivetype_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroup
    ADD CONSTRAINT lawgroup_eventeffectivetype_fk FOREIGN KEY (eventeffectivetype) REFERENCES geohistory.eventeffectivetype(eventeffectivetypeid) DEFERRABLE;


--
-- Name: lawgroupeventtype lawgroupeventtype_eventtype_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupeventtype
    ADD CONSTRAINT lawgroupeventtype_eventtype_fk FOREIGN KEY (eventtype) REFERENCES geohistory.eventtype(eventtypeid) DEFERRABLE;


--
-- Name: lawgroupeventtype lawgroupeventtype_lawgroup_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupeventtype
    ADD CONSTRAINT lawgroupeventtype_lawgroup_fk FOREIGN KEY (lawgroup) REFERENCES geohistory.lawgroup(lawgroupid) DEFERRABLE;


--
-- Name: lawgroupgovernmenttype lawgroupgovernmenttype_lawgroup_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupgovernmenttype
    ADD CONSTRAINT lawgroupgovernmenttype_lawgroup_fk FOREIGN KEY (lawgroup) REFERENCES geohistory.lawgroup(lawgroupid) DEFERRABLE;


--
-- Name: lawgroupsection lawgroupsection_eventrelationship_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupsection
    ADD CONSTRAINT lawgroupsection_eventrelationship_fk FOREIGN KEY (eventrelationship) REFERENCES geohistory.eventrelationship(eventrelationshipid) DEFERRABLE;


--
-- Name: lawgroupsection lawgroupsection_lawgroup_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupsection
    ADD CONSTRAINT lawgroupsection_lawgroup_fk FOREIGN KEY (lawgroup) REFERENCES geohistory.lawgroup(lawgroupid) DEFERRABLE;


--
-- Name: lawgroupsection lawgroupsection_lawsection_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawgroupsection
    ADD CONSTRAINT lawgroupsection_lawsection_fk FOREIGN KEY (lawsection) REFERENCES geohistory.lawsection(lawsectionid) DEFERRABLE;


--
-- Name: lawsection lawsection_eventtype_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawsection
    ADD CONSTRAINT lawsection_eventtype_fk FOREIGN KEY (eventtype) REFERENCES geohistory.eventtype(eventtypeid) DEFERRABLE;


--
-- Name: lawsection lawsection_law_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawsection
    ADD CONSTRAINT lawsection_law_fk FOREIGN KEY (law) REFERENCES geohistory.law(lawid) DEFERRABLE;


--
-- Name: lawsection lawsection_lawsectionamend_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawsection
    ADD CONSTRAINT lawsection_lawsectionamend_fk FOREIGN KEY (lawsectionamend) REFERENCES geohistory.lawsection(lawsectionid) DEFERRABLE;


--
-- Name: lawsection lawsection_lawsectionnewlaw_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawsection
    ADD CONSTRAINT lawsection_lawsectionnewlaw_fk FOREIGN KEY (lawsectionnewlaw) REFERENCES geohistory.law(lawid) DEFERRABLE;


--
-- Name: lawsectionevent lawsectionevent_event_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawsectionevent
    ADD CONSTRAINT lawsectionevent_event_fk FOREIGN KEY (event) REFERENCES geohistory.event(eventid) DEFERRABLE;


--
-- Name: lawsectionevent lawsectionevent_eventrelationship_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawsectionevent
    ADD CONSTRAINT lawsectionevent_eventrelationship_fk FOREIGN KEY (eventrelationship) REFERENCES geohistory.eventrelationship(eventrelationshipid) DEFERRABLE;


--
-- Name: lawsectionevent lawsectionevent_lawgroup_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawsectionevent
    ADD CONSTRAINT lawsectionevent_lawgroup_fk FOREIGN KEY (lawgroup) REFERENCES geohistory.lawgroup(lawgroupid) DEFERRABLE;


--
-- Name: lawsectionevent lawsectionevent_lawsection_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.lawsectionevent
    ADD CONSTRAINT lawsectionevent_lawsection_fk FOREIGN KEY (lawsection) REFERENCES geohistory.lawsection(lawsectionid) DEFERRABLE;


--
-- Name: metesdescription metesdescription_event_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.metesdescription
    ADD CONSTRAINT metesdescription_event_fk FOREIGN KEY (event) REFERENCES geohistory.event(eventid) DEFERRABLE;


--
-- Name: metesdescriptionline metesdescriptionline_metesdescription_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.metesdescriptionline
    ADD CONSTRAINT metesdescriptionline_metesdescription_fk FOREIGN KEY (metesdescription) REFERENCES geohistory.metesdescription(metesdescriptionid) DEFERRABLE;


--
-- Name: nationalarchives nationalarchives_government_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.nationalarchives
    ADD CONSTRAINT nationalarchives_government_fk FOREIGN KEY (government) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: plss plss_event_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plss
    ADD CONSTRAINT plss_event_fk FOREIGN KEY (event) REFERENCES geohistory.event(eventid) DEFERRABLE;


--
-- Name: plss plss_plssfirstdivision_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plss
    ADD CONSTRAINT plss_plssfirstdivision_fk FOREIGN KEY (plssfirstdivision) REFERENCES geohistory.plssfirstdivision(plssfirstdivisionid) DEFERRABLE;


--
-- Name: plss plss_plssrelationship_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plss
    ADD CONSTRAINT plss_plssrelationship_fk FOREIGN KEY (plssrelationship) REFERENCES geohistory.eventrelationship(eventrelationshipshort) DEFERRABLE;


--
-- Name: plss plss_plssseconddivision_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plss
    ADD CONSTRAINT plss_plssseconddivision_fk FOREIGN KEY (plssseconddivision) REFERENCES geohistory.plssseconddivision(plssseconddivisionid) DEFERRABLE;


--
-- Name: plss plss_plssspecialsurvey_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plss
    ADD CONSTRAINT plss_plssspecialsurvey_fk FOREIGN KEY (plssspecialsurvey) REFERENCES geohistory.plssspecialsurvey(plssspecialsurveyid) DEFERRABLE;


--
-- Name: plss plss_plsstownship_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plss
    ADD CONSTRAINT plss_plsstownship_fk FOREIGN KEY (plsstownship) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: plsstownship plsstownship_governmentstate_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plsstownship
    ADD CONSTRAINT plsstownship_governmentstate_fk FOREIGN KEY (governmentstate) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: plsstownship plsstownship_plssmeridian_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.plsstownship
    ADD CONSTRAINT plsstownship_plssmeridian_fk FOREIGN KEY (plssmeridian) REFERENCES geohistory.plssmeridian(plssmeridianid) DEFERRABLE;


--
-- Name: recording recording_recordingnumbertype_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recording
    ADD CONSTRAINT recording_recordingnumbertype_fk FOREIGN KEY (recordingnumbertype) REFERENCES geohistory.recordingtype(recordingtypeid) DEFERRABLE;


--
-- Name: recording recording_recordingoffice_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recording
    ADD CONSTRAINT recording_recordingoffice_fk FOREIGN KEY (recordingoffice) REFERENCES geohistory.recordingoffice(recordingofficeid) DEFERRABLE;


--
-- Name: recording recording_recordingtype_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recording
    ADD CONSTRAINT recording_recordingtype_fk FOREIGN KEY (recordingtype) REFERENCES geohistory.recordingtype(recordingtypeid) DEFERRABLE;


--
-- Name: recordingevent recordingevent_event_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recordingevent
    ADD CONSTRAINT recordingevent_event_fk FOREIGN KEY (event) REFERENCES geohistory.event(eventid) DEFERRABLE;


--
-- Name: recordingevent recordingevent_eventrelationship_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recordingevent
    ADD CONSTRAINT recordingevent_eventrelationship_fk FOREIGN KEY (eventrelationship) REFERENCES geohistory.eventrelationship(eventrelationshipid) DEFERRABLE;


--
-- Name: recordingevent recordingevent_recording_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recordingevent
    ADD CONSTRAINT recordingevent_recording_fk FOREIGN KEY (recording) REFERENCES geohistory.recording(recordingid) DEFERRABLE;


--
-- Name: recordingoffice recordingoffice_government_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recordingoffice
    ADD CONSTRAINT recordingoffice_government_fk FOREIGN KEY (government) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: recordingoffice recordingoffice_recordingofficetype_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.recordingoffice
    ADD CONSTRAINT recordingoffice_recordingofficetype_fk FOREIGN KEY (recordingofficetype) REFERENCES geohistory.recordingofficetype(recordingofficetypeid) DEFERRABLE;


--
-- Name: researchlog researchlog_event_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.researchlog
    ADD CONSTRAINT researchlog_event_fk FOREIGN KEY (event) REFERENCES geohistory.event(eventid) DEFERRABLE;


--
-- Name: researchlog researchlog_government_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.researchlog
    ADD CONSTRAINT researchlog_government_fk FOREIGN KEY (government) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: researchlog researchlog_researchlogtype_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.researchlog
    ADD CONSTRAINT researchlog_researchlogtype_fk FOREIGN KEY (researchlogtype) REFERENCES geohistory.researchlogtype(researchlogtypeid) DEFERRABLE;


--
-- Name: source source_sourcetype_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.source
    ADD CONSTRAINT source_sourcetype_fk FOREIGN KEY (sourcetype) REFERENCES geohistory.sourcetype(sourcetypeshort) DEFERRABLE;


--
-- Name: source source_sourceurlsubstitute_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.source
    ADD CONSTRAINT source_sourceurlsubstitute_fk FOREIGN KEY (sourceurlsubstitute) REFERENCES geohistory.source(sourceid) DEFERRABLE;


--
-- Name: sourcecitation sourcecitation_source_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitation
    ADD CONSTRAINT sourcecitation_source_fk FOREIGN KEY (source) REFERENCES geohistory.source(sourceid) DEFERRABLE;


--
-- Name: sourcecitationevent sourcecitationevent_event_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitationevent
    ADD CONSTRAINT sourcecitationevent_event_fk FOREIGN KEY (event) REFERENCES geohistory.event(eventid) DEFERRABLE;


--
-- Name: sourcecitationevent sourcecitationevent_sourcecitation_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitationevent
    ADD CONSTRAINT sourcecitationevent_sourcecitation_fk FOREIGN KEY (sourcecitation) REFERENCES geohistory.sourcecitation(sourcecitationid) DEFERRABLE;


--
-- Name: sourcecitationnote sourcecitationnote_sourcecitation_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitationnote
    ADD CONSTRAINT sourcecitationnote_sourcecitation_fk FOREIGN KEY (sourcecitation) REFERENCES geohistory.sourcecitation(sourcecitationid) DEFERRABLE;


--
-- Name: sourcecitationnote sourcecitationnote_sourcecitationnotetype_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitationnote
    ADD CONSTRAINT sourcecitationnote_sourcecitationnotetype_fk FOREIGN KEY (sourcecitationnotetype) REFERENCES geohistory.sourcecitationnotetype(sourcecitationnotetypeid) DEFERRABLE;


--
-- Name: sourcecitationnotetype sourcecitationnotetype_source_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcecitationnotetype
    ADD CONSTRAINT sourcecitationnotetype_source_fk FOREIGN KEY (source) REFERENCES geohistory.source(sourceid) DEFERRABLE;


--
-- Name: sourcegovernment sourcegovernment_government_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcegovernment
    ADD CONSTRAINT sourcegovernment_government_fk FOREIGN KEY (government) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: sourcegovernment sourcegovernment_source_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourcegovernment
    ADD CONSTRAINT sourcegovernment_source_fk FOREIGN KEY (source) REFERENCES geohistory.source(sourceid) DEFERRABLE;


--
-- Name: sourceitem sourceitem_source_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourceitem
    ADD CONSTRAINT sourceitem_source_fk FOREIGN KEY (source) REFERENCES geohistory.source(sourceid) DEFERRABLE;


--
-- Name: sourceitempart sourceitempart_sourceitem_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.sourceitempart
    ADD CONSTRAINT sourceitempart_sourceitem_fk FOREIGN KEY (sourceitem) REFERENCES geohistory.sourceitem(sourceitemid) DEFERRABLE;


--
-- Name: tribunal tribunal_government_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.tribunal
    ADD CONSTRAINT tribunal_government_fk FOREIGN KEY (government) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: tribunal tribunal_tribunaltype_fk; Type: FK CONSTRAINT; Schema: geohistory; Owner: postgres
--

ALTER TABLE ONLY geohistory.tribunal
    ADD CONSTRAINT tribunal_tribunaltype_fk FOREIGN KEY (tribunaltype) REFERENCES geohistory.tribunaltype(tribunaltypeid) DEFERRABLE;


--
-- Name: affectedgovernmentgis affectedgovernmentgis_affectedgovernment_fk; Type: FK CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.affectedgovernmentgis
    ADD CONSTRAINT affectedgovernmentgis_affectedgovernment_fk FOREIGN KEY (affectedgovernment) REFERENCES geohistory.affectedgovernmentgroup(affectedgovernmentgroupid) DEFERRABLE;


--
-- Name: affectedgovernmentgis affectedgovernmentgis_governmentshape_fk; Type: FK CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.affectedgovernmentgis
    ADD CONSTRAINT affectedgovernmentgis_governmentshape_fk FOREIGN KEY (governmentshape) REFERENCES gis.governmentshape(governmentshapeid) DEFERRABLE;


--
-- Name: governmentshape governmentshape_governmentcounty_fk; Type: FK CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.governmentshape
    ADD CONSTRAINT governmentshape_governmentcounty_fk FOREIGN KEY (governmentcounty) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: governmentshape governmentshape_governmentmunicipality_fk; Type: FK CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.governmentshape
    ADD CONSTRAINT governmentshape_governmentmunicipality_fk FOREIGN KEY (governmentmunicipality) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: governmentshape governmentshape_governmentschooldistrict_fk; Type: FK CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.governmentshape
    ADD CONSTRAINT governmentshape_governmentschooldistrict_fk FOREIGN KEY (governmentschooldistrict) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: governmentshape governmentshape_governmentshapeplsstownship_fk; Type: FK CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.governmentshape
    ADD CONSTRAINT governmentshape_governmentshapeplsstownship_fk FOREIGN KEY (governmentshapeplsstownship) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: governmentshape governmentshape_governmentstate_fk; Type: FK CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.governmentshape
    ADD CONSTRAINT governmentshape_governmentstate_fk FOREIGN KEY (governmentstate) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: governmentshape governmentshape_governmentsubmunicipality_fk; Type: FK CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.governmentshape
    ADD CONSTRAINT governmentshape_governmentsubmunicipality_fk FOREIGN KEY (governmentsubmunicipality) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: governmentshape governmentshape_governmentward_fk; Type: FK CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.governmentshape
    ADD CONSTRAINT governmentshape_governmentward_fk FOREIGN KEY (governmentward) REFERENCES geohistory.government(governmentid) DEFERRABLE;


--
-- Name: metesdescriptiongis metesdescriptiongis_governmentshape_fk; Type: FK CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.metesdescriptiongis
    ADD CONSTRAINT metesdescriptiongis_governmentshape_fk FOREIGN KEY (governmentshape) REFERENCES gis.governmentshape(governmentshapeid) DEFERRABLE;


--
-- Name: metesdescriptiongis metesdescriptiongis_metesdescription_fk; Type: FK CONSTRAINT; Schema: gis; Owner: postgres
--

ALTER TABLE ONLY gis.metesdescriptiongis
    ADD CONSTRAINT metesdescriptiongis_metesdescription_fk FOREIGN KEY (metesdescription) REFERENCES geohistory.metesdescription(metesdescriptionid) DEFERRABLE;


--
-- Name: SCHEMA extra; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extra TO readonly;


--
-- Name: FUNCTION affectedtypeshort(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.affectedtypeshort(integer) FROM PUBLIC;


--
-- Name: FUNCTION array_combine(integer[]); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.array_combine(integer[]) FROM PUBLIC;


--
-- Name: FUNCTION ci_model_area_affectedgovernment(v_governmentshape integer, v_state character varying, v_locale character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_area_affectedgovernment(v_governmentshape integer, v_state character varying, v_locale character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_area_affectedgovernment(v_governmentshape integer, v_state character varying, v_locale character varying) TO readonly;


--
-- Name: FUNCTION ci_model_area_currentgovernment(v_governmentshapeid integer, v_state character varying, v_locale character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_area_currentgovernment(v_governmentshapeid integer, v_state character varying, v_locale character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_area_currentgovernment(v_governmentshapeid integer, v_state character varying, v_locale character varying) TO readonly;


--
-- Name: FUNCTION ci_model_area_currentgovernment(v_governmentshapeid text, v_state character varying, v_locale character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_area_currentgovernment(v_governmentshapeid text, v_state character varying, v_locale character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_area_currentgovernment(v_governmentshapeid text, v_state character varying, v_locale character varying) TO readonly;


--
-- Name: FUNCTION ci_model_area_event_failure(integer, integer[]); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_area_event_failure(integer, integer[]) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_area_event_failure(integer, integer[]) TO readonly;


--
-- Name: FUNCTION ci_model_area_metesdescription(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_area_metesdescription(integer) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_area_metesdescription(integer) TO readonly;


--
-- Name: FUNCTION ci_model_area_point(pointy double precision, pointx double precision); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_area_point(pointy double precision, pointx double precision) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_area_point(pointy double precision, pointx double precision) TO readonly;


--
-- Name: FUNCTION ci_model_event_adjudication(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_event_adjudication(integer) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_event_adjudication(integer) TO readonly;


--
-- Name: FUNCTION ci_model_event_affectedgovernment(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_event_affectedgovernment(integer) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_event_affectedgovernment(integer) TO readonly;


--
-- Name: FUNCTION ci_model_event_affectedgovernment2(integer, character varying, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_event_affectedgovernment2(integer, character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_event_affectedgovernment2(integer, character varying, character varying) TO readonly;


--
-- Name: FUNCTION ci_model_event_affectedgovernment_part(integer, character varying, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_event_affectedgovernment_part(integer, character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_event_affectedgovernment_part(integer, character varying, character varying) TO readonly;


--
-- Name: FUNCTION ci_model_event_affectedgovernmentform(integer, character varying, boolean, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_event_affectedgovernmentform(integer, character varying, boolean, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_event_affectedgovernmentform(integer, character varying, boolean, character varying) TO readonly;


--
-- Name: FUNCTION ci_model_event_currentgovernment(integer, character varying, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_event_currentgovernment(integer, character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_event_currentgovernment(integer, character varying, character varying) TO readonly;


--
-- Name: FUNCTION ci_model_event_detail(integer, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_event_detail(integer, character varying) FROM PUBLIC;


--
-- Name: FUNCTION ci_model_event_detail(text, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_event_detail(text, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_event_detail(text, character varying) TO readonly;


--
-- Name: FUNCTION ci_model_event_governmentsource(integer, character varying, boolean, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_event_governmentsource(integer, character varying, boolean, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_event_governmentsource(integer, character varying, boolean, character varying) TO readonly;


--
-- Name: FUNCTION ci_model_event_law(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_event_law(integer) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_event_law(integer) TO readonly;


--
-- Name: FUNCTION ci_model_event_metesdescription(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_event_metesdescription(integer) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_event_metesdescription(integer) TO readonly;


--
-- Name: FUNCTION ci_model_event_plss(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_event_plss(integer) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_event_plss(integer) TO readonly;


--
-- Name: FUNCTION ci_model_event_recording(integer, character varying, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_event_recording(integer, character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_event_recording(integer, character varying, character varying) TO readonly;


--
-- Name: FUNCTION ci_model_event_source(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_event_source(integer) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_event_source(integer) TO readonly;


--
-- Name: FUNCTION ci_model_government_affectedgovernment(integer, character varying, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_government_affectedgovernment(integer, character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_government_affectedgovernment(integer, character varying, character varying) TO readonly;


--
-- Name: FUNCTION ci_model_governmentabbreviation(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_governmentabbreviation(integer) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_governmentabbreviation(integer) TO readonly;


--
-- Name: FUNCTION ci_model_governmentabbreviationid(text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_governmentabbreviationid(text) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_governmentabbreviationid(text) TO readonly;


--
-- Name: FUNCTION ci_model_governmentidentifier_detail(text, text, text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_governmentidentifier_detail(text, text, text) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_governmentidentifier_detail(text, text, text) TO readonly;


--
-- Name: FUNCTION ci_model_governmentidentifier_government(integer[], character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_governmentidentifier_government(integer[], character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_governmentidentifier_government(integer[], character varying) TO readonly;


--
-- Name: FUNCTION ci_model_governmentidentifier_related(integer[], integer[], text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_governmentidentifier_related(integer[], integer[], text) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_governmentidentifier_related(integer[], integer[], text) TO readonly;


--
-- Name: FUNCTION ci_model_governmentlong(integer, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_governmentlong(integer, character varying) FROM PUBLIC;


--
-- Name: FUNCTION ci_model_governmentrecording_detail(integer, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_governmentrecording_detail(integer, character varying) FROM PUBLIC;


--
-- Name: FUNCTION ci_model_governmentsource_detail(integer, character varying, boolean, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_governmentsource_detail(integer, character varying, boolean, character varying) FROM PUBLIC;


--
-- Name: FUNCTION ci_model_governmentsource_detail(text, character varying, boolean, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_governmentsource_detail(text, character varying, boolean, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_governmentsource_detail(text, character varying, boolean, character varying) TO readonly;


--
-- Name: FUNCTION ci_model_governmentsource_event(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_governmentsource_event(integer) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_governmentsource_event(integer) TO readonly;


--
-- Name: FUNCTION ci_model_governmentsource_url(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_governmentsource_url(integer) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_governmentsource_url(integer) TO readonly;


--
-- Name: FUNCTION ci_model_lastrefresh(); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_lastrefresh() FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_lastrefresh() TO readonly;


--
-- Name: FUNCTION ci_model_law_detail(integer, character varying, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_law_detail(integer, character varying, boolean) FROM PUBLIC;


--
-- Name: FUNCTION ci_model_law_detail(text, character varying, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_law_detail(text, character varying, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_law_detail(text, character varying, boolean) TO readonly;


--
-- Name: FUNCTION ci_model_law_event(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_law_event(integer) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_law_event(integer) TO readonly;


--
-- Name: FUNCTION ci_model_law_related(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_law_related(integer) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_law_related(integer) TO readonly;


--
-- Name: FUNCTION ci_model_law_url(integer, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_law_url(integer, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_law_url(integer, boolean) TO readonly;


--
-- Name: FUNCTION ci_model_lawalternate_detail(integer, character varying, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_lawalternate_detail(integer, character varying, boolean) FROM PUBLIC;


--
-- Name: FUNCTION ci_model_lawalternate_detail(text, character varying, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_lawalternate_detail(text, character varying, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_lawalternate_detail(text, character varying, boolean) TO readonly;


--
-- Name: FUNCTION ci_model_lawalternate_event(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_lawalternate_event(integer) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_lawalternate_event(integer) TO readonly;


--
-- Name: FUNCTION ci_model_lawalternate_related(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_lawalternate_related(integer) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_lawalternate_related(integer) TO readonly;


--
-- Name: FUNCTION ci_model_lawalternate_url(integer, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_lawalternate_url(integer, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_lawalternate_url(integer, boolean) TO readonly;


--
-- Name: FUNCTION ci_model_statistics_createddissolved_nation_part(character varying, integer, integer, character varying, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_statistics_createddissolved_nation_part(character varying, integer, integer, character varying, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_statistics_createddissolved_nation_part(character varying, integer, integer, character varying, boolean) TO readonly;


--
-- Name: FUNCTION ci_model_statistics_createddissolved_nation_whole(character varying, integer, integer, character varying, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_statistics_createddissolved_nation_whole(character varying, integer, integer, character varying, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_statistics_createddissolved_nation_whole(character varying, integer, integer, character varying, boolean) TO readonly;


--
-- Name: FUNCTION ci_model_statistics_createddissolved_state_part(character varying, integer, integer, character varying, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_statistics_createddissolved_state_part(character varying, integer, integer, character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_statistics_createddissolved_state_part(character varying, integer, integer, character varying, character varying) TO readonly;


--
-- Name: FUNCTION ci_model_statistics_createddissolved_state_whole(character varying, integer, integer, character varying, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_statistics_createddissolved_state_whole(character varying, integer, integer, character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_statistics_createddissolved_state_whole(character varying, integer, integer, character varying, character varying) TO readonly;


--
-- Name: FUNCTION ci_model_statistics_eventtype(text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_statistics_eventtype(text) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_statistics_eventtype(text) TO readonly;


--
-- Name: FUNCTION ci_model_statistics_eventtype_list(boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_statistics_eventtype_list(boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_statistics_eventtype_list(boolean) TO readonly;


--
-- Name: FUNCTION ci_model_statistics_eventtype_list(character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_statistics_eventtype_list(character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_statistics_eventtype_list(character varying) TO readonly;


--
-- Name: FUNCTION ci_model_statistics_eventtype_nation_part(text, integer, integer, character varying, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_statistics_eventtype_nation_part(text, integer, integer, character varying, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_statistics_eventtype_nation_part(text, integer, integer, character varying, boolean) TO readonly;


--
-- Name: FUNCTION ci_model_statistics_eventtype_nation_whole(text, integer, integer, character varying, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_statistics_eventtype_nation_whole(text, integer, integer, character varying, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_statistics_eventtype_nation_whole(text, integer, integer, character varying, boolean) TO readonly;


--
-- Name: FUNCTION ci_model_statistics_eventtype_state_part(text, integer, integer, character varying, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_statistics_eventtype_state_part(text, integer, integer, character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_statistics_eventtype_state_part(text, integer, integer, character varying, character varying) TO readonly;


--
-- Name: FUNCTION ci_model_statistics_eventtype_state_whole(text, integer, integer, character varying, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_statistics_eventtype_state_whole(text, integer, integer, character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION extra.ci_model_statistics_eventtype_state_whole(text, integer, integer, character varying, character varying) TO readonly;


--
-- Name: FUNCTION ci_model_statistics_mapped_nation_part(character varying, integer, integer, character varying, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_statistics_mapped_nation_part(character varying, integer, integer, character varying, boolean) FROM PUBLIC;


--
-- Name: FUNCTION ci_model_statistics_mapped_nation_whole(character varying, integer, integer, character varying, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_statistics_mapped_nation_whole(character varying, integer, integer, character varying, boolean) FROM PUBLIC;


--
-- Name: FUNCTION ci_model_statistics_mapped_state_part(character varying, integer, integer, character varying, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_statistics_mapped_state_part(character varying, integer, integer, character varying, character varying) FROM PUBLIC;


--
-- Name: FUNCTION ci_model_statistics_mapped_state_whole(character varying, integer, integer, character varying, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.ci_model_statistics_mapped_state_whole(character varying, integer, integer, character varying, character varying) FROM PUBLIC;


--
-- Name: FUNCTION emptytonull(text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.emptytonull(text) FROM PUBLIC;


--
-- Name: FUNCTION eventeffectivetype(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.eventeffectivetype(integer) FROM PUBLIC;


--
-- Name: FUNCTION eventeffectivetype(eventeffectivetypegroup character varying, eventeffectivetypequalifier character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.eventeffectivetype(eventeffectivetypegroup character varying, eventeffectivetypequalifier character varying) FROM PUBLIC;


--
-- Name: FUNCTION eventslug(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.eventslug(integer) FROM PUBLIC;


--
-- Name: FUNCTION eventslugidreplacement(text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.eventslugidreplacement(text) FROM PUBLIC;


--
-- Name: FUNCTION eventsortdate(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.eventsortdate(integer) FROM PUBLIC;


--
-- Name: FUNCTION eventsortdate(eventeffective character varying, eventfrom smallint, eventto smallint, eventeffectiveorder integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.eventsortdate(eventeffective character varying, eventfrom smallint, eventto smallint, eventeffectiveorder integer) FROM PUBLIC;


--
-- Name: FUNCTION eventsortdatedate(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.eventsortdatedate(integer) FROM PUBLIC;


--
-- Name: FUNCTION eventsortdatedate(eventeffective character varying, eventfrom smallint, eventto smallint); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.eventsortdatedate(eventeffective character varying, eventfrom smallint, eventto smallint) FROM PUBLIC;


--
-- Name: FUNCTION eventsortdateyear(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.eventsortdateyear(integer) FROM PUBLIC;


--
-- Name: FUNCTION eventsortdateyear(eventeffective character varying, eventfrom smallint, eventto smallint); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.eventsortdateyear(eventeffective character varying, eventfrom smallint, eventto smallint) FROM PUBLIC;


--
-- Name: FUNCTION eventtextshortdate(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.eventtextshortdate(integer) FROM PUBLIC;


--
-- Name: FUNCTION eventtextshortdate(eventeffective character varying, eventfrom smallint, eventto smallint); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.eventtextshortdate(eventeffective character varying, eventfrom smallint, eventto smallint) FROM PUBLIC;


--
-- Name: FUNCTION fulldate(text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.fulldate(text) FROM PUBLIC;


--
-- Name: FUNCTION governmentabbreviation(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentabbreviation(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentabbreviation(integer, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentabbreviation(integer, character varying) FROM PUBLIC;


--
-- Name: FUNCTION governmentabbreviationid(text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentabbreviationid(text) FROM PUBLIC;


--
-- Name: FUNCTION governmentcurrentleadparent(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentcurrentleadparent(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentcurrentleadstateid(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentcurrentleadstateid(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentformlong(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentformlong(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentformlong(integer, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentformlong(integer, boolean) FROM PUBLIC;


--
-- Name: FUNCTION governmentformlongreport(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentformlongreport(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentindigobook(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentindigobook(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentindigobook(integer, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentindigobook(integer, character varying) FROM PUBLIC;


--
-- Name: FUNCTION governmentlevel(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentlevel(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentlong(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentlong(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentlong(integer, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentlong(integer, character varying) FROM PUBLIC;


--
-- Name: FUNCTION governmentname(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentname(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentshapeslugid(text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentshapeslugid(text) FROM PUBLIC;


--
-- Name: FUNCTION governmentshort(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentshort(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentshort(integer, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentshort(integer, character varying) FROM PUBLIC;


--
-- Name: FUNCTION governmentslug(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentslug(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentslugalternate(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentslugalternate(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentslugid(text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentslugid(text) FROM PUBLIC;


--
-- Name: FUNCTION governmentsourceslugid(text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentsourceslugid(text) FROM PUBLIC;


--
-- Name: FUNCTION governmentstate(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentstate(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentstatelink(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentstatelink(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentstatelink(v_governmentid integer, v_state character varying, v_locale character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentstatelink(v_governmentid integer, v_state character varying, v_locale character varying) FROM PUBLIC;


--
-- Name: FUNCTION governmentstatus(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentstatus(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentsubstitutedcache(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmentsubstitutedcache(integer) FROM PUBLIC;


--
-- Name: FUNCTION governmenttype(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.governmenttype(integer) FROM PUBLIC;


--
-- Name: FUNCTION lawalternatecitation(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.lawalternatecitation(integer) FROM PUBLIC;


--
-- Name: FUNCTION lawalternatecitation(integer, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.lawalternatecitation(integer, boolean) FROM PUBLIC;


--
-- Name: FUNCTION lawalternatesectioncitation(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.lawalternatesectioncitation(integer) FROM PUBLIC;


--
-- Name: FUNCTION lawalternatesectioncitation(integer, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.lawalternatesectioncitation(integer, boolean) FROM PUBLIC;


--
-- Name: FUNCTION lawalternatesectionslug(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.lawalternatesectionslug(integer) FROM PUBLIC;


--
-- Name: FUNCTION lawalternatesectionslugid(text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.lawalternatesectionslugid(text) FROM PUBLIC;


--
-- Name: FUNCTION lawcitation(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.lawcitation(integer) FROM PUBLIC;


--
-- Name: FUNCTION lawcitation(integer, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.lawcitation(integer, boolean) FROM PUBLIC;


--
-- Name: FUNCTION lawsectioncitation(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.lawsectioncitation(integer) FROM PUBLIC;


--
-- Name: FUNCTION lawsectioncitation(integer, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.lawsectioncitation(integer, boolean) FROM PUBLIC;


--
-- Name: FUNCTION lawsectionslug(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.lawsectionslug(integer) FROM PUBLIC;


--
-- Name: FUNCTION lawsectionslugid(text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.lawsectionslugid(text) FROM PUBLIC;


--
-- Name: FUNCTION metesdescriptionlong(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.metesdescriptionlong(integer) FROM PUBLIC;


--
-- Name: FUNCTION metesdescriptionslug(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.metesdescriptionslug(integer) FROM PUBLIC;


--
-- Name: FUNCTION nulltoempty(integer[]); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.nulltoempty(integer[]) FROM PUBLIC;


--
-- Name: FUNCTION nulltoempty(text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.nulltoempty(text) FROM PUBLIC;


--
-- Name: FUNCTION nulltozero(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.nulltozero(integer) FROM PUBLIC;


--
-- Name: FUNCTION nulltozero(bigint); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.nulltozero(bigint) FROM PUBLIC;


--
-- Name: FUNCTION plsstownshiplong(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.plsstownshiplong(integer) FROM PUBLIC;


--
-- Name: FUNCTION plsstownshipshort(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.plsstownshipshort(integer) FROM PUBLIC;


--
-- Name: FUNCTION punctuationhyphen(text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.punctuationhyphen(text) FROM PUBLIC;


--
-- Name: FUNCTION punctuationnone(text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.punctuationnone(text) FROM PUBLIC;


--
-- Name: FUNCTION rangefix(text, text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.rangefix(text, text) FROM PUBLIC;


--
-- Name: FUNCTION refresh_view_long(); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.refresh_view_long() FROM PUBLIC;


--
-- Name: FUNCTION refresh_view_quick(); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.refresh_view_quick() FROM PUBLIC;


--
-- Name: FUNCTION shortdate(text); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.shortdate(text) FROM PUBLIC;


--
-- Name: FUNCTION sourceurlid(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.sourceurlid(integer) FROM PUBLIC;


--
-- Name: FUNCTION tribunalfilingoffice(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.tribunalfilingoffice(integer) FROM PUBLIC;


--
-- Name: FUNCTION tribunalgovernmentshort(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.tribunalgovernmentshort(integer) FROM PUBLIC;


--
-- Name: FUNCTION tribunalgovernmentshort(integer, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.tribunalgovernmentshort(integer, character varying) FROM PUBLIC;


--
-- Name: FUNCTION tribunalgovernmentshort(integer, character varying, boolean); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.tribunalgovernmentshort(integer, character varying, boolean) FROM PUBLIC;


--
-- Name: FUNCTION tribunallong(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.tribunallong(integer) FROM PUBLIC;


--
-- Name: FUNCTION tribunalshort(integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.tribunalshort(integer) FROM PUBLIC;


--
-- Name: FUNCTION tribunalshort(integer, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.tribunalshort(integer, character varying) FROM PUBLIC;


--
-- Name: FUNCTION tribunalshort(integer, integer, character varying); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.tribunalshort(integer, integer, character varying) FROM PUBLIC;


--
-- Name: FUNCTION zeropad(integer, integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.zeropad(integer, integer) FROM PUBLIC;


--
-- Name: FUNCTION zeropad(text, integer); Type: ACL; Schema: extra; Owner: postgres
--

REVOKE ALL ON FUNCTION extra.zeropad(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION source_insert(); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.source_insert() FROM PUBLIC;


--
-- Name: FUNCTION governmentshape_delete(); Type: ACL; Schema: gis; Owner: postgres
--

REVOKE ALL ON FUNCTION gis.governmentshape_delete() FROM PUBLIC;


--
-- Name: FUNCTION governmentshape_insert(); Type: ACL; Schema: gis; Owner: postgres
--

REVOKE ALL ON FUNCTION gis.governmentshape_insert() FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

