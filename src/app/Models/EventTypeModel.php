<?php

namespace App\Models;

use CodeIgniter\Model;

class EventTypeModel extends Model
{
    // extra.ci_model_key_eventtype()

    public function getKey()
    {
        $query = <<<QUERY
            SELECT eventtype.eventtypeshort AS keyshort,
                eventtype.eventtypeshort AS keysort,
                eventtype.eventtypelong AS keylong,
                CASE
                    WHEN eventtype.eventtypeborders ~~ 'yes%' THEN 'yes'
                    WHEN eventtype.eventtypeborders = 'documentation' THEN NULL
                    ELSE ''
                END AS keyincluded
            FROM geohistory.eventtype
            WHERE eventtype.eventtypelong NOT IN ('~', '*')
                AND eventtype.eventtypeborders <> 'ignore'
            ORDER BY 2, 1
        QUERY;

        $query = $this->db->query($query)->getResult();

        return $query ?? [];
    }

    // extra.ci_model_search_form_eventtype(character varying)

    // FUNCTION: extra.governmentabbreviationid
    // VIEW: extra.eventgovernmentcache

    public function getSearch($state)
    {
        $query = <<<QUERY
            SELECT DISTINCT eventtype.eventtypeshort,
                eventtype.eventtypeid,
                eventtype.eventtypeborders = 'documentation' AS isdocumentation
            FROM geohistory.eventtype
            LEFT JOIN geohistory.event
                ON eventtype.eventtypeid = event.eventtype
            LEFT JOIN extra.eventgovernmentcache
                ON event.eventid = eventgovernmentcache.eventid
                AND eventgovernmentcache.government = extra.governmentabbreviationid(?)
            WHERE (
                eventtype.eventtypeborders <> 'ignore'
                AND eventgovernmentcache.eventid IS NOT NULL
            )
            OR eventtype.eventtypeborders = 'documentation'
            ORDER BY 3 DESC, 1, 2
        QUERY;

        $query = $this->db->query($query, [
            strtoupper($state),
        ])->getResultArray();

        return $query ?? [];
    }
}