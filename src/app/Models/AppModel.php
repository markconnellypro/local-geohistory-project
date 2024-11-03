<?php

namespace App\Models;

use App\Models\BaseModel;
use stdClass;

class AppModel extends BaseModel
{
    // extra.ci_model_lastrefresh()

    public function getLastUpdated(): array
    {
        $query = <<<QUERY
            SELECT calendar.historicdatetextformat(lastrefreshdate::calendar.historicdatetext::calendar.historicdate, 'long', ?) AS fulldate,
                to_char(lastrefreshdate, 'J') AS sortdate,
                to_char(lastrefreshdate, 'Mon FMDD, YYYY') AS sortdatetext
            FROM geohistory.lastrefresh
        QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
        ]);

        $query = $this->getObject($query);

        if (count($query) > 1) {
            return [];
        }

        return $query;
    }
}
