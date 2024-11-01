<?php

namespace App\Models;

use App\Models\BaseModel;

class NationalArchivesModel extends BaseModel
{
    // extra.ci_model_government_nationalarchives(integer, character varying)

    // FUNCTION: extra.governmentlong
    // VIEW: extra.governmentsubstitutecache

    public function getByGovernment(int $id): array
    {
        $query = <<<QUERY
            SELECT DISTINCT source.sourceabbreviation,
                nationalarchives.nationalarchivesset,
                nationalarchives.nationalarchivesgovernmentname || ' ' || nationalarchives.nationalarchivesgovernmenttype AS nationalarchivesgovernment,
                nationalarchives.nationalarchivesunit,
                nationalarchives.nationalarchivesunitfrom,
                nationalarchives.nationalarchivesunitto,
                'https://catalog.archives.gov/id/' || nationalarchives.nationalarchivesunit || '?objectPage=' || nationalarchives.nationalarchivesunitfrom AS url,
                nationalarchives.nationalarchivesexamined,
                extra.governmentlong(nationalarchives.government) AS governmentlong
            FROM geohistory.nationalarchives
            JOIN geohistory.source
                ON nationalarchives.source = source.sourceid
            JOIN extra.governmentsubstitutecache
                ON nationalarchives.government = governmentsubstitutecache.governmentid
                AND governmentsubstitutecache.governmentsubstitute = ?
            UNION DISTINCT
            SELECT DISTINCT source.sourceabbreviation,
                censusmap.censusmapyear::character varying AS nationalarchivesset,
                censusmap.censusmapgovernmentname AS nationalarchivesgovernment,
                NULL::integer AS nationalarchivesunit,
                NULL::integer AS nationalarchivesunitfrom,
                NULL::integer AS nationalarchivesunitto,
                '' AS url,
                censusmap.censusmapexamined AS nationalarchivesexamined,
                extra.governmentlong(censusmap.government) AS governmentlong
            FROM geohistory.censusmap
            JOIN geohistory.source
                ON source.sourceshort = 'Cns.Mp.'
            LEFT JOIN geohistory.nationalarchives
                ON censusmap.government = nationalarchives.government
                AND source.sourceid = nationalarchives.source
                AND censusmap.censusmapyear::character varying = nationalarchives.nationalarchivesset
            JOIN extra.governmentsubstitutecache
                ON censusmap.government = governmentsubstitutecache.governmentid
                AND governmentsubstitutecache.governmentsubstitute = ?
            WHERE nationalarchives.nationalarchivesid IS NULL
            ORDER BY 1, 3, 4
        QUERY;

        $query = $this->db->query($query, [
            $id,
            $id,
        ]);

        return $this->getObject($query);
    }
}
