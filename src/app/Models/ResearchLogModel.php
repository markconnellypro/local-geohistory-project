<?php

namespace App\Models;

use App\Models\BaseModel;

class ResearchLogModel extends BaseModel
{
    // extra.ci_model_government_researchlog(integer, character varying, boolean)

    // FUNCTION: extra.shortdate
    // VIEW: extra.governmentsubstitutecache

    public function getByGovernment(int $id): array
    {
        $query = <<<QUERY
            SELECT researchlog.researchlogid,
                researchlogtype.researchlogtypelong || CASE
                    WHEN ? AND researchlogtype.researchlogtypelongpart <> '' THEN ' - ' || researchlogtype.researchlogtypelongpart
                    ELSE ''
                END AS researchlogtypelong,
                CASE
                    WHEN (? OR researchlogtype.researchlogtypeisspecificdate) THEN extra.shortdate(researchlog.researchlogdate)
                    ELSE ''
                END AS researchlogdate,
                researchlog.researchlogdate AS researchlogdatesort,
                researchlog.researchlogvolume,
                researchlog.researchlogyear,
                researchlog.researchlogismissing,
                CASE
                    WHEN ? THEN researchlog.researchlognotes
                    ELSE ''
                END AS researchlognotes,
                government.governmentlong
            FROM geohistory.researchlog
            JOIN geohistory.researchlogtype
                ON researchlog.researchlogtype = researchlogtype.researchlogtypeid
            JOIN geohistory.government
                ON researchlog.government = government.governmentid
            JOIN extra.governmentsubstitutecache
                ON researchlog.government = governmentsubstitutecache.governmentid
                AND governmentsubstitutecache.governmentsubstitute = ?
            WHERE (
                ?
                OR (researchlogtype.researchlogtypeisrecord AND NOT researchlog.researchlogismissing)
            )
            ORDER BY researchlogtype.researchlogtypelong, researchlog.researchlogfrom, researchlogdatesort    
        QUERY;

        $query = $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            \App\Controllers\BaseController::isLive(),
            \App\Controllers\BaseController::isLive(),
            $id,
            \App\Controllers\BaseController::isLive(),
        ]);

        return $this->getObject($query);
    }
}
