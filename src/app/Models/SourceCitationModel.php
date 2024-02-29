<?php

namespace App\Models;

use CodeIgniter\Model;

class SourceCitationModel extends Model
{
    // extra.ci_model_source_detail(integer, character varying)
    // extra.ci_model_source_detail(text, character varying)

    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate
    // VIEW: extra.sourcecitationgovernmentcache
    // VIEW: extra.sourceextra

    public function getDetail($id, $state)
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = <<<QUERY
            SELECT DISTINCT sourcecitation.sourcecitationid,
                sourceextra.sourceabbreviation,
                sourcecitation.sourcecitationdatetype || 
                    CASE WHEN sourcecitation.sourcecitationdatetype = '' THEN '' ELSE ' ' END ||
                    extra.shortdate(sourcecitation.sourcecitationdate) AS sourcecitationdate,
                sourcecitation.sourcecitationdate AS sourcecitationdatesort,
                sourcecitation.sourcecitationdaterangetype || 
                    CASE WHEN sourcecitation.sourcecitationdaterangetype = '' THEN '' ELSE ' ' END ||
                extra.shortdate(sourcecitation.sourcecitationdaterange) AS sourcecitationdaterange,
                sourcecitation.sourcecitationdaterange AS sourcecitationdaterangesort,
                sourcecitation.sourcecitationvolume,
                extra.rangefix(sourcecitation.sourcecitationpagefrom, sourcecitation.sourcecitationpageto) AS sourcecitationpage,
                sourcecitation.sourcecitationtypetitle,
                sourcecitation.sourcecitationperson,
                sourcecitation.sourcecitationurl AS url,
                source.sourcetype,
                sourceextra.sourcefullcitation,
                source.sourceid,
                'sourceitem' AS linktype
            FROM geohistory.source
            JOIN extra.sourceextra
                ON source.sourceid = sourceextra.sourceid
            JOIN geohistory.sourcecitation
                ON source.sourceid = sourcecitation.source
                AND sourcecitation.sourcecitationid = ?
            LEFT JOIN extra.sourcecitationgovernmentcache
                ON sourcecitation.sourcecitationid = sourcecitationgovernmentcache.sourcecitationid
            WHERE governmentrelationstate = ?
                OR governmentrelationstate IS NULL
        QUERY;

        $query = $this->db->query($query, [
            $id,
            strtoupper($state),
        ])->getResult();

        return $query ?? [];
    }

    // extra.sourcecitationslugid(text)

    // VIEW: extra.sourcecitationextracache

    private function getSlugId($id)
    {
        $query = <<<QUERY
            SELECT sourcecitationextracache.sourcecitationid AS id
                FROM extra.sourcecitationextracache
            WHERE sourcecitationextracache.sourcecitationslug = ?
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