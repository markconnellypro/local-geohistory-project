<?php

namespace App\Models;

use CodeIgniter\Model;

class GovernmentModel extends Model
{
    // extra.ci_model_government_detail(integer, character varying, boolean)
    // extra.ci_model_government_detail(text, character varying, boolean)

    // FUNCTION: extra.eventslug
    // FUNCTION: extra.governmentlevel
    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentsubstitutedcache
    // VIEW: extra.giscache
    // VIEW: extra.governmentchangecountcache
    // VIEW: extra.governmentextracache
    // VIEW: extra.governmenthasmappedeventcache
    // VIEW: extra.governmentrelationcache
    // VIEW: extra.governmentsubstitutecache

    public function getDetail($id, $state)
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = <<<QUERY
            SELECT government.governmentid,
                extra.governmentlong(government.governmentid, ?) AS governmentlong,
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
                    CASE
                        WHEN governmentchangecountcache.creationevent IS NOT NULL THEN extra.eventslug(governmentchangecountcache.creationevent[1])
                        ELSE NULL::text
                    END AS governmentcreationevent,
                governmentchangecountcache.creationtext AS governmentcreationtext,
                    CASE
                        WHEN governmentchangecountcache.creation = 1
                            AND array_length(governmentchangecountcache.creationas, 1) = 1
                            AND government.governmentid <> governmentchangecountcache.creationas[1]
                            THEN extra.governmentlong(governmentchangecountcache.creationas[1], ?)
                        ELSE ''
                    END AS governmentcreationlong,
                governmentchangecountcache.altertotal AS governmentaltercount,
                    CASE
                        WHEN governmentchangecountcache.dissolutionevent IS NOT NULL THEN extra.eventslug(governmentchangecountcache.dissolutionevent[1])
                        ELSE NULL::text
                    END AS governmentdissolutionevent,
                governmentchangecountcache.dissolutiontext AS governmentdissolutiontext,
                    CASE
                        WHEN hasmaptable.hasmap IS NULL THEN false
                        ELSE true
                    END AS hasmap,
                government.governmentmapstatus,
                governmentmapstatus.governmentmapstatustimelapse,
                governmentsubstitutecache.governmentsubstitutemultiple,
                governmentextracache.governmentsubstituteslug
            FROM geohistory.government
            JOIN extra.governmentextracache
                ON government.governmentid = governmentextracache.governmentid
            JOIN geohistory.governmentmapstatus
                ON government.governmentmapstatus = governmentmapstatus.governmentmapstatusid
            JOIN extra.governmentsubstitutecache
                ON government.governmentid = governmentsubstitutecache.governmentid
            LEFT JOIN geohistory.governmentform
                ON government.governmentcurrentform = governmentform.governmentformid
            LEFT JOIN extra.governmentchangecountcache
                ON government.governmentid = governmentchangecountcache.governmentid
            JOIN extra.governmentrelationcache
                ON government.governmentid = governmentrelationcache.governmentid
                AND (governmentrelationcache.governmentrelationstate = ?
                OR (governmentrelationcache.governmentlevel = 1 AND governmentrelationcache.governmentrelationstate = '' AND governmentrelationcache.governmentid = ?))
            LEFT OUTER JOIN
                (
                SELECT DISTINCT true AS hasmap
                    FROM extra.giscache
                    WHERE extra.governmentlevel(giscache.government) > 2
                        AND giscache.government = ANY (extra.governmentsubstitutedcache(?))
                    UNION
                    SELECT DISTINCT true AS hasmap
                    FROM extra.governmenthasmappedeventcache
                    WHERE governmentsubstitute = ?
                ) AS hasmaptable
                ON 0 = 0
            WHERE government.governmentid = ?
        QUERY;

        $query = $this->db->query($query, [
            strtoupper($state),
            strtoupper($state),
            strtoupper($state),
            $id,
            $id,
            $id,
            $id,
        ])->getResult();

