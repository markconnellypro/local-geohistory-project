<?php

namespace App\Models;

use App\Models\BaseModel;

class GovernmentModel extends BaseModel
{
    public function getDetail(int|string $id): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = <<<QUERY
                SELECT government.governmentid,
                    government.governmentlong,
                        CASE
                            WHEN government.governmentcurrentform IS NULL THEN government.governmenttype
                            ELSE governmentform.governmentformlong
                        END AS governmenttype,
                        CASE
                            WHEN government.governmentstatus IN ('placeholder') THEN 'placeholder'::text
                            WHEN government.governmentlevel = 1 THEN 'country'::text
                            WHEN government.governmentlevel = 2 THEN 'state'::text
                            WHEN government.governmentlevel = 3 THEN 'county'::text
                            ELSE 'municipality or lower'::text
                        END AS governmentlevel,
                        NOT (
                            governmentchangecountcache.creationevent IS NULL
                            AND governmentchangecountcache.altertotal = 0
                            AND governmentchangecountcache.dissolutionevent IS NULL
                        ) AS textflag,
                    creationevent.eventslug AS governmentcreationevent,
                    governmentchangecountcache.creationtext AS governmentcreationtext,
                        CASE
                            WHEN governmentchangecountcache.creation = 1
                                AND array_length(governmentchangecountcache.creationas, 1) = 1
                                AND government.governmentid <> governmentchangecountcache.creationas[1]
                                THEN creationas.governmentlong
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
                    CASE
                        WHEN government.governmentslug <> government.governmentslugsubstitute THEN government.governmentslugsubstitute
                        ELSE NULL
                    END AS governmentslugsubstitute,
                    government.governmentcurrentleadstate,
                    COUNT(DISTINCT governmentsubstitute.governmentid) > 1 AS governmentsubstitutemultiple
                FROM geohistory.government
                JOIN geohistory.governmentmapstatus
                    ON government.governmentmapstatus = governmentmapstatus.governmentmapstatusid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentstatus NOT IN ('alternate', 'language')
                LEFT JOIN geohistory.governmentform
                    ON government.governmentcurrentform = governmentform.governmentformid
                LEFT JOIN geohistory.governmentchangecountcache
                    ON government.governmentid = governmentchangecountcache.governmentid
                LEFT JOIN geohistory.event creationevent
                    ON governmentchangecountcache.creationevent IS NOT NULL
                    AND governmentchangecountcache.creationevent[1] = creationevent.eventid
                LEFT JOIN geohistory.event dissolutionevent
                    ON governmentchangecountcache.dissolutionevent IS NOT NULL
                    AND governmentchangecountcache.dissolutionevent[1] = dissolutionevent.eventid
                LEFT OUTER JOIN (
                    SELECT DISTINCT true AS hasmap
                    FROM gis.governmentshapecache
                    JOIN geohistory.government
                        ON governmentshapecache.government = government.governmentid
                        AND government.governmentlevel > 2
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                        AND governmentsubstitute.governmentid = ?
                    UNION
                    SELECT DISTINCT true AS hasmap
                    FROM geohistory.affectedgovernmentgrouppart
                    JOIN gis.affectedgovernmentgis
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgis.affectedgovernment
                    JOIN geohistory.affectedgovernmentpart
                        ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentto = government.governmentid
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    WHERE governmentsubstitute.governmentid = ?
                    UNION
                    SELECT DISTINCT true AS hasmap
                    FROM geohistory.affectedgovernmentgrouppart
                    JOIN gis.affectedgovernmentgis
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgis.affectedgovernment
                    JOIN geohistory.affectedgovernmentpart
                        ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentfrom = government.governmentid
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    WHERE governmentsubstitute.governmentid = ?
                ) AS hasmaptable
                    ON 0 = 0
                LEFT JOIN geohistory.government creationas
                    ON governmentchangecountcache.creationas[1] = creationas.governmentid
                WHERE government.governmentid = ?
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
            QUERY;

        $query = $this->db->query($query, [
            $id,
            $id,
            $id,
            $id,
        ]);

