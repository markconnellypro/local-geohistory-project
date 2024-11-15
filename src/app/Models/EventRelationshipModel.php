<?php

namespace App\Models;

use App\Models\BaseModel;

class EventRelationshipModel extends BaseModel
{
    public function getKey(): array
    {
        $query = <<<QUERY
                SELECT eventrelationship.eventrelationshipshort AS keyshort,
                    eventrelationship.eventrelationshipshort AS keysort,
                    eventrelationship.eventrelationshiplong AS keylong
                FROM geohistory.eventrelationship
                ORDER BY 2, 1
            QUERY;

        $query = $this->db->query($query);

        return $this->getObject($query);
    }
}
