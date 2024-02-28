<?php

namespace App\Models;

use CodeIgniter\Model;

class AdjudicationSourceCitationModel extends Model
{
    // 

    public function getByAdjudication($id)
    {
        // extra.ci_model_adjudication_source(integer)
        
        // FUNCTION: extra.rangefix
        // FUNCTION: extra.shortdate
        // VIEW: extra.adjudicationsourcecitationextracache

        $query = <<<QUERY
            SELECT adjudicationsourcecitationextracache.adjudicationsourcecitationslug,
                source.sourceshort,
                adjudicationsourcecitation.adjudicationsourcecitationvolume,
                extra.rangefix(adjudicationsourcecitation.adjudicationsourcecitationpagefrom::text, adjudicationsourcecitation.adjudicationsourcecitationpageto::text) AS adjudicationsourcecitationpage,
                adjudicationsourcecitation.adjudicationsourcecitationyear,
                extra.shortdate(adjudicationsourcecitation.adjudicationsourcecitationdate) AS adjudicationsourcecitationdate,
                adjudicationsourcecitation.adjudicationsourcecitationdate AS adjudicationsourcecitationdatesort,
                adjudicationsourcecitation.adjudicationsourcecitationtitle
            FROM geohistory.source
            JOIN geohistory.adjudicationsourcecitation
                ON adjudicationsourcecitation.source = source.sourceid
                AND adjudicationsourcecitation.adjudication = ?
            JOIN extra.adjudicationsourcecitationextracache
                ON adjudicationsourcecitation.adjudicationsourcecitationid = adjudicationsourcecitationextracache.adjudicationsourcecitationid
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        return $query ?? [];
    }
}