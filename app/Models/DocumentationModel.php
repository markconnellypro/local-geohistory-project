<?php

namespace App\Models;

use App\Models\BaseModel;

class DocumentationModel extends BaseModel
{
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
                    CASE
                        WHEN documentation.documentationshort = 'Text' THEN ''
                        ELSE documentation.documentationshort
                    END AS keysort,
                    documentation.documentationlong AS keylong,
                    documentation.documentationcolor AS keycolor
                FROM geohistory.documentation
                WHERE documentation.documentationtype = ?
                ORDER BY 2, 1
            QUERY;

        $query = $this->db->query($query, [
            $type,
        ]);

        $query = $this->getObject($query);

        if ($query[0]->keysort === '') {
            $query['Text'] = $query[0];
            unset($query[0]);
        }

        return $query;
    }

    public function getStatus(): array
    {
        $query = <<<QUERY
                SELECT upper(split_part(documentation.documentationtype, '_', 2)) AS jurisdiction,
                    upper(replace(documentation.documentationshort, ' ', '')) AS documentationshort,
                    documentation.documentationlong
                FROM geohistory.documentation
                WHERE documentation.documentationtype LIKE 'status_%'
                ORDER BY 1, 2
            QUERY;

        $query = $this->db->query($query);

        $query = $this->getObject($query);

        $result = [];

        foreach ($query as $row) {
            if ($row->documentationshort === 'TASK') {
                $result[$row->jurisdiction]['TASK'][] = $row->documentationlong;
            } else {
                $result[$row->jurisdiction][$row->documentationshort] = $row->documentationlong;
            }
        }

        return $result;
    }

    public function getWelcome(): string
    {
        $query = <<<QUERY
                SELECT documentation.documentationlong
                FROM geohistory.documentation
                WHERE documentation.documentationtype = 'welcome'
                ORDER BY 1
                LIMIT 1
            QUERY;

        $query = $this->db->query($query);

        $query = $this->getObject($query);

        if (count($query) === 1) {
            return $query[0]->documentationlong;
        }

        return '';
    }
}
