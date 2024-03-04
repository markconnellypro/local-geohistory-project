<?php

namespace App\Models;

use CodeIgniter\Model;

class PlssModel extends Model
{
    // extra.ci_model_event_plss(integer)

    // FUNCTION: extra.plsstownshiplong

    public function getByEvent($id)
    {
        $query = <<<QUERY
            -- Need to add support for second division and special survey
            SELECT extra.plsstownshiplong(plss.plsstownship) AS plsstownship,
                plssfirstdivision.plssfirstdivisionlong ||
                    CASE
                        WHEN plss.plssfirstdivisionnumber = '0' THEN ''
                        ELSE ' ' || plss.plssfirstdivisionnumber
                    END ||
                    CASE
                        WHEN plss.plssfirstdivisionduplicate = '0' THEN ''
                        ELSE ' ' || plss.plssfirstdivisionduplicate
                    END AS plssfirstdivision,
                replace(plss.plssfirstdivisionpart, '|', ', ') AS plssfirstdivisionpart,
                plss.plssrelationship
                FROM geohistory.plss
                    LEFT JOIN geohistory.plssfirstdivision
                    ON plss.plssfirstdivision = plssfirstdivision.plssfirstdivisionid
                WHERE event = ?
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        return $query ?? [];
    }
}
