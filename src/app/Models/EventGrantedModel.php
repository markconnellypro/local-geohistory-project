<?php

namespace App\Models;

use App\Models\BaseModel;

class EventGrantedModel extends BaseModel
{
    // extra.ci_model_key_eventgranted()

    public function getKey(): array
    {
        $query = <<<QUERY
            SELECT eventgranted.eventgrantedshort AS keyshort,
                eventgranted.eventgrantedshort AS keysort,
                eventgranted.eventgrantedlong AS keylong
            FROM geohistory.eventgranted
            ORDER BY 2, 1
        QUERY;

        $query = $this->db->query($query);

        return $this->getObject($query);
    }
}
