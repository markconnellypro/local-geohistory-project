<?php

namespace App\Models;

use CodeIgniter\Model;

class DocumentationModel extends Model
{
    // extra.ci_model_about(character varying)

    public function getAboutDetail($state)
    {
        $query = <<<QUERY
            SELECT documentation.documentationshort AS keyshort,
                lower(replace(documentation.documentationshort, ' ', '')) AS keysort,
                documentation.documentationlong AS keylong
            FROM geohistory.documentation
            WHERE documentation.documentationtype = ?
            ORDER BY 2, 1
        QUERY;

        $query = $this->db->query($query, [
            'about_' . $state,
        ])->getResult();

        return $query ?? [];
    }

    public function getKey($type)
    {
        $query = <<<QUERY
            SELECT documentation.documentationshort AS keyshort,
                documentation.documentationshort AS keysort,
                documentation.documentationlong AS keylong,
                documentation.documentationcolor AS keycolor
            FROM geohistory.documentation
            WHERE documentation.documentationtype = ?
            ORDER BY 2, 1
        QUERY;

        $query = $this->db->query($query, [
            $type,
        ])->getResult();

        return $query ?? [];
    }
}