<?php

namespace App\Models;

use CodeIgniter\Model;

class FilingModel extends Model
{
    // extra.ci_model_adjudication_filing(integer, boolean)

    // FUNCTION: extra.shortdate

    public function getByAdjudication(int $id): array
    {
        $query = <<<QUERY
            SELECT filingtype.filingtypelong,
                filing.filingspecific,
                extra.shortdate(filing.filingdate) AS filingdate,
                filing.filingdate AS filingdatesort,
                extra.shortdate(filing.filingfiled) AS filingfiled,
                filing.filingfiled AS filingfiledsort,
                extra.shortdate(filing.filingother) AS filingother,
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

        return $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            $id,
        ])->getResult();
    }
}
