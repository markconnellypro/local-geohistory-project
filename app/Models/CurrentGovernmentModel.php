<?php

namespace App\Models;

use App\Models\BaseModel;

class CurrentGovernmentModel extends BaseModel
{
    public function getByEvent(int $id): array
    {
        $query = <<<QUERY
                SELECT COALESCE(governmentsubmunicipality.governmentslugsubstitute, '') AS governmentsubmunicipality,
                    COALESCE(governmentsubmunicipality.governmentlong, '') AS governmentsubmunicipalitylong,
                    governmentmunicipality.governmentslugsubstitute AS governmentmunicipality,
                    governmentmunicipality.governmentlong AS governmentmunicipalitylong,
                    governmentcounty.governmentslugsubstitute AS governmentcounty,
                    governmentcounty.governmentshort AS governmentcountyshort,
                    governmentstate.governmentslugsubstitute AS governmentstate,
                    governmentstate.governmentabbreviation AS governmentstateabbreviation
                FROM geohistory.currentgovernment
                JOIN geohistory.government governmentmunicipality
                    ON currentgovernment.governmentmunicipality = governmentmunicipality.governmentid
                JOIN geohistory.government governmentcounty
                    ON currentgovernment.governmentcounty = governmentcounty.governmentid
                JOIN geohistory.government governmentstate
                    ON currentgovernment.governmentstate = governmentstate.governmentid
                LEFT JOIN geohistory.government governmentsubmunicipality
                    ON currentgovernment.governmentsubmunicipality = governmentsubmunicipality.governmentid
                WHERE currentgovernment.event = ?
                ORDER BY 8, 6, 4, 2
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }
}
