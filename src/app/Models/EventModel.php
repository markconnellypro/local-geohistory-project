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
}