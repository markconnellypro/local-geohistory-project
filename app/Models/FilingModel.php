<?php

namespace App\Models;

use App\Models\BaseModel;

class FilingModel extends BaseModel
{
    public function getByAdjudication(int $id): array
    {
        $query = <<<QUERY
                SELECT filingtype.filingtypelong,
                    filing.filingspecific,
                    calendar.historicdatetextformat(filing.filingdate::calendar.historicdate, 'short', ?) AS filingdate,
                    filing.filingdate AS filingdatesort,
                    calendar.historicdatetextformat(filing.filingfiled::calendar.historicdate, 'short', ?) AS filingfiled,
                    filing.filingfiled AS filingfiledsort,
                    calendar.historicdatetextformat(filing.filingother::calendar.historicdate, 'short', ?) AS filingother,
                    filing.filingother AS filingothersort,
                    filing.filingothertype,
                    filing.filingnotes,
                    filing.filingnotpresent <> '' AS filingnotpresent
                FROM geohistory.filing,
                    geohistory.filingtype
                WHERE filing.filingtype = filingtype.filingtypeid
                    AND (? OR filing.filingnotpresent = '')
                    AND filing.adjudication = ?
                ORDER BY filing.filingid
            QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
            \Config\Services::request()->getLocale(),
            \Config\Services::request()->getLocale(),
            \App\Controllers\BaseController::isLive(),
            $id,
        ]);

        return $this->getObject($query);
    }
}
