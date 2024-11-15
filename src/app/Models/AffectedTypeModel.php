<?php

namespace App\Models;

use App\Models\BaseModel;

class AffectedTypeModel extends BaseModel
{
    public function getKey(): array
    {
        $query = <<<QUERY
                SELECT affectedtype.affectedtypeshort AS keyshort,
                    CASE
                        WHEN left(affectedtype.affectedtypeshort, 1) IN ('*', '~') THEN substring(affectedtype.affectedtypeshort, 2) || left(affectedtype.affectedtypeshort, 1)
                        ELSE affectedtype.affectedtypeshort
                    END AS keysort,
                affectedtype.affectedtypelong AS keylong
                FROM geohistory.affectedtype
                ORDER BY 2, 1
            QUERY;

        $query = $this->db->query($query);

        return $this->getObject($query);
    }
}
