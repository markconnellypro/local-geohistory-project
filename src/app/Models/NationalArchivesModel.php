<?php

namespace App\Models;

use App\Models\BaseModel;

class NationalArchivesModel extends BaseModel
{
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
                    government.governmentlong
                FROM geohistory.nationalarchives
                JOIN geohistory.source
                    ON nationalarchives.source = source.sourceid
                JOIN geohistory.government
                    ON nationalarchives.government = government.governmentid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentid = ?
                UNION DISTINCT
                SELECT DISTINCT source.sourceabbreviation,
                    censusmap.censusmapyear::character varying AS nationalarchivesset,
                    censusmap.censusmapgovernmentname AS nationalarchivesgovernment,
                    NULL::integer AS nationalarchivesunit,
                    NULL::integer AS nationalarchivesunitfrom,
                    NULL::integer AS nationalarchivesunitto,
                    '' AS url,
                    censusmap.censusmapexamined AS nationalarchivesexamined,
                    government.governmentlong
                FROM geohistory.censusmap
                JOIN geohistory.source
                    ON source.sourceshort = 'Cns.Mp.'
                JOIN geohistory.government
                    ON censusmap.government = government.governmentid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentid = ?
                LEFT JOIN geohistory.nationalarchives
                    ON censusmap.government = nationalarchives.government
                    AND source.sourceid = nationalarchives.source
                    AND censusmap.censusmapyear::character varying = nationalarchives.nationalarchivesset
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
