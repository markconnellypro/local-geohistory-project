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
                -- BEGIN: PORTION TAKEN FROM GOVERNMENTCHANGECOUNT
                WITH affectedgovernmentsummary AS (
                    SELECT DISTINCT affectedgovernmentgroup.event AS eventid,
                        government_1.governmentid,
                        originalgovernment.governmentid AS originalgovernmentid,
                        affectedgovernmentpart.affectedtypefrom AS affectedtypeid,
                        'from'::text AS affectedside
                    FROM geohistory.affectedgovernmentgroup
                        JOIN geohistory.affectedgovernmentgrouppart ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
                        JOIN geohistory.affectedgovernmentpart ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
                        JOIN geohistory.government originalgovernment ON affectedgovernmentpart.governmentfrom = originalgovernment.governmentid
                        JOIN geohistory.government government_1 ON originalgovernment.governmentslugsubstitute = government_1.governmentslug AND government_1.governmentid = ?
                    UNION
                    SELECT DISTINCT affectedgovernmentgroup.event AS eventid,
                        government_1.governmentid,
                        originalgovernment.governmentid AS originalgovernmentid,
                        affectedgovernmentpart.affectedtypeto AS affectedtypeid,
                        'to'::text AS affectedside
                    FROM geohistory.affectedgovernmentgroup
                        JOIN geohistory.affectedgovernmentgrouppart ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
                        JOIN geohistory.affectedgovernmentpart ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
                        JOIN geohistory.government originalgovernment ON affectedgovernmentpart.governmentto = originalgovernment.governmentid
                        JOIN geohistory.government government_1 ON originalgovernment.governmentslugsubstitute = government_1.governmentslug AND government_1.governmentid = ?
                ), affectedgovernmentsummaryeventpart AS (
                    SELECT affectedgovernmentsummary.eventid,
                        affectedgovernmentsummary.governmentid,
                        array_agg(DISTINCT affectedgovernmentsummary.originalgovernmentid ORDER BY affectedgovernmentsummary.originalgovernmentid) AS originalgovernmentid,
                        affectedgovernmentsummary.affectedtypeid,
                        affectedgovernmentsummary.affectedside,
                        affectedtype.affectedtypecreationdissolution,
                        event.eventsortdate,
                        event.eventdatetext,
                        initcap((event.eventeffective::calendar.historicdate)."precision") AS eventeffectiveprecision,
                        eventeffectivetype.eventeffectivetypelong AS eventeffectivetype,
                        sum(
                            CASE
                                WHEN eventrelationship.eventrelationshipid IS NOT NULL THEN 1
                                ELSE 0
                            END) AS lawsection
                    FROM affectedgovernmentsummary
                        JOIN geohistory.event ON affectedgovernmentsummary.eventid = event.eventid
                        LEFT JOIN geohistory.eventeffectivetype ON event.eventeffectivetypepresumedsource = eventeffectivetype.eventeffectivetypeid
                        JOIN geohistory.eventgranted ON event.eventgranted = eventgranted.eventgrantedid AND eventgranted.eventgrantedsuccess
                        JOIN geohistory.affectedtype ON affectedgovernmentsummary.affectedtypeid = affectedtype.affectedtypeid
                        LEFT JOIN geohistory.lawsectionevent ON event.eventid = lawsectionevent.event
                        LEFT JOIN geohistory.eventrelationship ON lawsectionevent.eventrelationship = eventrelationship.eventrelationshipid AND eventrelationship.eventrelationshipsufficient
                    GROUP BY affectedgovernmentsummary.eventid, affectedgovernmentsummary.governmentid, affectedgovernmentsummary.affectedtypeid, affectedgovernmentsummary.affectedside, affectedtype.affectedtypecreationdissolution, event.eventsortdate, event.eventdatetext, eventeffectivetype.eventeffectivetypelong, event.eventeffective, event.eventfrom, event.eventto
                ), creationdissolution AS (
                    SELECT DISTINCT creationaffectedgovernmentsummaryeventpart.governmentid,
                        creationaffectedgovernmentsummaryeventpart.eventid
                    FROM affectedgovernmentsummaryeventpart creationaffectedgovernmentsummaryeventpart
                        JOIN affectedgovernmentsummaryeventpart dissolutionaffectedgovernmentsummaryeventpart ON creationaffectedgovernmentsummaryeventpart.governmentid = dissolutionaffectedgovernmentsummaryeventpart.governmentid AND creationaffectedgovernmentsummaryeventpart.eventid = dissolutionaffectedgovernmentsummaryeventpart.eventid AND creationaffectedgovernmentsummaryeventpart.affectedtypecreationdissolution::text = 'begin'::text AND dissolutionaffectedgovernmentsummaryeventpart.affectedtypecreationdissolution::text = 'end'::text
                ), affectedgovernmentsummaryevent AS (
                    SELECT DISTINCT affectedgovernmentsummaryeventpart.eventid,
                        affectedgovernmentsummaryeventpart.governmentid,
                        affectedgovernmentsummaryeventpart.originalgovernmentid,
                        affectedgovernmentsummaryeventpart.affectedtypeid,
                        affectedgovernmentsummaryeventpart.affectedside,
                            CASE
                                WHEN creationdissolution.eventid IS NOT NULL THEN 'alter'::character varying
                                ELSE affectedgovernmentsummaryeventpart.affectedtypecreationdissolution
                            END AS affectedtypecreationdissolution,
                        affectedgovernmentsummaryeventpart.eventsortdate,
                        affectedgovernmentsummaryeventpart.eventdatetext,
                        affectedgovernmentsummaryeventpart.eventeffectiveprecision,
                        affectedgovernmentsummaryeventpart.eventeffectivetype,
                        affectedgovernmentsummaryeventpart.lawsection
                    FROM affectedgovernmentsummaryeventpart
                        LEFT JOIN creationdissolution ON affectedgovernmentsummaryeventpart.eventid = creationdissolution.eventid AND affectedgovernmentsummaryeventpart.governmentid = creationdissolution.governmentid
                ), alterfrom AS (
                    SELECT affectedgovernmentsummaryevent.governmentid,
                        COALESCE(array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid), ARRAY[]::integer[]) AS eventid
                    FROM affectedgovernmentsummaryevent
                    WHERE affectedgovernmentsummaryevent.affectedside = 'from'::text AND affectedgovernmentsummaryevent.affectedtypecreationdissolution::text = 'alter'::text
                    GROUP BY affectedgovernmentsummaryevent.governmentid
                ), alterto AS (
                    SELECT affectedgovernmentsummaryevent.governmentid,
                        COALESCE(array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid), ARRAY[]::integer[]) AS eventid
                    FROM affectedgovernmentsummaryevent
                    WHERE affectedgovernmentsummaryevent.affectedside = 'to'::text AND affectedgovernmentsummaryevent.affectedtypecreationdissolution::text = 'alter'::text
                    GROUP BY affectedgovernmentsummaryevent.governmentid
                ), altertotal AS (
                    SELECT affectedgovernmentsummaryevent.governmentid,
                        COALESCE(array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid), ARRAY[]::integer[]) AS eventid
                    FROM affectedgovernmentsummaryevent
                    WHERE affectedgovernmentsummaryevent.affectedtypecreationdissolution::text = 'alter'::text
                    GROUP BY affectedgovernmentsummaryevent.governmentid
                ), creation AS (
                    SELECT affectedgovernmentsummaryevent.governmentid,
                        geohistory.array_combine(array_agg(affectedgovernmentsummaryevent.originalgovernmentid)) AS originalgovernmentid,
                        array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid) AS eventid,
                        array_agg(DISTINCT affectedgovernmentsummaryevent.eventsortdate) AS eventsortdate,
                        array_agg(DISTINCT affectedgovernmentsummaryevent.eventdatetext) AS eventdatetext,
                        array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectiveprecision) AS eventeffectiveprecision,
                        array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectivetype) AS eventeffectivetype,
                        sum(affectedgovernmentsummaryevent.lawsection) > 0::numeric AS lawsection
                    FROM affectedgovernmentsummaryevent
                    WHERE affectedgovernmentsummaryevent.affectedtypecreationdissolution::text = 'begin'::text
                    GROUP BY affectedgovernmentsummaryevent.governmentid
                ), dissolution AS (
                    SELECT affectedgovernmentsummaryevent.governmentid,
                        geohistory.array_combine(array_agg(affectedgovernmentsummaryevent.originalgovernmentid)) AS originalgovernmentid,
                        array_agg(DISTINCT affectedgovernmentsummaryevent.eventid ORDER BY affectedgovernmentsummaryevent.eventid) AS eventid,
                        array_agg(DISTINCT affectedgovernmentsummaryevent.eventsortdate) AS eventsortdate,
                        array_agg(DISTINCT affectedgovernmentsummaryevent.eventdatetext) AS eventdatetext,
                        array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectiveprecision) AS eventeffectiveprecision,
                        array_agg(DISTINCT affectedgovernmentsummaryevent.eventeffectivetype) AS eventeffectivetype,
                        sum(affectedgovernmentsummaryevent.lawsection) > 0::numeric AS lawsection
                    FROM affectedgovernmentsummaryevent
                    WHERE affectedgovernmentsummaryevent.affectedtypecreationdissolution::text = 'end'::text
                    GROUP BY affectedgovernmentsummaryevent.governmentid
                ), affectedgovernmentform AS (
                    SELECT DISTINCT affectedgovernmentpart.governmentto AS government,
                        governmentform.governmentformlong,
                        affectedgovernmentgroup.event,
                        row_number() OVER (PARTITION BY affectedgovernmentpart.governmentto ORDER BY event.eventsortdate DESC) AS recentness
                    FROM geohistory.affectedgovernmentpart
                        JOIN geohistory.affectedgovernmentgrouppart ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart AND affectedgovernmentpart.governmentformto IS NOT NULL AND affectedgovernmentpart.affectedtypeto <> 12
                        JOIN geohistory.affectedgovernmentgroup ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                        JOIN geohistory.event ON affectedgovernmentgroup.event = event.eventid
                        JOIN geohistory.eventgranted ON event.eventgranted = eventgranted.eventgrantedid AND eventgranted.eventgrantedsuccess
                        JOIN geohistory.governmentform ON affectedgovernmentpart.governmentformto = governmentform.governmentformid
                ), governmentchangecount AS (
                    SELECT COALESCE(government.governmentcurrentleadstate::text, ''::text) AS governmentstate,
                        government.governmentlevel,
                        government.governmenttype,
                        COALESCE(affectedgovernmentform.governmentformlong, ''::text) AS currentform,
                        COALESCE(affectedgovernmentform.governmentformlong, ''::text) AS currentformdetailed,
                            CASE
                                WHEN government.governmentlevel > 3 THEN governmentparent.governmentname::text
                                ELSE ''::text
                            END AS governmentleadparentcounty,
                        government.governmentid,
                        government.governmentlong,
                        COALESCE(array_length(creation.eventid, 1), 0) AS creation,
                        creation.eventid AS creationevent,
                            CASE
                                WHEN array_length(creation.eventid, 1) = 1 THEN creation.eventdatetext[1]
                                ELSE ''::text
                            END AS creationtext,
                            CASE
                                WHEN array_length(creation.eventid, 1) = 1 THEN COALESCE(creation.eventeffectiveprecision[1], 'None'::text)
                                ELSE 'None'::text
                            END AS creationprecision,
                            CASE
                                WHEN array_length(creation.eventid, 1) = 1 THEN creation.eventsortdate[1]
                                ELSE NULL::date
                            END AS creationsort,
                            CASE
                                WHEN array_length(creation.eventid, 1) = 1 THEN COALESCE(creation.eventeffectivetype[1], ''::text)
                                ELSE ''::text
                            END AS creationhow,
                            CASE
                                WHEN creation.lawsection IS NULL THEN false
                                ELSE creation.lawsection
                            END AS creationlawsection,
                        creation.originalgovernmentid AS creationas,
                        COALESCE(array_length(alterfrom.eventid, 1), 0) AS alterfrom,
                        COALESCE(array_length(alterto.eventid, 1), 0) AS alterto,
                        COALESCE(array_length(altertotal.eventid, 1), 0) AS altertotal,
                        COALESCE(array_length(dissolution.eventid, 1), 0) AS dissolution,
                        dissolution.eventid AS dissolutionevent,
                            CASE
                                WHEN array_length(dissolution.eventid, 1) = 1 THEN dissolution.eventdatetext[1]
                                ELSE ''::text
                            END AS dissolutiontext,
                            CASE
                                WHEN array_length(dissolution.eventid, 1) = 1 THEN COALESCE(dissolution.eventeffectiveprecision[1], 'None'::text)
                                ELSE 'None'::text
                            END AS dissolutionprecision,
                            CASE
                                WHEN array_length(dissolution.eventid, 1) = 1 THEN dissolution.eventsortdate[1]
                                ELSE NULL::date
                            END AS dissolutionsort,
                            CASE
                                WHEN array_length(dissolution.eventid, 1) = 1 THEN COALESCE(dissolution.eventeffectivetype[1], ''::text)
                                ELSE ''::text
                            END AS dissolutionhow,
                            CASE
                                WHEN dissolution.lawsection IS NULL THEN false
                                ELSE dissolution.lawsection
                            END AS dissolutionlawsection,
                        dissolution.originalgovernmentid AS dissolutionas
                    FROM geohistory.government
                        LEFT JOIN geohistory.government governmentparent ON government.governmentcurrentleadparent = governmentparent.governmentid
                        LEFT JOIN alterfrom ON government.governmentid = alterfrom.governmentid
                        LEFT JOIN alterto ON government.governmentid = alterto.governmentid
                        LEFT JOIN altertotal ON government.governmentid = altertotal.governmentid
                        LEFT JOIN creation ON government.governmentid = creation.governmentid
                        LEFT JOIN dissolution ON government.governmentid = dissolution.governmentid
                        LEFT JOIN affectedgovernmentform ON government.governmentid = affectedgovernmentform.government AND affectedgovernmentform.recentness = 1
                    WHERE government.governmentid = ?
                )
                -- END: PORTION TAKEN FROM GOVERNMENTCHANGECOUNT
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
                            governmentchangecount.creationevent IS NULL
                            AND governmentchangecount.altertotal = 0
                            AND governmentchangecount.dissolutionevent IS NULL
                        ) AS textflag,
                    creationevent.eventslug AS governmentcreationevent,
                    governmentchangecount.creationtext AS governmentcreationtext,
                        CASE
                            WHEN governmentchangecount.creation = 1
                                AND array_length(governmentchangecount.creationas, 1) = 1
                                AND government.governmentid <> governmentchangecount.creationas[1]
                                THEN creationas.governmentlong
                            ELSE ''
                        END AS governmentcreationlong,
                    governmentchangecount.altertotal AS governmentaltercount,
                    dissolutionevent.eventslug AS governmentdissolutionevent,
                    governmentchangecount.dissolutiontext AS governmentdissolutiontext,
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
                LEFT JOIN governmentchangecount
                    ON government.governmentid = governmentchangecount.governmentid
                LEFT JOIN geohistory.event creationevent
                    ON governmentchangecount.creationevent IS NOT NULL
                    AND governmentchangecount.creationevent[1] = creationevent.eventid
                LEFT JOIN geohistory.event dissolutionevent
                    ON governmentchangecount.dissolutionevent IS NOT NULL
                    AND governmentchangecount.dissolutionevent[1] = dissolutionevent.eventid
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
                    ON governmentchangecount.creationas[1] = creationas.governmentid
                WHERE government.governmentid = ?
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
            QUERY;

        $query = $this->db->query($query, [
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
                        ROW_NUMBER () OVER (PARTITION BY governmentrelation.governmentlong
                            ORDER BY CASE
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
                    'none' AS governmentcolor,
                    'government' AS governmentslugtype
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
            $government = $this->getIdByGovernmentShort($parameters[1]);
        } else {
            $government = $this->getIdByGovernmentShort($parameters[0], $parameters[1]);
        }
        $level = $parameters[2];

        $query = <<<QUERY
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong
                FROM geohistory.government
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND government.governmentid = ANY (?)
                    AND governmentsubstitute.governmentlevel = ?
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong
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
                    AND governmentsubstitute.governmentlevel = ?
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong
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
                    AND governmentsubstitute.governmentlevel = ?
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong
                FROM geohistory.government lookupgovernment
                JOIN geohistory.government
                    ON lookupgovernment.governmentid = ANY (?)
                    AND lookupgovernment.governmentcurrentleadparent = government.governmentid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentlevel = ?
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong
                FROM geohistory.government lookupgovernment
                JOIN geohistory.government
                    ON lookupgovernment.governmentid = ANY (?)
                    AND lookupgovernment.governmentid = government.governmentcurrentleadparent
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentlevel = ?
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong
                FROM geohistory.government lookupgovernment
                JOIN geohistory.government
                    ON lookupgovernment.governmentid = ANY (?)
                    AND lookupgovernment.governmentcurrentleadstateid = government.governmentid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentlevel = ?
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong
                FROM geohistory.government lookupgovernment
                JOIN geohistory.government
                    ON lookupgovernment.governmentid = ANY (?)
                    AND lookupgovernment.governmentid = government.governmentcurrentleadstateid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentlevel = ?
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong
                FROM geohistory.governmentothercurrentparent
                JOIN geohistory.government
                    ON governmentothercurrentparent.government = ANY (?)
                    AND governmentothercurrentparent.governmentothercurrentparent = government.governmentid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentlevel = ?
                UNION DISTINCT
                SELECT DISTINCT governmentsubstitute.governmentslugsubstitute AS governmentslug,
                    governmentsubstitute.governmentlong
                FROM geohistory.governmentothercurrentparent
                JOIN geohistory.government
                    ON governmentothercurrentparent.governmentothercurrentparent = ANY (?)
                    AND governmentothercurrentparent.government = government.governmentid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentlevel = ?
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
