<?php

namespace App\Models;

use CodeIgniter\Model;

class SourceModel extends Model
{
    public function getByGovernment($id): array
    {
        return [];
    }

    // extra.ci_model_search_form_reporter(character varying)

    // VIEW: extra.adjudicationsourcecitationsourcegovernmentcache

    public function getSearch($state): array
    {
        $query = <<<QUERY
            SELECT DISTINCT adjudicationsourcecitationsourcegovernmentcache.sourceshort
                FROM extra.adjudicationsourcecitationsourcegovernmentcache
            WHERE (adjudicationsourcecitationsourcegovernmentcache.governmentrelationstate = ?
                OR adjudicationsourcecitationsourcegovernmentcache.governmentrelationstate IS NULL)
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            strtoupper($state),
        ])->getResultArray();

        return $query;
    }
}
