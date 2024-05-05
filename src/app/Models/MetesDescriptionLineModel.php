<?php

namespace App\Models;

use CodeIgniter\Model;

class MetesDescriptionLineModel extends Model
{
    // extra.ci_model_metes_row(integer)

    public function getByMetesDescription(int $id): array
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

        return $this->db->query($query, [
            $id,
        ])->getResult();
    }

    public function getGeometryByEvent(int $id, string $state): array
    {
        return [];
    }

    public function getGeometryByGovernment(int $id): array
    {
        return [];
    }

    public function getGeometryByMetesDescription(int $id): array
    {
        return [];
    }
}
