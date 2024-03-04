<?php

namespace App\Models;

use CodeIgniter\Model;

class AffectedTypeModel extends Model
{
    // extra.ci_model_key_affectedtype()

    public function getKey()
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

        $query = $this->db->query($query)->getResult();

        return $query ?? [];
    }
}
