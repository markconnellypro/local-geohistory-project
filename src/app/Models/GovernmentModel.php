<?php

namespace App\Models;

use App\Models\BaseModel;

class GovernmentModel extends BaseModel
{
    // VIEW: extra.governmentchangecountcache

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
            LEFT JOIN extra.governmentchangecountcache
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
            WHERE governmentidentifier.governmentidentifierid = ANY (?);
        QUERY;

        $query = $this->db->query($query, [
            $ids
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

    // VIEW: extra.governmentparentcache

    public function getRelated(int $id): array
    {
        $query = <<<QUERY
            WITH relationpart AS (
                SELECT DISTINCT government.governmentslugsubstitute AS governmentslug,
                'government' AS governmentslugtype,
                government.governmentlong,
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
                JOIN geohistory.government governmentparentgovernment
                    ON governmentparentcache.governmentid = governmentparentgovernment.governmentid
                JOIN geohistory.government governmentsubstitute
                    ON governmentparentgovernment.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentid = ?
                LEFT JOIN geohistory.governmentmapstatus
                    ON government.governmentmapstatus = governmentmapstatus.governmentmapstatusid
                    AND governmentmapstatus.governmentmapstatusreviewed
                    AND (government.governmentstatus <> ALL (ARRAY['proposed', 'unincorporated']))
                WHERE governmentparentcache.governmentparentstatus <> 'placeholder' AND governmentparentcache.governmentparent IS NOT NULL
                UNION
                SELECT DISTINCT government.governmentslugsubstitute AS governmentslug,
                'government' AS governmentslugtype,
                government.governmentlong,
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
                JOIN geohistory.government governmentparent
                    ON governmentparentcache.governmentparent = governmentparent.governmentid
                JOIN geohistory.government governmentsubstitute
                    ON governmentparent.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentid = ?
                LEFT JOIN geohistory.governmentmapstatus
                    ON government.governmentmapstatus = governmentmapstatus.governmentmapstatusid
                    AND governmentmapstatus.governmentmapstatusreviewed
                    AND (government.governmentstatus <> ALL (ARRAY['proposed', 'unincorporated']))
                WHERE governmentparentcache.governmentparentstatus <> 'placeholder'
                UNION
                SELECT DISTINCT event.eventslug AS governmentslug,
                'event' AS governmentslugtype,
                government.governmentlong,
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
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentid = ?
                    AND government.governmentid <> governmentsubstitute.governmentid
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
            SELECT DISTINCT government.governmentslugsubstitute AS governmentslug,
                government.governmentlong
                FROM selectedgovernment
                JOIN extra.governmentrelationcache
                ON selectedgovernment.governmentid = governmentrelationcache.governmentid 
                AND governmentrelationcache.governmentrelationlevel = ?
                AND (? = 'government' OR governmentrelationcache.governmentrelationlevel < 4)
                JOIN geohistory.government
                ON governmentrelationcache.governmentrelation = government.governmentid
            UNION DISTINCT
            SELECT DISTINCT government.governmentslugsubstitute AS governmentslug,
                government.governmentlong
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
