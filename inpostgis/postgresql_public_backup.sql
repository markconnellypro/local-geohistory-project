--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6 (Debian 16.6-1.pgdg110+1)
-- Dumped by pg_dump version 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)

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
-- Name: adjudicationtypegovernmentshort(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.adjudicationtypegovernmentshort(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT government.governmentshort
        INTO o_value
        FROM geohistory.adjudicationtype
        JOIN geohistory.tribunal
            ON adjudicationtype.tribunal = tribunal.tribunalid
        JOIN geohistory.government
            ON tribunal.government = government.governmentid
        WHERE adjudicationtypeid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.adjudicationtypegovernmentshort(i_id integer) OWNER TO postgres;

--
-- Name: adjudicationtypegovernmentslug(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.adjudicationtypegovernmentslug(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT government.governmentslug
        INTO o_value
        FROM geohistory.adjudicationtype
        JOIN geohistory.tribunal
            ON adjudicationtype.tribunal = tribunal.tribunalid
        JOIN geohistory.government
            ON tribunal.government = government.governmentid
        WHERE adjudicationtypeid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.adjudicationtypegovernmentslug(i_id integer) OWNER TO postgres;

--
-- Name: adjudicationtypelong(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.adjudicationtypelong(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT adjudicationtypelong
        INTO o_value
        FROM geohistory.adjudicationtype
        WHERE adjudicationtypeid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.adjudicationtypelong(i_id integer) OWNER TO postgres;

--
-- Name: adjudicationtypetribunaltypesummary(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.adjudicationtypetribunaltypesummary(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT tribunaltype.tribunaltypesummary
        INTO o_value
        FROM geohistory.adjudicationtype
        JOIN geohistory.tribunal
            ON adjudicationtype.tribunal = tribunal.tribunalid
        JOIN geohistory.tribunaltype
            ON tribunal.tribunaltype = tribunaltype.tribunaltypeid
        WHERE adjudicationtypeid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.adjudicationtypetribunaltypesummary(i_id integer) OWNER TO postgres;

--
-- Name: array_combine(integer[]); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.array_combine(integer[]) RETURNS integer[]
    LANGUAGE sql STABLE
    AS $_$

 WITH arraylist AS (
   SELECT unnest($1) AS arrayitems
 )
 SELECT array_agg(DISTINCT arrayitems ORDER BY arrayitems) AS combinedarray
 FROM arraylist;
     
$_$;


ALTER FUNCTION geohistory.array_combine(integer[]) OWNER TO postgres;

--
-- Name: datetonumeric(date); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.datetonumeric(date) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
        SELECT to_char($1, 'J')::numeric;
$_$;


ALTER FUNCTION geohistory.datetonumeric(date) OWNER TO postgres;

--
-- Name: emptytonull(text); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.emptytonull(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$

        SELECT CASE WHEN $1 = ''
            THEN NULL::text ELSE $1 END AS emptytonull;
    
$_$;


ALTER FUNCTION geohistory.emptytonull(text) OWNER TO postgres;

--
-- Name: eventlong(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.eventlong(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT eventlong
        INTO o_value
        FROM geohistory.event
        WHERE eventid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.eventlong(i_id integer) OWNER TO postgres;

--
-- Name: eventslug(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.eventslug(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT eventslug
        INTO o_value
        FROM geohistory.event
        WHERE eventid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.eventslug(i_id integer) OWNER TO postgres;

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
-- Name: governmentcurrentleadstate(integer, integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.governmentcurrentleadstate(i_id integer, i_level integer) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_abbreviation character varying;
    DECLARE o_id integer;
    DECLARE o_state boolean;
    BEGIN
        SELECT governmentabbreviation,
            CASE
                WHEN governmentsubstitute IS NOT NULL THEN governmentsubstitute
                ELSE governmentcurrentleadparent
            END,
            governmentlevel <= 2 AND governmentsubstitute IS NULL
        INTO o_abbreviation,
            o_id,
            o_state
        FROM geohistory.government
        WHERE governmentid = i_id;

        IF o_state THEN
            RETURN o_abbreviation;
        ELSIF i_level < 10 THEN
            RETURN geohistory.governmentcurrentleadstate(o_id, i_level+1);
        ELSE
            RETURN ''::character varying;
        END IF;
    END;
$$;


ALTER FUNCTION geohistory.governmentcurrentleadstate(i_id integer, i_level integer) OWNER TO postgres;

--
-- Name: governmentcurrentleadstateid(integer, integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.governmentcurrentleadstateid(i_id integer, i_level integer) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_id integer;
    DECLARE o_state boolean;
    BEGIN
        SELECT CASE
                WHEN governmentsubstitute IS NOT NULL THEN governmentsubstitute
                ELSE governmentcurrentleadparent
            END,
            governmentlevel <= 2 AND governmentsubstitute IS NULL
        INTO o_id,
            o_state
        FROM geohistory.government
        WHERE governmentid = i_id;

        IF o_state THEN
            RETURN i_id;
        ELSIF i_level < 10 THEN
            RETURN geohistory.governmentcurrentleadstateid(o_id, i_level+1);
        ELSE
            RETURN NULL::integer;
        END IF;
    END;
$$;


ALTER FUNCTION geohistory.governmentcurrentleadstateid(i_id integer, i_level integer) OWNER TO postgres;

--
-- Name: governmentname(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.governmentname(i_id integer) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT governmentname
        INTO o_value
        FROM geohistory.government
        WHERE governmentid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.governmentname(i_id integer) OWNER TO postgres;

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
-- Name: governmentslug(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.governmentslug(i_id integer) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT governmentslug
        INTO o_value
        FROM geohistory.government
        WHERE governmentid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.governmentslug(i_id integer) OWNER TO postgres;

--
-- Name: governmentslugsubstitute(integer, integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.governmentslugsubstitute(i_id integer, i_level integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_id integer;
    DECLARE o_slug text;
    BEGIN
        SELECT
            CASE
                WHEN governmentsubstitute IS NOT NULL THEN governmentsubstitute
                ELSE NULL
            END,
            CASE
                WHEN governmentsubstitute IS NOT NULL THEN NULL
                ELSE governmentslug
            END
        INTO o_id,
            o_slug
        FROM geohistory.government
        WHERE governmentid = i_id;

        IF o_slug IS NOT NULL THEN
            RETURN o_slug;
        ELSIF i_level < 10 THEN
            RETURN geohistory.governmentslugsubstitute(o_id, i_level+1);
        ELSE
            RETURN NULL::text;
        END IF;
    END;
$$;


ALTER FUNCTION geohistory.governmentslugsubstitute(i_id integer, i_level integer) OWNER TO postgres;

--
-- Name: implode(text[]); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.implode(text[]) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
        SELECT array_to_string($1, ' ');
$_$;


ALTER FUNCTION geohistory.implode(text[]) OWNER TO postgres;

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
-- Name: lawalternatecitation(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.lawalternatecitation(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT lawalternatecitation
        INTO o_value
        FROM geohistory.lawalternate
        WHERE lawalternateid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.lawalternatecitation(i_id integer) OWNER TO postgres;

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
-- Name: lawalternateslug(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.lawalternateslug(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT lawalternateslug
        INTO o_value
        FROM geohistory.lawalternate
        WHERE lawalternateid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.lawalternateslug(i_id integer) OWNER TO postgres;

--
-- Name: lawapproved(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.lawapproved(i_id integer) RETURNS calendar.historicdatetext
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT lawapproved::text
        INTO o_value
        FROM geohistory.law
        WHERE lawid = i_id;

        RETURN COALESCE(o_value, '')::calendar.historicdatetext;
    END;
$$;


ALTER FUNCTION geohistory.lawapproved(i_id integer) OWNER TO postgres;

--
-- Name: lawcitation(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.lawcitation(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT lawcitation
        INTO o_value
        FROM geohistory.law
        WHERE lawid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.lawcitation(i_id integer) OWNER TO postgres;

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
-- Name: lawsectionfrom(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.lawsectionfrom(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT lawsectionfrom
        INTO o_value
        FROM geohistory.lawsection
        WHERE lawsectionid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.lawsectionfrom(i_id integer) OWNER TO postgres;

--
-- Name: lawsectionsymbol(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.lawsectionsymbol(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT lawsectionsymbol
        INTO o_value
        FROM geohistory.lawsection
        WHERE lawsectionid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.lawsectionsymbol(i_id integer) OWNER TO postgres;

--
-- Name: lawsectionto(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.lawsectionto(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT lawsectionto
        INTO o_value
        FROM geohistory.lawsection
        WHERE lawsectionid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.lawsectionto(i_id integer) OWNER TO postgres;

--
-- Name: lawslug(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.lawslug(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT lawslug
        INTO o_value
        FROM geohistory.law
        WHERE lawid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.lawslug(i_id integer) OWNER TO postgres;

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
-- Name: plssmeridianlong(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.plssmeridianlong(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT plssmeridianlong
        INTO o_value
        FROM geohistory.plssmeridian
        WHERE plssmeridianid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.plssmeridianlong(i_id integer) OWNER TO postgres;

--
-- Name: plssmeridianshort(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.plssmeridianshort(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT plssmeridianshort
        INTO o_value
        FROM geohistory.plssmeridian
        WHERE plssmeridianid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.plssmeridianshort(i_id integer) OWNER TO postgres;

--
-- Name: punctuationnone(text); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.punctuationnone(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$

  SELECT regexp_replace(
     lower(
        public.unaccent($1)
     ), '[^a-z0-9]', '', 'g'
  );
    
$_$;


ALTER FUNCTION geohistory.punctuationnone(text) OWNER TO postgres;

--
-- Name: punctuationnonefuzzy(text); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.punctuationnonefuzzy(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$

  SELECT regexp_replace(
     lower(
        public.unaccent($1)
     ), '[^a-z0-9]', '', 'g'
  ) || '%';
    
$_$;


ALTER FUNCTION geohistory.punctuationnonefuzzy(text) OWNER TO postgres;

--
-- Name: rangeformat(text, text); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.rangeformat(text, text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$

    DECLARE fullrange TEXT;
    BEGIN
        $1 := COALESCE($1::text, '');
        $2 := COALESCE($2::text, '');
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


ALTER FUNCTION geohistory.rangeformat(text, text) OWNER TO postgres;

--
-- Name: refresh_view(); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.refresh_view() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
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
    UPDATE geohistory.government
    SET governmentnotecurrentleadparent = TRUE
    WHERE NOT governmentnotecurrentleadparent
    AND governmentid IN (
        SELECT government.governmentid
        FROM geohistory.government
        JOIN (
            SELECT replace(lower(government.governmentname), ' ', '') AS governmentname,
                government.governmenttype,
                government.governmentcurrentleadstateid
            FROM geohistory.government
		    JOIN geohistory.government governmentparent
		        ON government.governmentcurrentleadparent = governmentparent.governmentid
		    JOIN geohistory.government governmentparentlead
		        ON governmentparent.governmentslugsubstitute = governmentparentlead.governmentslug
            GROUP BY 1, 2, 3
            HAVING count(DISTINCT governmentparentlead.governmentid) > 1
        ) governmentgroup
        ON replace(lower(government.governmentname), ' ', '') = governmentgroup.governmentname
            AND government.governmenttype = governmentgroup.governmenttype
            AND government.governmentcurrentleadstateid = governmentgroup.governmentcurrentleadstateid
            AND NOT government.governmentnotecurrentleadparent
     );
RAISE INFO '%', clock_timestamp();  
    UPDATE geohistory.government
    SET governmentnotecurrentleadparent = FALSE
    WHERE governmentnotecurrentleadparent
        AND governmentid IN (
            SELECT government.governmentid
            FROM geohistory.government
            JOIN (
                SELECT replace(lower(government.governmentname), ' ', '') AS governmentname,
                    government.governmenttype,
                    government.governmentcurrentleadstateid
                FROM geohistory.government
		        JOIN geohistory.government governmentparent
		            ON government.governmentcurrentleadparent = governmentparent.governmentid
		        JOIN geohistory.government governmentparentlead
		            ON governmentparent.governmentslugsubstitute = governmentparentlead.governmentslug
            GROUP BY 1, 2, 3
            HAVING count(DISTINCT governmentparentlead.governmentid) > 1
        ) governmentgroup
        ON replace(lower(government.governmentname), ' ', '') = governmentgroup.governmentname
            AND government.governmenttype = governmentgroup.governmenttype
            AND government.governmentcurrentleadstateid = governmentgroup.governmentcurrentleadstateid
            AND NOT government.governmentnotecurrentleadparent
     );
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.government
    SET governmentname = governmentname || ''
    WHERE governmentlevel = 1;
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.government
    SET governmentname = governmentname || ''
    WHERE governmentlevel = 2;
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.government
    SET governmentname = governmentname || ''
    WHERE governmentlevel = 3;
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.government
    SET governmentname = governmentname || ''
    WHERE governmentlevel = 4;
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.government
    SET governmentname = governmentname || ''
    WHERE governmentlevel = 5;
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.government
    SET governmentname = governmentname || '';
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.adjudication
    SET adjudicationname = adjudicationname || '';
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.adjudicationsourcecitation
    SET adjudicationsourcecitationname = adjudicationsourcecitationname || '';
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.governmentsource
    SET governmentsourcename = governmentsourcename || '';
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.law
    SET lawvolume = lawvolume || '';
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.lawalternate
    SET lawalternatevolume = lawalternatevolume || '';
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.lawalternatesection
    SET lawalternatesectionpagefrom = lawalternatesectionpagefrom + 0;
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.lawsection
    SET lawsectionfrom = lawsectionfrom || '';
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.metesdescription
    SET metesdescriptionname = metesdescriptionname || '';
RAISE INFO '%', clock_timestamp();
    UPDATE geohistory.sourcecitation
    SET sourcecitationname = sourcecitationname || '';
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW geohistory.governmentchangecountcache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW geohistory.governmentchangecountpartcache;
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW geohistory.lastrefresh;
RAISE INFO '%', clock_timestamp();
END
$$;


ALTER FUNCTION geohistory.refresh_view() OWNER TO postgres;

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
-- Name: sourcelawhasspecialsession(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.sourcelawhasspecialsession(i_id integer) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value boolean;
    BEGIN
        SELECT sourcelawhasspecialsession
        INTO o_value
        FROM geohistory.source
        WHERE sourceid = i_id;

        RETURN o_value;
    END;
$$;


ALTER FUNCTION geohistory.sourcelawhasspecialsession(i_id integer) OWNER TO postgres;

--
-- Name: sourcelawisbynumber(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.sourcelawisbynumber(i_id integer) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value boolean;
    BEGIN
        SELECT sourcelawisbynumber
        INTO o_value
        FROM geohistory.source
        WHERE sourceid = i_id;

        RETURN o_value;
    END;
$$;


ALTER FUNCTION geohistory.sourcelawisbynumber(i_id integer) OWNER TO postgres;

--
-- Name: sourcelawtype(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.sourcelawtype(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT sourcelawtype
        INTO o_value
        FROM geohistory.source
        WHERE sourceid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.sourcelawtype(i_id integer) OWNER TO postgres;

--
-- Name: sourceshort(integer); Type: FUNCTION; Schema: geohistory; Owner: postgres
--

CREATE FUNCTION geohistory.sourceshort(i_id integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE o_value text;
    BEGIN
        SELECT sourceshort
        INTO o_value
        FROM geohistory.source
        WHERE sourceid = i_id;

        RETURN COALESCE(o_value, '');
    END;
$$;


ALTER FUNCTION geohistory.sourceshort(i_id integer) OWNER TO postgres;

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

--
-- Name: refresh_sequence(); Type: FUNCTION; Schema: gis; Owner: postgres
--

CREATE FUNCTION gis.refresh_sequence() RETURNS void
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


ALTER FUNCTION gis.refresh_sequence() OWNER TO postgres;

--
-- Name: refresh_view(); Type: FUNCTION; Schema: gis; Owner: postgres
--

CREATE FUNCTION gis.refresh_view() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
RAISE INFO '%', clock_timestamp();
    UPDATE gis.governmentshape
    SET governmentshapetag = governmentshapetag || '';
RAISE INFO '%', clock_timestamp();
    TRUNCATE gis.deleted_affectedgovernmentgis;
RAISE INFO '%', clock_timestamp();
    TRUNCATE gis.deleted_metesdescriptiongis;
RAISE INFO '%', clock_timestamp();
    UPDATE gis.governmentshape
    SET governmentshapereference = governmentshapeid
    WHERE governmentshapereference IS NULL OR (
        governmentshapereference IS NOT NULL
        AND governmentshapereference <> governmentshapeid
    );
RAISE INFO '%', clock_timestamp();
    REFRESH MATERIALIZED VIEW gis.governmentshapecache;
RAISE INFO '%', clock_timestamp();
END
$$;


ALTER FUNCTION gis.refresh_view() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- Name: event; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.event (
    eventid integer NOT NULL,
    eventtype integer NOT NULL,
    eventmethod integer NOT NULL,
    eventlong character varying(500) NOT NULL,
    eventfrom smallint NOT NULL,
    eventto smallint NOT NULL,
    eventgranted integer NOT NULL,
    eventeffective calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    eventeffectivetypestatutory integer,
    eventeffectivetypepresumedsource integer,
    eventisrelevant character varying(1) DEFAULT ''::character varying NOT NULL,
    eventeffectiveorder integer DEFAULT 0 NOT NULL,
    eventismapped boolean DEFAULT false NOT NULL,
    eventismappedtype character varying(100) DEFAULT ''::character varying NOT NULL,
    government integer,
    eventdatetext text GENERATED ALWAYS AS (
CASE
    WHEN (((eventeffective)::text = ''::text) AND (eventfrom IS NULL) AND (eventto IS NULL)) THEN '?'::text
    WHEN ((eventeffective)::text <> ''::text) THEN calendar.historicdatetextformat((eventeffective)::calendar.historicdate, 'short'::text, 'en'::text)
    ELSE geohistory.rangeformat((eventfrom)::text, (eventto)::text)
END) STORED,
    eventeffectivetext text GENERATED ALWAYS AS (calendar.historicdatetextformat((eventeffective)::calendar.historicdate, 'short'::text, 'en'::text)) STORED,
    eventyear text GENERATED ALWAYS AS (geohistory.rangeformat((eventfrom)::text, (eventto)::text)) STORED,
    eventsort numeric GENERATED ALWAYS AS ((geohistory.datetonumeric(
CASE
    WHEN ((calendar.historicdate((eventeffective)::text)).gregorian IS NOT NULL) THEN (calendar.historicdate((eventeffective)::text)).gregorian
    ELSE make_date(
    CASE
        WHEN (eventto <> 0) THEN (eventto)::integer
        WHEN (eventfrom <> 0) THEN (eventfrom)::integer
        ELSE 1
    END, 1, 1)
END) + (0.01 * (eventeffectiveorder)::numeric))) STORED,
    eventsortdate date GENERATED ALWAYS AS (
CASE
    WHEN ((calendar.historicdate((eventeffective)::text)).gregorian IS NOT NULL) THEN (calendar.historicdate((eventeffective)::text)).gregorian
    ELSE make_date(
    CASE
        WHEN (eventto <> 0) THEN (eventto)::integer
        WHEN (eventfrom <> 0) THEN (eventfrom)::integer
        ELSE 1
    END, 1, 1)
END) STORED,
    eventsortyear integer GENERATED ALWAYS AS ((
CASE
    WHEN ((calendar.historicdate((eventeffective)::text)).gregorian IS NOT NULL) THEN date_part('year'::text, (calendar.historicdate((eventeffective)::text)).gregorian)
    ELSE (
    CASE
        WHEN (eventto <> 0) THEN (eventto)::integer
        WHEN (eventfrom <> 0) THEN (eventfrom)::integer
        ELSE 1
    END)::double precision
END)::integer) STORED,
    eventslug text GENERATED ALWAYS AS (lower(regexp_replace(regexp_replace(replace((eventlong)::text, ', '::text, ' '::text), '[ʻ \/'',]'::text, '-'::text, 'g'::text), '[:\*\(\)\?\.\[\]]'::text, ''::text, 'g'::text))) STORED,
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
-- Name: eventeffectivetype; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.eventeffectivetype (
    eventeffectivetypeid integer NOT NULL,
    eventeffectivetypegroup character varying(100) DEFAULT ''::character varying NOT NULL,
    eventeffectivetypequalifier character varying(100) DEFAULT ''::character varying NOT NULL,
    eventeffectivetypelong text GENERATED ALWAYS AS (((eventeffectivetypegroup)::text ||
CASE
    WHEN ((eventeffectivetypequalifier)::text <> ''::text) THEN (': '::text || (eventeffectivetypequalifier)::text)
    ELSE ''::text
END)) STORED
);


ALTER TABLE geohistory.eventeffectivetype OWNER TO postgres;

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
    governmentcurrentleadstate character varying(10) GENERATED ALWAYS AS (geohistory.governmentcurrentleadstate(governmentid, 1)) STORED,
    governmentcurrentleadstateid integer GENERATED ALWAYS AS (geohistory.governmentcurrentleadstateid(governmentid, 1)) STORED,
    governmentlong text GENERATED ALWAYS AS ((((
CASE
    WHEN ((governmentname)::text = ''::text) THEN (governmentnumber)::text
    WHEN ((governmentnumber)::text = ''::text) THEN (governmentname)::text
    ELSE ((((governmentname)::text || ' ('::text) || (governmentnumber)::text) || ')'::text)
END ||
CASE
    WHEN (governmentlevel > 1) THEN ((', '::text || (
    CASE
        WHEN ((governmentstyle)::text <> ''::text) THEN governmentstyle
        ELSE governmenttype
    END)::text) ||
    CASE
        WHEN ((governmentconnectingarticle)::text <> ''::text) THEN (' '::text || (governmentconnectingarticle)::text)
        WHEN ((locale)::text = ANY (ARRAY[('de'::character varying)::text, ('nl'::character varying)::text])) THEN ''::text
        WHEN ((locale)::text = 'fr'::text) THEN ' de'::text
        ELSE ' of'::text
    END)
    ELSE ''::text
END) ||
CASE
    WHEN (((governmentstatus)::text <> ''::text) OR governmentnotecurrentleadparent OR ((governmentnotecreation)::text <> ''::text) OR ((governmentnotedissolution)::text <> ''::text)) THEN ((((((' ('::text || (
    CASE
        WHEN governmentnotecurrentleadparent THEN geohistory.governmentname(governmentcurrentleadparent)
        ELSE ''::character varying
    END)::text) ||
    CASE
        WHEN (governmentnotecurrentleadparent AND (((governmentnotecreation)::text <> ''::text) OR ((governmentnotedissolution)::text <> ''::text))) THEN ', '::text
        ELSE ''::text
    END) ||
    CASE
        WHEN (((governmentnotecreation)::text <> ''::text) AND ((governmentnotedissolution)::text <> ''::text)) THEN (((governmentnotecreation)::text || '-'::text) || (governmentnotedissolution)::text)
        WHEN ((governmentnotecreation)::text <> ''::text) THEN ('since '::text || (governmentnotecreation)::text)
        WHEN ((governmentnotedissolution)::text <> ''::text) THEN ('thru '::text || (governmentnotedissolution)::text)
        ELSE ''::text
    END) ||
    CASE
        WHEN (((governmentstatus)::text <> ''::text) AND (governmentnotecurrentleadparent OR ((governmentnotecreation)::text <> ''::text) OR ((governmentnotedissolution)::text <> ''::text))) THEN ', '::text
        ELSE ''::text
    END) || (governmentstatus)::text) || ')'::text)
    ELSE ''::text
END) ||
CASE
    WHEN (governmentlevel > 2) THEN ((' ('::text || (geohistory.governmentcurrentleadstate(governmentid, 1))::text) || ')'::text)
    ELSE ''::text
END)) STORED,
    governmentsearch text GENERATED ALWAYS AS (geohistory.punctuationnone(((
CASE
    WHEN ((governmentlevel = 2) AND ((governmenttype)::text = 'District'::text)) THEN ((governmenttype)::text || ' of '::text)
    ELSE ''::text
END ||
CASE
    WHEN ((governmentname)::text = ''::text) THEN (governmentnumber)::text
    WHEN ((governmentnumber)::text = ''::text) THEN (governmentname)::text
    ELSE ((((governmentname)::text || ' ('::text) || (governmentnumber)::text) || ')'::text)
END) ||
CASE
    WHEN (governmentlevel > 2) THEN ((((' '::text || (
    CASE
        WHEN ((governmentstyle)::text <> ''::text) THEN governmentstyle
        ELSE governmenttype
    END)::text) || ' ('::text) || (geohistory.governmentcurrentleadstate(governmentid, 1))::text) || ')'::text)
    ELSE ''::text
END))) STORED,
    governmentshort text GENERATED ALWAYS AS (((
CASE
    WHEN ((governmentlevel = 2) AND ((governmenttype)::text = 'District'::text)) THEN ((governmenttype)::text || ' of '::text)
    ELSE ''::text
END ||
CASE
    WHEN ((governmentname)::text = ''::text) THEN (governmentnumber)::text
    WHEN ((governmentnumber)::text = ''::text) THEN (governmentname)::text
    ELSE ((((governmentname)::text || ' ('::text) || (governmentnumber)::text) || ')'::text)
END) ||
CASE
    WHEN (governmentlevel > 2) THEN ((((' '::text || (
    CASE
        WHEN ((governmentstyle)::text <> ''::text) THEN governmentstyle
        ELSE governmenttype
    END)::text) || ' ('::text) || (geohistory.governmentcurrentleadstate(governmentid, 1))::text) || ')'::text)
    ELSE ''::text
END)) STORED,
    governmentslug text GENERATED ALWAYS AS (lower(replace(regexp_replace(regexp_replace(
CASE
    WHEN ((governmentstatus)::text = 'placeholder'::text) THEN NULL::text
    WHEN ((governmentlevel < 3) AND ((governmentabbreviation)::text <> ''::text)) THEN (governmentabbreviation)::text
    ELSE ((((((geohistory.governmentcurrentleadstate(governmentid, 1))::text ||
    CASE
        WHEN ((governmentarticle)::text <> ''::text) THEN ('-'::text || (governmentarticle)::text)
        ELSE ''::text
    END) ||
    CASE
        WHEN ((governmentname)::text <> ''::text) THEN ('-'::text || (governmentname)::text)
        ELSE ''::text
    END) ||
    CASE
        WHEN ((governmentnumber)::text <> ''::text) THEN ('-'::text || (governmentnumber)::text)
        ELSE ''::text
    END) ||
    CASE
        WHEN (governmentlevel > 1) THEN ('-'::text || (
        CASE
            WHEN ((governmentstyle)::text <> ''::text) THEN governmentstyle
            ELSE governmenttype
        END)::text)
        ELSE ''::text
    END) ||
    CASE
        WHEN (((governmentstatus)::text <> ''::text) OR governmentnotecurrentleadparent OR ((governmentnotecreation)::text <> ''::text) OR ((governmentnotedissolution)::text <> ''::text)) THEN ((((('-'::text || (
        CASE
            WHEN governmentnotecurrentleadparent THEN geohistory.governmentname(governmentcurrentleadparent)
            ELSE ''::character varying
        END)::text) ||
        CASE
            WHEN (governmentnotecurrentleadparent AND (((governmentnotecreation)::text <> ''::text) OR ((governmentnotedissolution)::text <> ''::text))) THEN '-'::text
            ELSE ''::text
        END) ||
        CASE
            WHEN (((governmentnotecreation)::text <> ''::text) AND ((governmentnotedissolution)::text <> ''::text)) THEN (((governmentnotecreation)::text || '-'::text) || (governmentnotedissolution)::text)
            WHEN ((governmentnotecreation)::text <> ''::text) THEN ('since-'::text || (governmentnotecreation)::text)
            WHEN ((governmentnotedissolution)::text <> ''::text) THEN ('thru-'::text || (governmentnotedissolution)::text)
            ELSE ''::text
        END) ||
        CASE
            WHEN (((governmentstatus)::text <> ''::text) AND (governmentnotecurrentleadparent OR ((governmentnotecreation)::text <> ''::text) OR ((governmentnotedissolution)::text <> ''::text))) THEN '-'::text
            ELSE ''::text
        END) || (governmentstatus)::text)
        ELSE ''::text
    END)
END, '[\(\)\,\.]'::text, ''::text, 'g'::text), '[ \/ʻ]'::text, '-'::text, 'g'::text), ''''::text, '-'::text))) STORED,
    governmentslugsubstitute text GENERATED ALWAYS AS (geohistory.governmentslugsubstitute(governmentid, 1)) STORED,
    governmentshortshort text GENERATED ALWAYS AS (((
CASE
    WHEN ((governmentlevel = 2) AND ((governmenttype)::text = 'District'::text)) THEN ((governmenttype)::text || ' of '::text)
    ELSE ''::text
END ||
CASE
    WHEN ((governmentname)::text = ''::text) THEN (governmentnumber)::text
    WHEN ((governmentnumber)::text = ''::text) THEN (governmentname)::text
    ELSE ((((governmentname)::text || ' ('::text) || (governmentnumber)::text) || ')'::text)
END) ||
CASE
    WHEN (governmentlevel > 2) THEN (' '::text || (
    CASE
        WHEN ((governmentstyle)::text <> ''::text) THEN governmentstyle
        ELSE governmenttype
    END)::text)
    ELSE ''::text
END)) STORED,
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
    governmentformlong text GENERATED ALWAYS AS ((((governmentformtype ||
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
END)) STORED,
    governmentformlongreport text GENERATED ALWAYS AS (((governmentformtype ||
CASE
    WHEN (governmentformclass <> ''::text) THEN (', '::text || governmentformclass)
    ELSE ''::text
END) ||
CASE
    WHEN (governmentformqualifierinclude AND (governmentformqualifier <> ''::text)) THEN ((' ('::text || governmentformqualifier) || ')'::text)
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
    governmentschooldistrict integer,
    governmentshapeslug text GENERATED ALWAYS AS (ltrim((((geohistory.governmentslug(
CASE
    WHEN (governmentsubmunicipality IS NULL) THEN governmentmunicipality
    ELSE governmentsubmunicipality
END))::text || '-'::text) || public.st_geohash(public.st_pointonsurface(governmentshapegeometry), 9)), '-'::text)) STORED
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
-- Name: governmentshapecache; Type: MATERIALIZED VIEW; Schema: gis; Owner: postgres
--

CREATE MATERIALIZED VIEW gis.governmentshapecache AS
 SELECT governmentshape2.governmentlayer,
    governmentshape2.government,
    public.st_buffer(public.st_collect(governmentshape2.governmentshapegeometry), (0)::double precision) AS geometry
   FROM (( SELECT governmentshape.governmentcounty AS government,
            'county'::text AS governmentlayer,
            governmentshape.governmentshapegeometry
           FROM gis.governmentshape
        UNION
         SELECT governmentshape.governmentmunicipality AS government,
            'municipality'::text AS governmentlayer,
            governmentshape.governmentshapegeometry
           FROM gis.governmentshape
        UNION
         SELECT governmentshape.governmentschooldistrict AS government,
            'schooldistrict'::text AS governmentlayer,
            governmentshape.governmentshapegeometry
           FROM gis.governmentshape
          WHERE (governmentshape.governmentschooldistrict IS NOT NULL)
        UNION
         SELECT governmentshape.governmentshapeplsstownship AS government,
            'shapeplsstownship'::text AS governmentlayer,
            governmentshape.governmentshapegeometry
           FROM gis.governmentshape
          WHERE (governmentshape.governmentshapeplsstownship IS NOT NULL)
        UNION
         SELECT governmentshape.governmentsubmunicipality AS government,
            'submunicipality'::text AS governmentlayer,
            governmentshape.governmentshapegeometry
           FROM gis.governmentshape
          WHERE (governmentshape.governmentsubmunicipality IS NOT NULL)
        UNION
         SELECT governmentshape.governmentward AS government,
            'ward'::text AS governmentlayer,
            governmentshape.governmentshapegeometry
           FROM gis.governmentshape
          WHERE (governmentshape.governmentward IS NOT NULL)) governmentshape2
     JOIN geohistory.government ON (((governmentshape2.government = government.governmentid) AND ((government.governmentstatus)::text <> 'placeholder'::text))))
  GROUP BY governmentshape2.governmentlayer, governmentshape2.government
  ORDER BY governmentshape2.governmentlayer, governmentshape2.government
  WITH NO DATA;


ALTER MATERIALIZED VIEW gis.governmentshapecache OWNER TO postgres;

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
    adjudicationstatus text DEFAULT ''::text NOT NULL,
    adjudicationname text DEFAULT ''::text NOT NULL,
    adjudicationslug text GENERATED ALWAYS AS (lower(regexp_replace(regexp_replace(((((((((geohistory.adjudicationtypegovernmentslug(adjudicationtype) || '-'::text) || geohistory.adjudicationtypetribunaltypesummary(adjudicationtype)) ||
CASE
    WHEN ((adjudicationnumber)::text = ''::text) THEN ''::text
    ELSE ('-'::text || (adjudicationnumber)::text)
END) || '-'::text) || geohistory.adjudicationtypelong(adjudicationtype)) ||
CASE
    WHEN ((adjudicationterm)::text = ''::text) THEN ''::text
    ELSE ('-'::text || calendar.historicdatetextformat((((adjudicationterm)::text ||
    CASE
        WHEN (length((adjudicationterm)::text) = 4) THEN '-~07-~28'::text
        WHEN (length((adjudicationterm)::text) = 7) THEN '-~28'::text
        ELSE ''::text
    END))::calendar.historicdate, 'short'::text, 'en'::text))
END) || ' '::text) || adjudicationname), '[ \-]+'::text, '-'::text, 'g'::text), '[\/\,\.\(\)]'::text, ''::text, 'g'::text))) STORED,
    adjudicationtitle text GENERATED ALWAYS AS (regexp_replace(regexp_replace(((((((geohistory.adjudicationtypegovernmentshort(adjudicationtype) || ' '::text) || geohistory.adjudicationtypetribunaltypesummary(adjudicationtype)) ||
CASE
    WHEN ((adjudicationnumber)::text = ''::text) THEN ''::text
    ELSE (' '::text || (adjudicationnumber)::text)
END) || ' '::text) || geohistory.adjudicationtypelong(adjudicationtype)) ||
CASE
    WHEN ((adjudicationterm)::text = ''::text) THEN ''::text
    ELSE (' '::text || calendar.historicdatetextformat((((adjudicationterm)::text ||
    CASE
        WHEN (length((adjudicationterm)::text) = 4) THEN '-~07-~28'::text
        WHEN (length((adjudicationterm)::text) = 7) THEN '-~28'::text
        ELSE ''::text
    END))::calendar.historicdate, 'short'::text, 'en'::text))
END), '[ ]+'::text, ' '::text, 'g'::text), '[\/\,\.\(\)]'::text, ''::text, 'g'::text)) STORED,
    adjudicationsummary text GENERATED ALWAYS AS (btrim(((((adjudicationlong || ' '::text) || adjudicationshort) || ' '::text) || adjudicationnotes))) STORED
);


ALTER TABLE geohistory.adjudication OWNER TO postgres;

--
-- Name: COLUMN adjudication.adjudicationstatus; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.adjudication.adjudicationstatus IS 'This field is used for internal tracking purposes, and is not included in open data.';


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
    adjudicationlocationrepositoryseries character varying(50) DEFAULT ''::character varying NOT NULL,
    adjudicationlocationpage text GENERATED ALWAYS AS (geohistory.rangeformat((adjudicationlocationpagefrom)::text, (adjudicationlocationpageto)::text)) STORED
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
    governmentsourcename text DEFAULT ''::text NOT NULL,
    governmentsourceslug text GENERATED ALWAYS AS (btrim(lower(regexp_replace(((((((((((((geohistory.governmentslug(government))::text || '-'::text) || (governmentsourcebody)::text) || '-'::text) || (governmentsourcetype)::text) || '-'::text) || (governmentsourcenumber)::text) || '-'::text) || (governmentsourceterm)::text) ||
CASE
    WHEN ((governmentsourcevolume)::text <> ''::text) THEN ('-v'::text || (governmentsourcevolume)::text)
    ELSE ''::text
END) || '-'::text) || geohistory.rangeformat((governmentsourcepagefrom)::text, (((governmentsourcepageto)::text || ' '::text) || governmentsourcename))), '[\s\-\–\.\/''\(\);:,&"#§\?\[\]]+'::text, '-'::text, 'g'::text)), '-'::text)) STORED,
    hassource boolean GENERATED ALWAYS AS ((source IS NOT NULL)) STORED,
    governmentsourcepage text GENERATED ALWAYS AS (geohistory.rangeformat((governmentsourcepagefrom)::text, (governmentsourcepageto)::text)) STORED,
    sourcecitationpage text GENERATED ALWAYS AS (geohistory.rangeformat((sourcecitationpagefrom)::text, (sourcecitationpageto)::text)) STORED,
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
-- Name: COLUMN governmentsource.governmentsourceeffectivenotes; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.governmentsource.governmentsourceeffectivenotes IS 'Values in this field associated with governmentsourcetype Election are used for internal tracking purposes are omitted from open data.';


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
    lawissue integer,
    lawcitation text GENERATED ALWAYS AS ((geohistory.sourcelawtype(source) ||
CASE
    WHEN ((lawpage = 0) AND (lawnumberchapter = 0) AND ((lawapproved)::text = ''::text)) THEN ' Unknown'::text
    ELSE ((((((((((((
    CASE
        WHEN ((lawapproved)::text = ''::text) THEN ''::text
        ELSE ' of '::text
    END || calendar.historicdatetextformat((lawapproved)::calendar.historicdate, 'long'::text, 'en'::text)) || ' ('::text) ||
    CASE
        WHEN ((lawvolume)::text ~~ '%/%'::text) THEN ((((((
        CASE
            WHEN (split_part((lawvolume)::text, '/'::text, 3) <> ''::text) THEN (split_part((lawvolume)::text, '/'::text, 3) || ', '::text)
            ELSE ''::text
        END || split_part((lawvolume)::text, '/'::text, 2)) ||
        CASE
            WHEN (split_part((lawvolume)::text, '/'::text, 2) = '1'::text) THEN 'st'::text
            WHEN (split_part((lawvolume)::text, '/'::text, 2) = '2'::text) THEN 'nd'::text
            WHEN (split_part((lawvolume)::text, '/'::text, 2) = '3'::text) THEN 'rd'::text
            ELSE 'th'::text
        END) || ' '::text) ||
        CASE
            WHEN geohistory.sourcelawhasspecialsession(source) THEN 'Sp.'::text
            ELSE ''::text
        END) || 'Sess., '::text) ||
        CASE
            WHEN ("left"((lawapproved)::text, 4) <> split_part((lawvolume)::text, '/'::text, 1)) THEN (split_part((lawvolume)::text, '/'::text, 1) || ' '::text)
            ELSE ''::text
        END)
        ELSE
        CASE
            WHEN (((lawvolume)::text = "left"((lawapproved)::text, 4)) OR ((lawvolume)::text = ''::text)) THEN ''::text
            ELSE ((lawvolume)::text || ' '::text)
        END
    END) || geohistory.sourceshort(source)) || ' '::text) ||
    CASE
        WHEN (lawpage = 0) THEN '___'::text
        ELSE (lawpage)::text
    END) || ', '::text) ||
    CASE
        WHEN geohistory.sourcelawisbynumber(source) THEN 'No'::text
        ELSE 'Ch'::text
    END) || '. '::text) ||
    CASE
        WHEN (lawnumberchapter = 0) THEN '___'::text
        ELSE (lawnumberchapter)::text
    END) ||
    CASE
        WHEN ((lawpublished)::text <> ''::text) THEN (', '::text || calendar.historicdatetextformat((lawpublished)::calendar.historicdate, 'long'::text, 'en'::text))
        ELSE ''::text
    END) || ')'::text)
END)) STORED,
    lawslug text GENERATED ALWAYS AS ((geohistory.sourcelawtype(source) ||
CASE
    WHEN ((lawpage = 0) AND (lawnumberchapter = 0) AND ((lawapproved)::text = ''::text)) THEN ' Unknown'::text
    ELSE ((((((((((((
    CASE
        WHEN ((lawapproved)::text = ''::text) THEN ''::text
        ELSE ' of '::text
    END || calendar.historicdatetextformat((lawapproved)::calendar.historicdate, 'short'::text, 'en'::text)) || ' ('::text) ||
    CASE
        WHEN ((lawvolume)::text ~~ '%/%'::text) THEN ((((((
        CASE
            WHEN (split_part((lawvolume)::text, '/'::text, 3) <> ''::text) THEN (split_part((lawvolume)::text, '/'::text, 3) || ', '::text)
            ELSE ''::text
        END || split_part((lawvolume)::text, '/'::text, 2)) ||
        CASE
            WHEN (split_part((lawvolume)::text, '/'::text, 2) = '1'::text) THEN 'st'::text
            WHEN (split_part((lawvolume)::text, '/'::text, 2) = '2'::text) THEN 'nd'::text
            WHEN (split_part((lawvolume)::text, '/'::text, 2) = '3'::text) THEN 'rd'::text
            ELSE 'th'::text
        END) || ' '::text) ||
        CASE
            WHEN geohistory.sourcelawhasspecialsession(source) THEN 'Sp.'::text
            ELSE ''::text
        END) || 'Sess., '::text) ||
        CASE
            WHEN ("left"((lawapproved)::text, 4) <> split_part((lawvolume)::text, '/'::text, 1)) THEN (split_part((lawvolume)::text, '/'::text, 1) || ' '::text)
            ELSE ''::text
        END)
        ELSE
        CASE
            WHEN (((lawvolume)::text = "left"((lawapproved)::text, 4)) OR ((lawvolume)::text = ''::text)) THEN ''::text
            ELSE ((lawvolume)::text || ' '::text)
        END
    END) || geohistory.sourceshort(source)) || ' '::text) ||
    CASE
        WHEN (lawpage = 0) THEN '___'::text
        ELSE (lawpage)::text
    END) || ', '::text) ||
    CASE
        WHEN geohistory.sourcelawisbynumber(source) THEN 'No'::text
        ELSE 'Ch'::text
    END) || '. '::text) ||
    CASE
        WHEN (lawnumberchapter = 0) THEN '___'::text
        ELSE (lawnumberchapter)::text
    END) ||
    CASE
        WHEN ((lawpublished)::text <> ''::text) THEN (', '::text || calendar.historicdatetextformat((lawpublished)::calendar.historicdate, 'short'::text, 'en'::text))
        ELSE ''::text
    END) || ')'::text)
END)) STORED
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
    lawsectionnewsymbol character varying(20) DEFAULT ''::character varying NOT NULL,
    lawsectioncitation text GENERATED ALWAYS AS ((((geohistory.lawcitation(law) || ', '::text) || (lawsectionsymbol)::text) ||
CASE
    WHEN ((lawsectionfrom)::text = '0'::text) THEN '___'::text
    WHEN ((lawsectionfrom)::text = (lawsectionto)::text) THEN (' '::text || (lawsectionfrom)::text)
    ELSE ((('§ '::text || (lawsectionfrom)::text) || '–'::text) || (lawsectionto)::text)
END)) STORED,
    lawsectionslug text GENERATED ALWAYS AS (lower(replace(replace(regexp_replace(regexp_replace((((geohistory.lawslug(law) || ', '::text) || (lawsectionsymbol)::text) ||
CASE
    WHEN ((lawsectionfrom)::text = '0'::text) THEN '___'::text
    WHEN ((lawsectionfrom)::text = (lawsectionto)::text) THEN (' '::text || (lawsectionfrom)::text)
    ELSE ((('§ '::text || (lawsectionfrom)::text) || '–'::text) || (lawsectionto)::text)
END), '[,\.\[\]\(\)\'']'::text, ''::text, 'g'::text), '([ :\–\—\/_]+| of )'::text, '-'::text, 'g'::text), '§'::text, 's'::text), '¶'::text, 'p'::text))) STORED,
    lawsectionnewsection text GENERATED ALWAYS AS (geohistory.rangeformat((lawsectionnewfrom)::text, (lawsectionnewto)::text)) STORED,
    lawsectionpage text GENERATED ALWAYS AS (geohistory.rangeformat((lawsectionpagefrom)::text, (lawsectionpageto)::text)) STORED
);


ALTER TABLE geohistory.lawsection OWNER TO postgres;

--
-- Name: lawsectionevent; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.lawsectionevent (
    lawsectioneventid integer NOT NULL,
    lawsection integer NOT NULL,
    event integer NOT NULL,
    eventrelationship integer NOT NULL,
    lawsectioneventnotes text,
    lawgroup integer,
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
    metesdescriptionlong text GENERATED ALWAYS AS ((geohistory.eventlong(event) ||
CASE
    WHEN ((metesdescriptionname)::text = ''::text) THEN ''::text
    ELSE (': '::text || (metesdescriptionname)::text)
END)) STORED,
    metesdescriptionslug text GENERATED ALWAYS AS ((geohistory.eventslug(event) ||
CASE
    WHEN ((metesdescriptionname)::text = ''::text) THEN ''::text
    ELSE ('-'::text || lower(regexp_replace(regexp_replace(replace((metesdescriptionname)::text, ', '::text, ' '::text), '[ \/'',"]'::text, '-'::text, 'g'::text), '[\(\)\?\.\[\]]'::text, ''::text, 'g'::text)))
END)) STORED,
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
-- Name: metesdescriptiongis; Type: TABLE; Schema: gis; Owner: postgres
--

CREATE TABLE gis.metesdescriptiongis (
    metesdescriptiongisid integer NOT NULL,
    metesdescription integer NOT NULL,
    governmentshape integer
);


ALTER TABLE gis.metesdescriptiongis OWNER TO postgres;

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
    sourcetemporarynote text DEFAULT ''::text NOT NULL,
    sourceabbreviation text GENERATED ALWAYS AS (((sourceshort)::text ||
CASE
    WHEN ((sourceshortpart)::text <> ''::text) THEN (' '::text || (sourceshortpart)::text)
    ELSE ''::text
END)) STORED,
    sourcefullcitation text GENERATED ALWAYS AS (geohistory.implode(ARRAY[
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
END])) STORED
);


ALTER TABLE geohistory.source OWNER TO postgres;

--
-- Name: COLUMN source.sourcetemporarynote; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.source.sourcetemporarynote IS 'This field is used for internal tracking purposes, and is not included in open data.';


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
    recordingrepositorycontainer character varying(50) DEFAULT ''::character varying NOT NULL,
    recordingrepositoryitemrange text GENERATED ALWAYS AS (geohistory.rangeformat((recordingrepositoryitemfrom)::text, (recordingrepositoryitemto)::text)) STORED
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
-- Name: COLUMN recording.recordingisrelevant; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.recording.recordingisrelevant IS 'This field is used for internal tracking purposes, and is not included in open data.';


--
-- Name: COLUMN recording.recordingobtainedcopy; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.recording.recordingobtainedcopy IS 'This field is used for internal tracking purposes, and is not included in open data.';


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
    researchlogvolume text GENERATED ALWAYS AS (geohistory.rangeformat((researchlogvolumefrom)::text, (researchlogvolumeto)::text)) STORED,
    researchlogyear text GENERATED ALWAYS AS (geohistory.rangeformat((researchlogfrom)::text, (researchlogto)::text)) STORED,
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
-- Name: governmentchangecountpart; Type: VIEW; Schema: geohistory; Owner: postgres
--

CREATE VIEW geohistory.governmentchangecountpart AS
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
            event.eventsortdate,
            event.eventdatetext,
            initcap(((event.eventeffective)::calendar.historicdate)."precision") AS eventeffectiveprecision,
            eventeffectivetype.eventeffectivetypelong AS eventeffectivetype,
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
          GROUP BY affectedgovernmentsummary.eventid, affectedgovernmentsummary.governmentid, affectedgovernmentsummary.affectedtypeid, affectedgovernmentsummary.affectedside, affectedtype.affectedtypecreationdissolution, event.eventsortdate, event.eventdatetext, eventeffectivetype.eventeffectivetypelong, event.eventeffective, event.eventfrom, event.eventto
        ), alterfrom AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            COALESCE(array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid), ARRAY[]::integer[]) AS eventid
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedside = 'from'::text) AND ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'alter'::text))
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), alterto AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            COALESCE(array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid), ARRAY[]::integer[]) AS eventid
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedside = 'to'::text) AND ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'alter'::text))
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), altertotal AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            COALESCE(array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid), ARRAY[]::integer[]) AS eventid
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'alter'::text)
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), creation AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid) AS eventid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventsortdate) AS eventsortdate,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventdatetext) AS eventdatetext,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectiveprecision) AS eventeffectiveprecision,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectivetype) AS eventeffectivetype,
            (sum(affectedgovernmentsummaryevent.lawsection) > (0)::numeric) AS lawsection
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'begin'::text)
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), dissolution AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid) AS eventid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventsortdate) AS eventsortdate,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventdatetext) AS eventdatetext,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectiveprecision) AS eventeffectiveprecision,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectivetype) AS eventeffectivetype,
            (sum(affectedgovernmentsummaryevent.lawsection) > (0)::numeric) AS lawsection
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'end'::text)
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), affectedgovernmentform AS (
         SELECT DISTINCT affectedgovernmentpart.governmentto AS government,
            governmentform.governmentformlong,
            affectedgovernmentgroup.event,
            row_number() OVER (PARTITION BY affectedgovernmentpart.governmentto ORDER BY event.eventsortdate DESC) AS recentness
           FROM (((((geohistory.affectedgovernmentpart
             JOIN geohistory.affectedgovernmentgrouppart ON (((affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart) AND (affectedgovernmentpart.governmentformto IS NOT NULL) AND (affectedgovernmentpart.affectedtypeto <> 12))))
             JOIN geohistory.affectedgovernmentgroup ON ((affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid)))
             JOIN geohistory.event ON ((affectedgovernmentgroup.event = event.eventid)))
             JOIN geohistory.eventgranted ON (((event.eventgranted = eventgranted.eventgrantedid) AND eventgranted.eventgrantedsuccess)))
             JOIN geohistory.governmentform ON ((affectedgovernmentpart.governmentformto = governmentform.governmentformid)))
        )
 SELECT COALESCE((government.governmentcurrentleadstate)::text, ''::text) AS governmentstate,
    government.governmentlevel,
    government.governmenttype,
    COALESCE(affectedgovernmentform.governmentformlong, ''::text) AS currentform,
    COALESCE(affectedgovernmentform.governmentformlong, ''::text) AS currentformdetailed,
        CASE
            WHEN (government.governmentlevel > 3) THEN (governmentparent.governmentname)::text
            ELSE ''::text
        END AS governmentleadparentcounty,
    government.governmentid,
    government.governmentlong,
    COALESCE(array_length(creation.eventid, 1), 0) AS creation,
    creation.eventid AS creationevent,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN creation.eventdatetext[1]
            ELSE ''::text
        END AS creationtext,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN COALESCE(creation.eventeffectiveprecision[1], 'None'::text)
            ELSE 'None'::text
        END AS creationprecision,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN creation.eventsortdate[1]
            ELSE NULL::date
        END AS creationsort,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN COALESCE(creation.eventeffectivetype[1], ''::text)
            ELSE ''::text
        END AS creationhow,
        CASE
            WHEN (creation.lawsection IS NULL) THEN false
            ELSE creation.lawsection
        END AS creationlawsection,
    COALESCE(array_length(alterfrom.eventid, 1), 0) AS alterfrom,
    COALESCE(array_length(alterto.eventid, 1), 0) AS alterto,
    COALESCE(array_length(altertotal.eventid, 1), 0) AS altertotal,
    COALESCE(array_length(dissolution.eventid, 1), 0) AS dissolution,
    dissolution.eventid AS dissolutionevent,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN dissolution.eventdatetext[1]
            ELSE ''::text
        END AS dissolutiontext,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN COALESCE(dissolution.eventeffectiveprecision[1], 'None'::text)
            ELSE 'None'::text
        END AS dissolutionprecision,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN dissolution.eventsortdate[1]
            ELSE NULL::date
        END AS dissolutionsort,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN COALESCE(dissolution.eventeffectivetype[1], ''::text)
            ELSE ''::text
        END AS dissolutionhow,
        CASE
            WHEN (dissolution.lawsection IS NULL) THEN false
            ELSE dissolution.lawsection
        END AS dissolutionlawsection,
    governmentsubstitute.governmentid AS governmentsubstituteid,
    governmentsubstitute.governmentlong AS governmentsubstitutelong
   FROM ((((((((geohistory.government
     LEFT JOIN geohistory.government governmentparent ON ((government.governmentcurrentleadparent = governmentparent.governmentid)))
     LEFT JOIN alterfrom ON ((government.governmentid = alterfrom.governmentid)))
     LEFT JOIN alterto ON ((government.governmentid = alterto.governmentid)))
     LEFT JOIN altertotal ON ((government.governmentid = altertotal.governmentid)))
     LEFT JOIN creation ON ((government.governmentid = creation.governmentid)))
     LEFT JOIN dissolution ON ((government.governmentid = dissolution.governmentid)))
     LEFT JOIN affectedgovernmentform ON (((government.governmentid = affectedgovernmentform.government) AND (affectedgovernmentform.recentness = 1))))
     LEFT JOIN geohistory.government governmentsubstitute ON (((government.governmentslugsubstitute = governmentsubstitute.governmentslug) AND ((government.governmentstatus)::text <> ALL (ARRAY[('alternate'::character varying)::text, ('language'::character varying)::text, ('placeholder'::character varying)::text])))))
  ORDER BY COALESCE((government.governmentcurrentleadstate)::text, ''::text), government.governmentlevel, government.governmenttype,
        CASE
            WHEN (government.governmentlevel > 3) THEN (governmentparent.governmentname)::text
            ELSE NULL::text
        END, government.governmentlong, government.governmentid;


ALTER VIEW geohistory.governmentchangecountpart OWNER TO postgres;

--
-- Name: governmentchangecountpartcache; Type: MATERIALIZED VIEW; Schema: geohistory; Owner: postgres
--

CREATE MATERIALIZED VIEW geohistory.governmentchangecountpartcache AS
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
   FROM geohistory.governmentchangecountpart
  WITH NO DATA;


ALTER MATERIALIZED VIEW geohistory.governmentchangecountpartcache OWNER TO postgres;

--
-- Name: governmentchangecount; Type: VIEW; Schema: geohistory; Owner: postgres
--

CREATE VIEW geohistory.governmentchangecount AS
 WITH affectedgovernmentsummary AS (
         SELECT DISTINCT affectedgovernmentgroup.event AS eventid,
            government_1.governmentid,
            originalgovernment.governmentid AS originalgovernmentid,
            affectedgovernmentpart.affectedtypefrom AS affectedtypeid,
            'from'::text AS affectedside
           FROM ((((geohistory.affectedgovernmentgroup
             JOIN geohistory.affectedgovernmentgrouppart ON ((affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup)))
             JOIN geohistory.affectedgovernmentpart ON ((affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid)))
             JOIN geohistory.government originalgovernment ON ((affectedgovernmentpart.governmentfrom = originalgovernment.governmentid)))
             JOIN geohistory.government government_1 ON ((originalgovernment.governmentslugsubstitute = government_1.governmentslug)))
        UNION
         SELECT DISTINCT affectedgovernmentgroup.event AS eventid,
            government_1.governmentid,
            originalgovernment.governmentid AS originalgovernmentid,
            affectedgovernmentpart.affectedtypeto AS affectedtypeid,
            'to'::text AS affectedside
           FROM ((((geohistory.affectedgovernmentgroup
             JOIN geohistory.affectedgovernmentgrouppart ON ((affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup)))
             JOIN geohistory.affectedgovernmentpart ON ((affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid)))
             JOIN geohistory.government originalgovernment ON ((affectedgovernmentpart.governmentto = originalgovernment.governmentid)))
             JOIN geohistory.government government_1 ON ((originalgovernment.governmentslugsubstitute = government_1.governmentslug)))
        ), affectedgovernmentsummaryeventpart AS (
         SELECT affectedgovernmentsummary.eventid,
            affectedgovernmentsummary.governmentid,
            array_agg(DISTINCT affectedgovernmentsummary.originalgovernmentid ORDER BY affectedgovernmentsummary.originalgovernmentid) AS originalgovernmentid,
            affectedgovernmentsummary.affectedtypeid,
            affectedgovernmentsummary.affectedside,
            affectedtype.affectedtypecreationdissolution,
            event.eventsortdate,
            event.eventdatetext,
            initcap(((event.eventeffective)::calendar.historicdate)."precision") AS eventeffectiveprecision,
            eventeffectivetype.eventeffectivetypelong AS eventeffectivetype,
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
          GROUP BY affectedgovernmentsummary.eventid, affectedgovernmentsummary.governmentid, affectedgovernmentsummary.affectedtypeid, affectedgovernmentsummary.affectedside, affectedtype.affectedtypecreationdissolution, event.eventsortdate, event.eventdatetext, eventeffectivetype.eventeffectivetypelong, event.eventeffective, event.eventfrom, event.eventto
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
            affectedgovernmentsummaryeventpart.eventsortdate,
            affectedgovernmentsummaryeventpart.eventdatetext,
            affectedgovernmentsummaryeventpart.eventeffectiveprecision,
            affectedgovernmentsummaryeventpart.eventeffectivetype,
            affectedgovernmentsummaryeventpart.lawsection
           FROM (affectedgovernmentsummaryeventpart
             LEFT JOIN creationdissolution ON (((affectedgovernmentsummaryeventpart.eventid = creationdissolution.eventid) AND (affectedgovernmentsummaryeventpart.governmentid = creationdissolution.governmentid))))
        ), alterfrom AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            COALESCE(array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid), ARRAY[]::integer[]) AS eventid
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedside = 'from'::text) AND ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'alter'::text))
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), alterto AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            COALESCE(array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid), ARRAY[]::integer[]) AS eventid
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedside = 'to'::text) AND ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'alter'::text))
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), altertotal AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            COALESCE(array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid), ARRAY[]::integer[]) AS eventid
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'alter'::text)
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), creation AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            geohistory.array_combine(array_agg(affectedgovernmentsummaryevent.originalgovernmentid)) AS originalgovernmentid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid) AS eventid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventsortdate) AS eventsortdate,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventdatetext) AS eventdatetext,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectiveprecision) AS eventeffectiveprecision,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectivetype) AS eventeffectivetype,
            (sum(affectedgovernmentsummaryevent.lawsection) > (0)::numeric) AS lawsection
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'begin'::text)
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), dissolution AS (
         SELECT affectedgovernmentsummaryevent.governmentid,
            geohistory.array_combine(array_agg(affectedgovernmentsummaryevent.originalgovernmentid)) AS originalgovernmentid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid) AS eventid,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventsortdate) AS eventsortdate,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventdatetext) AS eventdatetext,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectiveprecision) AS eventeffectiveprecision,
            array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectivetype) AS eventeffectivetype,
            (sum(affectedgovernmentsummaryevent.lawsection) > (0)::numeric) AS lawsection
           FROM affectedgovernmentsummaryevent
          WHERE ((affectedgovernmentsummaryevent.affectedtypecreationdissolution)::text = 'end'::text)
          GROUP BY affectedgovernmentsummaryevent.governmentid
        ), affectedgovernmentform AS (
         SELECT DISTINCT affectedgovernmentpart.governmentto AS government,
            governmentform.governmentformlong,
            affectedgovernmentgroup.event,
            row_number() OVER (PARTITION BY affectedgovernmentpart.governmentto ORDER BY event.eventsortdate DESC) AS recentness
           FROM (((((geohistory.affectedgovernmentpart
             JOIN geohistory.affectedgovernmentgrouppart ON (((affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart) AND (affectedgovernmentpart.governmentformto IS NOT NULL) AND (affectedgovernmentpart.affectedtypeto <> 12))))
             JOIN geohistory.affectedgovernmentgroup ON ((affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid)))
             JOIN geohistory.event ON ((affectedgovernmentgroup.event = event.eventid)))
             JOIN geohistory.eventgranted ON (((event.eventgranted = eventgranted.eventgrantedid) AND eventgranted.eventgrantedsuccess)))
             JOIN geohistory.governmentform ON ((affectedgovernmentpart.governmentformto = governmentform.governmentformid)))
        )
 SELECT COALESCE((government.governmentcurrentleadstate)::text, ''::text) AS governmentstate,
    government.governmentlevel,
    government.governmenttype,
    COALESCE(affectedgovernmentform.governmentformlong, ''::text) AS currentform,
    COALESCE(affectedgovernmentform.governmentformlong, ''::text) AS currentformdetailed,
        CASE
            WHEN (government.governmentlevel > 3) THEN (governmentparent.governmentname)::text
            ELSE ''::text
        END AS governmentleadparentcounty,
    government.governmentid,
    government.governmentlong,
    COALESCE(array_length(creation.eventid, 1), 0) AS creation,
    creation.eventid AS creationevent,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN creation.eventdatetext[1]
            ELSE ''::text
        END AS creationtext,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN COALESCE(creation.eventeffectiveprecision[1], 'None'::text)
            ELSE 'None'::text
        END AS creationprecision,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN creation.eventsortdate[1]
            ELSE NULL::date
        END AS creationsort,
        CASE
            WHEN (array_length(creation.eventid, 1) = 1) THEN COALESCE(creation.eventeffectivetype[1], ''::text)
            ELSE ''::text
        END AS creationhow,
        CASE
            WHEN (creation.lawsection IS NULL) THEN false
            ELSE creation.lawsection
        END AS creationlawsection,
    creation.originalgovernmentid AS creationas,
    COALESCE(array_length(alterfrom.eventid, 1), 0) AS alterfrom,
    COALESCE(array_length(alterto.eventid, 1), 0) AS alterto,
    COALESCE(array_length(altertotal.eventid, 1), 0) AS altertotal,
    COALESCE(array_length(dissolution.eventid, 1), 0) AS dissolution,
    dissolution.eventid AS dissolutionevent,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN dissolution.eventdatetext[1]
            ELSE ''::text
        END AS dissolutiontext,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN COALESCE(dissolution.eventeffectiveprecision[1], 'None'::text)
            ELSE 'None'::text
        END AS dissolutionprecision,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN dissolution.eventsortdate[1]
            ELSE NULL::date
        END AS dissolutionsort,
        CASE
            WHEN (array_length(dissolution.eventid, 1) = 1) THEN COALESCE(dissolution.eventeffectivetype[1], ''::text)
            ELSE ''::text
        END AS dissolutionhow,
        CASE
            WHEN (dissolution.lawsection IS NULL) THEN false
            ELSE dissolution.lawsection
        END AS dissolutionlawsection,
    dissolution.originalgovernmentid AS dissolutionas
   FROM (((((((geohistory.government
     LEFT JOIN geohistory.government governmentparent ON ((government.governmentcurrentleadparent = governmentparent.governmentid)))
     LEFT JOIN alterfrom ON ((government.governmentid = alterfrom.governmentid)))
     LEFT JOIN alterto ON ((government.governmentid = alterto.governmentid)))
     LEFT JOIN altertotal ON ((government.governmentid = altertotal.governmentid)))
     LEFT JOIN creation ON ((government.governmentid = creation.governmentid)))
     LEFT JOIN dissolution ON ((government.governmentid = dissolution.governmentid)))
     LEFT JOIN affectedgovernmentform ON (((government.governmentid = affectedgovernmentform.government) AND (affectedgovernmentform.recentness = 1))))
  WHERE (government.governmentsubstitute IS NULL)
  ORDER BY COALESCE((government.governmentcurrentleadstate)::text, ''::text), government.governmentlevel, government.governmenttype,
        CASE
            WHEN (government.governmentlevel > 3) THEN (governmentparent.governmentname)::text
            ELSE NULL::text
        END, government.governmentlong, government.governmentid;


ALTER VIEW geohistory.governmentchangecount OWNER TO postgres;

--
-- Name: governmentchangecountcache; Type: MATERIALIZED VIEW; Schema: geohistory; Owner: postgres
--

CREATE MATERIALIZED VIEW geohistory.governmentchangecountcache AS
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
   FROM geohistory.governmentchangecount
  WITH NO DATA;


ALTER MATERIALIZED VIEW geohistory.governmentchangecountcache OWNER TO postgres;

--
-- Name: recordingevent; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.recordingevent (
    recordingeventid integer NOT NULL,
    event integer NOT NULL,
    recording integer NOT NULL,
    eventrelationship integer NOT NULL,
    recordingeventinclude boolean,
    CONSTRAINT recordingevent_check CHECK ((eventrelationship <> ALL (ARRAY[6, 7, 9])))
);


ALTER TABLE geohistory.recordingevent OWNER TO postgres;

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
    sourcecitationissue character varying(20) DEFAULT ''::character varying NOT NULL,
    sourcecitationname text DEFAULT ''::text NOT NULL,
    sourcecitationslug text GENERATED ALWAYS AS (lower(regexp_replace(regexp_replace(btrim(((((((((((((((geohistory.sourceshort(source) || ' '::text) || split_part(sourcecitationtypetitle, ' '::text, 1)) || ' '::text) || split_part(sourcecitationtypetitle, ' '::text, 2)) || ' '::text) || split_part(regexp_replace(sourcecitationgovernmentreferences, '[;]+'::text, ' '::text, 'g'::text), ' '::text, 1)) || ' '::text) || split_part(regexp_replace(sourcecitationgovernmentreferences, '[;]+'::text, ' '::text, 'g'::text), ' '::text, 2)) || ' '::text) || (sourcecitationvolume)::text) || ' '::text) || (sourcecitationpagefrom)::text) || ' '::text) || sourcecitationname)), '[ –—]+'::text, '-'::text, 'g'::text), '[\.\/''\(\);:,&"#§\?\[\]]'::text, ''::text, 'g'::text))) STORED,
    sourcecitationpage text GENERATED ALWAYS AS (geohistory.rangeformat((sourcecitationpagefrom)::text, (sourcecitationpageto)::text)) STORED
);


ALTER TABLE geohistory.sourcecitation OWNER TO postgres;

--
-- Name: COLUMN sourcecitation.sourcecitationstatus; Type: COMMENT; Schema: geohistory; Owner: postgres
--

COMMENT ON COLUMN geohistory.sourcecitation.sourcecitationstatus IS 'This field is used for internal tracking purposes, and is not included in open data.';


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
historic-error: Government-identifier link created in error.
historic-match: Secondary records with spelling match.
historic-missing: Successor current government does not list as USGS alternate (name change).
historic-obsolete: Historic government with USGS spelling match.
historic-spelling: Historic government with USGS alternate spelling mismatch.
historic-status: Historic government missing USGS historic flag.
historic-successor: Successor current government does not list as USGS alternate (merger-consolidation).

Entries other than current-* or full can also be combined with -lead flag.';


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
    lawgroupsectionlead text DEFAULT ''::text NOT NULL,
    lawgroupyear text GENERATED ALWAYS AS (geohistory.rangeformat((lawgroupfrom)::text, (lawgroupto)::text)) STORED
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
-- Name: governmentothercurrentparent; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.governmentothercurrentparent (
    governmentothercurrentparentid integer NOT NULL,
    government integer NOT NULL,
    governmentothercurrentparent integer NOT NULL
);


ALTER TABLE geohistory.governmentothercurrentparent OWNER TO postgres;

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
    tribunaltypedistrictcircuit text DEFAULT ''::text NOT NULL,
    tribunaltypesummary character varying(50) DEFAULT ''::character varying NOT NULL,
    CONSTRAINT tribunaltype_check CHECK ((((tribunaltypefilingoffice)::text <> ''::text) AND (tribunaltypelong <> ''::text) AND ((tribunaltypeshort)::text <> ''::text)))
);


ALTER TABLE geohistory.tribunaltype OWNER TO postgres;

--
-- Name: adjudicationsourcecitation; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.adjudicationsourcecitation (
    adjudicationsourcecitationid integer NOT NULL,
    source integer NOT NULL,
    adjudicationsourcecitationvolume smallint NOT NULL,
    adjudicationsourcecitationpagefrom smallint NOT NULL,
    adjudicationsourcecitationpageto smallint,
    adjudicationsourcecitationyear character varying(4) DEFAULT ''::character varying NOT NULL,
    adjudicationsourcecitationdate calendar.historicdatetext DEFAULT (''::text)::calendar.historicdatetext NOT NULL,
    adjudicationsourcecitationtitle text DEFAULT ''::text NOT NULL,
    adjudicationsourcecitationauthor character varying(45) DEFAULT ''::character varying NOT NULL,
    adjudicationsourcecitationjudge character varying(45) DEFAULT ''::character varying NOT NULL,
    adjudicationsourcecitationdissentjudge character varying(45) DEFAULT ''::character varying NOT NULL,
    adjudicationsourcecitationurl text DEFAULT ''::text NOT NULL,
    adjudication integer NOT NULL,
    adjudicationsourcecitationname text DEFAULT ''::text NOT NULL,
    adjudicationsourcecitationslug text GENERATED ALWAYS AS (lower(replace(replace(replace(btrim((((((
CASE
    WHEN (adjudicationsourcecitationvolume = 0) THEN ''::text
    ELSE (adjudicationsourcecitationvolume || '-'::text)
END || geohistory.sourceshort(source)) ||
CASE
    WHEN (adjudicationsourcecitationpagefrom = 0) THEN ''::text
    ELSE ('-'::text || adjudicationsourcecitationpagefrom)
END) ||
CASE
    WHEN (((adjudicationsourcecitationdate)::text = ''::text) OR ("left"((adjudicationsourcecitationdate)::text, 4) = '0000'::text)) THEN
    CASE
        WHEN ((adjudicationsourcecitationyear)::text = ''::text) THEN ''::text
        ELSE ('-'::text || (adjudicationsourcecitationyear)::text)
    END
    ELSE ('-'::text || "left"((adjudicationsourcecitationdate)::text, 4))
END) || ' '::text) || adjudicationsourcecitationname)), '.'::text, ''::text), '& '::text, ''::text), ' '::text, '-'::text))) STORED,
    adjudicationsourcecitationpage text GENERATED ALWAYS AS (geohistory.rangeformat((adjudicationsourcecitationpagefrom)::text, (adjudicationsourcecitationpageto)::text)) STORED
);


ALTER TABLE geohistory.adjudicationsourcecitation OWNER TO postgres;

--
-- Name: lawalternatesection; Type: TABLE; Schema: geohistory; Owner: postgres
--

CREATE TABLE geohistory.lawalternatesection (
    lawalternatesectionid integer NOT NULL,
    lawalternate integer NOT NULL,
    lawsection integer NOT NULL,
    lawalternatesectionpagefrom smallint,
    lawalternatesectionpageto smallint,
    lawalternatesectioncitation text GENERATED ALWAYS AS ((((geohistory.lawalternatecitation(lawalternate) || ', '::text) || geohistory.lawsectionsymbol(lawsection)) ||
CASE
    WHEN (geohistory.lawsectionfrom(lawsection) = '0'::text) THEN '___'::text
    WHEN (geohistory.lawsectionfrom(lawsection) = geohistory.lawsectionto(lawsection)) THEN (' '::text || geohistory.lawsectionfrom(lawsection))
    ELSE ((('§ '::text || geohistory.lawsectionfrom(lawsection)) || '-'::text) || geohistory.lawsectionto(lawsection))
END)) STORED,
    lawalternatesectionslug text GENERATED ALWAYS AS (lower(replace(replace(regexp_replace(regexp_replace((((geohistory.lawalternatecitation(lawalternate) || ', '::text) || geohistory.lawsectionsymbol(lawsection)) ||
CASE
    WHEN (geohistory.lawsectionfrom(lawsection) = '0'::text) THEN '___'::text
    WHEN (geohistory.lawsectionfrom(lawsection) = geohistory.lawsectionto(lawsection)) THEN (' '::text || geohistory.lawsectionfrom(lawsection))
    ELSE ((('§ '::text || geohistory.lawsectionfrom(lawsection)) || '-'::text) || geohistory.lawsectionto(lawsection))
END), '[,\.\[\]\(\)\'']'::text, ''::text, 'g'::text), '([ :\–\—\/]| of )'::text, '-'::text, 'g'::text), '§'::text, 's'::text), '¶'::text, 'p'::text))) STORED
);


ALTER TABLE geohistory.lawalternatesection OWNER TO postgres;

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
    documentationshort character varying(50) NOT NULL,
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
    governmentidentifiertypeprefixlengthfrom integer,
    governmentidentifiertypeprefixlengthto integer,
    governmentidentifiertypelengthfrom integer,
    governmentidentifiertypelengthto integer,
    governmentidentifiertypeslug text,
    governmentidentifiertypeprefixdelimiter character varying(1) DEFAULT ''::character varying NOT NULL,
    governmentidentifiertypenote text DEFAULT ''::text NOT NULL,
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
-- Name: lastrefresh; Type: MATERIALIZED VIEW; Schema: geohistory; Owner: postgres
--

CREATE MATERIALIZED VIEW geohistory.lastrefresh AS
 SELECT '2024-11-02'::date AS lastrefreshdate
  WITH NO DATA;


ALTER MATERIALIZED VIEW geohistory.lastrefresh OWNER TO postgres;

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
    lawalternateurl text DEFAULT ''::text NOT NULL,
    lawalternatecitation text GENERATED ALWAYS AS ((geohistory.sourcelawtype(source) ||
CASE
    WHEN ((lawalternatepage = 0) AND (lawalternatenumberchapter = 0)) THEN ' Unknown'::text
    ELSE (((((((((((
    CASE
        WHEN ((geohistory.lawapproved(law))::text = ''::text) THEN ''::text
        ELSE ' of '::text
    END || calendar.historicdatetextformat((geohistory.lawapproved(law))::calendar.historicdate, 'long'::text, 'en'::text)) || ' ('::text) ||
    CASE
        WHEN ((lawalternatevolume)::text ~~ '%/%'::text) THEN ((((((
        CASE
            WHEN (split_part((lawalternatevolume)::text, '/'::text, 3) <> ''::text) THEN (split_part((lawalternatevolume)::text, '/'::text, 3) || ', '::text)
            ELSE ''::text
        END || split_part((lawalternatevolume)::text, '/'::text, 2)) ||
        CASE
            WHEN (split_part((lawalternatevolume)::text, '/'::text, 2) = '1'::text) THEN 'st'::text
            WHEN (split_part((lawalternatevolume)::text, '/'::text, 2) = '2'::text) THEN 'nd'::text
            WHEN (split_part((lawalternatevolume)::text, '/'::text, 2) = '3'::text) THEN 'rd'::text
            ELSE 'th'::text
        END) || ' '::text) ||
        CASE
            WHEN geohistory.sourcelawhasspecialsession(source) THEN 'Sp.'::text
            ELSE ''::text
        END) || 'Sess., '::text) ||
        CASE
            WHEN ("left"((geohistory.lawapproved(law))::text, 4) <> split_part((lawalternatevolume)::text, '/'::text, 1)) THEN (split_part((lawalternatevolume)::text, '/'::text, 1) || ' '::text)
            ELSE ''::text
        END)
        ELSE
        CASE
            WHEN (((lawalternatevolume)::text = "left"((geohistory.lawapproved(law))::text, 4)) OR ((lawalternatevolume)::text = ''::text)) THEN ''::text
            ELSE ((lawalternatevolume)::text || ' '::text)
        END
    END) || geohistory.sourceshort(source)) || ' '::text) ||
    CASE
        WHEN (lawalternatepage = 0) THEN '___'::text
        ELSE (lawalternatepage)::text
    END) || ', '::text) ||
    CASE
        WHEN geohistory.sourcelawisbynumber(source) THEN 'No'::text
        ELSE 'Ch'::text
    END) || '. '::text) ||
    CASE
        WHEN (lawalternatenumberchapter = 0) THEN '___'::text
        ELSE (lawalternatenumberchapter)::text
    END) || ')'::text)
END)) STORED,
    lawalternateslug text GENERATED ALWAYS AS ((geohistory.sourcelawtype(source) ||
CASE
    WHEN ((lawalternatepage = 0) AND (lawalternatenumberchapter = 0)) THEN ' Unknown'::text
    ELSE (((((((((((
    CASE
        WHEN ((geohistory.lawapproved(law))::text = ''::text) THEN ''::text
        ELSE ' of '::text
    END || calendar.historicdatetextformat((geohistory.lawapproved(law))::calendar.historicdate, 'short'::text, 'en'::text)) || ' ('::text) ||
    CASE
        WHEN ((lawalternatevolume)::text ~~ '%/%'::text) THEN ((((((
        CASE
            WHEN (split_part((lawalternatevolume)::text, '/'::text, 3) <> ''::text) THEN (split_part((lawalternatevolume)::text, '/'::text, 3) || ', '::text)
            ELSE ''::text
        END || split_part((lawalternatevolume)::text, '/'::text, 2)) ||
        CASE
            WHEN (split_part((lawalternatevolume)::text, '/'::text, 2) = '1'::text) THEN 'st'::text
            WHEN (split_part((lawalternatevolume)::text, '/'::text, 2) = '2'::text) THEN 'nd'::text
            WHEN (split_part((lawalternatevolume)::text, '/'::text, 2) = '3'::text) THEN 'rd'::text
            ELSE 'th'::text
        END) || ' '::text) ||
        CASE
            WHEN geohistory.sourcelawhasspecialsession(source) THEN 'Sp.'::text
            ELSE ''::text
        END) || 'Sess., '::text) ||
        CASE
            WHEN ("left"((geohistory.lawapproved(law))::text, 4) <> split_part((lawalternatevolume)::text, '/'::text, 1)) THEN (split_part((lawalternatevolume)::text, '/'::text, 1) || ' '::text)
            ELSE ''::text
        END)
        ELSE
        CASE
            WHEN (((lawalternatevolume)::text = "left"((geohistory.lawapproved(law))::text, 4)) OR ((lawalternatevolume)::text = ''::text)) THEN ''::text
            ELSE ((lawalternatevolume)::text || ' '::text)
        END
    END) || geohistory.sourceshort(source)) || ' '::text) ||
    CASE
        WHEN (lawalternatepage = 0) THEN '___'::text
        ELSE (lawalternatepage)::text
    END) || ', '::text) ||
    CASE
        WHEN geohistory.sourcelawisbynumber(source) THEN 'No'::text
        ELSE 'Ch'::text
    END) || '. '::text) ||
    CASE
        WHEN (lawalternatenumberchapter = 0) THEN '___'::text
        ELSE (lawalternatenumberchapter)::text
    END) || ')'::text)
END)) STORED
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
    plsstownshipname text DEFAULT ''::text NOT NULL,
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
END)) STORED,
    plsstownshipabbreviation text GENERATED ALWAYS AS (((((((
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
END) || ' '::text) || geohistory.plssmeridianshort(plssmeridian))) STORED
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
-- Name: adjudication_adjudicationslug_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX adjudication_adjudicationslug_idx ON geohistory.adjudication USING btree (adjudicationslug) WITH (deduplicate_items='true');


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
-- Name: adjudicationsourcecitation_adjudicationsourcecitationslug_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX adjudicationsourcecitation_adjudicationsourcecitationslug_idx ON geohistory.adjudicationsourcecitation USING btree (adjudicationsourcecitationslug) WITH (deduplicate_items='true');


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
-- Name: event_eventslug_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX event_eventslug_idx ON geohistory.event USING btree (eventslug);


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
-- Name: eventslugretired_eventslug_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX eventslugretired_eventslug_idx ON geohistory.eventslugretired USING btree (eventslug);


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
-- Name: government_governmentabbreviation_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX government_governmentabbreviation_idx ON geohistory.government USING btree (governmentabbreviation) WITH (deduplicate_items='true');


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
-- Name: government_governmentsearch_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX government_governmentsearch_idx ON geohistory.government USING btree (governmentsearch) WITH (deduplicate_items='true');


--
-- Name: government_governmentshort_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX government_governmentshort_idx ON geohistory.government USING btree (governmentshort) WITH (deduplicate_items='true');


--
-- Name: government_governmentslugsubstitute_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX government_governmentslugsubstitute_idx ON geohistory.government USING btree (governmentslugsubstitute) WITH (deduplicate_items='true');


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
-- Name: lawalternatesection_lawalternatesectioncitation_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawalternatesection_lawalternatesectioncitation_idx ON geohistory.lawalternatesection USING btree (lawalternatesectioncitation) WITH (deduplicate_items='true');


--
-- Name: lawalternatesection_lawalternatesectionslug_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawalternatesection_lawalternatesectionslug_idx ON geohistory.lawalternatesection USING btree (lawalternatesectionslug) WITH (deduplicate_items='true');


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
-- Name: lawsection_lawsectioncitation_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawsection_lawsectioncitation_idx ON geohistory.lawsection USING btree (lawsectioncitation) WITH (deduplicate_items='true');


--
-- Name: lawsection_lawsectionnewlaw_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawsection_lawsectionnewlaw_idx ON geohistory.lawsection USING btree (lawsectionnewlaw);


--
-- Name: lawsection_lawsectionslug_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX lawsection_lawsectionslug_idx ON geohistory.lawsection USING btree (lawsectionslug) WITH (deduplicate_items='true');


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
-- Name: metesdescription_metesdescriptionslug_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX metesdescription_metesdescriptionslug_idx ON geohistory.metesdescription USING btree (metesdescriptionslug) WITH (deduplicate_items='true');


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
-- Name: sourcecitation_sourcecitationslug_idx; Type: INDEX; Schema: geohistory; Owner: postgres
--

CREATE INDEX sourcecitation_sourcecitationslug_idx ON geohistory.sourcecitation USING btree (sourcecitationslug) WITH (deduplicate_items='true');


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
-- Name: governmentshape_governmentshapeslug_idx; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX governmentshape_governmentshapeslug_idx ON gis.governmentshape USING btree (governmentshapeslug) WITH (deduplicate_items='true');


--
-- Name: governmentshape_idx; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX governmentshape_idx ON gis.governmentshape USING gist (governmentshapegeometry);


--
-- Name: governmentshape_municipality_idx; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX governmentshape_municipality_idx ON gis.governmentshape USING btree (governmentsubmunicipality, governmentmunicipality);


--
-- Name: governmentshapecache_geometry_idx; Type: INDEX; Schema: gis; Owner: postgres
--

CREATE INDEX governmentshapecache_geometry_idx ON gis.governmentshapecache USING gist (geometry);


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

CREATE TRIGGER lawsectionevent_insertupdate_trigger BEFORE INSERT OR UPDATE OF lawsection, lawgroup, eventrelationship ON geohistory.lawsectionevent FOR EACH ROW EXECUTE FUNCTION geohistory.lawsectionevent_insertupdate();


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
-- Name: SCHEMA geohistory; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA geohistory TO readonly;


--
-- Name: SCHEMA gis; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA gis TO readonly;


--
-- Name: FUNCTION adjudicationtypegovernmentshort(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.adjudicationtypegovernmentshort(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION adjudicationtypegovernmentslug(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.adjudicationtypegovernmentslug(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION adjudicationtypelong(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.adjudicationtypelong(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION adjudicationtypetribunaltypesummary(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.adjudicationtypetribunaltypesummary(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION array_combine(integer[]); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.array_combine(integer[]) FROM PUBLIC;
GRANT ALL ON FUNCTION geohistory.array_combine(integer[]) TO readonly;


--
-- Name: FUNCTION datetonumeric(date); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.datetonumeric(date) FROM PUBLIC;


--
-- Name: FUNCTION emptytonull(text); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.emptytonull(text) FROM PUBLIC;
GRANT ALL ON FUNCTION geohistory.emptytonull(text) TO readonly;


--
-- Name: FUNCTION eventlong(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.eventlong(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION eventslug(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.eventslug(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION government_insertupdate(); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.government_insertupdate() FROM PUBLIC;


--
-- Name: FUNCTION governmentcurrentleadstate(i_id integer, i_level integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.governmentcurrentleadstate(i_id integer, i_level integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentcurrentleadstateid(i_id integer, i_level integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.governmentcurrentleadstateid(i_id integer, i_level integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentname(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.governmentname(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentothercurrentparent_insertupdate(); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.governmentothercurrentparent_insertupdate() FROM PUBLIC;


--
-- Name: FUNCTION governmentslug(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.governmentslug(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION governmentslugsubstitute(i_id integer, i_level integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.governmentslugsubstitute(i_id integer, i_level integer) FROM PUBLIC;


--
-- Name: FUNCTION implode(text[]); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.implode(text[]) FROM PUBLIC;


--
-- Name: FUNCTION law_insertupdate(); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.law_insertupdate() FROM PUBLIC;


--
-- Name: FUNCTION lawalternate_update(); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.lawalternate_update() FROM PUBLIC;


--
-- Name: FUNCTION lawalternatecitation(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.lawalternatecitation(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION lawalternatesection_insertupdate(); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.lawalternatesection_insertupdate() FROM PUBLIC;


--
-- Name: FUNCTION lawalternateslug(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.lawalternateslug(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION lawapproved(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.lawapproved(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION lawcitation(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.lawcitation(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION lawgroupsection_deleteupdate(); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.lawgroupsection_deleteupdate() FROM PUBLIC;


--
-- Name: FUNCTION lawsection_update(); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.lawsection_update() FROM PUBLIC;


--
-- Name: FUNCTION lawsectionevent_insertupdate(); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.lawsectionevent_insertupdate() FROM PUBLIC;


--
-- Name: FUNCTION lawsectionfrom(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.lawsectionfrom(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION lawsectionsymbol(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.lawsectionsymbol(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION lawsectionto(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.lawsectionto(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION lawslug(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.lawslug(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION metesdescriptionline_insertupdate(); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.metesdescriptionline_insertupdate() FROM PUBLIC;


--
-- Name: FUNCTION plssmeridianlong(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.plssmeridianlong(i_id integer) FROM PUBLIC;
GRANT ALL ON FUNCTION geohistory.plssmeridianlong(i_id integer) TO readonly;


--
-- Name: FUNCTION plssmeridianshort(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.plssmeridianshort(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION punctuationnone(text); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.punctuationnone(text) FROM PUBLIC;


--
-- Name: FUNCTION punctuationnonefuzzy(text); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.punctuationnonefuzzy(text) FROM PUBLIC;
GRANT ALL ON FUNCTION geohistory.punctuationnonefuzzy(text) TO readonly;


--
-- Name: FUNCTION rangeformat(text, text); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.rangeformat(text, text) FROM PUBLIC;


--
-- Name: FUNCTION refresh_view(); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.refresh_view() FROM PUBLIC;


--
-- Name: FUNCTION source_insert(); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.source_insert() FROM PUBLIC;


--
-- Name: FUNCTION source_update(); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.source_update() FROM PUBLIC;


--
-- Name: FUNCTION sourcelawhasspecialsession(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.sourcelawhasspecialsession(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION sourcelawisbynumber(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.sourcelawisbynumber(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION sourcelawtype(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.sourcelawtype(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION sourceshort(i_id integer); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.sourceshort(i_id integer) FROM PUBLIC;


--
-- Name: FUNCTION sourcetype_update(); Type: ACL; Schema: geohistory; Owner: postgres
--

REVOKE ALL ON FUNCTION geohistory.sourcetype_update() FROM PUBLIC;


--
-- Name: FUNCTION governmentshape_delete(); Type: ACL; Schema: gis; Owner: postgres
--

REVOKE ALL ON FUNCTION gis.governmentshape_delete() FROM PUBLIC;


--
-- Name: FUNCTION governmentshape_insert(); Type: ACL; Schema: gis; Owner: postgres
--

REVOKE ALL ON FUNCTION gis.governmentshape_insert() FROM PUBLIC;


--
-- Name: FUNCTION refresh_sequence(); Type: ACL; Schema: gis; Owner: postgres
--

REVOKE ALL ON FUNCTION gis.refresh_sequence() FROM PUBLIC;


--
-- Name: FUNCTION refresh_view(); Type: ACL; Schema: gis; Owner: postgres
--

REVOKE ALL ON FUNCTION gis.refresh_view() FROM PUBLIC;


--
-- Name: TABLE affectedgovernmentgroup; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.affectedgovernmentgroup TO readonly;


--
-- Name: TABLE affectedgovernmentgrouppart; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.affectedgovernmentgrouppart TO readonly;


--
-- Name: TABLE affectedgovernmentlevel; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.affectedgovernmentlevel TO readonly;


--
-- Name: TABLE affectedgovernmentpart; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.affectedgovernmentpart TO readonly;


--
-- Name: TABLE affectedtype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.affectedtype TO readonly;


--
-- Name: TABLE event; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.event TO readonly;


--
-- Name: TABLE eventeffectivetype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.eventeffectivetype TO readonly;


--
-- Name: TABLE eventgranted; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.eventgranted TO readonly;


--
-- Name: TABLE eventtype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.eventtype TO readonly;


--
-- Name: TABLE government; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.government TO readonly;


--
-- Name: TABLE governmentform; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.governmentform TO readonly;


--
-- Name: TABLE governmentmapstatus; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.governmentmapstatus TO readonly;


--
-- Name: TABLE affectedgovernmentgis; Type: ACL; Schema: gis; Owner: postgres
--

GRANT SELECT ON TABLE gis.affectedgovernmentgis TO readonly;


--
-- Name: TABLE governmentshape; Type: ACL; Schema: gis; Owner: postgres
--

GRANT SELECT ON TABLE gis.governmentshape TO readonly;


--
-- Name: TABLE governmentshapecache; Type: ACL; Schema: gis; Owner: postgres
--

GRANT SELECT ON TABLE gis.governmentshapecache TO readonly;


--
-- Name: TABLE adjudication; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.adjudication TO readonly;


--
-- Name: TABLE adjudicationevent; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.adjudicationevent TO readonly;


--
-- Name: TABLE adjudicationlocation; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.adjudicationlocation TO readonly;


--
-- Name: TABLE adjudicationlocationtype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.adjudicationlocationtype TO readonly;


--
-- Name: TABLE adjudicationtype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.adjudicationtype TO readonly;


--
-- Name: TABLE currentgovernment; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.currentgovernment TO readonly;


--
-- Name: TABLE governmentsource; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.governmentsource TO readonly;


--
-- Name: TABLE governmentsourceevent; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.governmentsourceevent TO readonly;


--
-- Name: TABLE law; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.law TO readonly;


--
-- Name: TABLE lawsection; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.lawsection TO readonly;


--
-- Name: TABLE lawsectionevent; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.lawsectionevent TO readonly;


--
-- Name: TABLE metesdescription; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.metesdescription TO readonly;


--
-- Name: TABLE sourcegovernment; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.sourcegovernment TO readonly;


--
-- Name: TABLE tribunal; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.tribunal TO readonly;


--
-- Name: TABLE metesdescriptiongis; Type: ACL; Schema: gis; Owner: postgres
--

GRANT SELECT ON TABLE gis.metesdescriptiongis TO readonly;


--
-- Name: TABLE source; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.source TO readonly;


--
-- Name: TABLE recording; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.recording TO readonly;


--
-- Name: TABLE recordingoffice; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.recordingoffice TO readonly;


--
-- Name: TABLE recordingofficetype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.recordingofficetype TO readonly;


--
-- Name: TABLE recordingtype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.recordingtype TO readonly;


--
-- Name: TABLE researchlog; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.researchlog TO readonly;


--
-- Name: TABLE researchlogtype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.researchlogtype TO readonly;


--
-- Name: TABLE eventrelationship; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.eventrelationship TO readonly;


--
-- Name: TABLE governmentchangecountpart; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.governmentchangecountpart TO readonly;


--
-- Name: TABLE governmentchangecountpartcache; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.governmentchangecountpartcache TO readonly;


--
-- Name: TABLE governmentchangecount; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.governmentchangecount TO readonly;


--
-- Name: TABLE governmentchangecountcache; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.governmentchangecountcache TO readonly;


--
-- Name: TABLE recordingevent; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.recordingevent TO readonly;


--
-- Name: TABLE sourcecitation; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.sourcecitation TO readonly;


--
-- Name: TABLE sourcecitationevent; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.sourcecitationevent TO readonly;


--
-- Name: TABLE sourcecitationnote; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.sourcecitationnote TO readonly;


--
-- Name: TABLE sourcecitationnotetype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.sourcecitationnotetype TO readonly;


--
-- Name: TABLE governmentidentifier; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.governmentidentifier TO readonly;


--
-- Name: TABLE lawgroup; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.lawgroup TO readonly;


--
-- Name: TABLE lawgroupsection; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.lawgroupsection TO readonly;


--
-- Name: TABLE governmentothercurrentparent; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.governmentothercurrentparent TO readonly;


--
-- Name: TABLE lawgroupgovernmenttype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.lawgroupgovernmenttype TO readonly;


--
-- Name: TABLE tribunaltype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.tribunaltype TO readonly;


--
-- Name: TABLE adjudicationsourcecitation; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.adjudicationsourcecitation TO readonly;


--
-- Name: TABLE lawalternatesection; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.lawalternatesection TO readonly;


--
-- Name: TABLE censusmap; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.censusmap TO readonly;


--
-- Name: TABLE documentation; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.documentation TO readonly;


--
-- Name: TABLE eventmethod; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.eventmethod TO readonly;


--
-- Name: TABLE eventslugretired; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.eventslugretired TO readonly;


--
-- Name: TABLE filing; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.filing TO readonly;


--
-- Name: TABLE filingtype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.filingtype TO readonly;


--
-- Name: TABLE governmentformgovernment; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.governmentformgovernment TO readonly;


--
-- Name: TABLE governmentidentifiertype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.governmentidentifiertype TO readonly;


--
-- Name: TABLE lastrefresh; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.lastrefresh TO readonly;


--
-- Name: TABLE lawalternate; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.lawalternate TO readonly;


--
-- Name: TABLE lawgroupeventtype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.lawgroupeventtype TO readonly;


--
-- Name: TABLE locale; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.locale TO readonly;


--
-- Name: TABLE metesdescriptionline; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.metesdescriptionline TO readonly;


--
-- Name: TABLE nationalarchives; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.nationalarchives TO readonly;


--
-- Name: TABLE plss; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.plss TO readonly;


--
-- Name: TABLE plssfirstdivision; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.plssfirstdivision TO readonly;


--
-- Name: TABLE plssfirstdivisionpart; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.plssfirstdivisionpart TO readonly;


--
-- Name: TABLE plssmeridian; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.plssmeridian TO readonly;


--
-- Name: TABLE plssseconddivision; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.plssseconddivision TO readonly;


--
-- Name: TABLE plssspecialsurvey; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.plssspecialsurvey TO readonly;


--
-- Name: TABLE plsstownship; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.plsstownship TO readonly;


--
-- Name: TABLE shorttype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.shorttype TO readonly;


--
-- Name: TABLE sourceitem; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.sourceitem TO readonly;


--
-- Name: TABLE sourceitemcategory; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.sourceitemcategory TO readonly;


--
-- Name: TABLE sourceitempart; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.sourceitempart TO readonly;


--
-- Name: TABLE sourcetype; Type: ACL; Schema: geohistory; Owner: postgres
--

GRANT SELECT ON TABLE geohistory.sourcetype TO readonly;


--
-- Name: TABLE deleted_affectedgovernmentgis; Type: ACL; Schema: gis; Owner: postgres
--

GRANT SELECT ON TABLE gis.deleted_affectedgovernmentgis TO readonly;


--
-- Name: TABLE deleted_metesdescriptiongis; Type: ACL; Schema: gis; Owner: postgres
--

GRANT SELECT ON TABLE gis.deleted_metesdescriptiongis TO readonly;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: geohistory; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA geohistory GRANT ALL ON FUNCTIONS TO readonly;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: geohistory; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA geohistory GRANT SELECT ON TABLES TO readonly;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: gis; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA gis GRANT ALL ON FUNCTIONS TO readonly;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: gis; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA gis GRANT SELECT ON TABLES TO readonly;


--
-- PostgreSQL database dump complete
--

