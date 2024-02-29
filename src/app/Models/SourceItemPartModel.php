<?php

namespace App\Models;

use CodeIgniter\Model;

class SourceItemPartModel extends Model
{
    // extra.ci_model_reporter_url(integer)

    public function getByAdjudicationSourceCitation($id)
    {
        $query = <<<QUERY
            SELECT sourceitem.sourceitemurl ||
            CASE
                WHEN sourceitem.sourceitemurlcomplete THEN ''::text
                ELSE
                CASE
                    WHEN sourceitempart.sourceitempartisbypage THEN sourceitempart.sourceitempartsequencecharacter::text || (sourceitempart.sourceitempartsequence + adjudicationsourcecitation.adjudicationsourcecitationpagefrom)
                    ELSE lpad((sourceitempart.sourceitempartsequence + 0)::text, 4, '0'::text) || sourceitempart.sourceitempartsequencecharacter::text
                END || sourceitempart.sourceitempartsequencecharacterafter::text
            END AS url
            FROM geohistory.sourceitempart,
                geohistory.sourceitem,
                geohistory.source,
                geohistory.adjudicationsourcecitation
            WHERE sourceitempart.sourceitem = sourceitem.sourceitemid
                AND sourceitem.source = source.sourceurlsubstitute
                AND source.sourceid = adjudicationsourcecitation.source
                AND (
                    (sourceitempartfrom IS NULL AND sourceitempartto IS NULL) OR
                    (sourceitempartisbypage AND sourceitempartfrom <= adjudicationsourcecitationpagefrom AND sourceitempartto >= adjudicationsourcecitationpagefrom)
                ) AND adjudicationsourcecitationvolume::character varying = sourceitemvolume
                AND adjudicationsourcecitation.adjudicationsourcecitationid = ?
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        return $query ?? [];
    }
}