        return $this->getObject($query);
    }

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

    public function getByGovernmentIdentifier(string $ids): array
    {
        $query = <<<QUERY
                SELECT government.governmentslugsubstitute AS governmentslug,
                    government.governmentlong,
                    governmentidentifier.governmentidentifierstatus AS governmentparentstatus
                FROM geohistory.governmentidentifier
                JOIN geohistory.government
                    ON governmentidentifier.government = government.governmentid
                WHERE governmentidentifier.governmentidentifierid = ANY (?)
            QUERY;

        $query = $this->db->query($query, [
            $ids,
        ]);

        return $this->getObject($query);
    }

    public function getByStatisticsJurisdiction(): array
    {
        $jurisdiction = implode(',', \App\Controllers\BaseController::getJurisdictions());
        $jurisdiction = '{' . strtoupper($jurisdiction) . '}';

        $query = <<<QUERY
                SELECT DISTINCT government.governmentshort,
                    lower(government.governmentabbreviation) AS governmentabbreviation
                FROM geohistory.government
                WHERE government.governmentstatus = ''
                    AND government.governmentlevel = 2
                    AND government.governmentabbreviation = ANY (?)
            QUERY;

        $query = $this->db->query($query, [
            $jurisdiction,
        ]);

        return $this->getArray($query);
    }

    public function getByStatisticsNationPart(array $parameters): array
    {
        $for = $parameters[0];
        $from = $parameters[1];
        $to = $parameters[2];
        $jurisdiction = $parameters[4];
        if ($jurisdiction === '') {
            $jurisdiction = implode(',', \App\Controllers\BaseController::getJurisdictions());
        }
        $jurisdiction = '{' . strtoupper($jurisdiction) . '}';

        $query = <<<QUERY
                WITH eventlist AS (
                    SELECT DISTINCT affectedgovernmentgroup.event,
                        affectedtype.affectedtypecreationdissolution,
                        government.governmentid,
                        COALESCE(governmentidentifier.governmentidentifier::integer, 0) AS series
                    FROM geohistory.affectedgovernmentpart
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentto = government.governmentid
                        AND government.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND government.governmentlevel = 4
                    JOIN geohistory.affectedtype
                        ON affectedgovernmentpart.affectedtypeto = affectedtype.affectedtypeid
                        AND affectedtype.affectedtypecreationdissolution = 'begin'
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                        AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE '%municipality'
                    JOIN geohistory.affectedgovernmentgrouppart affectedgovernmentgrouppartparent
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgrouppartparent.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentlevel affectedgovernmentlevelparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentlevel = affectedgovernmentlevelparent.affectedgovernmentlevelid
                        AND affectedgovernmentlevelparent.affectedgovernmentlevelshort LIKE 'state'
                    JOIN geohistory.affectedgovernmentpart affectedgovernmentpartparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentpart = affectedgovernmentpartparent.affectedgovernmentpartid
                    JOIN geohistory.government governmentparent
                        ON affectedgovernmentpartparent.governmentto = governmentparent.governmentid
                        AND governmentparent.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND governmentparent.governmentcurrentleadstate = ANY (?)
                    JOIN geohistory.government governmentparentsubstitute
                        ON governmentparent.governmentslugsubstitute = governmentparentsubstitute.governmentslug
                    LEFT JOIN geohistory.governmentidentifier
                        ON governmentparentsubstitute.governmentid = governmentidentifier.government
                        AND governmentidentifier.governmentidentifiertype = 1
                    UNION
                    SELECT DISTINCT affectedgovernmentgroup.event,
                        affectedtype.affectedtypecreationdissolution,
                        government.governmentid,
                        COALESCE(governmentidentifier.governmentidentifier::integer, 0) AS series
                    FROM geohistory.affectedgovernmentpart
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentfrom = government.governmentid
                        AND government.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND government.governmentlevel = 4
                    JOIN geohistory.affectedtype
                        ON affectedgovernmentpart.affectedtypefrom = affectedtype.affectedtypeid
                        AND affectedtype.affectedtypecreationdissolution = 'end'
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                        AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE '%municipality'
                    JOIN geohistory.affectedgovernmentgrouppart affectedgovernmentgrouppartparent
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgrouppartparent.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentlevel affectedgovernmentlevelparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentlevel = affectedgovernmentlevelparent.affectedgovernmentlevelid
                        AND affectedgovernmentlevelparent.affectedgovernmentlevelshort LIKE 'state'
                    JOIN geohistory.affectedgovernmentpart affectedgovernmentpartparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentpart = affectedgovernmentpartparent.affectedgovernmentpartid
                    JOIN geohistory.government governmentparent
                        ON affectedgovernmentpartparent.governmentfrom = governmentparent.governmentid
                        AND governmentparent.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND governmentparent.governmentcurrentleadstate = ANY (?)
                    JOIN geohistory.government governmentparentsubstitute
                        ON governmentparent.governmentslugsubstitute = governmentparentsubstitute.governmentslug
                    LEFT JOIN geohistory.governmentidentifier
                        ON governmentparentsubstitute.governmentid = governmentidentifier.government
                        AND governmentidentifier.governmentidentifiertype = 1
                ), eventyear AS (
                    SELECT eventlist.series,
                        event.eventsortyear AS x,
                        COALESCE(count(DISTINCT CASE
                            WHEN eventlist.affectedtypecreationdissolution = 'begin' THEN eventlist.governmentid
                            ELSE NULL
                        END), 0)::integer AS begin,
                        COALESCE(count(DISTINCT CASE
                            WHEN eventlist.affectedtypecreationdissolution = 'end' THEN eventlist.governmentid
                            ELSE NULL
                        END), 0)::integer AS end
                    FROM eventlist
                    JOIN geohistory.event
                        ON eventlist.event = event.eventid
                        AND event.eventsortyear >= ?
                        AND event.eventsortyear <= ?
                    JOIN geohistory.eventgranted
                        ON event.eventgranted = eventgranted.eventgrantedid
                        AND eventgranted.eventgrantedsuccess
                    GROUP BY 1, 2
                ), eventdata AS (
                    SELECT DISTINCT eventyear.series,
                        eventyear.x,
                        CASE
                            WHEN ? = 'created' THEN eventyear.begin
                            WHEN ? = 'dissolved' THEN eventyear.end
                            WHEN ? = 'net' THEN eventyear.begin - eventyear.end
                            ELSE 0::integer
                        END AS y
                    FROM eventyear
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
            $jurisdiction,
            $jurisdiction,
            $from,
            $to,
            $for,
            $for,
            $for,
        ]);

        return $this->getObject($query);
    }

    public function getByStatisticsNationWhole(array $parameters): array
    {
        $for = $parameters[0];
        $from = $parameters[1];
        $to = $parameters[2];
        $jurisdiction = $parameters[4];
        if ($jurisdiction === '') {
            $jurisdiction = implode(',', \App\Controllers\BaseController::getJurisdictions());
        }
        $jurisdiction = '{' . strtoupper($jurisdiction) . '}';

        $query = <<<QUERY
                WITH eventlist AS (
                    SELECT DISTINCT affectedgovernmentgroup.event,
                        affectedtype.affectedtypecreationdissolution,
                        government.governmentid,
                        COALESCE(governmentidentifier.governmentidentifier::integer, 0) AS series
                    FROM geohistory.affectedgovernmentpart
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentto = government.governmentid
                        AND government.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND government.governmentlevel = 4
                    JOIN geohistory.affectedtype
                        ON affectedgovernmentpart.affectedtypeto = affectedtype.affectedtypeid
                        AND affectedtype.affectedtypecreationdissolution = 'begin'
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                        AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE '%municipality'
                    JOIN geohistory.affectedgovernmentgrouppart affectedgovernmentgrouppartparent
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgrouppartparent.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentlevel affectedgovernmentlevelparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentlevel = affectedgovernmentlevelparent.affectedgovernmentlevelid
                        AND affectedgovernmentlevelparent.affectedgovernmentlevelshort LIKE 'state'
                    JOIN geohistory.affectedgovernmentpart affectedgovernmentpartparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentpart = affectedgovernmentpartparent.affectedgovernmentpartid
                    JOIN geohistory.government governmentparent
                        ON affectedgovernmentpartparent.governmentto = governmentparent.governmentid
                        AND governmentparent.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND governmentparent.governmentcurrentleadstate = ANY (?)
                    JOIN geohistory.government governmentparentsubstitute
                        ON governmentparent.governmentslugsubstitute = governmentparentsubstitute.governmentslug
                    LEFT JOIN geohistory.governmentidentifier
                        ON governmentparentsubstitute.governmentid = governmentidentifier.government
                        AND governmentidentifier.governmentidentifiertype = 1
                    UNION
                    SELECT DISTINCT affectedgovernmentgroup.event,
                        affectedtype.affectedtypecreationdissolution,
                        government.governmentid,
                        COALESCE(governmentidentifier.governmentidentifier::integer, 0) AS series
                    FROM geohistory.affectedgovernmentpart
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentfrom = government.governmentid
                        AND government.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND government.governmentlevel = 4
                    JOIN geohistory.affectedtype
                        ON affectedgovernmentpart.affectedtypefrom = affectedtype.affectedtypeid
                        AND affectedtype.affectedtypecreationdissolution = 'end'
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                        AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE '%municipality'
                    JOIN geohistory.affectedgovernmentgrouppart affectedgovernmentgrouppartparent
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgrouppartparent.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentlevel affectedgovernmentlevelparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentlevel = affectedgovernmentlevelparent.affectedgovernmentlevelid
                        AND affectedgovernmentlevelparent.affectedgovernmentlevelshort LIKE 'state'
                    JOIN geohistory.affectedgovernmentpart affectedgovernmentpartparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentpart = affectedgovernmentpartparent.affectedgovernmentpartid
                    JOIN geohistory.government governmentparent
                        ON affectedgovernmentpartparent.governmentfrom = governmentparent.governmentid
                        AND governmentparent.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND governmentparent.governmentcurrentleadstate = ANY (?)
                    JOIN geohistory.government governmentparentsubstitute
                        ON governmentparent.governmentslugsubstitute = governmentparentsubstitute.governmentslug
                    LEFT JOIN geohistory.governmentidentifier
                        ON governmentparentsubstitute.governmentid = governmentidentifier.government
                        AND governmentidentifier.governmentidentifiertype = 1
                ), eventyear AS (
                    SELECT event.eventsortyear AS x,
                        COALESCE(count(DISTINCT CASE
                            WHEN eventlist.affectedtypecreationdissolution = 'begin' THEN eventlist.governmentid
                            ELSE NULL
                        END), 0)::integer AS begin,
                        COALESCE(count(DISTINCT CASE
                            WHEN eventlist.affectedtypecreationdissolution = 'end' THEN eventlist.governmentid
                            ELSE NULL
                        END), 0)::integer AS end
                    FROM eventlist
                    JOIN geohistory.event
                        ON eventlist.event = event.eventid
                        AND event.eventsortyear >= ?
                        AND event.eventsortyear <= ?
                    JOIN geohistory.eventgranted
                        ON event.eventgranted = eventgranted.eventgrantedid
                        AND eventgranted.eventgrantedsuccess
                    GROUP BY 1
                ), eventdata AS (
                    SELECT DISTINCT eventyear.x,
                        CASE
                            WHEN ? = 'created' THEN eventyear.begin
                            WHEN ? = 'dissolved' THEN eventyear.end
                            WHEN ? = 'net' THEN eventyear.begin - eventyear.end
                            ELSE 0::integer
                        END AS y
                    FROM eventyear
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
                        ELSE eventdata.y::text
                    END ORDER BY xvalue.x)) AS datarow
                FROM xvalue
                LEFT JOIN eventdata
                    ON xvalue.x = eventdata.x
            QUERY;

        $query = $this->db->query($query, [
            $jurisdiction,
            $jurisdiction,
            $from,
            $to,
            $for,
            $for,
            $for,
        ]);

        return $this->getObject($query);
    }

    public function getByStatisticsStatePart(array $parameters): array
    {
        $for = $parameters[0];
        $from = $parameters[1];
        $to = $parameters[2];
        $jurisdiction = strtoupper($parameters[4]);

        $query = <<<QUERY
                WITH eventlist AS (
                    SELECT DISTINCT affectedgovernmentgroup.event,
                        affectedtype.affectedtypecreationdissolution,
                        government.governmentid,
                        COALESCE(governmentidentifier.governmentidentifier::integer, 0) AS series
                    FROM geohistory.affectedgovernmentpart
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentto = government.governmentid
                        AND government.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND government.governmentlevel = 4
                    JOIN geohistory.affectedtype
                        ON affectedgovernmentpart.affectedtypeto = affectedtype.affectedtypeid
                        AND affectedtype.affectedtypecreationdissolution = 'begin'
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                        AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE '%municipality'
                    JOIN geohistory.affectedgovernmentgrouppart affectedgovernmentgrouppartparent
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgrouppartparent.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentlevel affectedgovernmentlevelparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentlevel = affectedgovernmentlevelparent.affectedgovernmentlevelid
                        AND affectedgovernmentlevelparent.affectedgovernmentlevelshort LIKE '%county'
                    JOIN geohistory.affectedgovernmentpart affectedgovernmentpartparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentpart = affectedgovernmentpartparent.affectedgovernmentpartid
                    JOIN geohistory.government governmentparent
                        ON affectedgovernmentpartparent.governmentto = governmentparent.governmentid
                        AND governmentparent.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND governmentparent.governmentcurrentleadstate = ?
                    JOIN geohistory.government governmentparentsubstitute
                        ON governmentparent.governmentslugsubstitute = governmentparentsubstitute.governmentslug
                    LEFT JOIN geohistory.governmentidentifier
                        ON governmentparentsubstitute.governmentid = governmentidentifier.government
                        AND governmentidentifier.governmentidentifiertype = 1
                    UNION
                    SELECT DISTINCT affectedgovernmentgroup.event,
                        affectedtype.affectedtypecreationdissolution,
                        government.governmentid,
                        COALESCE(governmentidentifier.governmentidentifier::integer, 0) AS series
                    FROM geohistory.affectedgovernmentpart
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentfrom = government.governmentid
                        AND government.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND government.governmentlevel = 4
                    JOIN geohistory.affectedtype
                        ON affectedgovernmentpart.affectedtypefrom = affectedtype.affectedtypeid
                        AND affectedtype.affectedtypecreationdissolution = 'end'
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                        AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE '%municipality'
                    JOIN geohistory.affectedgovernmentgrouppart affectedgovernmentgrouppartparent
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgrouppartparent.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentlevel affectedgovernmentlevelparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentlevel = affectedgovernmentlevelparent.affectedgovernmentlevelid
                        AND affectedgovernmentlevelparent.affectedgovernmentlevelshort LIKE '%county'
                    JOIN geohistory.affectedgovernmentpart affectedgovernmentpartparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentpart = affectedgovernmentpartparent.affectedgovernmentpartid
                    JOIN geohistory.government governmentparent
                        ON affectedgovernmentpartparent.governmentfrom = governmentparent.governmentid
                        AND governmentparent.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND governmentparent.governmentcurrentleadstate = ?
                    JOIN geohistory.government governmentparentsubstitute
                        ON governmentparent.governmentslugsubstitute = governmentparentsubstitute.governmentslug
                    LEFT JOIN geohistory.governmentidentifier
                        ON governmentparentsubstitute.governmentid = governmentidentifier.government
                        AND governmentidentifier.governmentidentifiertype = 1
                ), eventyear AS (
                    SELECT eventlist.series,
                        event.eventsortyear AS x,
                        COALESCE(count(DISTINCT CASE
                            WHEN eventlist.affectedtypecreationdissolution = 'begin' THEN eventlist.governmentid
                            ELSE NULL
                        END), 0)::integer AS begin,
                        COALESCE(count(DISTINCT CASE
                            WHEN eventlist.affectedtypecreationdissolution = 'end' THEN eventlist.governmentid
                            ELSE NULL
                        END), 0)::integer AS end
                    FROM eventlist
                    JOIN geohistory.event
                        ON eventlist.event = event.eventid
                        AND event.eventsortyear >= ?
                        AND event.eventsortyear <= ?
                    JOIN geohistory.eventgranted
                        ON event.eventgranted = eventgranted.eventgrantedid
                        AND eventgranted.eventgrantedsuccess
                    GROUP BY 1, 2
                ), eventdata AS (
                    SELECT DISTINCT eventyear.series,
                        eventyear.x,
                        CASE
                            WHEN ? = 'created' THEN eventyear.begin
                            WHEN ? = 'dissolved' THEN eventyear.end
                            WHEN ? = 'net' THEN eventyear.begin - eventyear.end
                            ELSE 0::integer
                        END AS y
                    FROM eventyear
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
            $jurisdiction,
            $jurisdiction,
            $from,
            $to,
            $for,
            $for,
            $for,
        ]);

        return $this->getObject($query);
    }

    public function getByStatisticsStateWhole(array $parameters): array
    {
        $for = $parameters[0];
        $from = $parameters[1];
        $to = $parameters[2];
        $jurisdiction = strtoupper($parameters[4]);

        $query = <<<QUERY
                WITH eventlist AS (
                    SELECT DISTINCT affectedgovernmentgroup.event,
                        affectedtype.affectedtypecreationdissolution,
                        government.governmentid
                    FROM geohistory.affectedgovernmentpart
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentto = government.governmentid
                        AND government.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND government.governmentlevel = 4
                    JOIN geohistory.affectedtype
                        ON affectedgovernmentpart.affectedtypeto = affectedtype.affectedtypeid
                        AND affectedtype.affectedtypecreationdissolution = 'begin'
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                        AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE '%municipality'
                    JOIN geohistory.affectedgovernmentgrouppart affectedgovernmentgrouppartparent
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgrouppartparent.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentlevel affectedgovernmentlevelparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentlevel = affectedgovernmentlevelparent.affectedgovernmentlevelid
                        AND affectedgovernmentlevelparent.affectedgovernmentlevelshort LIKE '%county'
                    JOIN geohistory.affectedgovernmentpart affectedgovernmentpartparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentpart = affectedgovernmentpartparent.affectedgovernmentpartid
                    JOIN geohistory.government governmentparent
                        ON affectedgovernmentpartparent.governmentto = governmentparent.governmentid
                        AND governmentparent.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND governmentparent.governmentcurrentleadstate = ?
                    JOIN geohistory.government governmentparentsubstitute
                        ON governmentparent.governmentslugsubstitute = governmentparentsubstitute.governmentslug
                    LEFT JOIN geohistory.governmentidentifier
                        ON governmentparentsubstitute.governmentid = governmentidentifier.government
                        AND governmentidentifier.governmentidentifiertype = 1
                    UNION
                    SELECT DISTINCT affectedgovernmentgroup.event,
                        affectedtype.affectedtypecreationdissolution,
                        government.governmentid
                    FROM geohistory.affectedgovernmentpart
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentfrom = government.governmentid
                        AND government.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND government.governmentlevel = 4
                    JOIN geohistory.affectedtype
                        ON affectedgovernmentpart.affectedtypefrom = affectedtype.affectedtypeid
                        AND affectedtype.affectedtypecreationdissolution = 'end'
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                        AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE '%municipality'
                    JOIN geohistory.affectedgovernmentgrouppart affectedgovernmentgrouppartparent
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgrouppartparent.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentlevel affectedgovernmentlevelparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentlevel = affectedgovernmentlevelparent.affectedgovernmentlevelid
                        AND affectedgovernmentlevelparent.affectedgovernmentlevelshort LIKE '%county'
                    JOIN geohistory.affectedgovernmentpart affectedgovernmentpartparent
                        ON affectedgovernmentgrouppartparent.affectedgovernmentpart = affectedgovernmentpartparent.affectedgovernmentpartid
                    JOIN geohistory.government governmentparent
                        ON affectedgovernmentpartparent.governmentfrom = governmentparent.governmentid
                        AND governmentparent.governmentstatus NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND governmentparent.governmentcurrentleadstate = ?
                    JOIN geohistory.government governmentparentsubstitute
                        ON governmentparent.governmentslugsubstitute = governmentparentsubstitute.governmentslug
                    LEFT JOIN geohistory.governmentidentifier
                        ON governmentparentsubstitute.governmentid = governmentidentifier.government
                        AND governmentidentifier.governmentidentifiertype = 1
                ), eventyear AS (
                    SELECT event.eventsortyear AS x,
                        COALESCE(count(DISTINCT CASE
                            WHEN eventlist.affectedtypecreationdissolution = 'begin' THEN eventlist.governmentid
                            ELSE NULL
                        END), 0)::integer AS begin,
                        COALESCE(count(DISTINCT CASE
                            WHEN eventlist.affectedtypecreationdissolution = 'end' THEN eventlist.governmentid
                            ELSE NULL
                        END), 0)::integer AS end
                    FROM eventlist
                    JOIN geohistory.event
                        ON eventlist.event = event.eventid
                        AND event.eventsortyear >= ?
                        AND event.eventsortyear <= ?
                    JOIN geohistory.eventgranted
                        ON event.eventgranted = eventgranted.eventgrantedid
                        AND eventgranted.eventgrantedsuccess
                    GROUP BY 1
                ), eventdata AS (
                    SELECT DISTINCT eventyear.x,
                        CASE
                            WHEN ? = 'created' THEN eventyear.begin
                            WHEN ? = 'dissolved' THEN eventyear.end
                            WHEN ? = 'net' THEN eventyear.begin - eventyear.end
                            ELSE 0::integer
                        END AS y
                    FROM eventyear
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
                        ELSE eventdata.y::text
                    END ORDER BY xvalue.x)) AS datarow
                FROM xvalue
                LEFT JOIN eventdata
                    ON xvalue.x = eventdata.x
            QUERY;

        $query = $this->db->query($query, [
            $jurisdiction,
            $jurisdiction,
            $from,
            $to,
            $for,
            $for,
            $for,
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

    public function getIdByGovernmentShort(string $government, string $parent = ''): string
    {
        if ($parent !== '') {
            return $this->getIdByGovernmentShortParent($government, $parent);
        }

        $query = <<<QUERY
                SELECT DISTINCT government.governmentid
                FROM geohistory.government lookupgovernment
                JOIN geohistory.government
                    ON lookupgovernment.governmentslugsubstitute = government.governmentslugsubstitute
                    AND government.governmentstatus <> 'placeholder'
                    AND (
                        lookupgovernment.governmentshort = ?
                        OR lookupgovernment.governmentabbreviation = ?
                    )
                ORDER BY 1
            QUERY;

        $query = $this->db->query($query, [
            $government,
            strtoupper($government),
        ]);

        $result = [];

        $query = $this->getObject($query);
        foreach ($query as $row) {
            $result[] = $row->governmentid;
        }

        return '{' . implode(',', $result) . '}';
    }

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

    public function getRelated(int $id): array
    {
        $query = <<<QUERY
                WITH governmentmatch AS (
                    SELECT DISTINCT governmentsubstitute.governmentid,
                        governmentsubstitute.governmentstatus,
                        governmentsubstitute.governmentcurrentleadparent,
                        governmentsubstitute.governmentcurrentleadstateid,
                        governmentsubstitute.governmentlevel
                    FROM geohistory.government
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                        AND government.governmentid = ?
                ), governmentrelation AS (
                    SELECT DISTINCT COALESCE(event.eventslug, '') AS governmentslug,
                        governmentsubstitute.governmentlong,
                        CASE
                            WHEN governmentsubstitute.governmentstatus = 'defunct' THEN 'Historic'
                            ELSE 'Variant'
                        END AS governmentrelationship,
                        CASE
                            WHEN governmentsubstitute.governmentstatus = 'defunct' THEN 'former'
                            ELSE 'variant'
                        END AS governmentparentstatus,
                        'event' AS governmentslugtype
                    FROM governmentmatch
                    JOIN geohistory.government governmentsubstitute
                        ON governmentmatch.governmentid = governmentsubstitute.governmentid
                        AND governmentsubstitute.governmentid <> ?
                    LEFT JOIN geohistory.event
                        ON governmentsubstitute.governmentid = event.government
                    UNION DISTINCT
                    SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                        governmentsubstitute.governmentlong,
                        CASE
                            WHEN affectedgovernmentlevel.affectedgovernmentlevelgroup > otheraffectedgovernmentlevel.affectedgovernmentlevelgroup THEN 'Parent'
                            WHEN affectedgovernmentlevel.affectedgovernmentlevelgroup < otheraffectedgovernmentlevel.affectedgovernmentlevelgroup THEN 'Child'
                            ELSE 'Even'
                        END AS governmentrelationship,
                        CASE
                            WHEN NOT eventgranted.eventgrantedsuccess THEN 'proposed'
                            WHEN government.governmentid <> governmentsubstitute.governmentid THEN 'variant'
                            WHEN affectedtype.affectedtypeid = 12 THEN 'reference'
                            ELSE 'former'
                        END AS governmentparentstatus,
                        'government' AS governmentslugtype
                    FROM governmentmatch
                    JOIN geohistory.affectedgovernmentpart
                        ON governmentmatch.governmentid = affectedgovernmentpart.governmentfrom
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.event
                        ON affectedgovernmentgroup.event = event.eventid
                    JOIN geohistory.eventgranted
                        ON event.eventgranted = eventgranted.eventgrantedid
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                    JOIN geohistory.affectedgovernmentgrouppart otheraffectedgovernmentgrouppart
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = otheraffectedgovernmentgrouppart.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentlevel otheraffectedgovernmentlevel
                        ON otheraffectedgovernmentgrouppart.affectedgovernmentlevel = otheraffectedgovernmentlevel.affectedgovernmentlevelid
                        AND (
                            governmentmatch.governmentlevel > 2
                            OR affectedgovernmentlevel.affectedgovernmentlevelgroup >= otheraffectedgovernmentlevel.affectedgovernmentlevelgroup
                            OR otheraffectedgovernmentlevel.affectedgovernmentlevelgroup - governmentmatch.governmentlevel = 1
                        )
                    JOIN geohistory.affectedgovernmentpart otheraffectedgovernmentpart
                        ON otheraffectedgovernmentgrouppart.affectedgovernmentpart = otheraffectedgovernmentpart.affectedgovernmentpartid
                    JOIN geohistory.affectedtype
                        ON otheraffectedgovernmentpart.affectedtypefrom = affectedtype.affectedtypeid
                    JOIN geohistory.government
                        ON otheraffectedgovernmentpart.governmentfrom = government.governmentid
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                        AND governmentsubstitute.governmentid <> ?
                        AND governmentsubstitute.governmentstatus <> 'placeholder'
                    UNION DISTINCT
                    SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                        governmentsubstitute.governmentlong,
                        CASE
                            WHEN affectedgovernmentlevel.affectedgovernmentlevelgroup > otheraffectedgovernmentlevel.affectedgovernmentlevelgroup THEN 'Parent'
                            WHEN affectedgovernmentlevel.affectedgovernmentlevelgroup < otheraffectedgovernmentlevel.affectedgovernmentlevelgroup THEN 'Child'
                            ELSE 'Even'
                        END AS governmentrelationship,
                        CASE
                            WHEN NOT eventgranted.eventgrantedsuccess THEN 'proposed'
                            WHEN government.governmentid <> governmentsubstitute.governmentid THEN 'variant'
                            WHEN affectedtype.affectedtypeid = 12 THEN 'reference'
                            ELSE 'former'
                        END AS governmentparentstatus,
                        'government' AS governmentslugtype
                    FROM governmentmatch
                    JOIN geohistory.affectedgovernmentpart
                        ON governmentmatch.governmentid = affectedgovernmentpart.governmentto
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.event
                        ON affectedgovernmentgroup.event = event.eventid
                    JOIN geohistory.eventgranted
                        ON event.eventgranted = eventgranted.eventgrantedid
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                    JOIN geohistory.affectedgovernmentgrouppart otheraffectedgovernmentgrouppart
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = otheraffectedgovernmentgrouppart.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentlevel otheraffectedgovernmentlevel
                        ON otheraffectedgovernmentgrouppart.affectedgovernmentlevel = otheraffectedgovernmentlevel.affectedgovernmentlevelid
                        AND (
                            governmentmatch.governmentlevel > 2
                            OR affectedgovernmentlevel.affectedgovernmentlevelgroup >= otheraffectedgovernmentlevel.affectedgovernmentlevelgroup
                            OR otheraffectedgovernmentlevel.affectedgovernmentlevelgroup - governmentmatch.governmentlevel = 1
                        )
                    JOIN geohistory.affectedgovernmentpart otheraffectedgovernmentpart
                        ON otheraffectedgovernmentgrouppart.affectedgovernmentpart = otheraffectedgovernmentpart.affectedgovernmentpartid
                    JOIN geohistory.affectedtype
                        ON otheraffectedgovernmentpart.affectedtypeto = affectedtype.affectedtypeid
                    JOIN geohistory.government
                        ON otheraffectedgovernmentpart.governmentto = government.governmentid
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                        AND governmentsubstitute.governmentid <> ?
                        AND governmentsubstitute.governmentstatus <> 'placeholder'
                    UNION DISTINCT
                    SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                        governmentsubstitute.governmentlong,
                        'Parent' AS governmentrelationship,
                        CASE
                            WHEN governmentmatch.governmentstatus IN ('alternate', 'language') OR governmentsubstitute.governmentstatus IN ('alternate', 'language') THEN 'variant'
                            WHEN governmentmatch.governmentstatus = 'proposed' OR governmentsubstitute.governmentstatus = 'proposed' THEN 'proposed'
                            WHEN governmentmatch.governmentstatus = 'defunct' OR governmentsubstitute.governmentstatus = 'defunct' THEN 'former'
                            ELSE 'current'
                        END AS governmentparentstatus,
                        'government' AS governmentslugtype
                    FROM governmentmatch
                    JOIN geohistory.government
                        ON governmentmatch.governmentcurrentleadparent = government.governmentid
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                        AND governmentsubstitute.governmentid <> ?
                    UNION DISTINCT
                    SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                        governmentsubstitute.governmentlong,
                        'Child' AS governmentrelationship,
                        CASE
                            WHEN governmentmatch.governmentstatus IN ('alternate', 'language') OR governmentsubstitute.governmentstatus IN ('alternate', 'language') THEN 'variant'
                            WHEN governmentmatch.governmentstatus = 'proposed' OR governmentsubstitute.governmentstatus = 'proposed' THEN 'proposed'
                            WHEN governmentmatch.governmentstatus = 'defunct' OR governmentsubstitute.governmentstatus = 'defunct' THEN 'former'
                            ELSE 'current'
                        END AS governmentparentstatus,
                        'government' AS governmentslugtype
                    FROM governmentmatch
                    JOIN geohistory.government
                        ON governmentmatch.governmentid = government.governmentcurrentleadparent
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                        AND governmentsubstitute.governmentid <> ?
                        AND (
                            governmentmatch.governmentlevel > 2
                            OR governmentsubstitute.governmentlevel - governmentmatch.governmentlevel = 1
                        )
                    UNION DISTINCT
                    SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                        governmentsubstitute.governmentlong,
                        'Parent' AS governmentrelationship,
                        CASE
                            WHEN governmentmatch.governmentstatus IN ('alternate', 'language') OR governmentsubstitute.governmentstatus IN ('alternate', 'language') THEN 'variant'
                            WHEN governmentmatch.governmentstatus = 'proposed' OR governmentsubstitute.governmentstatus = 'proposed' THEN 'proposed'
                            WHEN governmentmatch.governmentstatus = 'defunct' OR governmentsubstitute.governmentstatus = 'defunct' THEN 'former'
                            ELSE 'current'
                        END AS governmentparentstatus,
                        'government' AS governmentslugtype
                    FROM governmentmatch
                    JOIN geohistory.government
                        ON governmentmatch.governmentcurrentleadstateid = government.governmentid
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                        AND governmentsubstitute.governmentid <> ?
                    UNION DISTINCT
                    SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                        governmentsubstitute.governmentlong,
                        'Child' AS governmentrelationship,
                        CASE
                            WHEN governmentmatch.governmentstatus IN ('alternate', 'language') OR governmentsubstitute.governmentstatus IN ('alternate', 'language') THEN 'variant'
                            WHEN governmentmatch.governmentstatus = 'proposed' OR governmentsubstitute.governmentstatus = 'proposed' THEN 'proposed'
                            WHEN governmentmatch.governmentstatus = 'defunct' OR governmentsubstitute.governmentstatus = 'defunct' THEN 'former'
                            ELSE 'current'
                        END AS governmentparentstatus,
                        'government' AS governmentslugtype
                    FROM governmentmatch
                    JOIN geohistory.government
                        ON governmentmatch.governmentid = government.governmentcurrentleadstateid
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                        AND governmentsubstitute.governmentid <> ?
                        AND (
                            governmentmatch.governmentlevel > 2
                            OR governmentsubstitute.governmentlevel - governmentmatch.governmentlevel = 1
                        )
                    UNION DISTINCT
                    SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                        governmentsubstitute.governmentlong,
                        'Parent' AS governmentrelationship,
                        CASE
                            WHEN governmentmatch.governmentstatus IN ('alternate', 'language') OR governmentsubstitute.governmentstatus IN ('alternate', 'language') THEN 'variant'
                            WHEN governmentmatch.governmentstatus = 'proposed' OR governmentsubstitute.governmentstatus = 'proposed' THEN 'proposed'
                            WHEN governmentmatch.governmentstatus = 'defunct' OR governmentsubstitute.governmentstatus = 'defunct' THEN 'former'
                            ELSE 'current'
                        END AS governmentparentstatus,
                        'government' AS governmentslugtype
                    FROM governmentmatch
                    JOIN geohistory.governmentothercurrentparent
                        ON governmentmatch.governmentid = governmentothercurrentparent.government
                    JOIN geohistory.government
                        ON governmentothercurrentparent.governmentothercurrentparent = government.governmentid
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                        AND governmentsubstitute.governmentid <> ?
                    UNION DISTINCT
                    SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                        governmentsubstitute.governmentlong,
                        'Child' AS governmentrelationship,
                        CASE
                            WHEN governmentmatch.governmentstatus IN ('alternate', 'language') OR governmentsubstitute.governmentstatus IN ('alternate', 'language') THEN 'variant'
                            WHEN governmentmatch.governmentstatus = 'proposed' OR governmentsubstitute.governmentstatus = 'proposed' THEN 'proposed'
                            WHEN governmentmatch.governmentstatus = 'defunct' OR governmentsubstitute.governmentstatus = 'defunct' THEN 'former'
                            ELSE 'current'
                        END AS governmentparentstatus,
                        'government' AS governmentslugtype
                    FROM governmentmatch
                    JOIN geohistory.governmentothercurrentparent
                        ON governmentmatch.governmentid = governmentothercurrentparent.governmentothercurrentparent
                    JOIN geohistory.government
                        ON governmentothercurrentparent.government = government.governmentid
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                        AND governmentsubstitute.governmentid <> ?
                        AND (
                            governmentmatch.governmentlevel > 2
                            OR governmentsubstitute.governmentlevel - governmentmatch.governmentlevel = 1
                        )
                ), governmentrelationrank AS (
                    SELECT governmentrelation.governmentslug,
                        governmentrelation.governmentlong,
                        governmentrelation.governmentrelationship,
                        governmentrelation.governmentparentstatus,
                        governmentrelation.governmentslugtype,
                        ROW_NUMBER () OVER (PARTITION BY governmentrelation.governmentlong
                            ORDER BY governmentrelation.governmentslugtype,
                            CASE
                                WHEN governmentrelation.governmentrelationship = 'Historic' THEN 1
                                WHEN governmentrelation.governmentrelationship = 'Variant' THEN 2
                                ELSE 3
                            END, CASE
                                WHEN governmentrelation.governmentparentstatus = 'current' THEN 1
                                WHEN governmentrelation.governmentparentstatus = 'former' THEN 2
                                WHEN governmentrelation.governmentparentstatus = 'variant' THEN 3
                                WHEN governmentrelation.governmentparentstatus = 'proposed' THEN 4
                                ELSE 5
                            END) AS governmentrelationrank
                    FROM governmentrelation
                )
                SELECT *,
                    'none' AS governmentcolor
                FROM governmentrelationrank
                WHERE governmentrelationrank = 1
                ORDER BY 2
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
        ]);

        return $this->getObject($query);
    }

    public function getSearch(): array
    {
        $query = <<<QUERY
                SELECT DISTINCT government.governmentshort,
                    lpad(government.governmentid::text, 6, '0') AS governmentid,
                    government.governmentlevel
                FROM geohistory.government
                WHERE government.governmentlevel <= 3
                ORDER BY government.governmentlevel, 1
            QUERY;

        $query = $this->db->query($query);

        return $this->getArray($query);
    }

    public function getSearchByGovernment(array $parameters): array
    {
        if ($parameters[3] === 'statewide') {
            if (preg_match('/^\d+$/', $parameters[1]) === 1) {
                $government = $this->getIdByGovernment(intval($parameters[1]));
            } else {
                $government = $this->getIdByGovernmentShort($parameters[1]);
            }
        } else {
            $government = $this->getIdByGovernmentShort($parameters[0], $parameters[1]);
        }
        $level = $parameters[2];

        $query = <<<QUERY
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong,
                    governmentsubstitute.governmentid,
                    governmentsubstitute.governmentshort,
                    governmentsubstitute.governmentstatus
                FROM geohistory.government
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND government.governmentid = ANY (?)
                    AND governmentsubstitute.governmentlevel = ANY (?)
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong,
                    governmentsubstitute.governmentid,
                    governmentsubstitute.governmentshort,
                    governmentsubstitute.governmentstatus
                FROM geohistory.affectedgovernmentpart
                JOIN geohistory.affectedgovernmentgrouppart
                    ON affectedgovernmentpart.governmentfrom = ANY (?)
                    AND affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                JOIN geohistory.affectedgovernmentgrouppart otheraffectedgovernmentgrouppart
                    ON affectedgovernmentgrouppart.affectedgovernmentgroup = otheraffectedgovernmentgrouppart.affectedgovernmentgroup
                JOIN geohistory.affectedgovernmentpart otheraffectedgovernmentpart
                    ON otheraffectedgovernmentgrouppart.affectedgovernmentpart = otheraffectedgovernmentpart.affectedgovernmentpartid
                JOIN geohistory.government
                    ON otheraffectedgovernmentpart.governmentfrom = government.governmentid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentlevel = ANY (?)
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong,
                    governmentsubstitute.governmentid,
                    governmentsubstitute.governmentshort,
                    governmentsubstitute.governmentstatus
                FROM geohistory.affectedgovernmentpart
                JOIN geohistory.affectedgovernmentgrouppart
                    ON affectedgovernmentpart.governmentto = ANY (?)
                    AND affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                JOIN geohistory.affectedgovernmentgrouppart otheraffectedgovernmentgrouppart
                    ON affectedgovernmentgrouppart.affectedgovernmentgroup = otheraffectedgovernmentgrouppart.affectedgovernmentgroup
                JOIN geohistory.affectedgovernmentpart otheraffectedgovernmentpart
                    ON otheraffectedgovernmentgrouppart.affectedgovernmentpart = otheraffectedgovernmentpart.affectedgovernmentpartid
                JOIN geohistory.government
                    ON otheraffectedgovernmentpart.governmentto = government.governmentid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentlevel = ANY (?)
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong,
                    governmentsubstitute.governmentid,
                    governmentsubstitute.governmentshort,
                    governmentsubstitute.governmentstatus
                FROM geohistory.government lookupgovernment
                JOIN geohistory.government
                    ON lookupgovernment.governmentid = ANY (?)
                    AND lookupgovernment.governmentcurrentleadparent = government.governmentid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentlevel = ANY (?)
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong,
                    governmentsubstitute.governmentid,
                    governmentsubstitute.governmentshort,
                    governmentsubstitute.governmentstatus
                FROM geohistory.government lookupgovernment
                JOIN geohistory.government
                    ON lookupgovernment.governmentid = ANY (?)
                    AND lookupgovernment.governmentid = government.governmentcurrentleadparent
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentlevel = ANY (?)
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong,
                    governmentsubstitute.governmentid,
                    governmentsubstitute.governmentshort,
                    governmentsubstitute.governmentstatus
                FROM geohistory.government lookupgovernment
                JOIN geohistory.government
                    ON lookupgovernment.governmentid = ANY (?)
                    AND lookupgovernment.governmentcurrentleadstateid = government.governmentid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentlevel = ANY (?)
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong,
                    governmentsubstitute.governmentid,
                    governmentsubstitute.governmentshort,
                    governmentsubstitute.governmentstatus
                FROM geohistory.government lookupgovernment
                JOIN geohistory.government
                    ON lookupgovernment.governmentid = ANY (?)
                    AND lookupgovernment.governmentid = government.governmentcurrentleadstateid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentlevel = ANY (?)
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong,
                    governmentsubstitute.governmentid,
                    governmentsubstitute.governmentshort,
                    governmentsubstitute.governmentstatus
                FROM geohistory.governmentothercurrentparent
                JOIN geohistory.government
                    ON governmentothercurrentparent.government = ANY (?)
                    AND governmentothercurrentparent.governmentothercurrentparent = government.governmentid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentlevel = ANY (?)
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong,
                    governmentsubstitute.governmentid,
                    governmentsubstitute.governmentshort,
                    governmentsubstitute.governmentstatus
                FROM geohistory.governmentothercurrentparent
                JOIN geohistory.government
                    ON governmentothercurrentparent.governmentothercurrentparent = ANY (?)
                    AND governmentothercurrentparent.government = government.governmentid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentlevel = ANY (?)
                ORDER BY 2
            QUERY;

        $query = $this->db->query($query, [
            $government,
            $level,
            $government,
            $level,
            $government,
            $level,
            $government,
            $level,
            $government,
            $level,
            $government,
            $level,
            $government,
            $level,
            $government,
            $level,
            $government,
            $level,
        ]);

        return $this->getObject($query);
    }

    public function getSchoolDistrict(int $id): array
    {
        return [];
    }

    public function getSlug(int $id): string
    {
        $query = <<<QUERY
                SELECT government.governmentslugsubstitute AS id
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
