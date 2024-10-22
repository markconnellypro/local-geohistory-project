<?php

namespace App\Models;

use App\Models\BaseModel;

class SourceModel extends BaseModel
{
    public function getByGovernment(int $id): array
    {
        return [];
    }

    // extra.ci_model_search_form_reporter(character varying)

    // VIEW: extra.adjudicationsourcecitationsourcegovernmentcache

    public function getSearch(): array
    {
        $query = <<<QUERY
            SELECT DISTINCT adjudicationsourcecitationsourcegovernmentcache.sourceshort
                FROM extra.adjudicationsourcecitationsourcegovernmentcache
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query);

        return $this->getArray($query);
    }
}
