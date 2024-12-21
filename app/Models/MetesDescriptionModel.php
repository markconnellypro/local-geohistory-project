<?php

namespace App\Models;

use App\Models\BaseModel;

class MetesDescriptionModel extends BaseModel
{
    public function getDetail(int|string $id): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = <<<QUERY
                WITH metesdescriptionpart AS (
                    SELECT DISTINCT metesdescription.metesdescriptionid,
                        metesdescription.metesdescriptiontype,
                        metesdescription.metesdescriptionsource,
                        metesdescription.metesdescriptionbeginningpoint,
                        metesdescription.metesdescriptionlong,
                        metesdescription.metesdescriptionacres,
                            CASE
                                WHEN metesdescription.metesdescriptionlongitude = 0::numeric AND metesdescription.metesdescriptionlatitude = 0::numeric THEN false
                                ELSE true
                            END AS hasbeginpoint,
                        event.eventslug,
                        eventtype.eventtypeshort,
                        event.eventlong,
                        event.eventyear,
                        eventgranted.eventgrantedshort AS eventgranted,
                        event.eventeffectivetext AS eventeffective,
                        event.eventsort,
                        event.eventid
                    FROM geohistory.metesdescription
                    JOIN geohistory.event
                        ON metesdescription.event = event.eventid
                    JOIN geohistory.eventgranted
                        ON event.eventgranted = eventgranted.eventgrantedid
                    JOIN geohistory.eventtype
                        ON event.eventtype = eventtype.eventtypeid
                    WHERE metesdescription.metesdescriptionid = ?
                )
                SELECT metesdescriptionpart.*,
                    public.st_asgeojson(public.st_buffer(public.st_collect(governmentshape.governmentshapegeometry), 0)) AS geometry,
                    lower(array_to_string(array_agg(DISTINCT government.governmentabbreviation ORDER BY government.governmentabbreviation), ',')) AS jurisdictions
                FROM metesdescriptionpart
                LEFT JOIN gis.metesdescriptiongis
                    ON metesdescriptionpart.metesdescriptionid = metesdescriptiongis.metesdescription
                LEFT JOIN gis.governmentshape
                    ON metesdescriptiongis.governmentshape = governmentshape.governmentshapeid
                LEFT JOIN geohistory.government
                    ON governmentshape.governmentstate = government.governmentid
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getByEvent(int $id): array
    {
        $query = <<<QUERY
                SELECT metesdescription.metesdescriptionslug,
                    metesdescription.metesdescriptiontype,
                    metesdescription.metesdescriptionsource,
                    metesdescription.metesdescriptionbeginningpoint,
                    metesdescription.metesdescriptionlong,
                    metesdescription.metesdescriptionacres
                FROM geohistory.metesdescription
                WHERE metesdescription.event = ?
                ORDER BY 5
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getByGovernmentShape(int $id): array
    {
        $query = <<<QUERY
                SELECT metesdescription.metesdescriptionslug,
                    metesdescription.metesdescriptiontype,
                    metesdescription.metesdescriptionsource,
                    metesdescription.metesdescriptionbeginningpoint,
                    metesdescription.metesdescriptionlong,
                    metesdescription.metesdescriptionacres,
                    metesdescription.event,
                    event.eventslug
                FROM geohistory.metesdescription
                JOIN gis.metesdescriptiongis
                    ON metesdescription.metesdescriptionid = metesdescriptiongis.metesdescription
                JOIN geohistory.event
                    ON metesdescription.event = event.eventid
                JOIN geohistory.eventgranted
                    ON event.eventgranted = eventgranted.eventgrantedid
                    AND eventgranted.eventgrantedsuccess
                WHERE governmentshape = ?
                ORDER BY 5
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        $query = $this->getObject($query);

        $output = [
            'event' => [],
            'query' => $query,
        ];

        foreach ($query as $row) {
            $output['event'][] = $row->event;
        }

        return $output;
    }

    private function getSlugId(string $id): int
    {
        $query = <<<QUERY
                SELECT metesdescription.metesdescriptionid AS id
                    FROM geohistory.metesdescription
                WHERE metesdescription.metesdescriptionslug = ?
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        $query = $this->getObject($query);

        $id = -1;

        if (count($query) === 1) {
            $id = $query[0]->id;
        }

        return $id;
    }
}
