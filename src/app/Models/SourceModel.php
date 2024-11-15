<?php

namespace App\Models;

use App\Models\BaseModel;

class SourceModel extends BaseModel
{
    public function getByGovernment(int $id): array
    {
        return [];
    }

    public function getSearch(): array
    {
        $query = <<<QUERY
                SELECT DISTINCT source.sourceshort
                FROM geohistory.source
                WHERE source.sourcetype = 'court reporters'
                ORDER BY 1
            QUERY;

        $query = $this->db->query($query);

        return $this->getArray($query);
    }
}
