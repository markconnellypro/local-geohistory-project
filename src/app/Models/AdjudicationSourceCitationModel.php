<?php

namespace App\Models;

use App\Models\BaseModel;

class AdjudicationSourceCitationModel extends BaseModel
{
    // extra.ci_model_reporter_detail(integer, character varying)
    // extra.ci_model_reporter_detail(text, character varying)

    // FUNCTION: extra.rangefix
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
                extra.rangefix(adjudicationsourcecitation.adjudicationsourcecitationpagefrom::text, adjudicationsourcecitation.adjudicationsourcecitationpageto::text) AS adjudicationsourcecitationpage,
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

    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate
    // VIEW: extra.adjudicationsourcecitationextracache

    public function getByAdjudication(int $id): array
    {
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
        ]);

        return $this->getObject($query);
    }

    // VIEW: extra.adjudicationsourcecitationextracache

    private function getSlugId(string $id): int
    {
        $query = <<<QUERY
            SELECT adjudicationsourcecitationextracache.adjudicationsourcecitationid AS id
                FROM extra.adjudicationsourcecitationextracache
            WHERE adjudicationsourcecitationextracache.adjudicationsourcecitationslug = ?
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
