<?php

namespace App\Models;

use CodeIgniter\Model;

class GovernmentIdentifierModel extends Model
{
    // extra.ci_model_search_governmentidentifier_identifier(character varying, character varying, character varying)

    // VIEW: extra.governmentrelationcache

    public function getSearchByIdentifier($parameters)
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
            intval($identifier),
            intval($identifier),
        ])->getResult();

        return $query ?? [];
    }
}