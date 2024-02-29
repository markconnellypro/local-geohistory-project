<?php

namespace App\Models;

use CodeIgniter\Model;

class MetesDescriptionLineModel extends Model
{
    public function getGeometryByGovernment($id)
    {
        return [];
    }

    // extra.ci_model_metes_row(integer)

    public function getByMetesDescription($id)
    {
        $query = <<<QUERY
            SELECT metesdescriptionline.metesdescriptionline,
                metesdescriptionline.thencepoint,
                metesdescriptionline.northsouth,
                metesdescriptionline.degree,
                metesdescriptionline.eastwest,
                metesdescriptionline.foot,
                metesdescriptionline.topoint
            FROM geohistory.metesdescriptionline
            WHERE metesdescriptionline.metesdescription = ?
            ORDER BY metesdescriptionline.metesdescriptionline
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        return $query ?? [];
    }

    public function getGeometryByMetesDescription($id)
    {
        return [];
    }
}