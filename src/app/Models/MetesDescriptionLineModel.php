<?php

namespace App\Models;

use App\Models\BaseModel;

class MetesDescriptionLineModel extends BaseModel
{
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

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getGeometryByEvent(int $id): array
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
