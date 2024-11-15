<?php

namespace App\Models;

use App\Models\BaseModel;

class PlssModel extends BaseModel
{
    public function getByEvent(int $id): array
    {
        $query = <<<QUERY
                -- Need to add support for second division and special survey
                SELECT government.governmentlong AS plsstownship,
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
                JOIN geohistory.government
                    ON plss.plsstownship = government.governmentid
                LEFT JOIN geohistory.plssfirstdivision
                    ON plss.plssfirstdivision = plssfirstdivision.plssfirstdivisionid
                WHERE event = ?
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }
}
