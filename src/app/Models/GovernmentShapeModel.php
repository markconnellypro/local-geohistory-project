<?php

namespace App\Models;

use App\Models\BaseModel;

class GovernmentShapeModel extends BaseModel
{
    // extra.ci_model_area_currentgovernment(v_governmentshapeid integer, v_state character varying, v_locale character varying)
    // extra.ci_model_area_currentgovernment(v_governmentshapeid text, v_state character varying, v_locale character varying)

    // FUNCTION: extra.governmentabbreviation
    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentshort
    // FUNCTION: extra.governmentslug

    public function getDetail(int|string $id): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = <<<QUERY
            SELECT DISTINCT governmentshape.governmentshapeid,
                COALESCE(extra.governmentslug(governmentshape.governmentsubmunicipality), '') AS governmentsubmunicipality,
                COALESCE(extra.governmentlong(governmentshape.governmentsubmunicipality), '') AS governmentsubmunicipalitylong,
                extra.governmentslug(governmentshape.governmentmunicipality) AS governmentmunicipality,
                extra.governmentlong(governmentshape.governmentmunicipality) AS governmentmunicipalitylong,
                extra.governmentslug(governmentshape.governmentcounty) AS governmentcounty,
                extra.governmentshort(governmentshape.governmentcounty, '') AS governmentcountyshort,
                extra.governmentslug(governmentshape.governmentstate) AS governmentstate,
                extra.governmentabbreviation(governmentshape.governmentstate) AS governmentstateabbreviation,
                governmentshape.governmentshapeid AS id,
                public.st_asgeojson(governmentshape.governmentshapegeometry) AS geometry
            FROM gis.governmentshape
            WHERE governmentshape.governmentshapeid = ?
            ORDER BY 8, 6, 4, 2
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_area_point(pointy double precision, pointx double precision)

