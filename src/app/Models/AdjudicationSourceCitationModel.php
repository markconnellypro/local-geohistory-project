<?php

namespace App\Models;

use CodeIgniter\Model;

class AdjudicationSourceCitationModel extends Model
{
    // extra.ci_model_reporter_detail(integer, character varying)
    // extra.ci_model_reporter_detail(text, character varying)

    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate
    // VIEW: extra.sourceextra
    // VIEW: extra.adjudicationgovernmentcache

    public function getDetail($id, $state): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = <<<QUERY
            SELECT DISTINCT adjudicationsourcecitation.adjudicationsourcecitationid,
                source.sourceshort,
                sourceextra.sourceabbreviation,
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
                sourceextra.sourcefullcitation
            FROM geohistory.source
            JOIN extra.sourceextra
                ON source.sourceid = sourceextra.sourceid
            JOIN geohistory.adjudicationsourcecitation
                ON source.sourceid = adjudicationsourcecitation.source
                AND adjudicationsourcecitation.adjudicationsourcecitationid = ?
            LEFT JOIN extra.adjudicationgovernmentcache
                ON adjudicationsourcecitation.adjudication = adjudicationgovernmentcache.adjudicationid
            WHERE governmentrelationstate = ?
                OR governmentrelationstate IS NULL
        QUERY;

        return $this->db->query($query, [
            $id,
            strtoupper($state),
        ])->getResult();
    }

    public function getByAdjudication($id): array
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

        return $this->db->query($query, [
            $id,
        ])->getResult();
    }

    private function getSlugId($id): int
    {
        $query = <<<QUERY
            SELECT adjudicationsourcecitationextracache.adjudicationsourcecitationid AS id
                FROM extra.adjudicationsourcecitationextracache
            WHERE adjudicationsourcecitationextracache.adjudicationsourcecitationslug = ?
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        $id = -1;

        if (count($query) == 1) {
            $id = $query[0]->id;
        }

        return $id;
    }
}
