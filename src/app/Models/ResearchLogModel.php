<?php

namespace App\Models;

use CodeIgniter\Model;

class ResearchLogModel extends Model
{
    // extra.ci_model_government_researchlog(integer, character varying, boolean)

    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate
    // VIEW: extra.governmentsubstitutecache

    public function getByGovernment($id, $state): array
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
                extra.rangefix(researchlog.researchlogvolumefrom, researchlog.researchlogvolumeto) AS researchlogvolume,
                extra.rangefix(researchlog.researchlogfrom, researchlog.researchlogto) AS researchlogrange,
                researchlog.researchlogismissing,
                CASE
                    WHEN ? THEN researchlog.researchlognotes
                    ELSE ''
                END AS researchlognotes,
                extra.governmentlong(researchlog.government, ?) AS governmentlong
            FROM geohistory.researchlog
            JOIN geohistory.researchlogtype
                ON researchlog.researchlogtype = researchlogtype.researchlogtypeid
            JOIN extra.governmentsubstitutecache
                ON researchlog.government = governmentsubstitutecache.governmentid
                AND governmentsubstitutecache.governmentsubstitute = ?
            WHERE (
                ?
                OR (researchlogtype.researchlogtypeisrecord AND NOT researchlog.researchlogismissing)
            )
            ORDER BY researchlogtype.researchlogtypelong, researchlog.researchlogfrom, researchlogdatesort    
        QUERY;

        return $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            \App\Controllers\BaseController::isLive(),
            \App\Controllers\BaseController::isLive(),
            strtoupper($state),
            $id,
            \App\Controllers\BaseController::isLive(),
        ])->getResult();
    }
}
