<?php

namespace App\Models;

use CodeIgniter\Model;

class GovernmentIdentifierTypeModel extends Model
{
    // extra.ci_model_search_form_governmentidentifiertype(character varying)

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

        return $this->db->query($query)->getResultArray();
    }
}
