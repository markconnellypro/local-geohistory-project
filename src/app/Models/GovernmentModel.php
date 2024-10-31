<?php

namespace App\Models;

use App\Models\BaseModel;

class GovernmentModel extends BaseModel
{
    // extra.ci_model_government_detail(integer, character varying, boolean)
    // extra.ci_model_government_detail(text, character varying, boolean)

    // FUNCTION: extra.governmentlevel
    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentsubstitutedcache
    // VIEW: extra.governmentchangecountcache
    // VIEW: extra.governmenthasmappedeventcache
    // VIEW: extra.governmentsubstitutecache

    public function getDetail(int|string $id): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = <<<QUERY
            SELECT government.governmentid,
                extra.governmentlong(government.governmentid) AS governmentlong,
                    CASE
                        WHEN government.governmentcurrentform IS NULL THEN government.governmenttype
                        ELSE governmentform.governmentformlongextended
                    END AS governmenttype,
                    CASE
                        WHEN government.governmentstatus IN ('placeholder') THEN 'placeholder'::text
                        WHEN government.governmentlevel = 1 THEN 'country'::text
                        WHEN government.governmentlevel = 2 THEN 'state'::text
                        WHEN government.governmentlevel = 3 THEN 'county'::text
                        ELSE 'municipality or lower'::text
                    END AS governmentlevel,
                    NOT (governmentchangecountcache.creationevent IS NULL
                    AND governmentchangecountcache.altertotal = 0
                    AND governmentchangecountcache.dissolutionevent IS NULL
                    ) AS textflag,
                    creationevent.eventslug AS governmentcreationevent,
                governmentchangecountcache.creationtext AS governmentcreationtext,
                    CASE
                        WHEN governmentchangecountcache.creation = 1
                            AND array_length(governmentchangecountcache.creationas, 1) = 1
                            AND government.governmentid <> governmentchangecountcache.creationas[1]
                            THEN extra.governmentlong(governmentchangecountcache.creationas[1])
                        ELSE ''
                    END AS governmentcreationlong,
                governmentchangecountcache.altertotal AS governmentaltercount,
                dissolutionevent.eventslug AS governmentdissolutionevent,
                governmentchangecountcache.dissolutiontext AS governmentdissolutiontext,
                    CASE
                        WHEN hasmaptable.hasmap IS NULL THEN false
                        ELSE true
                    END AS hasmap,
                government.governmentmapstatus,
                governmentmapstatus.governmentmapstatustimelapse,
                governmentsubstitutecache.governmentsubstitutemultiple,
                CASE
                    WHEN government.governmentslug <> government.governmentslugsubstitute THEN government.governmentslugsubstitute
                    ELSE NULL
                END AS governmentslugsubstitute, 
                government.governmentcurrentleadstate
            FROM geohistory.government
            JOIN geohistory.governmentmapstatus
                ON government.governmentmapstatus = governmentmapstatus.governmentmapstatusid
            JOIN extra.governmentsubstitutecache
                ON government.governmentid = governmentsubstitutecache.governmentid
            LEFT JOIN geohistory.governmentform
                ON government.governmentcurrentform = governmentform.governmentformid
            LEFT JOIN extra.governmentchangecountcache
                ON government.governmentid = governmentchangecountcache.governmentid
            LEFT JOIN geohistory.event creationevent
                ON governmentchangecountcache.creationevent IS NOT NULL
                AND governmentchangecountcache.creationevent[1] = creationevent.eventid
            LEFT JOIN geohistory.event dissolutionevent
                ON governmentchangecountcache.dissolutionevent IS NOT NULL
                AND governmentchangecountcache.dissolutionevent[1] = dissolutionevent.eventid
            LEFT OUTER JOIN
                (
                SELECT DISTINCT true AS hasmap
                    FROM gis.governmentshapecache
                    WHERE extra.governmentlevel(governmentshapecache.government) > 2
                        AND governmentshapecache.government = ANY (extra.governmentsubstitutedcache(?))
                    UNION
                    SELECT DISTINCT true AS hasmap
                    FROM extra.governmenthasmappedeventcache
                    WHERE governmentsubstitute = ?
                ) AS hasmaptable
                ON 0 = 0
            WHERE government.governmentid = ?
        QUERY;

        $query = $this->db->query($query, [
            $id,
            $id,
            $id,
            $id,
        ]);

