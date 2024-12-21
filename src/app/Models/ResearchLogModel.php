<?php

namespace App\Models;

use App\Models\BaseModel;

class ResearchLogModel extends BaseModel
{
    public function getByGovernment(int $id): array
    {
        $query = <<<QUERY
                SELECT researchlog.researchlogid,
                    researchlogtype.researchlogtypelong || CASE
                        WHEN ? AND researchlogtype.researchlogtypelongpart <> '' THEN ' - ' || researchlogtype.researchlogtypelongpart
                        ELSE ''
                    END AS researchlogtypelong,
                    CASE
                        WHEN (? OR researchlogtype.researchlogtypeisspecificdate) THEN calendar.historicdatetextformat(researchlog.researchlogdate::calendar.historicdate, 'short', ?)
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
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentid = ?
                WHERE (
                    ?
                    OR (researchlogtype.researchlogtypeisrecord AND NOT researchlog.researchlogismissing)
                )
                ORDER BY researchlogtype.researchlogtypelong, researchlog.researchlogfrom, researchlogdatesort
            QUERY;

        $query = $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            \App\Controllers\BaseController::isLive(),
            \Config\Services::request()->getLocale(),
            \App\Controllers\BaseController::isLive(),
            $id,
            \App\Controllers\BaseController::isLive(),
        ]);

        return $this->getObject($query);
    }
}