        return $query ?? [];
    }

    // extra.governmentabbreviationid(text)
    // NOT REMOVED

    public function getAbbreviationId($id)
    {
        $query = <<<QUERY
            SELECT governmentid
            FROM geohistory.government
            WHERE governmentabbreviation = ?
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        $id = -1;

        if (count($query) == 1) {
            $id = $query[0]->id;
        }
        
        return $id;
    }

    // extra.ci_model_governmentidentifier_government(integer[], character varying)

    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentstatelink

    public function getByGovernmentIdentifier($ids)
    {
        $query = <<<QUERY
            SELECT extra.governmentstatelink(governmentidentifier.government, '--', ?) governmentstatelink,
                extra.governmentlong(governmentidentifier.government, '--') AS governmentlong,
                governmentidentifier.governmentidentifierstatus AS governmentparentstatus
            FROM geohistory.governmentidentifier
            WHERE governmentidentifier.governmentidentifierid = ANY (?);
        QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
            $ids
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_statistics_createddissolved_nation_part(character varying, integer, integer, character varying, boolean)

    // FUNCTION: extra.governmentabbreviation
    // VIEW: extra.statistics_createddissolved

    public function getByStatisticsNationPart($fields)
    {
        $for = $fields[0];
        $from = $fields[1];
        $to = $fields[2];
        $by = $fields[3];
        $state = $fields[4];
        if (empty($state)) {
            $state = implode(',', \App\Controllers\BaseController::getJurisdictions());
        }
        $state = '{' . strtoupper($state) . '}';

        $query = <<<QUERY
            WITH eventdata AS (
                    SELECT DISTINCT min(governmentidentifier.governmentidentifier) AS series,
                    statistics_createddissolved.governmentstate AS actualseries,
                    statistics_createddissolved.eventyear AS x,
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
                    AND statistics_createddissolved.eventyear >= ?
                    AND statistics_createddissolved.eventyear <= ?
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
            $state,
            $from,
            $to,
            $for,
            $for,
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_statistics_createddissolved_nation_whole(character varying, integer, integer, character varying, boolean)

    // VIEW: extra.statistics_createddissolved

    public function getByStatisticsNationWhole($fields)
    {
        $for = $fields[0];
        $from = $fields[1];
        $to = $fields[2];
        $by = $fields[3];

        $query = <<<QUERY
            WITH eventdata AS (
                SELECT DISTINCT statistics_createddissolved.eventyear AS x,
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
                AND statistics_createddissolved.eventyear >= ?
                AND statistics_createddissolved.eventyear <= ?
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
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_statistics_createddissolved_state_part(character varying, integer, integer, character varying, character varying)

    // VIEW: extra.statistics_createddissolved

    public function getByStatisticsStatePart($fields)
    {
        $for = $fields[0];
        $from = $fields[1];
        $to = $fields[2];
        $by = $fields[3];
        $state = strtoupper($fields[4]);

        $query = <<<QUERY
            WITH eventdata AS (
                SELECT DISTINCT statistics_createddissolved.governmentcounty AS series,
                statistics_createddissolved.eventyear AS x,
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
                AND statistics_createddissolved.eventyear >= ?
                AND statistics_createddissolved.eventyear <= ?
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
            $state,
            $from,
            $to,
            $for,
            $for,
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_statistics_createddissolved_state_whole(character varying, integer, integer, character varying, character varying)

    // VIEW: extra.statistics_createddissolved

    public function getByStatisticsStateWhole($fields)
    {
        $for = $fields[0];
        $from = $fields[1];
        $to = $fields[2];
        $by = $fields[3];
        $state = strtoupper($fields[4]);

        $query = <<<QUERY
            WITH eventdata AS (
                SELECT DISTINCT statistics_createddissolved.eventyear AS x,
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
                AND statistics_createddissolved.eventyear >= ?
                AND statistics_createddissolved.eventyear <= ?
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
            $state,
            $from,
            $to,
            $for,
            $for,
            $state,
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_search_lookup_government(character varying, character varying)

    // FUNCTION: extra.punctuationnone
    // FUNCTION: extra.punctuationnonefuzzy
    // VIEW: extra.governmentextracache
    // VIEW: extra.governmentrelationcache

    public function getLookupByGovernment($state, $government)
    {
        if (strlen($government) < 3) {
            return [];
        }

        $query = <<<QUERY
            SELECT DISTINCT governmentrelationcache.governmentshort,
                extra.punctuationnone(governmentrelationcache.governmentshort) AS governmentsearch
            FROM extra.governmentrelationcache
            JOIN extra.governmentextracache
                ON governmentrelationcache.governmentid = governmentextracache.governmentid
                AND NOT governmentextracache.governmentisplaceholder
            WHERE governmentrelationcache.governmentlevel > 2
                AND (governmentrelationcache.governmentrelationstate = ?
                OR governmentrelationcache.governmentrelationstate IS NULL)
                AND extra.punctuationnone(governmentrelationcache.governmentshort) LIKE extra.punctuationnonefuzzy(?)
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            strtoupper($state),
            rawurldecode($government) . '%',
        ])->getResultArray();

        return $query ?? [];
    }

    // extra.ci_model_search_lookup_governmentparent(text, text)

    // FUNCTION: extra.punctuationnone
    // FUNCTION: extra.punctuationnonefuzzy
    // VIEW: extra.governmentextracache
    // VIEW: extra.governmentrelationcache

    public function getLookupByGovernmentParent($state, $government)
    {
        $query = <<<QUERY
            SELECT DISTINCT governmentextracache.governmentshort,
                extra.punctuationnone(governmentrelationcache.governmentshort) AS governmentsearch
            FROM extra.governmentrelationcache
            JOIN extra.governmentrelationcache lookupgovernment
                ON governmentrelationcache.governmentid = lookupgovernment.governmentid
                AND lookupgovernment.governmentid <> lookupgovernment.governmentrelation
                AND lookupgovernment.governmentrelationlevel > 2
                AND lookupgovernment.governmentlevel <> lookupgovernment.governmentrelationlevel
            JOIN extra.governmentextracache
                ON lookupgovernment.governmentrelation = governmentextracache.governmentid
                AND NOT governmentextracache.governmentisplaceholder
            WHERE (governmentrelationcache.governmentrelationstate = ?
                OR governmentrelationcache.governmentrelationstate IS NULL)
                AND extra.punctuationnone(governmentrelationcache.governmentshort) LIKE extra.punctuationnonefuzzy(?)
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            strtoupper($state),
            rawurldecode($government),
        ])->getResultArray();

        return $query ?? [];
    }

    public function getNote($id, $state)
    {
        return [];
    }

    public function getOffice($id, $state)
    {
        return [];
    }

    // extra.ci_model_government_related(integer, character varying, character varying)

    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentstatelink
    // VIEW: extra.eventextracache
    // VIEW: extra.governmentparentcache
    // VIEW: extra.governmentsubstitutecache

    public function getRelated($id, $state)
    {
        $query = <<<QUERY
            WITH relationpart AS (
                SELECT DISTINCT extra.governmentstatelink(
                    CASE
                        WHEN government.governmentstatus = ANY (ARRAY['alternate', 'language']) THEN government.governmentsubstitute
                        ELSE government.governmentid
                    END, ?, ?) AS governmentstatelink,
                extra.governmentlong(governmentparentcache.governmentparent, ?) AS governmentlong,
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
                SELECT DISTINCT extra.governmentstatelink(
                    CASE
                        WHEN government.governmentstatus = ANY (ARRAY['alternate', 'language']) THEN government.governmentsubstitute
                        ELSE government.governmentid
                    END, ?, ?) AS governmentstatelink,
                extra.governmentlong(governmentparentcache.governmentid, ?) AS governmentlong,
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
                SELECT DISTINCT '/en/' || ? || '/event/' || eventextracache.eventslug || '/' AS governmentstatelink,
                extra.governmentlong(government.governmentid, ?) AS governmentlong,
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
                    LEFT JOIN extra.eventextracache
                    ON event.eventid = eventextracache.eventid
                    AND eventextracache.eventslugnew IS NULL
                ), relationrank AS (
                    SELECT relationpart.governmentstatelink,
                    relationpart.governmentlong,
                    relationpart.governmentrelationship,
                    relationpart.governmentparentstatus,
                    relationpart.governmentcolor,
                    row_number() OVER (PARTITION BY relationpart.governmentstatelink, relationpart.governmentlong, relationpart.governmentrelationship ORDER BY relationpart.isgovernmentsubstitute DESC, (
                        CASE
                            WHEN relationpart.governmentparentstatus = 'current' THEN 1
                            WHEN relationpart.governmentparentstatus = 'most recent' THEN 2
                            WHEN relationpart.governmentparentstatus = 'former' THEN 3
                            WHEN relationpart.governmentparentstatus = 'variant' THEN 4
                            ELSE 5
                        END)) AS roworder
                    FROM relationpart
                )
            SELECT relationrank.governmentstatelink,
            relationrank.governmentlong,
            relationrank.governmentrelationship,
            relationrank.governmentparentstatus,
            relationrank.governmentcolor
            FROM relationrank
            WHERE relationrank.roworder = 1
            ORDER BY 3 DESC, 2, 4, 1
        QUERY;

        $query = $this->db->query($query, [
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $id,
            $id,
            $id,
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $id,
            $id,
            $id,
            strtolower($state),
            strtoupper($state),
            $id,
            $id,
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_search_form_tribunalgovernmentshort(character varying)
    
    // FUNCTION: extra.governmentabbreviationid
    // FUNCTION: extra.governmentcurrentleadparent
    // VIEW: governmentrelationcache

    public function getSearch($state)
    {
        $query = <<<QUERY
            SELECT DISTINCT governmentrelationcache.governmentshort,
                lpad(governmentrelationcache.governmentid::text, 6, '0') AS governmentid,
                governmentrelationcache.governmentlevel
            FROM extra.governmentrelationcache
            WHERE (governmentrelationcache.governmentlevel = 3
                AND (governmentrelationcache.governmentrelationstate = ?
                OR governmentrelationcache.governmentrelationstate IS NULL))
                OR (governmentrelationcache.governmentlevel = 2
                AND governmentrelationcache.governmentrelationstate = ?)
                OR (governmentrelationcache.governmentlevel = 1
                AND governmentrelationcache.governmentid = extra.governmentcurrentleadparent(extra.governmentabbreviationid(?)))
            ORDER BY governmentrelationcache.governmentlevel, 1
        QUERY;

        $query = $this->db->query($query, [
            strtoupper($state),
            strtoupper($state),
            strtoupper($state),
        ])->getResultArray();

        return $query ?? [];
    }

    // extra.ci_model_search_government_government(text, text, text, integer, text, character varying)

    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentstatelink
    // VIEW: extra.governmentextracache
    // VIEW: extra.governmentrelationcache

    public function getSearchByGovernment($parameters)
    {
        $state = $parameters[0];
        $government = $parameters[1];
        $parent = $parameters[2];
        $level = $parameters[3];
        $type = $parameters[4];

        $query = <<<QUERY
            WITH selectedgovernment AS (
                SELECT DISTINCT governmentrelationcache.governmentid
                FROM extra.governmentrelationcache
                JOIN extra.governmentrelationcache lookupgovernment
                    ON governmentrelationcache.governmentid = lookupgovernment.governmentid
                    AND lookupgovernment.governmentid <> lookupgovernment.governmentrelation
                JOIN extra.governmentextracache governmentparentextracache
                    ON lookupgovernment.governmentrelation = governmentparentextracache.governmentid
                    AND (? = ''::text OR governmentparentextracache.governmentshort = ?)
                WHERE (
                    governmentrelationcache.governmentrelationstate = ?
                    OR governmentrelationcache.governmentrelationstate IS NULL
                ) AND (
                    governmentrelationcache.governmentshort ILIKE ?
                    OR (? = 'statewide' AND governmentrelationcache.governmentlevel = 2)
                )
            )
            SELECT DISTINCT extra.governmentstatelink(CASE
                    WHEN government.governmentstatus IN ('alternate', 'language') THEN government.governmentsubstitute
                    ELSE government.governmentid
                END, ?, ?) AS governmentstatelink,
                extra.governmentlong(government.governmentid, ?) AS governmentlong
                FROM selectedgovernment
                JOIN extra.governmentrelationcache
                ON selectedgovernment.governmentid = governmentrelationcache.governmentid 
                AND governmentrelationcache.governmentrelationlevel = ?
                AND (? = 'government' OR governmentrelationcache.governmentrelationlevel < 4)
                JOIN geohistory.government
                ON governmentrelationcache.governmentrelation = government.governmentid
            UNION DISTINCT
            SELECT DISTINCT extra.governmentstatelink(CASE
                    WHEN government.governmentstatus IN ('alternate', 'language') THEN government.governmentsubstitute
                    ELSE government.governmentid
                END, ?, ?) AS governmentstatelink,
                extra.governmentlong(government.governmentid, ?) AS governmentlong
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
            strtoupper($state),
            $government,
            $type,
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $level,
            $type,
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $level,
            $type
        ])->getResult();

        return $query ?? [];
    }

    public function getSchoolDistrict($id, $state)
    {
        return [];
    }

    // extra.ci_model_search_form_detail(character varying)
    // REMOVED
    // extra.governmentslug(integer)
    // NOT REMOVED

    // VIEW: extra.governmentextracache

    public function getSlug($id)
    {
        $query = <<<QUERY
            SELECT CASE
                WHEN governmentextracache.governmentsubstituteslug IS NULL THEN governmentextracache.governmentslug
                ELSE governmentextracache.governmentsubstituteslug
            END AS id
            FROM extra.governmentextracache
            WHERE governmentextracache.governmentid = ?
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        $id = '';

        if (count($query) == 1) {
            $id = $query[0]->id;
        }
        
        return $id;
    }

    // extra.governmentslugid(text)
    // NOT REMOVED

    // VIEW: extra.governmentextracache

    protected function getSlugId($id)
    {
        $query = <<<QUERY
            SELECT governmentextracache.governmentid AS id
                FROM extra.governmentextracache
            WHERE governmentextracache.governmentslug = ?
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        $id = -1;

        if (count($query) == 1) {
            $id = $query[0]->id;
        }
        
        return $id;
    }
}