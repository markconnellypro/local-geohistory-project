<?php

namespace App\Models;

use CodeIgniter\Model;

class EventRelationshipModel extends Model
{
    // extra.ci_model_key_eventrelationship()

    public function getKey(): array
    {
        $query = <<<QUERY
            SELECT eventrelationship.eventrelationshipshort AS keyshort,
                eventrelationship.eventrelationshipshort AS keysort,
                eventrelationship.eventrelationshiplong AS keylong
            FROM geohistory.eventrelationship
            ORDER BY 2, 1
        QUERY;

        $query = $this->db->query($query)->getResult();

        return $query;
    }
}
