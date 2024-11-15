<?php

namespace App\Models;

use App\Models\BaseModel;

class GovernmentIdentifierTypeModel extends BaseModel
{
    public function getSearch(): array
    {
        $query = <<<QUERY
                SELECT DISTINCT split_part(governmentidentifiertype.governmentidentifiertypeshort, ':', 1) AS governmentidentifiertypeshort,
                    governmentidentifiertype.governmentidentifiertypeslug
                FROM geohistory.governmentidentifiertype
                JOIN geohistory.governmentidentifier
                    ON governmentidentifiertype.governmentidentifiertypeid = governmentidentifier.governmentidentifiertype
                ORDER BY 1
            QUERY;

        $query = $this->db->query($query);

        return $this->getArray($query);
    }
}
