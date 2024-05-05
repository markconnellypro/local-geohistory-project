<?php

namespace App\Models;

use CodeIgniter\Model;

class AdjudicationLocationModel extends Model
{
    // extra.ci_model_adjudication_location(integer)

    // FUNCTION: extra.rangefix
    // FUNCTION: extra.tribunallong
    // FUNCTION: extra.tribunalfilingoffice

    public function getByAdjudication(int $id): array
    {
        $query = <<<QUERY
            SELECT adjudicationlocationtype.adjudicationlocationtypelong,
                adjudicationlocation.adjudicationlocationvolume,
                extra.rangefix(adjudicationlocation.adjudicationlocationpagefrom, adjudicationlocation.adjudicationlocationpageto) AS adjudicationlocationpage,
                adjudicationlocationtype.adjudicationlocationtypevolumetype,
                adjudicationlocationtype.adjudicationlocationtypepagetype,
                adjudicationlocationtype.adjudicationlocationtypearchiveseries,
                adjudicationlocationtype.adjudicationlocationtypetype,
                CASE
                    WHEN adjudicationlocationtype.adjudicationlocationtypearchivelevel = 1 THEN 'national'::text
                    WHEN adjudicationlocationtype.adjudicationlocationtypearchivelevel = 2 THEN 'state'::text
                    WHEN adjudicationlocationtype.adjudicationlocationtypearchivelevel = 3 THEN 'county'::text
                    WHEN adjudicationlocationtype.adjudicationlocationtypearchivelevel > 3 THEN 'municipal'::text
                    ELSE ''::text
                END AS adjudicationlocationtypearchivetype,
                CASE
                    WHEN adjudicationlocationtype.tribunal <> adjudicationtype.tribunal THEN extra.tribunallong(adjudicationlocationtype.tribunal) 
                    ELSE ''::text
                END AS tribunallong,
                CASE
                    WHEN adjudicationlocationtype.tribunal <> adjudicationtype.tribunal THEN extra.tribunalfilingoffice(adjudicationlocationtype.tribunal)
                    ELSE ''::text
                END AS tribunalfilingoffice
            FROM geohistory.adjudicationlocation
            JOIN geohistory.adjudicationlocationtype
                ON adjudicationlocation.adjudicationlocationtype = adjudicationlocationtype.adjudicationlocationtypeid
            JOIN geohistory.adjudication
                ON adjudicationlocation.adjudication = adjudication.adjudicationid
            JOIN geohistory.adjudicationtype
                ON adjudication.adjudicationtype = adjudicationtype.adjudicationtypeid
            WHERE adjudicationlocation.adjudication = ?
            ORDER BY adjudicationlocation.adjudicationlocationid
        QUERY;

        return $this->db->query($query, [
            $id,
        ])->getResult();
    }
}
