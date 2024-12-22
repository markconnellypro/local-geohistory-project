<?php

namespace App\Models;

use App\Models\BaseModel;
use App\Models\GovernmentModel;

class EventModel extends BaseModel
{
    public function getDetail(int|string $id): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = <<<QUERY
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
                    event.eventyear,
                    event.eventeffectivetext AS eventeffective,
                    eventeffectivetype.eventeffectivetypegroup::text ||
                        CASE
                            WHEN eventeffectivetype.eventeffectivetypequalifier IS NOT NULL AND eventeffectivetype.eventeffectivetypequalifier::text = ''::text THEN ''::text
                            ELSE ': '::text || eventeffectivetype.eventeffectivetypequalifier::text
                        END AS eventeffectivetype,
                    other.otherdate,
                    other.otherdatetype,
                    event.eventismapped,
                    government.governmentslugsubstitute AS government
                FROM geohistory.event
                    JOIN geohistory.eventgranted
                    ON event.eventgranted = eventgranted.eventgrantedid
                    JOIN geohistory.eventmethod
                    ON event.eventmethod = eventmethod.eventmethodid
                    JOIN geohistory.eventtype
                    ON event.eventtype = eventtype.eventtypeid
                    LEFT JOIN geohistory.government
                        ON event.government = government.governmentid
                    LEFT JOIN ( SELECT other_1.otherdate,
                            other_1.otherdatetype
                        FROM ( SELECT DISTINCT calendar.historicdatetextformat(filing.filingdate::calendar.historicdate, 'short', ?) AS otherdate,
                                    'Final Decree'::text AS otherdatetype
                                FROM geohistory.adjudicationevent,
                                    geohistory.filing,
                                    geohistory.filingtype
                                WHERE adjudicationevent.adjudication = filing.adjudication AND filing.filingtype = filingtype.filingtypeid AND filingtype.filingtypefinalrecording AND adjudicationevent.event = ?
                                UNION
                                SELECT DISTINCT calendar.historicdatetextformat(governmentsource.governmentsourcedate::calendar.historicdate, 'short', ?) AS otherdate,
                                    'Letters Patent'::text AS otherdatetype
                                FROM geohistory.governmentsource,
                                    geohistory.governmentsourceevent
                                WHERE governmentsource.governmentsourceid = governmentsourceevent.governmentsource AND governmentsource.governmentsourcetype::text = 'Letters Patent'::text AND governmentsourceevent.event = ?) other_1
                        WHERE 1 = (( SELECT count(*) AS rowct
                                FROM ( SELECT DISTINCT calendar.historicdatetextformat(filing.filingdate::calendar.historicdate, 'short', ?) AS otherdate,
                                            'Final Decree'::text AS otherdatetype,
                                            true AS isother
                                        FROM geohistory.adjudicationevent,
                                            geohistory.filing,
                                            geohistory.filingtype
                                        WHERE adjudicationevent.adjudication = filing.adjudication AND filing.filingtype = filingtype.filingtypeid AND filingtype.filingtypefinalrecording AND adjudicationevent.event = ?
                                        UNION
                                        SELECT DISTINCT calendar.historicdatetextformat(governmentsource.governmentsourcedate::calendar.historicdate, 'short', ?) AS otherdate,
                                            'Letters Patent'::text AS otherdatetype,
                                            true AS isother
                                        FROM geohistory.governmentsource,
                                            geohistory.governmentsourceevent
                                        WHERE governmentsource.governmentsourceid = governmentsourceevent.governmentsource AND governmentsource.governmentsourcetype::text = 'Letters Patent'::text AND governmentsourceevent.event = ?) other_2))) other ON 0 = 0
                    LEFT JOIN geohistory.eventeffectivetype ON event.eventeffectivetypepresumedsource = eventeffectivetype.eventeffectivetypeid
                WHERE event.eventid = ?
            QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
            $id,
            \Config\Services::request()->getLocale(),
            $id,
            \Config\Services::request()->getLocale(),
            $id,
            \Config\Services::request()->getLocale(),
            $id,
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getByAdjudication(int $id): array
    {
        $query = <<<QUERY
                SELECT DISTINCT event.eventslug,
                    eventtype.eventtypeshort,
                    event.eventlong,
                    event.eventyear,
                    eventgranted.eventgrantedshort AS eventgranted,
                    event.eventeffectivetext AS eventeffective,
                    event.eventsort,
                    eventrelationship.eventrelationshipshort AS eventrelationship
                FROM geohistory.event
                JOIN geohistory.eventgranted
                    ON event.eventgranted = eventgranted.eventgrantedid
                JOIN geohistory.eventtype
                    ON event.eventtype = eventtype.eventtypeid
                JOIN geohistory.adjudicationevent
                    ON event.eventid = adjudicationevent.event
                    AND adjudicationevent.adjudication = ?
                JOIN geohistory.eventrelationship
                    ON adjudicationevent.eventrelationship = eventrelationship.eventrelationshipid
                ORDER BY event.eventsort, event.eventlong
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getByAdjudicationSourceCitation(int $id): array
    {
        $query = <<<QUERY
                SELECT DISTINCT event.eventslug,
                    eventtype.eventtypeshort,
                    event.eventlong,
                    event.eventyear,
                    eventgranted.eventgrantedshort AS eventgranted,
                    event.eventeffectivetext AS eventeffective,
                    event.eventsort
                FROM geohistory.event
                JOIN geohistory.eventgranted
                    ON event.eventgranted = eventgranted.eventgrantedid
                JOIN geohistory.eventtype
                    ON event.eventtype = eventtype.eventtypeid
                JOIN geohistory.adjudicationevent
                    ON event.eventid = adjudicationevent.event
                JOIN geohistory.adjudicationsourcecitation
                    ON adjudicationevent.adjudication = adjudicationsourcecitation.adjudication
                    AND adjudicationsourcecitation.adjudicationsourcecitationid = ?
                ORDER BY event.eventsort, event.eventlong
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getByGovernmentOther(string $allId, array $omitEvents): array
    {
        $events = $this->getIdByGovernment($allId);

        $query = <<<QUERY
                SELECT DISTINCT event.eventslug,
                    eventtype.eventtypeshort,
                    event.eventlong,
                    event.eventyear,
                    eventgranted.eventgrantedshort AS eventgranted,
                    event.eventeffectivetext AS eventeffective,
                    event.eventsort
                FROM geohistory.event
                JOIN geohistory.eventgranted
                    ON event.eventgranted = eventgranted.eventgrantedid
                    AND NOT eventgranted.eventgrantedplaceholder
                JOIN geohistory.eventtype
                    ON event.eventtype = eventtype.eventtypeid
                WHERE event.eventid = ANY (?)
                    AND event.eventid <> ALL (?)
                ORDER BY event.eventsort, event.eventlong
            QUERY;

        $query = $this->db->query($query, [
            $events,
            '{' . implode(',', $omitEvents) . '}',
        ]);

        return $this->getObject($query);
    }

    public function getByGovernmentShapeFailure(int $id, array $events): array
    {
        $query = <<<QUERY
                SELECT DISTINCT event.eventslug,
                    eventtype.eventtypeshort,
                    event.eventlong,
                    event.eventyear,
                    eventgranted.eventgrantedshort AS eventgranted,
                    event.eventeffectivetext AS eventeffective,
                    event.eventsort
                FROM geohistory.event
                JOIN geohistory.eventgranted
                    ON event.eventgranted = eventgranted.eventgrantedid
                JOIN geohistory.eventtype
                    ON event.eventtype = eventtype.eventtypeid
                    AND event.eventid <> ALL (?)
                WHERE (event.eventid IN ( SELECT event_1.eventid
                        FROM geohistory.event event_1,
                            geohistory.affectedgovernmentgroup,
                            gis.affectedgovernmentgis
                        WHERE event_1.eventid = affectedgovernmentgroup.event
                            AND affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgis.affectedgovernment
                            AND affectedgovernmentgis.governmentshape = ?
                        UNION
                        SELECT event_1.eventid
                        FROM geohistory.event event_1,
                            geohistory.metesdescription,
                            gis.metesdescriptiongis
                        WHERE event_1.eventid = metesdescription.event
                            AND metesdescription.metesdescriptionid = metesdescriptiongis.metesdescription
                            AND metesdescriptiongis.governmentshape = ?))
                ORDER BY event.eventsort, event.eventlong
            QUERY;

        $query = $this->db->query($query, [
            '{' . implode(',', $events) . '}',
            $id,
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getByGovernmentSource(int $id): array
    {
        $query = <<<QUERY
                SELECT DISTINCT event.eventslug,
                    eventtype.eventtypeshort,
                    event.eventlong,
                    event.eventyear,
                    eventgranted.eventgrantedshort AS eventgranted,
                    event.eventeffectivetext AS eventeffective,
                    event.eventsort
                FROM geohistory.event
                JOIN geohistory.eventgranted
                    ON event.eventgranted = eventgranted.eventgrantedid
                JOIN geohistory.eventtype
                    ON event.eventtype = eventtype.eventtypeid
                JOIN geohistory.governmentsourceevent
                    ON event.eventid = governmentsourceevent.event
                    AND governmentsourceevent.governmentsource = ?
                ORDER BY event.eventsort, event.eventlong
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getByLawAlternateSection(int $id): array
    {
        $query = <<<QUERY
                SELECT DISTINCT event.eventslug,
                    eventtype.eventtypeshort,
                    event.eventlong,
                    event.eventyear,
                    eventgranted.eventgrantedshort AS eventgranted,
                    event.eventeffectivetext AS eventeffective,
                    event.eventsort,
                    eventrelationship.eventrelationshipshort AS eventrelationship,
                    lawgroup.lawgrouplong
                FROM geohistory.event
                JOIN geohistory.eventgranted
                    ON event.eventgranted = eventgranted.eventgrantedid
                JOIN geohistory.eventtype
                    ON event.eventtype = eventtype.eventtypeid
                JOIN geohistory.lawsectionevent
                    ON event.eventid = lawsectionevent.event
                JOIN geohistory.eventrelationship
                    ON lawsectionevent.eventrelationship = eventrelationship.eventrelationshipid
                JOIN geohistory.lawalternatesection
                    ON lawsectionevent.lawsection = lawalternatesection.lawsection
                    AND lawalternatesection.lawalternatesectionid = ?
                LEFT JOIN geohistory.lawgroup
                    ON lawsectionevent.lawgroup = lawgroup.lawgroupid
                ORDER BY event.eventsort, event.eventlong
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getByLawSection(int $id): array
    {
        $query = <<<QUERY
                SELECT DISTINCT event.eventslug,
                    eventtype.eventtypeshort,
                    event.eventlong,
                    event.eventyear,
                    eventgranted.eventgrantedshort AS eventgranted,
                    event.eventeffectivetext AS eventeffective,
                    event.eventsort,
                    eventrelationship.eventrelationshipshort AS eventrelationship,
                    lawgroup.lawgrouplong
                FROM geohistory.event
                JOIN geohistory.eventgranted
                    ON event.eventgranted = eventgranted.eventgrantedid
                JOIN geohistory.eventtype
                    ON event.eventtype = eventtype.eventtypeid
                JOIN geohistory.lawsectionevent
                    ON event.eventid = lawsectionevent.event
                    AND lawsectionevent.lawsection = ?
                JOIN geohistory.eventrelationship
                    ON lawsectionevent.eventrelationship = eventrelationship.eventrelationshipid
                LEFT JOIN geohistory.lawgroup
                    ON lawsectionevent.lawgroup = lawgroup.lawgroupid
                ORDER BY event.eventsort, event.eventlong
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getBySourceCitation(int $id): array
    {
        $query = <<<QUERY
                SELECT DISTINCT event.eventslug,
                    eventtype.eventtypeshort,
                    event.eventlong,
                    event.eventyear,
                    eventgranted.eventgrantedshort AS eventgranted,
                    event.eventeffectivetext AS eventeffective,
                    event.eventsort
                FROM geohistory.event
                JOIN geohistory.eventgranted
                    ON event.eventgranted = eventgranted.eventgrantedid
                JOIN geohistory.eventtype
                    ON event.eventtype = eventtype.eventtypeid
                JOIN geohistory.sourcecitationevent
                    ON event.eventid = sourcecitationevent.event
                    AND sourcecitationevent.sourcecitation = ?
                ORDER BY event.eventsort, event.eventlong
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
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
                        COALESCE(governmentidentifier.governmentidentifier::integer, 0) AS series
                    FROM geohistory.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                        AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE 'state'
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentfrom = government.governmentid
                        AND government.governmentstatus::text NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND government.governmentcurrentleadstate = ANY (?)
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslug
                    LEFT JOIN geohistory.governmentidentifier
                        ON governmentsubstitute.governmentid = governmentidentifier.government
                        AND governmentidentifier.governmentidentifiertype = 1
                    WHERE affectedgovernmentpart.affectedtypefrom <> 12
                    UNION
                    SELECT DISTINCT affectedgovernmentgroup.event,
                        COALESCE(governmentidentifier.governmentidentifier::integer, 0) AS series
                    FROM geohistory.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                        AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE 'state'
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentto = government.governmentid
                        AND government.governmentstatus::text NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND government.governmentcurrentleadstate = ANY (?)
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslug
                    LEFT JOIN geohistory.governmentidentifier
                        ON governmentsubstitute.governmentid = governmentidentifier.government
                        AND governmentidentifier.governmentidentifiertype = 1
                    WHERE affectedgovernmentpart.affectedtypeto <> 12
                ), eventdata AS (
                    SELECT eventlist.series,
                        event.eventsortyear AS x,
                        count(DISTINCT event.eventid)::integer AS y
                    FROM geohistory.event
                    JOIN eventlist
                        ON event.eventid = eventlist.event
                    JOIN geohistory.eventgranted
                        ON event.eventgranted = eventgranted.eventgrantedid
                        AND eventgranted.eventgrantedsuccess
                    JOIN geohistory.eventtype
                        ON event.eventtype = eventtype.eventtypeid
                        AND eventtype.eventtypeshort = ?
                    WHERE event.eventsortyear >= ?
                        AND event.eventsortyear <= ?
                    GROUP BY 1, 2
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
            $for,
            $from,
            $to,
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
                SELECT DISTINCT affectedgovernmentgroup.event
                FROM geohistory.affectedgovernmentpart
                JOIN geohistory.affectedgovernmentgrouppart
                    ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                JOIN geohistory.affectedgovernmentlevel
                    ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                    AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE 'state'
                JOIN geohistory.affectedgovernmentgroup
                    ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                JOIN geohistory.government
                    ON affectedgovernmentpart.governmentfrom = government.governmentid
                    AND government.governmentstatus::text NOT IN ('placeholder', 'proposed', 'unincorporated')
                    AND government.governmentcurrentleadstate = ANY (?)
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslug
                LEFT JOIN geohistory.governmentidentifier
                    ON governmentsubstitute.governmentid = governmentidentifier.government
                    AND governmentidentifier.governmentidentifiertype = 1
                WHERE affectedgovernmentpart.affectedtypefrom <> 12
                UNION
                SELECT DISTINCT affectedgovernmentgroup.event
                FROM geohistory.affectedgovernmentpart
                JOIN geohistory.affectedgovernmentgrouppart
                    ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                JOIN geohistory.affectedgovernmentlevel
                    ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                    AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE 'state'
                JOIN geohistory.affectedgovernmentgroup
                    ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                JOIN geohistory.government
                    ON affectedgovernmentpart.governmentto = government.governmentid
                    AND government.governmentstatus::text NOT IN ('placeholder', 'proposed', 'unincorporated')
                    AND government.governmentcurrentleadstate = ANY (?)
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslug
                LEFT JOIN geohistory.governmentidentifier
                    ON governmentsubstitute.governmentid = governmentidentifier.government
                    AND governmentidentifier.governmentidentifiertype = 1
                WHERE affectedgovernmentpart.affectedtypeto <> 12
            ), eventdata AS (
                SELECT event.eventsortyear AS x,
                    count(DISTINCT event.eventid)::integer AS y
                FROM geohistory.event
                JOIN eventlist
                    ON event.eventid = eventlist.event
                JOIN geohistory.eventgranted
                    ON event.eventgranted = eventgranted.eventgrantedid
                    AND eventgranted.eventgrantedsuccess
                JOIN geohistory.eventtype
                    ON event.eventtype = eventtype.eventtypeid
                    AND eventtype.eventtypeshort = ?
                WHERE event.eventsortyear >= ?
                    AND event.eventsortyear <= ?
                GROUP BY 1
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
            $for,
            $from,
            $to,
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
                        COALESCE(governmentidentifier.governmentidentifier::integer, 0) AS series
                    FROM geohistory.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                        AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE '%county'
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentfrom = government.governmentid
                        AND government.governmentstatus::text NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND government.governmentcurrentleadstate = ?
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslug
                    LEFT JOIN geohistory.governmentidentifier
                        ON governmentsubstitute.governmentid = governmentidentifier.government
                        AND governmentidentifier.governmentidentifiertype = 1
                    WHERE affectedgovernmentpart.affectedtypefrom <> 12
                    UNION
                    SELECT DISTINCT affectedgovernmentgroup.event,
                        COALESCE(governmentidentifier.governmentidentifier::integer, 0) AS series
                    FROM geohistory.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                        AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE '%county'
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentto = government.governmentid
                        AND government.governmentstatus::text NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND government.governmentcurrentleadstate = ?
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslug
                    LEFT JOIN geohistory.governmentidentifier
                        ON governmentsubstitute.governmentid = governmentidentifier.government
                        AND governmentidentifier.governmentidentifiertype = 1
                    WHERE affectedgovernmentpart.affectedtypeto <> 12
                ), eventdata AS (
                    SELECT eventlist.series,
                        event.eventsortyear AS x,
                        count(DISTINCT event.eventid)::integer AS y
                    FROM geohistory.event
                    JOIN eventlist
                        ON event.eventid = eventlist.event
                    JOIN geohistory.eventgranted
                        ON event.eventgranted = eventgranted.eventgrantedid
                        AND eventgranted.eventgrantedsuccess
                    JOIN geohistory.eventtype
                        ON event.eventtype = eventtype.eventtypeid
                        AND eventtype.eventtypeshort = ?
                    WHERE event.eventsortyear >= ?
                        AND event.eventsortyear <= ?
                    GROUP BY 1, 2
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
            $for,
            $from,
            $to,
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
                    SELECT DISTINCT affectedgovernmentgroup.event
                    FROM geohistory.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                        AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE '%county'
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentfrom = government.governmentid
                        AND government.governmentstatus::text NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND government.governmentcurrentleadstate = ?
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslug
                    LEFT JOIN geohistory.governmentidentifier
                        ON governmentsubstitute.governmentid = governmentidentifier.government
                        AND governmentidentifier.governmentidentifiertype = 1
                    WHERE affectedgovernmentpart.affectedtypefrom <> 12
                    UNION
                    SELECT DISTINCT affectedgovernmentgroup.event
                    FROM geohistory.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentpart.affectedgovernmentpartid = affectedgovernmentgrouppart.affectedgovernmentpart
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                        AND affectedgovernmentlevel.affectedgovernmentlevelshort LIKE '%county'
                    JOIN geohistory.affectedgovernmentgroup
                        ON affectedgovernmentgrouppart.affectedgovernmentgroup = affectedgovernmentgroup.affectedgovernmentgroupid
                    JOIN geohistory.government
                        ON affectedgovernmentpart.governmentto = government.governmentid
                        AND government.governmentstatus::text NOT IN ('placeholder', 'proposed', 'unincorporated')
                        AND government.governmentcurrentleadstate = ?
                    JOIN geohistory.government governmentsubstitute
                        ON government.governmentslugsubstitute = governmentsubstitute.governmentslug
                    LEFT JOIN geohistory.governmentidentifier
                        ON governmentsubstitute.governmentid = governmentidentifier.government
                        AND governmentidentifier.governmentidentifiertype = 1
                    WHERE affectedgovernmentpart.affectedtypeto <> 12
                ), eventdata AS (
                    SELECT event.eventsortyear AS x,
                        count(DISTINCT event.eventid)::integer AS y
                    FROM geohistory.event
                    JOIN eventlist
                        ON event.eventid = eventlist.event
                    JOIN geohistory.eventgranted
                        ON event.eventgranted = eventgranted.eventgrantedid
                        AND eventgranted.eventgrantedsuccess
                    JOIN geohistory.eventtype
                        ON event.eventtype = eventtype.eventtypeid
                        AND eventtype.eventtypeshort = ?
                    WHERE event.eventsortyear >= ?
                        AND event.eventsortyear <= ?
                    GROUP BY 1
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
            $for,
            $from,
            $to,
        ]);

        return $this->getObject($query);
    }

    public function getIdByGovernment(string $government): string
    {
        $query = <<<QUERY
                WITH governments AS (
                    SELECT governmentid
                    FROM geohistory.government
                    WHERE governmentid = ANY (?)
                )
                SELECT DISTINCT adjudicationevent.event AS eventid
                FROM geohistory.adjudicationevent
                JOIN geohistory.adjudicationlocation
                    ON adjudicationevent.adjudication = adjudicationlocation.adjudication
                JOIN geohistory.adjudicationlocationtype
                    ON adjudicationlocation.adjudicationlocationtype = adjudicationlocationtype.adjudicationlocationtypeid
                JOIN geohistory.tribunal
                    ON adjudicationlocationtype.tribunal = tribunal.tribunalid
                JOIN governments
                    ON tribunal.government = governments.governmentid
                UNION
                SELECT DISTINCT adjudicationevent.event AS eventid
                FROM geohistory.adjudicationevent
                JOIN geohistory.adjudication
                    ON adjudicationevent.adjudication = adjudication.adjudicationid
                JOIN geohistory.adjudicationtype
                    ON adjudication.adjudicationtype = adjudicationtype.adjudicationtypeid
                JOIN geohistory.tribunal
                    ON adjudicationtype.tribunal = tribunal.tribunalid
                JOIN governments
                    ON tribunal.government = governments.governmentid
                UNION
                SELECT DISTINCT affectedgovernmentgroup.event AS eventid
                FROM geohistory.affectedgovernmentgroup
                JOIN geohistory.affectedgovernmentgrouppart
                    ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
                JOIN geohistory.affectedgovernmentpart
                    ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
                JOIN governments
                    ON (
                        COALESCE(affectedgovernmentpart.governmentfrom, -1) = governments.governmentid
                        OR COALESCE(affectedgovernmentpart.governmentto, -1) = governments.governmentid
                    )
                UNION
                SELECT DISTINCT affectedgovernmentgroup.event AS eventid
                FROM geohistory.affectedgovernmentgroup
                JOIN gis.affectedgovernmentgis
                    ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgis.affectedgovernment
                JOIN gis.governmentshape
                    ON affectedgovernmentgis.governmentshape = governmentshape.governmentshapeid
                JOIN governments
                    ON (
                        COALESCE(governmentshape.governmentschooldistrict, -1) = governments.governmentid
                        OR COALESCE(governmentshape.governmentshapeplsstownship, -1) = governments.governmentid
                        OR COALESCE(governmentshape.governmentsubmunicipality, -1) = governments.governmentid
                        OR COALESCE(governmentshape.governmentward, -1) = governments.governmentid
                        OR governmentshape.governmentmunicipality = governments.governmentid
                        OR governmentshape.governmentcounty = governments.governmentid
                        OR governmentshape.governmentstate = governments.governmentid
                    )
                UNION
                SELECT DISTINCT currentgovernment.event AS eventid
                FROM geohistory.currentgovernment
                JOIN governments
                    ON (
                        COALESCE(currentgovernment.governmentsubmunicipality, -1) = governments.governmentid
                        OR currentgovernment.governmentmunicipality = governments.governmentid
                        OR currentgovernment.governmentcounty = governments.governmentid
                        OR currentgovernment.governmentstate = governments.governmentid
                    )
                UNION
                SELECT DISTINCT event.eventid
                FROM geohistory.event
                JOIN governments
                    ON event.government = governments.governmentid
                UNION
                SELECT DISTINCT governmentsourceevent.event AS eventid
                FROM geohistory.governmentsourceevent
                JOIN geohistory.governmentsource
                    ON governmentsourceevent.governmentsource = governmentsource.governmentsourceid
                JOIN governments
                    ON governmentsource.government = governments.governmentid
                UNION
                SELECT DISTINCT lawsectionevent.event AS eventid
                FROM geohistory.lawsectionevent
                JOIN geohistory.lawsection
                    ON lawsectionevent.lawsection = lawsection.lawsectionid
                JOIN geohistory.law
                    ON lawsection.law = law.lawid
                JOIN geohistory.sourcegovernment
                    ON law.source = sourcegovernment.source
                    AND sourcegovernment.sourceorder = 1
                JOIN governments
                    ON sourcegovernment.government = governments.governmentid
                UNION
                SELECT DISTINCT metesdescription.event AS eventid
                FROM geohistory.metesdescription
                JOIN gis.metesdescriptiongis
                    ON metesdescription.metesdescriptionid = metesdescriptiongis.metesdescription
                JOIN gis.governmentshape
                    ON metesdescriptiongis.governmentshape = governmentshape.governmentshapeid
                JOIN governments
                    ON (
                        COALESCE(governmentshape.governmentschooldistrict, -1) = governments.governmentid
                        OR COALESCE(governmentshape.governmentshapeplsstownship, -1) = governments.governmentid
                        OR COALESCE(governmentshape.governmentsubmunicipality, -1) = governments.governmentid
                        OR COALESCE(governmentshape.governmentward, -1) = governments.governmentid
                        OR governmentshape.governmentmunicipality = governments.governmentid
                        OR governmentshape.governmentcounty = governments.governmentid
                        OR governmentshape.governmentstate = governments.governmentid
                    )
            QUERY;

        $query = $this->db->query($query, [
            $government,
        ]);

        $result = [];

        $query = $this->getObject($query);
        foreach ($query as $row) {
            $result[] = $row->eventid;
        }

        return '{' . implode(',', $result) . '}';
    }

    public function getIdByGovernmentShort(int|string $government, string $parent = ''): string
    {
        $GovernmentModel = new GovernmentModel();
        if (is_int($government)) {
            $government = $GovernmentModel->getIdByGovernment($government);
        } else {
            $government = $GovernmentModel->getIdByGovernmentShort($government, $parent);
        }
        return $this->getIdByGovernment($government);
    }

    public function getSearchByGovernment(array $parameters): array
    {
        $government = $parameters[0];
        $parent = $parameters[1];
        $events = $this->getIdByGovernmentShort($government, $parent);
        $eventType = $parameters[2];
        $year = $parameters[3];
        $plusMinus = $parameters[4];

        // Get event

        $query = <<<QUERY
                SELECT DISTINCT event.eventslug,
                    eventtype.eventtypeshort,
                    event.eventlong,
                    event.eventyear,
                    eventgranted.eventgrantedshort AS eventgranted,
                    event.eventeffectivetext AS eventeffective,
                    event.eventsort
                    FROM geohistory.event
                    JOIN geohistory.eventgranted
                        ON event.eventgranted = eventgranted.eventgrantedid
                        AND NOT eventgranted.eventgrantedplaceholder
                    JOIN geohistory.eventtype
                        ON event.eventtype = eventtype.eventtypeid
                    WHERE event.eventid = ANY (?)
                    AND (? = ''::text
                        OR ? = 'Any Type'::text
                        OR (? = 'Only Border Changes'::text AND eventtype.eventtypeborders ~~ 'yes%')
                        OR eventtype.eventtypeshort = ?)
                    AND (0 = ?
                        OR (event.eventfrom <= (? + ?) AND event.eventfrom >= (? - ?))
                        OR (event.eventto <= (? + ?) AND event.eventto >= (? - ?))
                        OR (floor(event.eventsort) <= (? + ?) AND floor(event.eventsort) >= (? - ?)))
                    ORDER BY event.eventsort, event.eventlong
            QUERY;

        $query = $this->db->query($query, [
            $events,
            $eventType,
            $eventType,
            $eventType,
            $eventType,
            $year,
            $year,
            $plusMinus,
            $year,
            $plusMinus,
            $year,
            $plusMinus,
            $year,
            $plusMinus,
            $year,
            $plusMinus,
            $year,
            $plusMinus,
        ]);

        return $this->getObject($query);
    }

    private function getSlugId(string $id): int
    {
        $query = <<<QUERY
                SELECT event.eventid AS id
                FROM geohistory.event
                WHERE event.eventslug = ?
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        $query = $this->getObject($query);

        $output = -1;

        if (count($query) === 1) {
            $output = $query[0]->id;
        } else {
            $this->getRetiredSlugRedirect($id);
        }

        return $output;
    }

    private function getRetiredSlugRedirect(int|string $id): void
    {
        $query = <<<QUERY
                SELECT DISTINCT event.eventslug
                FROM geohistory.eventslugretired
                JOIN geohistory.event
                ON eventslugretired.eventid = event.eventid
                WHERE eventslugretired.eventslug = ?
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        $query = $this->getObject($query);

        if (count($query) === 1) {
            header("HTTP/1.1 301 Moved Permanently");
            header("Location: /" . \Config\Services::request()->getLocale() . "/event/" . $query[0]->eventslug . "/");
            exit();
        }
    }
}