    public function getPointId(float $y, float $x): array
    {
        $query = <<<QUERY
            SELECT DISTINCT governmentshape.governmentshapeid
                FROM gis.governmentshape
            WHERE ST_Contains(governmentshape.governmentshapegeometry, ST_SetSRID(ST_Point(?,?),4326))
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            $x,
            $y
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_statistics_mapped_nation_part(character varying, integer, integer, character varying, boolean)

    // FUNCTION: extra.governmentabbreviation
    // VIEW: extra.statistics_mapped

    public function getByStatisticsNationPart(array $parameters): array
    {
        $by = $parameters[3];
        $jurisdiction = $parameters[4];
        if ($jurisdiction === '') {
            $jurisdiction = implode(',', \App\Controllers\BaseController::getJurisdictions());
        }
        $jurisdiction = '{' . strtoupper($jurisdiction) . '}';

        $query = <<<QUERY
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
                AND statistics_mapped.grouptype = ?
                AND statistics_mapped.governmentstate = ANY (?)
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
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            $by,
            $jurisdiction,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_statistics_mapped_nation_whole(character varying, integer, integer, character varying, boolean)

    // VIEW: extra.statistics_mapped

    public function getByStatisticsNationWhole(array $parameters): array
    {
        $by = $parameters[3];

        $query = <<<QUERY
            WITH eventdata AS (
                SELECT DISTINCT 0 AS x,
                statistics_mapped.percentmapped::text AS y
                FROM extra.statistics_mapped
                WHERE statistics_mapped.governmenttype = 'nation'
                AND statistics_mapped.grouptype = ?
                AND statistics_mapped.governmentstate = ?
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
                ON xvalue.x = eventdata.x
        QUERY;

        $query = $this->db->query($query, [
            $by,
            ENVIRONMENT,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_statistics_mapped_state_part(character varying, integer, integer, character varying, character varying)

    // VIEW: extra.statistics_mapped

    public function getByStatisticsStatePart(array $parameters): array
    {
        $by = $parameters[3];
        $jurisdiction = strtoupper($parameters[4]);

        $query = <<<QUERY
            WITH eventdata AS (
                SELECT DISTINCT statistics_mapped.governmentcounty AS series,
                0 AS x,
                statistics_mapped.percentmapped::numeric AS y
                FROM extra.statistics_mapped
                WHERE statistics_mapped.governmenttype = 'county'
                AND statistics_mapped.grouptype = ?
                AND statistics_mapped.governmentstate = ?
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
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            $by,
            $jurisdiction,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_statistics_mapped_state_whole(character varying, integer, integer, character varying, character varying)

    // VIEW: extra.statistics_mapped

    public function getByStatisticsStateWhole(array $parameters): array
    {
        $by = $parameters[3];
        $jurisdiction = strtoupper($parameters[4]);

        $query = <<<QUERY
            WITH eventdata AS (
                SELECT DISTINCT 0 AS x,
                statistics_mapped.percentmapped::text AS y
                FROM extra.statistics_mapped
                WHERE statistics_mapped.governmenttype = 'state'
                AND statistics_mapped.grouptype = ?
                AND statistics_mapped.governmentstate = ?
            ), xvalue AS (
                SELECT DISTINCT generate_series(min(eventdata.x),max(eventdata.x)) AS x
                FROM eventdata
            )
            SELECT array_to_json(ARRAY['x'::text] || array_agg(DISTINCT xvalue.x::text ORDER BY xvalue.x::text)) AS datarow
            FROM xvalue
            UNION ALL
            SELECT array_to_json(ARRAY[?] || array_agg(
                CASE
                    WHEN eventdata.y IS NULL THEN '0'::text
                    ELSE eventdata.y
                END ORDER BY xvalue.x)) AS datarow
            FROM xvalue
            LEFT JOIN eventdata
                ON xvalue.x = eventdata.x
        QUERY;

        $query = $this->db->query($query, [
            $by,
            $jurisdiction,
            $jurisdiction,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_government_current(integer)

    // VIEW: extra.giscache

    public function getCurrentByGovernment(int $id): array
    {
        $query = <<<QUERY
            SELECT giscache.government AS id,
                public.st_asgeojson(public.st_boundary(geometry), 5) AS geometry
            FROM extra.giscache
            WHERE giscache.government = ?
            GROUP BY 1, 2;
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_government_shape(integer, character varying, character varying)

    // FUNCTION: extra.emptytonull
    // FUNCTION: extra.governmentshort
    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentslug
    // FUNCTION: extra.plsstownshipshort
    // VIEW: extra.governmentshapeextracache
    // VIEW: extra.governmentsubstitutecache

    public function getPartByGovernment(int $id): array
    {
        $query = <<<QUERY
            WITH affectedgovernmentsummary AS (
                SELECT DISTINCT affectedgovernmentgroup.affectedgovernmentgroupid AS affectedgovernmentid,
                affectedgovernmentgroup.event AS eventid,
                affectedgovernmentpart.affectedtypefrom AS affectedtypeid,
                'from' AS fromto,
                NULL::integer AS governmentto
                FROM geohistory.affectedgovernmentgroup
                JOIN geohistory.affectedgovernmentgrouppart
                    ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
                JOIN geohistory.affectedgovernmentpart
                    ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
                JOIN extra.governmentsubstitutecache
                    ON affectedgovernmentpart.governmentfrom = governmentsubstitutecache.governmentid
                    AND governmentsubstitutecache.governmentsubstitute = ?
                UNION
                    SELECT DISTINCT affectedgovernmentgroup.affectedgovernmentgroupid AS affectedgovernmentid,
                    affectedgovernmentgroup.event AS eventid,
                    affectedgovernmentpart.affectedtypeto AS affectedtypeid,
                    'to' AS fromto,
                    affectedgovernmentpart.governmentto
                    FROM geohistory.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentpart
                        ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
                    JOIN extra.governmentsubstitutecache
                        ON affectedgovernmentpart.governmentto = governmentsubstitutecache.governmentid
                        AND governmentsubstitutecache.governmentsubstitute = ?
            ), governmentshapeeventpartparts AS (
                    SELECT affectedgovernmentgis.governmentshape AS governmentshapeid,
                    event.eventdatetext,
                    event.eventsort,
                    to_char(event.eventsortdate, 'Mon FMDD, YYYY') || CASE
                        WHEN event.eventeffective <> '' AND event.eventeffective NOT LIKE '%~%' THEN ''
                        ELSE ' (About)'
                    END AS eventtextsortdate,
                    event.eventslug,
                    array_agg(DISTINCT CASE
                        WHEN NOT eventgranted.eventgrantedsuccess THEN 'proposed'
                        WHEN affectedtype.affectedtypecreationdissolution IN ('end', 'alter', 'ascertain') AND affectedgovernmentsummary.fromto = 'from' THEN 'remove'
                        WHEN affectedtype.affectedtypecreationdissolution IN ('begin', 'alter', 'ascertain') AND affectedgovernmentsummary.fromto = 'to' THEN 'add'
                        WHEN affectedtype.affectedtypecreationdissolution IN ('subordinate', 'separate') THEN affectedtype.affectedtypecreationdissolution
                        ELSE 'other'
                    END ORDER BY CASE
                        WHEN NOT eventgranted.eventgrantedsuccess THEN 'proposed'
                        WHEN affectedtype.affectedtypecreationdissolution IN ('end', 'alter', 'ascertain') AND affectedgovernmentsummary.fromto = 'from' THEN 'remove'
                        WHEN affectedtype.affectedtypecreationdissolution IN ('begin', 'alter', 'ascertain') AND affectedgovernmentsummary.fromto = 'to' THEN 'add'
                        WHEN affectedtype.affectedtypecreationdissolution IN ('subordinate', 'separate') THEN affectedtype.affectedtypecreationdissolution
                        ELSE 'other'
                    END) AS eventstatus,
                    array_agg(DISTINCT affectedgovernmentsummary.governmentto ORDER BY affectedgovernmentsummary.governmentto) AS governmentto
                    FROM affectedgovernmentsummary
                    JOIN geohistory.affectedtype
                        ON affectedgovernmentsummary.affectedtypeid = affectedtype.affectedtypeid
                    JOIN gis.affectedgovernmentgis
                        ON affectedgovernmentsummary.affectedgovernmentid = affectedgovernmentgis.affectedgovernment
                    JOIN geohistory.event
                        ON affectedgovernmentsummary.eventid = event.eventid
                    JOIN geohistory.eventgranted
                        ON event.eventgranted = eventgranted.eventgrantedid
                    GROUP BY 1, 2, 3, 4, 5
            ), governmentshapeeventparts AS (
                    SELECT governmentshapeeventpartparts.governmentshapeid,
                    governmentshapeeventpartparts.eventdatetext,
                    governmentshapeeventpartparts.eventsort,
                    governmentshapeeventpartparts.eventtextsortdate,
                    governmentshapeeventpartparts.eventslug,
                    CASE
                        WHEN governmentshapeeventpartparts.eventstatus = '{add,remove}' THEN 'name' 
                        ELSE governmentshapeeventpartparts.eventstatus[1] 
                    END AS eventstatus,
                    extra.emptytonull(array_to_string(governmentshapeeventpartparts.governmentto, ','))::integer AS governmentto
                    FROM governmentshapeeventpartparts
            ), lasteventstatus AS (
                    SELECT governmentshapeeventparts.governmentshapeid,
                    (array_agg(governmentshapeeventparts.eventstatus ORDER BY CASE
                        WHEN governmentshapeeventparts.eventstatus IN ('add', 'remove') THEN 0
                        ELSE 1
                    END ASC, governmentshapeeventparts.eventsort DESC))[1] AS eventstatus
                    FROM governmentshapeeventparts
                    GROUP BY 1
            ), governmentshapeeventearliest AS (
                    SELECT min(governmentshapeeventparts.eventsort) AS mineventsort
                    FROM governmentshapeeventparts
            ), governmentshapeeventjsonparts AS (
                    SELECT governmentshapeeventparts.governmentshapeid,
                    governmentshapeeventparts.eventsort,
                    json_strip_nulls(json_build_object('eventsort', governmentshapeeventparts.eventsort,
                        'eventslug', governmentshapeeventparts.eventslug,
                        'eventstatus', governmentshapeeventparts.eventstatus,
                        'eventdatetext', governmentshapeeventparts.eventdatetext,
                        'eventtextsortdate', governmentshapeeventparts.eventtextsortdate,
                        'eventgovernmentlong', CASE
                            WHEN governmentshapeeventearliest.mineventsort = governmentshapeeventparts.eventsort OR governmentshapeeventparts.eventstatus = 'name' THEN extra.governmentlong(governmentshapeeventparts.governmentto, '')
                            ELSE NULL
                        END)) AS eventjson
                    FROM governmentshapeeventparts,
                        governmentshapeeventearliest
            ), governmentshapeevent AS (
                    SELECT governmentshapeeventjsonparts.governmentshapeid,
                    lasteventstatus.eventstatus,
                    json_agg(governmentshapeeventjsonparts.eventjson ORDER BY governmentshapeeventjsonparts.eventsort) AS eventjson
                    FROM governmentshapeeventjsonparts
                    JOIN lasteventstatus
                        ON governmentshapeeventjsonparts.governmentshapeid = lasteventstatus.governmentshapeid
                    GROUP BY 1, 2
            )
            SELECT
            CASE
                WHEN governmentshapeextracache.governmentshapeslug IS NOT NULL THEN governmentshapeextracache.governmentshapeslug
                ELSE governmentshape.governmentshapeid::text
            END AS governmentshapeslug,
            '' AS plsstownship,
            COALESCE(extra.plsstownshipshort(governmentshape.governmentshapeplsstownship), '') AS plsstownshipshort,
            COALESCE(extra.governmentslug(governmentshape.governmentsubmunicipality), '') AS submunicipality,
            COALESCE(extra.governmentlong(governmentshape.governmentsubmunicipality), '') AS submunicipalitylong,
            extra.governmentslug(governmentshape.governmentmunicipality) AS municipality,
            extra.governmentlong(governmentshape.governmentmunicipality) AS municipalitylong,
            extra.governmentslug(governmentshape.governmentcounty) AS county,
            extra.governmentshort(governmentshape.governmentcounty, '') AS countyshort,
            st_asgeojson(governmentshape.governmentshapegeometry) AS geometry,
            CASE
                WHEN NOT (ARRAY[governmentshape.governmentcounty, governmentshape.governmentmunicipality, governmentshape.governmentshapeplsstownship, governmentshape.governmentschooldistrict, governmentshape.governmentsubmunicipality, governmentshape.governmentward] && ARRAY[?::integer]) AND governmentshapeevent.governmentshapeid IS NOT NULL AND governmentshapeevent.eventstatus = 'proposed' THEN 1
                WHEN NOT (ARRAY[governmentshape.governmentcounty, governmentshape.governmentmunicipality, governmentshape.governmentshapeplsstownship, governmentshape.governmentschooldistrict, governmentshape.governmentsubmunicipality, governmentshape.governmentward] && ARRAY[?::integer]) THEN 2
                WHEN (ARRAY[governmentshape.governmentcounty, governmentshape.governmentmunicipality, governmentshape.governmentshapeplsstownship, governmentshape.governmentschooldistrict, governmentshape.governmentsubmunicipality, governmentshape.governmentward] && ARRAY[?::integer]) AND governmentshapeevent.governmentshapeid IS NOT NULL AND governmentshapeevent.eventstatus = 'add' THEN 4
                ELSE 3
            END AS disposition,
            CASE
                WHEN governmentshapeevent.eventjson IS NULL THEN '[]'::json
                ELSE governmentshapeevent.eventjson
            END AS eventjson
            FROM gis.governmentshape
            LEFT JOIN extra.governmentshapeextracache
            ON governmentshape.governmentshapeid = governmentshapeextracache.governmentshapeid
            LEFT JOIN governmentshapeevent
            ON governmentshape.governmentshapeid = governmentshapeevent.governmentshapeid
            WHERE governmentshape.governmentmunicipality = ? OR
            governmentshape.governmentcounty = ? OR
            (governmentshape.governmentschooldistrict IS NOT NULL AND governmentshape.governmentschooldistrict = ?) OR
            (governmentshape.governmentshapeplsstownship IS NOT NULL AND governmentshape.governmentshapeplsstownship = ?) OR
            (governmentshape.governmentsubmunicipality IS NOT NULL AND governmentshape.governmentsubmunicipality = ?) OR
            (governmentshape.governmentward IS NOT NULL AND governmentshape.governmentward = ?) OR
            governmentshape.governmentshapeid IN (
                SELECT governmentshapeevent.governmentshapeid
                FROM governmentshapeevent
            )
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            $id,
            $id,
            $id,
            $id,
            $id,
            $id,
            $id,
            $id,
            $id,
            $id,
            $id,
        ]);

        return $this->getObject($query);
    }

    // extra.governmentshapeslugid(text)

    // VIEW: extra.governmentshapeextracache

    private function getSlugId(string $id): int
    {
        $query = <<<QUERY
            SELECT governmentshapeextracache.governmentshapeid AS id
                FROM extra.governmentshapeextracache
            WHERE governmentshapeextracache.governmentshapeslug = ?
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        $query = $this->getObject($query);

        $id = -1;

        if (count($query) === 1) {
            $id = $query[0]->id;
        }

        return $id;
    }

    // extra.ci_model_map_tile(v_state character varying, v_z integer, v_x integer, v_y integer)

    // FUNCTION: extra.governmentshort
    // VIEW: extra.giscountycache
    // VIEW: extra.gismunicipalitycache
    // VIEW: extra.gissubmunicipalitycache

    public function getTile(float $z, float $x, float $y): array
    {
        $query = <<<QUERY
            WITH mvtgeometrycounty AS (
                SELECT ST_AsMVTGeom(ST_Transform(giscountycache.geometry, 3857), ST_TileEnvelope(?, ?, ?), extent => 4096, buffer => 64) AS geometry,
                giscountycache.government AS name,
                extra.governmentshort(giscountycache.government) AS description
                FROM extra.giscountycache
                WHERE giscountycache.geometry && ST_Transform(ST_TileEnvelope(?, ?, ?, margin => (64.0 / 4096)), 4326)
            ),
            mvtgeometrymunicipality AS (
                SELECT ST_AsMVTGeom(ST_Transform(gismunicipalitycache.geometry, 3857), ST_TileEnvelope(?, ?, ?), extent => 4096, buffer => 64) AS geometry,
                gismunicipalitycache.government AS name,
                extra.governmentshort(gismunicipalitycache.government) AS description
                FROM extra.gismunicipalitycache
                WHERE ? >= 6 
                AND gismunicipalitycache.geometry && ST_Transform(ST_TileEnvelope(?, ?, ?, margin => (64.0 / 4096)), 4326)
            ),
            mvtgeometrysubmunicipality AS (
                SELECT ST_AsMVTGeom(ST_Transform(gissubmunicipalitycache.geometry, 3857), ST_TileEnvelope(?, ?, ?), extent => 4096, buffer => 64) AS geometry,
                gissubmunicipalitycache.government AS name,
                extra.governmentshort(gissubmunicipalitycache.government) AS description
                FROM extra.gissubmunicipalitycache
                WHERE ? >= 6 
                AND gissubmunicipalitycache.geometry && ST_Transform(ST_TileEnvelope(?, ?, ?, margin => (64.0 / 4096)), 4326)
            )
            SELECT ST_AsMVT(mvtgeometrycounty.*, 'county') AS mvt
            FROM mvtgeometrycounty
            UNION
            SELECT ST_AsMVT(mvtgeometrymunicipality.*, 'municipality') AS mvt
            FROM mvtgeometrymunicipality
            UNION
            SELECT ST_AsMVT(mvtgeometrysubmunicipality.*, 'submunicipality') AS mvt
            FROM mvtgeometrysubmunicipality;
        QUERY;

        $query = $this->db->query($query, [
            $z,
            $x,
            $y,
            $z,
            $x,
            $y,
            $z,
            $x,
            $y,
            $z,
            $z,
            $x,
            $y,
            $z,
            $x,
            $y,
            $z,
            $z,
            $x,
            $y,
        ]);

        return $this->getObject($query);
    }
}
