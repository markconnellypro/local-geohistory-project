<?php

namespace App\Models;

use CodeIgniter\Model;

class CurrentGovernmentModel extends Model
{
    // extra.ci_model_event_currentgovernment(integer, character varying, character varying)

    // FUNCTION: extra.governmentabbreviation
    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentshort
    // FUNCTION: extra.governmentstatelink

    public function getByEvent($id, $state)
    {
        $query = <<<QUERY
            SELECT extra.governmentstatelink(currentgovernment.governmentsubmunicipality, ?, ?) AS governmentsubmunicipality,
                extra.governmentlong(currentgovernment.governmentsubmunicipality, ?) AS governmentsubmunicipalitylong,
                extra.governmentstatelink(currentgovernment.governmentmunicipality, ?, ?) AS governmentmunicipality,
                extra.governmentlong(currentgovernment.governmentmunicipality, ?) AS governmentmunicipalitylong,
                extra.governmentstatelink(currentgovernment.governmentcounty, ?, ?) AS governmentcounty,
                extra.governmentshort(currentgovernment.governmentcounty, ?) AS governmentcountyshort,
                extra.governmentstatelink(currentgovernment.governmentstate, ?, ?) AS governmentstate,
                extra.governmentabbreviation(currentgovernment.governmentstate) AS governmentstateabbreviation
            FROM geohistory.currentgovernment
            WHERE currentgovernment.event = ?
            ORDER BY 8, 6, 4, 2
        QUERY;

        $query = $this->db->query($query, [
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $state,
            \Config\Services::request()->getLocale(),
            $id,
        ])->getResult();

        return $query ?? [];
    }
}