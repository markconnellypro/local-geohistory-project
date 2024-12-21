<?php

namespace App\Models;

use App\Models\BaseModel;

class GovernmentIdentifierModel extends BaseModel
{
    public function getDetail(string $type, string $id): array
    {
        $query = <<<QUERY
                SELECT governmentidentifiertype.governmentidentifiertypetype,
                    governmentidentifiertype.governmentidentifiertypeshort,
                    governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier AS governmentidentifier,
                    replace(replace(governmentidentifiertype.governmentidentifiertypeurl, '<Identifier>', governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier), '<Language>', ?) AS governmentidentifiertypeurl,
                    array_agg(DISTINCT governmentidentifier.governmentidentifierid ORDER BY governmentidentifier.governmentidentifierid) AS governmentidentifierids,
                    string_to_array(array_to_string(array_agg(DISTINCT governmentidentifier.government ORDER BY governmentidentifier.government), '|'), '|') AS governments
                FROM geohistory.governmentidentifier
                    JOIN geohistory.governmentidentifiertype
                    ON governmentidentifier.governmentidentifiertype = governmentidentifiertype.governmentidentifiertypeid
                    AND governmentidentifiertype.governmentidentifiertypeslug = ?
                WHERE lower(governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier) = ?
                GROUP BY 1, 2, 3, 4
            QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
            $type,
            strtolower($id),
        ]);

        return $this->getObject($query);
    }

    public function getByGovernment(int $id): array
    {
        $query = <<<QUERY
                SELECT DISTINCT governmentidentifiertype.governmentidentifiertypetype,
                    governmentidentifiertype.governmentidentifiertypeslug,
                    governmentidentifiertype.governmentidentifiertypeshort,
                    governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier AS governmentidentifier,
                    governmentidentifier.governmentidentifierstatus,
                    replace(replace(governmentidentifiertype.governmentidentifiertypeurl, '<Identifier>', governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier), '<Language>', ?) AS governmentidentifiertypeurl,
                    government.governmentlong
                FROM geohistory.governmentidentifier
                JOIN geohistory.government
                    ON governmentidentifier.government = government.governmentid
                JOIN geohistory.governmentidentifiertype
                    ON governmentidentifier.governmentidentifiertype = governmentidentifiertype.governmentidentifiertypeid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentid = ?
            QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getCensus(string $ids): array
    {
        return [];
    }

    public function getUsgs(string $ids): array
    {
        return [];
    }

    public function getRelated(string $governments, string $governmentidentifierids): array
    {
        $query = <<<QUERY
                SELECT DISTINCT governmentidentifiertype.governmentidentifiertypetype,
                    governmentidentifiertype.governmentidentifiertypeslug,
                    governmentidentifiertype.governmentidentifiertypeshort,
                    governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier AS governmentidentifier,
                    replace(replace(governmentidentifiertype.governmentidentifiertypeurl, '<Identifier>', governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier), '<Language>', ?) AS governmentidentifiertypeurl
                FROM geohistory.governmentidentifier
                    JOIN geohistory.governmentidentifiertype
                    ON governmentidentifier.governmentidentifiertype = governmentidentifiertype.governmentidentifiertypeid
                WHERE governmentidentifier.government = ANY (?)
                    AND governmentidentifier.governmentidentifierid <> ALL (?)
            QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
            $governments,
            $governmentidentifierids,
        ]);

        return $this->getObject($query);
    }

    public function getSearchByIdentifier(array $parameters): array
    {
        $type = $parameters[0];
        $identifier = $parameters[1];

        $query = <<<QUERY
                SELECT DISTINCT governmentidentifiertype.governmentidentifiertypetype,
                    governmentidentifiertype.governmentidentifiertypeslug,
                    governmentidentifiertype.governmentidentifiertypeshort,
                    governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier AS governmentidentifier,
                    replace(governmentidentifiertype.governmentidentifiertypeurl, '<Identifier>', governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier) AS governmentidentifiertypeurl
                FROM geohistory.governmentidentifier
                JOIN geohistory.governmentidentifiertype
                    ON governmentidentifier.governmentidentifiertype = governmentidentifiertype.governmentidentifiertypeid
                    AND governmentidentifiertype.governmentidentifiertypeshort = ?
                WHERE lower(governmentidentifier.governmentidentifier) = ?
                    OR lower(governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier) = ?
                    OR (
                        governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier ~ '^\d+$'
                        AND ? ~ '^\d+$'
                        AND (
                            governmentidentifier.governmentidentifier::integer = ?
                            OR (governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier)::integer = ?
                        )
                    )
            QUERY;

        $query = $this->db->query($query, [
            $type,
            strtolower($identifier),
            strtolower($identifier),
            strtolower($identifier),
            (int) $identifier,
            (int) $identifier,
        ]);

        return $this->getObject($query);
    }
}
