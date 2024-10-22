<?php

namespace App\Models;

use App\Models\BaseModel;

class DocumentationModel extends BaseModel
{
    // extra.ci_model_about(character varying)

    public function getAboutDetail(string $jurisdiction): array
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
            'about_' . $jurisdiction,
        ]);

        return $this->getObject($query);
    }

    public function getAboutJurisdiction(): array
    {
        $query = <<<QUERY
            SELECT DISTINCT government.governmentshort,
                lower(government.governmentabbreviation) AS governmentabbreviation
            FROM geohistory.documentation
            JOIN geohistory.government
                ON upper(split_part(documentation.documentationtype, '_', 2)) = government.governmentabbreviation
                AND government.governmentstatus = ''
            WHERE documentation.documentationtype ~ '^about_[a-z]+'
            ORDER BY 2, 1
        QUERY;

        $query = $this->db->query($query);

        return $this->getObject($query);
    }

    public function getDisclaimer(): array
    {
        $query = <<<QUERY
            SELECT documentation.documentationid,
                lower(replace(documentation.documentationshort, ' ', '')) AS documentationsort,
                documentation.documentationshort,
                documentation.documentationlong
            FROM geohistory.documentation
            WHERE documentation.documentationtype = 'disclaimer'
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query);

        return $this->getObject($query);
    }

    public function getKey(string $type): array
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
        ]);

        return $this->getObject($query);
    }
}
