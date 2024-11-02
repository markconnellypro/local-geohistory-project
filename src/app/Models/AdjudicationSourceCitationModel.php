<?php

namespace App\Models;

use App\Models\BaseModel;

class AdjudicationSourceCitationModel extends BaseModel
{
    // extra.ci_model_reporter_detail(integer, character varying)
    // extra.ci_model_reporter_detail(text, character varying)

    // FUNCTION: extra.shortdate

    public function getDetail(int|string $id): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = <<<QUERY
            SELECT DISTINCT adjudicationsourcecitation.adjudicationsourcecitationid,
                source.sourceshort,
                source.sourceabbreviation,
                adjudicationsourcecitation.adjudicationsourcecitationvolume,
                geohistory.rangeformat(adjudicationsourcecitation.adjudicationsourcecitationpagefrom::text, adjudicationsourcecitation.adjudicationsourcecitationpageto::text) AS adjudicationsourcecitationpage,
                adjudicationsourcecitation.adjudicationsourcecitationyear,
                extra.shortdate(adjudicationsourcecitation.adjudicationsourcecitationdate) AS adjudicationsourcecitationdate,
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
                AND adjudicationsourcecitation.adjudicationsourcecitationid = ?
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_adjudication_source(integer)

    // FUNCTION: extra.shortdate

    public function getByAdjudication(int $id): array
    {
        $query = <<<QUERY
            SELECT adjudicationsourcecitation.adjudicationsourcecitationslug,
                source.sourceshort,
                adjudicationsourcecitation.adjudicationsourcecitationvolume,
                geohistory.rangeformat(adjudicationsourcecitation.adjudicationsourcecitationpagefrom::text, adjudicationsourcecitation.adjudicationsourcecitationpageto::text) AS adjudicationsourcecitationpage,
                adjudicationsourcecitation.adjudicationsourcecitationyear,
                extra.shortdate(adjudicationsourcecitation.adjudicationsourcecitationdate) AS adjudicationsourcecitationdate,
                adjudicationsourcecitation.adjudicationsourcecitationdate AS adjudicationsourcecitationdatesort,
                adjudicationsourcecitation.adjudicationsourcecitationtitle
            FROM geohistory.source
            JOIN geohistory.adjudicationsourcecitation
                ON adjudicationsourcecitation.source = source.sourceid
                AND adjudicationsourcecitation.adjudication = ?
        QUERY;

        $query = $this->db->query($query, [
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
