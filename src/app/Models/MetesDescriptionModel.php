<?php

namespace App\Models;

use CodeIgniter\Model;

class MetesDescriptionModel extends Model
{
    // extra.ci_model_metes_detail(integer, character varying)
    // extra.ci_model_metes_detail(text, character varying)

    // VIEW: extra.metesdescriptionextracache

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
                    metesdescriptionextracache.metesdescriptionlong,
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
                LEFT JOIN extra.metesdescriptionextracache
                    ON metesdescription.metesdescriptionid = metesdescriptionextracache.metesdescriptionid
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

        return $this->db->query($query, [
            $id,
        ])->getResult();
    }

    // extra.ci_model_event_metesdescription(integer)

    // VIEW: extra.metesdescriptionextracache

    public function getByEvent(int $id): array
    {
        $query = <<<QUERY
            SELECT metesdescriptionextracache.metesdescriptionslug,
                metesdescription.metesdescriptiontype,
                metesdescription.metesdescriptionsource,
                metesdescription.metesdescriptionbeginningpoint,
                metesdescriptionextracache.metesdescriptionlong,
                metesdescription.metesdescriptionacres
            FROM geohistory.metesdescription
            JOIN extra.metesdescriptionextracache
                ON metesdescription.metesdescriptionid = metesdescriptionextracache.metesdescriptionid
            WHERE metesdescription.event = ?
            ORDER BY 5;
        QUERY;

        return $this->db->query($query, [
            $id,
        ])->getResult();
    }

    // extra.ci_model_area_metesdescription(integer)

    // VIEW: extra.metesdescriptionextracache

    public function getByGovernmentShape(int $id): array
    {
        $query = <<<QUERY
            SELECT metesdescriptionextracache.metesdescriptionslug,
                metesdescription.metesdescriptiontype,
                metesdescription.metesdescriptionsource,
                metesdescription.metesdescriptionbeginningpoint,
                metesdescriptionextracache.metesdescriptionlong,
                metesdescription.metesdescriptionacres,
                metesdescription.event,
                event.eventslug
            FROM geohistory.metesdescription
            JOIN extra.metesdescriptionextracache
                ON metesdescription.metesdescriptionid = metesdescriptionextracache.metesdescriptionid
            JOIN gis.metesdescriptiongis
                ON metesdescription.metesdescriptionid = metesdescriptiongis.metesdescription
            JOIN geohistory.event
                ON metesdescription.event = event.eventid
            WHERE governmentshape = ?
            ORDER BY 5
        QUERY;

        return $this->db->query($query, [
            $id,
        ])->getResult();
    }

    // extra.metesdescriptionslugid(text)

    // VIEW: extra.metesdescriptionextracache

    private function getSlugId(string $id): int
    {
        $query = <<<QUERY
            SELECT metesdescriptionextracache.metesdescriptionid AS id
                FROM extra.metesdescriptionextracache
            WHERE metesdescriptionextracache.metesdescriptionslug = ?
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        $id = -1;

        if (count($query) === 1) {
            $id = $query[0]->id;
        }

        return $id;
    }
}
