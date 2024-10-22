<?php

namespace App\Models;

use App\Models\BaseModel;

class CurrentGovernmentModel extends BaseModel
{
    // extra.ci_model_event_currentgovernment(integer, character varying, character varying)

    // FUNCTION: extra.governmentabbreviation
    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentshort
    // FUNCTION: extra.governmentslug

    public function getByEvent(int $id): array
    {
        $query = <<<QUERY
            SELECT COALESCE(extra.governmentslug(currentgovernment.governmentsubmunicipality), '') AS governmentsubmunicipality,
                COALESCE(extra.governmentlong(currentgovernment.governmentsubmunicipality, ''), '') AS governmentsubmunicipalitylong,
                extra.governmentslug(currentgovernment.governmentmunicipality) AS governmentmunicipality,
                extra.governmentlong(currentgovernment.governmentmunicipality, '') AS governmentmunicipalitylong,
                extra.governmentslug(currentgovernment.governmentcounty) AS governmentcounty,
                extra.governmentshort(currentgovernment.governmentcounty, '') AS governmentcountyshort,
                extra.governmentslug(currentgovernment.governmentstate) AS governmentstate,
                extra.governmentabbreviation(currentgovernment.governmentstate) AS governmentstateabbreviation
            FROM geohistory.currentgovernment
            WHERE currentgovernment.event = ?
            ORDER BY 8, 6, 4, 2
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }
}
