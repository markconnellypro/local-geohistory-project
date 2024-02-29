<?php

namespace App\Models;

use CodeIgniter\Model;

class EventModel extends Model
{
    // extra.ci_model_adjudication_event(integer)

    // FUNCTION: extra.eventsortdate
    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate
    // VIEW: extra.eventextracache

    public function getByAdjudication($id)
    {
        $query = <<<QUERY
            SELECT DISTINCT eventextracache.eventslug,
                eventtype.eventtypeshort,
                event.eventlong,
                extra.rangefix(event.eventfrom::text, event.eventto::text) AS eventrange,
                eventgranted.eventgrantedshort AS eventgranted,
                extra.shortdate(event.eventeffective) AS eventeffective,
                extra.eventsortdate(event.eventid) AS eventsortdate,
                eventrelationship.eventrelationshipshort AS eventrelationship
            FROM geohistory.event
            JOIN geohistory.eventgranted
                ON event.eventgranted = eventgranted.eventgrantedid
            JOIN geohistory.eventtype
                ON event.eventtype = eventtype.eventtypeid
            JOIN extra.eventextracache
                ON event.eventid = eventextracache.eventid
                AND eventextracache.eventslugnew IS NULL
            JOIN geohistory.adjudicationevent
                ON event.eventid = adjudicationevent.event 
                AND adjudicationevent.adjudication = ?
            JOIN geohistory.eventrelationship
                ON adjudicationevent.eventrelationship = eventrelationship.eventrelationshipid
            ORDER BY (extra.eventsortdate(event.eventid)), event.eventlong
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_reporter_event(integer)

    // FUNCTION: extra.eventsortdate
    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate
    // VIEW: extra.eventextracache

    public function getByAdjudicationSourceCitation($id)
    {
        $query = <<<QUERY
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
            JOIN geohistory.adjudicationevent
                ON event.eventid = adjudicationevent.event
            JOIN geohistory.adjudicationsourcecitation
                ON adjudicationevent.adjudication = adjudicationsourcecitation.adjudication
                AND adjudicationsourcecitation.adjudicationsourcecitationid = ?
            ORDER BY (extra.eventsortdate(event.eventid)), event.eventlong;
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_source_event(integer)

    // FUNCTION: extra.eventsortdate
    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate
    // VIEW: extra.eventextracache

    public function getBySourceCitation($id)
    {
        $query = <<<QUERY
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
            JOIN geohistory.sourcecitationevent
                ON event.eventid = sourcecitationevent.event 
                AND sourcecitationevent.sourcecitation = ?
            ORDER BY (extra.eventsortdate(event.eventid)), event.eventlong
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_search_event_government(text, text, text, text, integer, integer)

    // FUNCTION: extra.eventsortdate
    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate
    // VIEW: extra.eventextracache
    // VIEW: extra.eventgovernmentcache
    // VIEW: extra.governmentextracache
    // VIEW: extra.governmentrelationcache

    public function getSearchByGovernment($parameters)
    {
        $state = $parameters[0];
        $government = $parameters[1];
        $parent = $parameters[2];
        $eventType = $parameters[3];
        $year = $parameters[4];
        $plusMinus = $parameters[5];

        $query = <<<QUERY
            WITH alternategovernment AS (
                SELECT DISTINCT alternategovernment.governmentrelation AS governmentid
                FROM extra.governmentrelationcache
                JOIN extra.governmentrelationcache alternategovernment
                    ON governmentrelationcache.governmentid = alternategovernment.governmentid
                    AND alternategovernment.governmentlevel = alternategovernment.governmentrelationlevel
                    AND governmentrelationcache.governmentlevel > 2
                    AND (
                    governmentrelationcache.governmentrelationstate = ?
                    OR governmentrelationcache.governmentrelationstate IS NULL
                    )
                    AND governmentrelationcache.governmentshort ILIKE ?
            )
            SELECT DISTINCT eventextracache.eventslug,
                eventtype.eventtypeshort,
                event.eventlong,
                extra.rangefix(event.eventfrom::text, event.eventto::text) AS eventrange,
                eventgranted.eventgrantedshort AS eventgranted,
                extra.shortdate(event.eventeffective) AS eventeffective,
                extra.eventsortdate(event.eventid) AS eventsortdate
                FROM alternategovernment
                JOIN extra.eventgovernmentcache      
                    ON alternategovernment.governmentid = eventgovernmentcache.government
                JOIN geohistory.event
                    ON eventgovernmentcache.eventid = event.eventid
                JOIN geohistory.eventgranted
                    ON event.eventgranted = eventgranted.eventgrantedid
                    AND NOT eventgranted.eventgrantedplaceholder
                JOIN geohistory.eventtype
                    ON event.eventtype = eventtype.eventtypeid  
                JOIN extra.governmentextracache
                    ON alternategovernment.governmentid = governmentextracache.governmentid
                    AND NOT governmentextracache.governmentisplaceholder
                JOIN extra.governmentrelationcache lookupgovernment
                    ON alternategovernment.governmentid = lookupgovernment.governmentid
                    AND lookupgovernment.governmentid <> lookupgovernment.governmentrelation
                JOIN extra.governmentextracache governmentparentextracache
                    ON lookupgovernment.governmentrelation = governmentparentextracache.governmentid
                    AND (? = ''::text OR governmentparentextracache.governmentshort ILIKE ?)
                JOIN extra.eventextracache
                    ON event.eventid = eventextracache.eventid
                    AND eventextracache.eventslugnew IS NULL
                WHERE (? = ''::text 
                    OR ? = 'Any Type'::text
                    OR (? = 'Only Border Changes'::text AND eventtype.eventtypeborders ~~ 'yes%')
                    OR eventtype.eventtypeshort = ?)
                AND (0 = ?
                    OR (event.eventfrom <= (? + ?) AND event.eventfrom >= (? - ?))
                    OR (event.eventto <= (? + ?) AND event.eventto >= (? - ?))
                    OR (floor(extra.eventsortdate(event.eventid)) <= (? + ?) AND floor(extra.eventsortdate(event.eventid)) >= (? - ?)))
                ORDER BY (extra.eventsortdate(event.eventid)), event.eventlong
        QUERY;

        $query = $this->db->query($query, [
            strtoupper($state),
            $government,
            $parent,
            $parent,
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
        ])->getResult();

        return $query ?? [];
    }
}