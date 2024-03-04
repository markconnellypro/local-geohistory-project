<?php

namespace App\Models;

use CodeIgniter\Model;

class SourceCitationNoteModel extends Model
{
    // extra.ci_model_source_note(integer)

    public function getBySourceCitation($id): array
    {
        $query = <<<QUERY
            SELECT
                -2::integer AS sourcecitationnotegroup,
                'Government References' AS sourcecitationnotetypetext,
                sourcecitation.sourcecitationgovernmentreferences AS sourcecitationnotetext
            FROM geohistory.sourcecitation
            WHERE sourcecitation.sourcecitationid = ?
                AND sourcecitation.sourcecitationgovernmentreferences <> ''
            UNION
            SELECT
                sourcecitationnote.sourcecitationnotegroup,
                sourcecitationnotetype.sourcecitationnotetypetext,
                sourcecitationnote.sourcecitationnotetext
            FROM geohistory.sourcecitationnote
            JOIN geohistory.sourcecitationnotetype
                ON sourcecitationnote.sourcecitationnotetype = sourcecitationnotetype.sourcecitationnotetypeid
            WHERE sourcecitationnote.sourcecitation = ?
            ORDER BY 1, 2;
        QUERY;

        return $this->db->query($query, [
            $id,
            $id,
        ])->getResult();
    }
}
