<?php

namespace App\Models;

use App\Models\BaseModel;

class AdjudicationLocationModel extends BaseModel
{
    // extra.ci_model_adjudication_location(integer)

    // FUNCTION: extra.tribunallong
    // FUNCTION: extra.tribunalfilingoffice

    public function getByAdjudication(int $id): array
    {
        $query = <<<QUERY
            SELECT adjudicationlocationtype.adjudicationlocationtypelong,
                adjudicationlocation.adjudicationlocationvolume,
                adjudicationlocation.adjudicationlocationpage,
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

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }
}
