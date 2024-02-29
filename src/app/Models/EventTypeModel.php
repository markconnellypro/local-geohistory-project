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
}