        return $this->getObject($query);
    }

    // extra.governmentabbreviationid(text)
    // NOT REMOVED

    public function getAbbreviationId(string $id): int
    {
        $query = <<<QUERY
            SELECT governmentid AS id
            FROM geohistory.government
            WHERE upper(governmentabbreviation) = ?
        QUERY;

        $query = $this->db->query($query, [
            strtoupper($id),
        ]);

        $query = $this->getObject($query);

        $id = -1;

        if (count($query) === 1) {
            $id = $query[0]->id;
        }

        return $id;
    }

    // extra.ci_model_governmentidentifier_government(integer[], character varying)

    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentslug

    public function getByGovernmentIdentifier(string $ids): array
    {
        $query = <<<QUERY
            SELECT extra.governmentslug(governmentidentifier.government) governmentslug,
                extra.governmentlong(governmentidentifier.government) AS governmentlong,
                governmentidentifier.governmentidentifierstatus AS governmentparentstatus
            FROM geohistory.governmentidentifier
            WHERE governmentidentifier.governmentidentifierid = ANY (?);
        QUERY;

        $query = $this->db->query($query, [
            $ids
        ]);

        return $this->getObject($query);
    }

    public function getByStatisticsJurisdiction(): array
    {
        $query = <<<QUERY
            SELECT DISTINCT government.governmentshort,
                lower(government.governmentabbreviation) AS governmentabbreviation
            FROM geohistory.government
            JOIN extra.statistics_eventtype
                ON government.governmentabbreviation = statistics_eventtype.governmentstate
                AND government.governmentstatus = ''
                AND government.governmentlevel = 2
        QUERY;

        $query = $this->db->query($query);

        return $this->getArray($query);
    }

    // extra.ci_model_statistics_createddissolved_nation_part(character varying, integer, integer, character varying, boolean)

    // FUNCTION: extra.governmentabbreviation
    // VIEW: extra.statistics_createddissolved

    public function getByStatisticsNationPart(array $parameters): array
    {
        $for = $parameters[0];
        $from = $parameters[1];
        $to = $parameters[2];
        $by = $parameters[3];
        $jurisdiction = $parameters[4];
        if ($jurisdiction === '') {
            $jurisdiction = implode(',', \App\Controllers\BaseController::getJurisdictions());
        }
        $jurisdiction = '{' . strtoupper($jurisdiction) . '}';

        $query = <<<QUERY
            WITH eventdata AS (
                    SELECT DISTINCT min(governmentidentifier.governmentidentifier) AS series,
                    statistics_createddissolved.governmentstate AS actualseries,
                    statistics_createddissolved.eventsortyear AS x,
                    CASE
                        WHEN ? = 'created' THEN statistics_createddissolved.created::integer
                        WHEN ? = 'dissolved' THEN statistics_createddissolved.dissolved::integer
                        WHEN ? = 'net' THEN (statistics_createddissolved.created - statistics_createddissolved.dissolved)::integer
                        ELSE 0::integer
                    END AS y
                    FROM extra.statistics_createddissolved
                    JOIN geohistory.governmentidentifier
                        ON statistics_createddissolved.governmentstate = extra.governmentabbreviation(governmentidentifier.government)
                        AND governmentidentifier.governmentidentifiertype = 1
                    WHERE statistics_createddissolved.governmenttype = 'state'
                    AND statistics_createddissolved.grouptype = ?
                    AND statistics_createddissolved.governmentstate = ANY (?)
                    AND statistics_createddissolved.eventsortyear >= ?
                    AND statistics_createddissolved.eventsortyear <= ?
                    AND CASE
                        WHEN ? = 'created' THEN statistics_createddissolved.created > 0
                        WHEN ? = 'dissolved' THEN statistics_createddissolved.dissolved > 0
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
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            $for,
            $for,
            $for,
            $by,
            $jurisdiction,
            $from,
            $to,
            $for,
            $for,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_statistics_createddissolved_nation_whole(character varying, integer, integer, character varying, boolean)

    // VIEW: extra.statistics_createddissolved

    public function getByStatisticsNationWhole(array $parameters): array
    {
        $for = $parameters[0];
        $from = $parameters[1];
        $to = $parameters[2];
        $by = $parameters[3];

        $query = <<<QUERY
            WITH eventdata AS (
                SELECT DISTINCT statistics_createddissolved.eventsortyear AS x,
                (CASE
                    WHEN ? = 'created' THEN statistics_createddissolved.created::integer
                    WHEN ? = 'dissolved' THEN statistics_createddissolved.dissolved::integer
                    WHEN ? = 'net' THEN (statistics_createddissolved.created - statistics_createddissolved.dissolved)::integer
                    ELSE 0::integer
                END)::text AS y
                FROM extra.statistics_createddissolved
                WHERE statistics_createddissolved.governmenttype = 'nation'
                AND statistics_createddissolved.grouptype = ?
                AND statistics_createddissolved.governmentstate = ?
                AND statistics_createddissolved.eventsortyear >= ?
                AND statistics_createddissolved.eventsortyear <= ?
                AND CASE
                    WHEN ? = 'created' THEN statistics_createddissolved.created > 0
                    WHEN ? = 'dissolved' THEN statistics_createddissolved.dissolved > 0
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
                ON xvalue.x = eventdata.x
        QUERY;

        $query = $this->db->query($query, [
            $for,
            $for,
            $for,
            $by,
            ENVIRONMENT,
            $from,
            $to,
            $for,
            $for,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_statistics_createddissolved_state_part(character varying, integer, integer, character varying, character varying)

    // VIEW: extra.statistics_createddissolved

    public function getByStatisticsStatePart(array $parameters): array
    {
        $for = $parameters[0];
        $from = $parameters[1];
        $to = $parameters[2];
        $by = $parameters[3];
        $jurisdiction = strtoupper($parameters[4]);

        $query = <<<QUERY
            WITH eventdata AS (
                SELECT DISTINCT statistics_createddissolved.governmentcounty AS series,
                statistics_createddissolved.eventsortyear AS x,
                CASE
                    WHEN ? = 'created' THEN statistics_createddissolved.created::integer
                    WHEN ? = 'dissolved' THEN statistics_createddissolved.dissolved::integer
                    WHEN ? = 'net' THEN (statistics_createddissolved.created - statistics_createddissolved.dissolved)::integer
                    ELSE 0::integer
                END AS y
                FROM extra.statistics_createddissolved
                WHERE statistics_createddissolved.governmenttype = 'county'
                AND statistics_createddissolved.grouptype = ?
                AND statistics_createddissolved.governmentstate = ?
                AND statistics_createddissolved.eventsortyear >= ?
                AND statistics_createddissolved.eventsortyear <= ?
                AND CASE
                    WHEN ? = 'created' THEN statistics_createddissolved.created > 0
                    WHEN ? = 'dissolved' THEN statistics_createddissolved.dissolved > 0
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
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            $for,
            $for,
            $for,
            $by,
            $jurisdiction,
            $from,
            $to,
            $for,
            $for,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_statistics_createddissolved_state_whole(character varying, integer, integer, character varying, character varying)

    // VIEW: extra.statistics_createddissolved

    public function getByStatisticsStateWhole(array $parameters): array
    {
        $for = $parameters[0];
        $from = $parameters[1];
        $to = $parameters[2];
        $by = $parameters[3];
        $jurisdiction = strtoupper($parameters[4]);

        $query = <<<QUERY
            WITH eventdata AS (
                SELECT DISTINCT statistics_createddissolved.eventsortyear AS x,
                (CASE
                    WHEN ? = 'created' THEN statistics_createddissolved.created::integer
                    WHEN ? = 'dissolved' THEN statistics_createddissolved.dissolved::integer
                    WHEN ? = 'net' THEN (statistics_createddissolved.created - statistics_createddissolved.dissolved)::integer
                    ELSE 0::integer
                END)::text AS y
                FROM extra.statistics_createddissolved
                WHERE statistics_createddissolved.governmenttype = 'state'
                AND statistics_createddissolved.grouptype = ?
                AND statistics_createddissolved.governmentstate = ?
                AND statistics_createddissolved.eventsortyear >= ?
                AND statistics_createddissolved.eventsortyear <= ?
                AND CASE
                    WHEN ? = 'created' THEN statistics_createddissolved.created > 0
                    WHEN ? = 'dissolved' THEN statistics_createddissolved.dissolved > 0
                    ELSE 0 = 0
                END
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
            $for,
            $for,
            $for,
            $by,
            $jurisdiction,
            $from,
            $to,
            $for,
            $for,
            $jurisdiction,
        ]);

        return $this->getObject($query);
    }

    public function getIdByGovernment(int $government): string
    {
        $query = <<<QUERY
            SELECT DISTINCT government.governmentid
            FROM geohistory.government lookupgovernment
            JOIN geohistory.government
                ON lookupgovernment.governmentslugsubstitute = government.governmentslugsubstitute
                AND government.governmentstatus <> 'placeholder'
                AND lookupgovernment.governmentid = ?
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            $government,
        ]);

        $result = [];

        $query = $this->getObject($query);
        foreach ($query as $row) {
            $result[] = $row->governmentid;
        }

        return '{' . implode(',', $result) . '}';
    }

    public function getIdByGovernmentShort(string $government): string
    {
        $query = <<<QUERY
            SELECT DISTINCT government.governmentid
            FROM geohistory.government lookupgovernment
            JOIN geohistory.government
                ON lookupgovernment.governmentslugsubstitute = government.governmentslugsubstitute
                AND government.governmentstatus <> 'placeholder'
                AND lookupgovernment.governmentshort = ?
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            $government,
        ]);

        $result = [];

        $query = $this->getObject($query);
        foreach ($query as $row) {
            $result[] = $row->governmentid;
        }

        return '{' . implode(',', $result) . '}';
    }

    // replace extra.governmentparent(cache), extra.governmentrelation(cache)

    public function getIdByGovernmentShortParent(string $government, string $parent): string
    {
        $government = $this->getIdByGovernmentShort($government);
        $parent = $this->getIdByGovernmentShort($parent);

        $query = <<<QUERY
            SELECT DISTINCT government.governmentid
            FROM geohistory.government
            JOIN geohistory.government governmentparent
                ON government.governmentcurrentleadparent = governmentparent.governmentid
                AND governmentparent.governmentstatus <> 'placeholder'
                AND government.governmentid = ANY (?)
                AND governmentparent.governmentid = ANY (?)
            UNION DISTINCT
            SELECT DISTINCT government.governmentid
            FROM geohistory.government
            JOIN geohistory.governmentothercurrentparent
                ON government.governmentid = governmentothercurrentparent.government
                AND government.governmentid = ANY (?)
            JOIN geohistory.government governmentparent
                ON governmentothercurrentparent.governmentothercurrentparent = governmentparent.governmentid
                AND governmentparent.governmentstatus <> 'placeholder'
                AND governmentparent.governmentid = ANY (?)
            UNION DISTINCT
            SELECT DISTINCT government.governmentid
            FROM geohistory.government
            JOIN geohistory.affectedgovernmentpart lookuppart
                ON government.governmentid = lookuppart.governmentfrom
                AND government.governmentid = ANY (?)
            JOIN geohistory.affectedgovernmentgrouppart lookupgrouppart
                ON lookuppart.affectedgovernmentpartid = lookupgrouppart.affectedgovernmentpart
            JOIN geohistory.affectedgovernmentlevel lookuplevel
                ON lookupgrouppart.affectedgovernmentlevel = lookuplevel.affectedgovernmentlevelid
                AND lookuplevel.affectedgovernmentlevelgroup > 3
            JOIN geohistory.affectedgovernmentgrouppart
                ON lookupgrouppart.affectedgovernmentgroup = affectedgovernmentgrouppart.affectedgovernmentgroup
            JOIN geohistory.affectedgovernmentlevel
                ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                AND lookuplevel.affectedgovernmentlevelgroup = 3
            JOIN geohistory.affectedgovernmentpart
                ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
            JOIN geohistory.government governmentparent
                ON affectedgovernmentpart.governmentfrom = governmentparent.governmentid
                AND governmentparent.governmentstatus <> 'placeholder'
                AND governmentparent.governmentid = ANY (?)
            UNION DISTINCT
            SELECT DISTINCT government.governmentid
            FROM geohistory.government
            JOIN geohistory.affectedgovernmentpart lookuppart
                ON government.governmentid = lookuppart.governmentto
                AND government.governmentid = ANY (?)
            JOIN geohistory.affectedgovernmentgrouppart lookupgrouppart
                ON lookuppart.affectedgovernmentpartid = lookupgrouppart.affectedgovernmentpart
            JOIN geohistory.affectedgovernmentlevel lookuplevel
                ON lookupgrouppart.affectedgovernmentlevel = lookuplevel.affectedgovernmentlevelid
                AND lookuplevel.affectedgovernmentlevelgroup > 3
            JOIN geohistory.affectedgovernmentgrouppart
                ON lookupgrouppart.affectedgovernmentgroup = affectedgovernmentgrouppart.affectedgovernmentgroup
            JOIN geohistory.affectedgovernmentlevel
                ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                AND lookuplevel.affectedgovernmentlevelgroup = 3
            JOIN geohistory.affectedgovernmentpart
                ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
            JOIN geohistory.government governmentparent
                ON affectedgovernmentpart.governmentto = governmentparent.governmentid
                AND governmentparent.governmentstatus <> 'placeholder'
                AND governmentparent.governmentid = ANY (?)
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            $government,
            $parent,
            $government,
            $parent,
            $government,
            $parent,
            $government,
            $parent,
        ]);

        $result = [];

        $query = $this->getObject($query);
        foreach ($query as $row) {
            $result[] = $row->governmentid;
        }

        return '{' . implode(',', $result) . '}';
    }

    // extra.ci_model_search_lookup_government(character varying, character varying)

    public function getLookupByGovernment(string $government): array
    {
        if (strlen($government) < 3) {
            return [];
        }

        $query = <<<QUERY
            SELECT DISTINCT government.governmentshort,
                government.governmentsearch
            FROM geohistory.government
            WHERE government.governmentstatus <> 'placeholder'
                AND government.governmentlevel > 2
                AND government.governmentsearch LIKE geohistory.punctuationnonefuzzy(?)
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            rawurldecode($government),
        ]);

        return $this->getArray($query);
    }

    public function getLookupByGovernmentJurisdiction(string $government): array
    {
        if (strlen($government) < 3) {
            return [];
        }

        $query = <<<QUERY
            SELECT DISTINCT government.governmentshort,
                government.governmentsearch
            FROM geohistory.government
            WHERE government.governmentstatus = ''
                AND government.governmentlevel = 2
                AND government.governmentsearch LIKE geohistory.punctuationnonefuzzy(?)
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            rawurldecode($government),
        ]);

        return $this->getArray($query);
    }

    // extra.ci_model_search_lookup_governmentparent(text, text)

    // VIEW: extra.governmentrelationcache

    public function getLookupByGovernmentParent(string $government): array
    {
        $query = <<<QUERY
            SELECT DISTINCT government.governmentshort,
                government.governmentsearch
            FROM geohistory.government lookupgovernment
            JOIN geohistory.government
                ON lookupgovernment.governmentcurrentleadparent = government.governmentid
                AND government.governmentstatus <> 'placeholder'
                AND lookupgovernment.governmentsearch LIKE geohistory.punctuationnonefuzzy(?)
            UNION DISTINCT
            SELECT DISTINCT government.governmentshort,
                government.governmentsearch
            FROM geohistory.government lookupgovernment
            JOIN geohistory.governmentothercurrentparent
                ON lookupgovernment.governmentid = governmentothercurrentparent.government
                AND lookupgovernment.governmentsearch LIKE geohistory.punctuationnonefuzzy(?)
            JOIN geohistory.government
                ON governmentothercurrentparent.governmentothercurrentparent = government.governmentid
                AND government.governmentstatus <> 'placeholder'
            UNION DISTINCT
            SELECT DISTINCT government.governmentshort,
                government.governmentsearch
            FROM geohistory.government lookupgovernment
            JOIN geohistory.affectedgovernmentpart lookuppart
                ON lookupgovernment.governmentid = lookuppart.governmentfrom
                AND lookupgovernment.governmentsearch LIKE geohistory.punctuationnonefuzzy(?)
            JOIN geohistory.affectedgovernmentgrouppart lookupgrouppart
                ON lookuppart.affectedgovernmentpartid = lookupgrouppart.affectedgovernmentpart
            JOIN geohistory.affectedgovernmentlevel lookuplevel
                ON lookupgrouppart.affectedgovernmentlevel = lookuplevel.affectedgovernmentlevelid
                AND lookuplevel.affectedgovernmentlevelgroup > 3
            JOIN geohistory.affectedgovernmentgrouppart
                ON lookupgrouppart.affectedgovernmentgroup = affectedgovernmentgrouppart.affectedgovernmentgroup
            JOIN geohistory.affectedgovernmentlevel
                ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                AND lookuplevel.affectedgovernmentlevelgroup = 3
            JOIN geohistory.affectedgovernmentpart
                ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
            JOIN geohistory.government
                ON affectedgovernmentpart.governmentfrom = government.governmentid
                AND government.governmentstatus <> 'placeholder'
            UNION DISTINCT
            SELECT DISTINCT government.governmentshort,
                government.governmentsearch
            FROM geohistory.government lookupgovernment
            JOIN geohistory.affectedgovernmentpart lookuppart
                ON lookupgovernment.governmentid = lookuppart.governmentto
                AND lookupgovernment.governmentsearch LIKE geohistory.punctuationnonefuzzy(?)
            JOIN geohistory.affectedgovernmentgrouppart lookupgrouppart
                ON lookuppart.affectedgovernmentpartid = lookupgrouppart.affectedgovernmentpart
            JOIN geohistory.affectedgovernmentlevel lookuplevel
                ON lookupgrouppart.affectedgovernmentlevel = lookuplevel.affectedgovernmentlevelid
                AND lookuplevel.affectedgovernmentlevelgroup > 3
            JOIN geohistory.affectedgovernmentgrouppart
                ON lookupgrouppart.affectedgovernmentgroup = affectedgovernmentgrouppart.affectedgovernmentgroup
            JOIN geohistory.affectedgovernmentlevel
                ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                AND lookuplevel.affectedgovernmentlevelgroup = 3
            JOIN geohistory.affectedgovernmentpart
                ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
            JOIN geohistory.government
                ON affectedgovernmentpart.governmentto = government.governmentid
                AND government.governmentstatus <> 'placeholder'
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            rawurldecode($government),
            rawurldecode($government),
            rawurldecode($government),
            rawurldecode($government),
        ]);

        return $this->getArray($query);
    }

    public function getNote(int $id): array
    {
        return [];
    }

    public function getOffice(int $id): array
    {
        return [];
    }

    // extra.ci_model_government_related(integer, character varying, character varying)

    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentslug
    // VIEW: extra.governmentparentcache
    // VIEW: extra.governmentsubstitutecache

    public function getRelated(int $id): array
    {
        $query = <<<QUERY
            WITH relationpart AS (
                SELECT DISTINCT extra.governmentslug(
                    CASE
                        WHEN government.governmentstatus = ANY (ARRAY['alternate', 'language']) THEN government.governmentsubstitute
                        ELSE government.governmentid
                    END) AS governmentslug,
                'government' AS governmentslugtype,
                extra.governmentlong(governmentparentcache.governmentparent) AS governmentlong,
                'Parent' AS governmentrelationship,
                    CASE
                        WHEN government.governmentstatus = ANY (ARRAY['alternate', 'language']) THEN 'variant'
                        WHEN governmentparentcache.governmentid <> ? AND governmentparentcache.governmentparentstatus = ANY (ARRAY['current', 'most recent']) THEN 'former'
                        ELSE governmentparentcache.governmentparentstatus
                    END AS governmentparentstatus,
                    CASE
                        WHEN governmentmapstatus.governmentmapstatusid IS NOT NULL AND governmentmapstatus.governmentmapstatustimelapse AND NOT governmentmapstatus.governmentmapstatusfurtherresearch THEN 'complete'
                        WHEN governmentmapstatus.governmentmapstatusid IS NOT NULL AND governmentmapstatus.governmentmapstatustimelapse THEN 'research'
                        WHEN governmentmapstatus.governmentmapstatusid IS NOT NULL AND governmentmapstatus.governmentmapstatusfurtherresearch THEN 'incomplete'
                        ELSE 'none'
                    END AS governmentcolor,
                governmentparentcache.governmentid = ? AS isgovernmentsubstitute
                FROM extra.governmentparentcache
                    JOIN geohistory.government
                    ON governmentparentcache.governmentparent = government.governmentid
                    JOIN extra.governmentsubstitutecache
                    ON governmentparentcache.governmentid = governmentsubstitutecache.governmentid
                    AND governmentsubstitutecache.governmentsubstitute = ?
                    LEFT JOIN geohistory.governmentmapstatus ON government.governmentmapstatus = governmentmapstatus.governmentmapstatusid AND governmentmapstatus.governmentmapstatusreviewed AND (government.governmentstatus <> ALL (ARRAY['proposed', 'unincorporated']))
                WHERE governmentparentcache.governmentparentstatus <> 'placeholder' AND governmentparentcache.governmentparent IS NOT NULL
                UNION
                SELECT DISTINCT extra.governmentslug(
                    CASE
                        WHEN government.governmentstatus = ANY (ARRAY['alternate', 'language']) THEN government.governmentsubstitute
                        ELSE government.governmentid
                    END) AS governmentslug,
                'government' AS governmentslugtype,
                extra.governmentlong(governmentparentcache.governmentid) AS governmentlong,
                'Child' AS governmentrelationship,
                    CASE
                        WHEN government.governmentstatus = ANY (ARRAY['alternate', 'language']) THEN 'variant'
                        WHEN governmentparentcache.governmentparent <> ? AND governmentparentcache.governmentparentstatus = ANY (ARRAY['current', 'most recent']) THEN 'former'
                        ELSE governmentparentcache.governmentparentstatus
                    END AS governmentparentstatus,
                    CASE
                        WHEN governmentmapstatus.governmentmapstatusid IS NOT NULL AND governmentmapstatus.governmentmapstatustimelapse AND NOT governmentmapstatus.governmentmapstatusfurtherresearch THEN 'complete'
                        WHEN governmentmapstatus.governmentmapstatusid IS NOT NULL AND governmentmapstatus.governmentmapstatustimelapse THEN 'research'
                        WHEN governmentmapstatus.governmentmapstatusid IS NOT NULL AND governmentmapstatus.governmentmapstatusfurtherresearch THEN 'incomplete'
                        ELSE 'none'
                    END AS governmentcolor,
                governmentparentcache.governmentparent = ? AS isgovernmentsubstitute
                FROM extra.governmentparentcache
                    JOIN geohistory.government leadgovernment
                    ON governmentparentcache.governmentparent = leadgovernment.governmentid
                    JOIN geohistory.government
                    ON governmentparentcache.governmentid = government.governmentid
                    AND NOT (leadgovernment.governmentlevel < 3 AND (government.governmentlevel - leadgovernment.governmentlevel) > 1)
                    JOIN extra.governmentsubstitutecache
                    ON governmentparentcache.governmentparent = governmentsubstitutecache.governmentid
                    AND governmentsubstitutecache.governmentsubstitute = ?
                    LEFT JOIN geohistory.governmentmapstatus
                    ON government.governmentmapstatus = governmentmapstatus.governmentmapstatusid
                    AND governmentmapstatus.governmentmapstatusreviewed
                    AND (government.governmentstatus <> ALL (ARRAY['proposed', 'unincorporated']))
                WHERE governmentparentcache.governmentparentstatus <> 'placeholder'
                UNION
                SELECT DISTINCT event.eventslug AS governmentslug,
                'event' AS governmentslugtype,
                extra.governmentlong(government.governmentid) AS governmentlong,
                    CASE
                        WHEN government.governmentstatus = ANY (ARRAY['alternate', 'language']) THEN 'Variant'
                        ELSE 'Historic'
                    END AS governmentrelationship,
                    CASE
                        WHEN government.governmentstatus = ANY (ARRAY['alternate', 'language']) THEN 'variant'
                        ELSE 'former'
                    END AS governmentparentstatus,
                'none' AS governmentcolor,
                government.governmentid = ? AS isgovernmentsubstitute
                FROM geohistory.government
                    JOIN extra.governmentsubstitutecache
                    ON government.governmentid = governmentsubstitutecache.governmentid
                    AND governmentsubstitutecache.governmentsubstitute = ?
                    AND government.governmentid <> governmentsubstitutecache.governmentsubstitute
                    LEFT JOIN geohistory.event
                    ON government.governmentid = event.government
                ), relationrank AS (
                    SELECT relationpart.governmentslug,
                    relationpart.governmentslugtype,
                    relationpart.governmentlong,
                    relationpart.governmentrelationship,
                    relationpart.governmentparentstatus,
                    relationpart.governmentcolor,
                    row_number() OVER (PARTITION BY relationpart.governmentslug, relationpart.governmentlong, relationpart.governmentrelationship ORDER BY relationpart.isgovernmentsubstitute DESC, (
                        CASE
                            WHEN relationpart.governmentparentstatus = 'current' THEN 1
                            WHEN relationpart.governmentparentstatus = 'most recent' THEN 2
                            WHEN relationpart.governmentparentstatus = 'former' THEN 3
                            WHEN relationpart.governmentparentstatus = 'variant' THEN 4
                            ELSE 5
                        END)) AS roworder
                    FROM relationpart
                )
            SELECT relationrank.governmentslug,
            relationrank.governmentslugtype,
            relationrank.governmentlong,
            relationrank.governmentrelationship,
            relationrank.governmentparentstatus,
            relationrank.governmentcolor
            FROM relationrank
            WHERE relationrank.roworder = 1
            ORDER BY 3 DESC, 2, 4, 1
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
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_search_form_tribunalgovernmentshort(character varying)

    // VIEW: governmentrelationcache

    public function getSearch(): array
    {
        $query = <<<QUERY
            SELECT DISTINCT governmentrelationcache.governmentshort,
                lpad(governmentrelationcache.governmentid::text, 6, '0') AS governmentid,
                governmentrelationcache.governmentlevel
            FROM extra.governmentrelationcache
            WHERE governmentrelationcache.governmentlevel <= 3
            ORDER BY governmentrelationcache.governmentlevel, 1
        QUERY;

        $query = $this->db->query($query);

        return $this->getArray($query);
    }

    // extra.ci_model_search_government_government(text, text, text, integer, text, character varying)

    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentslug
    // VIEW: extra.governmentrelationcache

    public function getSearchByGovernment(array $parameters): array
    {
        $government = $parameters[0];
        $parent = $parameters[1];
        $level = $parameters[2];
        $type = $parameters[3];

        $query = <<<QUERY
            WITH selectedgovernment AS (
                SELECT DISTINCT governmentrelationcache.governmentid
                FROM extra.governmentrelationcache
                JOIN extra.governmentrelationcache lookupgovernment
                    ON governmentrelationcache.governmentid = lookupgovernment.governmentid
                    AND lookupgovernment.governmentid <> lookupgovernment.governmentrelation
                JOIN geohistory.government governmentparent
                    ON lookupgovernment.governmentrelation = governmentparent.governmentid
                    AND (? = ''::text OR governmentparent.governmentshort = ?)
                WHERE (
                    governmentrelationcache.governmentshort ILIKE ?
                    OR (? = 'statewide' AND governmentrelationcache.governmentlevel = 2)
                )
            )
            SELECT DISTINCT extra.governmentslug(CASE
                    WHEN government.governmentstatus IN ('alternate', 'language') THEN government.governmentsubstitute
                    ELSE government.governmentid
                END) AS governmentslug,
                extra.governmentlong(government.governmentid) AS governmentlong
                FROM selectedgovernment
                JOIN extra.governmentrelationcache
                ON selectedgovernment.governmentid = governmentrelationcache.governmentid 
                AND governmentrelationcache.governmentrelationlevel = ?
                AND (? = 'government' OR governmentrelationcache.governmentrelationlevel < 4)
                JOIN geohistory.government
                ON governmentrelationcache.governmentrelation = government.governmentid
            UNION DISTINCT
            SELECT DISTINCT extra.governmentslug(CASE
                    WHEN government.governmentstatus IN ('alternate', 'language') THEN government.governmentsubstitute
                    ELSE government.governmentid
                END) AS governmentslug,
                extra.governmentlong(government.governmentid) AS governmentlong
                FROM selectedgovernment
                JOIN extra.governmentrelationcache
                ON selectedgovernment.governmentid = governmentrelationcache.governmentrelation
                AND governmentrelationcache.governmentlevel = ?
                AND (? = 'government' OR governmentrelationcache.governmentlevel < 4)
                JOIN geohistory.government
                ON governmentrelationcache.governmentid = government.governmentid
            ORDER BY 2
        QUERY;

        $query = $this->db->query($query, [
            $parent,
            $parent,
            $government,
            $type,
            $level,
            $type,
            $level,
            $type
        ]);

        return $this->getObject($query);
    }

    public function getSchoolDistrict(int $id): array
    {
        return [];
    }

    // extra.ci_model_search_form_detail(character varying)
    // REMOVED
    // extra.governmentslug(integer)
    // NOT REMOVED

    public function getSlug(int $id): string
    {
        $query = <<<QUERY
            SELECT geohistory.governmentslugsubstitute AS id
            FROM geohistory.government
            WHERE government.governmentid = ?
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        $query = $this->getObject($query);

        $id = '';

        if (count($query) === 1) {
            $id = $query[0]->id;
        }

        return $id;
    }

    // extra.governmentslugid(text)
    // NOT REMOVED

    protected function getSlugId(string $id): int
    {
        $query = <<<QUERY
            SELECT government.governmentid AS id
                FROM geohistory.government
            WHERE government.governmentslug = ?
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
}
