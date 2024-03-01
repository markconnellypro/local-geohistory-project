<?php

namespace App\Models;

use CodeIgniter\Model;

class LawSectionModel extends Model
{
    // extra.ci_model_event_law(integer)

    // VIEW: extra.lawsectionextracache

    public function getByEvent($id)
    {
        $query = <<<QUERY
            SELECT DISTINCT lawsectionextracache.lawsectionslug,
                law.lawapproved,
                lawsectionextracache.lawsectioncitation,
                eventrelationship.eventrelationshipshort AS lawsectioneventrelationship,
                lawsection.lawsectionfrom,
                law.lawnumberchapter,
                lawgroup.lawgrouplong
            FROM geohistory.law
            JOIN geohistory.lawsection
                ON law.lawid = lawsection.law   
            JOIN extra.lawsectionextracache
                ON lawsection.lawsectionid = lawsectionextracache.lawsectionid
            JOIN geohistory.lawsectionevent
                ON lawsection.lawsectionid = lawsectionevent.lawsection 
                AND lawsectionevent.event = ?
            JOIN geohistory.eventrelationship
                ON lawsectionevent.eventrelationship = eventrelationship.eventrelationshipid
            LEFT JOIN geohistory.lawgroup
                ON lawsectionevent.lawgroup = lawgroup.lawgroupid
            ORDER BY 4, 2, 1
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_search_law_dateevent(character varying, text, character varying)

    // FUNCTION: extra.governmentabbreviation
    // FUNCTION: extra.governmentabbreviationid
    // FUNCTION: extra.governmentcurrentleadparent
    // VIEW: extra.lawsectionextracache

    public function getSearchByDateEvent($parameters)
    {
        $date = $parameters[0];
        $eventType = $parameters[1];
        $state = $parameters[2];

        $query = <<<QUERY
            WITH source AS (
                SELECT source.sourceid,
                sourcegovernment.government
                FROM geohistory.source
                LEFT JOIN geohistory.sourcegovernment
                ON source.sourceid = sourcegovernment.source
                AND sourcegovernment.sourceorder = 1
                WHERE source.sourcetype = 'session laws'
            )
            SELECT lawsectionextracache.lawsectionslug,
               lawsectionextracache.lawsectioncitation,
               lawapproved,
               eventtypeshort
              FROM geohistory.lawsection
                JOIN extra.lawsectionextracache
                  ON lawsection.lawsectionid = lawsectionextracache.lawsectionid
                JOIN geohistory.eventtype
                  ON lawsection.eventtype = eventtype.eventtypeid
                  AND (? = ''::text 
                 OR ? = 'Any Type'::text
                 OR (? = 'Only Border Changes'::text AND eventtype.eventtypeborders ~~ 'yes%')
                 OR eventtype.eventtypeshort = ?)
                JOIN geohistory.law
                  ON lawsection.law = law.lawid
                  AND law.lawapproved = ?
                JOIN source
                  ON law.source = source.sourceid
                  AND (extra.governmentabbreviation(source.government) = ?
                OR source.government = extra.governmentcurrentleadparent(extra.governmentabbreviationid(?))
                OR source.government IS NULL);
        QUERY;

        $query = $this->db->query($query, [
            $eventType,
            $eventType,
            $eventType,
            $eventType,
            $date,
            strtoupper($state),
            strtoupper($state),
        ])->getResult();

        return $query ?? [];
    }

    // extra_removed.ci_model_search_law_reference(character varying, integer, integer, character varying)

    // FUNCTION: extra.governmentabbreviation
    // FUNCTION: extra.governmentabbreviationid
    // FUNCTION: extra.governmentcurrentleadparent
    // VIEW: extra.lawsectionextracache

    public function getSearchByReference($parameters)
    {
        $yearVolume = $parameters[0];
        $page = $parameters[1];
        $numberChapter = $parameters[2];
        $state = $parameters[3];

        $query = <<<QUERY
            WITH source AS (
                SELECT source.sourceid,
                sourcegovernment.government
                FROM geohistory.source
                LEFT JOIN geohistory.sourcegovernment
                ON source.sourceid = sourcegovernment.source
                AND sourcegovernment.sourceorder = 1
                WHERE source.sourcetype = 'session laws'
            )
            SELECT lawsectionextracache.lawsectionslug,
               lawsectionextracache.lawsectioncitation,
               lawapproved,
               eventtypeshort
              FROM geohistory.lawsection
                JOIN extra.lawsectionextracache
                  ON lawsection.lawsectionid = lawsectionextracache.lawsectionid   
                JOIN geohistory.eventtype
                  ON lawsection.eventtype = eventtype.eventtypeid
                JOIN geohistory.law
                  ON lawsection.law = law.lawid
                  AND (law.lawvolume = ? OR left(law.lawapproved, 4) = ?)
                JOIN source
                  ON law.source = source.sourceid
                  AND (extra.governmentabbreviation(source.government) = ?
                OR source.government = extra.governmentcurrentleadparent(extra.governmentabbreviationid(?))
                OR source.government IS NULL)
             WHERE (0 = ? OR law.lawpage = ? OR (lawsection.lawsectionpagefrom >= ? AND lawsection.lawsectionpageto <= ?))
               AND (0 = ? OR law.lawnumberchapter = ?)
        QUERY;

        $query = $this->db->query($query, [
            $yearVolume,
            $yearVolume,
            strtoupper($state),
            strtoupper($state),
            $page,
            $page,
            $page,
            $page,
            $numberChapter,
            $numberChapter,
        ])->getResult();

        return $query ?? [];
    }
}