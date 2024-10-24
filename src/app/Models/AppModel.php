<?php

namespace App\Models;

use App\Models\BaseModel;
use stdClass;

class AppModel extends BaseModel
{
    // extra.ci_model_lastrefresh()

    // FUNCTION: extra.fulldate

    public function getLastUpdated(): array
    {
        $query = <<<QUERY
            SELECT extra.fulldate(lastrefreshdate::text) AS fulldate,
                to_char(lastrefreshdate, 'J') AS sortdate,
                to_char(lastrefreshdate, 'Mon FMDD, YYYY') AS sortdatetext
            FROM extra.lastrefresh;
        QUERY;

        $query = $this->db->query($query);

        $query = $this->getObject($query);

        if (count($query) > 1) {
            return [];
        }

        return $query;
    }
}
