<?php

namespace App\Models;

use CodeIgniter\Model;

class AppModel extends Model
{
    // extra.ci_model_lastrefresh()

    // FUNCTION: extra.fulldate

    public function getLastUpdated()
    {
        $query = <<<QUERY
            SELECT extra.fulldate(lastrefreshdate::text) AS fulldate,
                to_char(lastrefreshdate, 'J') AS sortdate,
                to_char(lastrefreshdate, 'Mon FMDD, YYYY') AS sortdatetext
            FROM extra.lastrefresh;
        QUERY;

        $query = $this->db->query($query)->getResult();

        if (count($query) == 1) {
            return $query[0];
        }

        return [];
    }
}
