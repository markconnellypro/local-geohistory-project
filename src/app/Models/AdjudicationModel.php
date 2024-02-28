<?php

namespace App\Models;

use CodeIgniter\Model;

class AdjudicationModel extends Model
{
    // extra.ci_model_adjudication_detail(character varying, character varying)
    // extra.ci_model_adjudication_detail(integer, character varying)

    public function getDetail($id, $state)
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        // FUNCTION: extra.shortdate
        // FUNCTION: extra.tribunalfilingoffice
        // FUNCTION: extra.tribunallong
        // VIEW: extra.adjudicationextracache
        // VIEW: extra.adjudicationgovernmentcache

        $query = <<<QUERY
            SELECT DISTINCT adjudication.adjudicationid,
                adjudicationtype.adjudicationtypelong,
                extra.tribunallong(tribunal.tribunalid) AS tribunallong,
                adjudication.adjudicationnumber,
                extra.shortdate(adjudication.adjudicationterm || CASE
                    WHEN length(adjudication.adjudicationterm) = 4 THEN '-~07-~28'
                    WHEN length(adjudication.adjudicationterm) = 7 THEN '-~28'
                    ELSE ''
                END) AS adjudicationterm,
                CASE
                    WHEN adjudication.adjudicationlong = '' AND adjudication.adjudicationshort = '' AND adjudication.adjudicationnotes = '' THEN FALSE
                    ELSE TRUE
                END AS textflag,
                adjudication.adjudicationlong,
                adjudication.adjudicationshort,
                adjudication.adjudicationnotes,
                extra.tribunalfilingoffice(tribunal.tribunalid) AS tribunalfilingoffice,
                adjudicationextracache.adjudicationtitle
            FROM geohistory.adjudicationtype
            JOIN geohistory.tribunal
                ON adjudicationtype.tribunal = tribunal.tribunalid
            JOIN geohistory.adjudication
                ON adjudicationtype.adjudicationtypeid = adjudication.adjudicationtype
                AND adjudication.adjudicationid = ?
            JOIN extra.adjudicationextracache
                ON adjudication.adjudicationid = adjudicationextracache.adjudicationid
            LEFT JOIN extra.adjudicationgovernmentcache
                ON adjudication.adjudicationid = adjudicationgovernmentcache.adjudicationid
            WHERE governmentrelationstate = ?
                OR governmentrelationstate IS NULL
        QUERY;

        $query = $this->db->query($query, [
            $id,
            strtoupper($state),
        ])->getResult();

        return $query ?? [];
    }

    // extra.adjudicationslugid(text)

    // VIEW: extra.adjudicationextracache

    private function getSlugId($id)
    {
        $query = <<<QUERY
            SELECT adjudicationextracache.adjudicationid
                FROM extra.adjudicationextracache
            WHERE adjudicationextracache.adjudicationslug = ?;
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        $id = -1;

        if (count($query) == 1) {
            $id = $query[0]->adjudicationid;
        }
        
        return $id;
    }
}