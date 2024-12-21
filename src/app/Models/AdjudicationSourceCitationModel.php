<?php

namespace App\Models;

use App\Models\BaseModel;

class AdjudicationSourceCitationModel extends BaseModel
{
    private function getFields(): string
    {
        return <<<QUERY
                SELECT DISTINCT adjudicationsourcecitation.adjudicationsourcecitationid,
                    adjudicationsourcecitation.adjudicationsourcecitationslug,
                    source.sourceshort,
                    source.sourceabbreviation,
                    adjudicationsourcecitation.adjudicationsourcecitationvolume,
                    adjudicationsourcecitation.adjudicationsourcecitationpage,
                    adjudicationsourcecitation.adjudicationsourcecitationyear,
                    calendar.historicdatetextformat(adjudicationsourcecitation.adjudicationsourcecitationdate::calendar.historicdate, 'short', ?) AS adjudicationsourcecitationdate,
                    adjudicationsourcecitation.adjudicationsourcecitationdate AS adjudicationsourcecitationdatesort,
                    adjudicationsourcecitation.adjudicationsourcecitationtitle,
                    adjudicationsourcecitation.adjudicationsourcecitationauthor,
                    adjudicationsourcecitation.adjudicationsourcecitationjudge,
                    adjudicationsourcecitation.adjudicationsourcecitationdissentjudge,
                    adjudicationsourcecitation.adjudicationsourcecitationurl AS url,
                    source.sourcetype,
                    source.sourcefullcitation
                FROM geohistory.source
                JOIN geohistory.adjudicationsourcecitation
                    ON source.sourceid = adjudicationsourcecitation.source
            QUERY;
    }

    public function getDetail(int|string $id): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = $this->getFields() . <<<QUERY
                    AND adjudicationsourcecitation.adjudicationsourcecitationid = ?
            QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getByAdjudication(int $id): array
    {
        $query = $this->getFields() . <<<QUERY
                    AND adjudicationsourcecitation.adjudication = ?
            QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
            $id,
        ]);

        return $this->getObject($query);
    }

    private function getSlugId(string $id): int
    {
        $query = <<<QUERY
                SELECT adjudicationsourcecitation.adjudicationsourcecitationid AS id
                    FROM geohistory.adjudicationsourcecitation
                WHERE adjudicationsourcecitation.adjudicationsourcecitationslug = ?
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
