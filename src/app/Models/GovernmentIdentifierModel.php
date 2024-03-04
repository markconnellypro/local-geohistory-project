<?php

namespace App\Models;

use CodeIgniter\Model;

class GovernmentIdentifierModel extends Model
{
    // extra.ci_model_governmentidentifier_detail(text, text, text)

    public function getDetail($type, $id): array
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
            GROUP BY 1, 2, 3, 4;
        QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
            $type,
            strtolower($id),
        ])->getResult();

        return $query;
    }

    // extra.ci_model_government_identifier(integer, character varying, character varying)

    // FUNCTION: extra.governmentlong
    // VIEW: extra.governmentsubstitutecache

    public function getByGovernment($id, $state): array
    {
        $query = <<<QUERY
            SELECT DISTINCT governmentidentifiertype.governmentidentifiertypetype,
                governmentidentifiertype.governmentidentifiertypeslug,
                governmentidentifiertype.governmentidentifiertypeshort,
                governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier AS governmentidentifier,
                governmentidentifier.governmentidentifierstatus,
                replace(replace(governmentidentifiertype.governmentidentifiertypeurl, '<Identifier>', governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier), '<Language>', ?) AS governmentidentifiertypeurl,
                extra.governmentlong(governmentidentifier.government, ?) AS governmentlong
            FROM geohistory.governmentidentifier
                JOIN geohistory.governmentidentifiertype
                ON governmentidentifier.governmentidentifiertype = governmentidentifiertype.governmentidentifiertypeid
                JOIN extra.governmentsubstitutecache
                ON governmentidentifier.government = governmentsubstitutecache.governmentid
                AND governmentsubstitutecache.governmentsubstitute = ?
        QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $id,
        ])->getResult();

        return $query;
    }

    public function getCensus($ids): array
    {
        return [];
    }

    public function getUsgs($ids): array
    {
        return [];
    }

    // extra.ci_model_governmentidentifier_related(integer[], integer[], text)

    public function getRelated($governments, $governmentidentifierids): array
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
                AND governmentidentifier.governmentidentifierid <> ALL (?);
        QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
            $governments,
            $governmentidentifierids,
        ])->getResult();

        return $query;
    }

    // extra.ci_model_search_governmentidentifier_identifier(character varying, character varying, character varying)

    // VIEW: extra.governmentrelationcache

    public function getSearchByIdentifier($parameters): array
    {
        $type = $parameters[0];
        $identifier = $parameters[1];
        $state = $parameters[2];

        $query = <<<QUERY
            SELECT DISTINCT governmentidentifiertype.governmentidentifiertypetype,
                governmentidentifiertype.governmentidentifiertypeslug,
                governmentidentifiertype.governmentidentifiertypeshort,
                governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier AS governmentidentifier,
                replace(governmentidentifiertype.governmentidentifiertypeurl, '<Identifier>', governmentidentifier.governmentidentifierprefix || governmentidentifiertype.governmentidentifiertypeprefixdelimiter || governmentidentifier.governmentidentifier) AS governmentidentifiertypeurl
            FROM geohistory.governmentidentifier
            JOIN geohistory.governmentidentifiertype
                ON governmentidentifier.governmentidentifiertype = governmentidentifiertype.governmentidentifiertypeid
            JOIN extra.governmentrelationcache
                ON governmentidentifier.government = governmentrelationcache.governmentid
                AND governmentrelationcache.governmentrelationstate = ?
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
            strtoupper($state),
            $type,
            strtolower($identifier),
            strtolower($identifier),
            strtolower($identifier),
            (int) $identifier,
            (int) $identifier,
        ])->getResult();

        return $query;
    }
}
