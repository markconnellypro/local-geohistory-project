<?php

namespace App\Models;

use CodeIgniter\Model;

class EventGrantedModel extends Model
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

        return $this->db->query($query)->getResult();
    }
}
