<?php

namespace App\Models;

use App\Models\BaseModel;
use App\Models\TribunalModel;

class AdjudicationLocationModel extends BaseModel
{
    public function getByAdjudication(int $id): array
    {
        $TribunalModel = new TribunalModel();

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
                        WHEN adjudicationlocationtype.tribunal <> adjudicationtype.tribunal THEN
            QUERY . $TribunalModel->getLong() . <<<QUERY
                        ELSE ''::text
                    END AS tribunallong,
                    CASE
                        WHEN adjudicationlocationtype.tribunal <> adjudicationtype.tribunal THEN
            QUERY . $TribunalModel->getFilingOffice() . <<<QUERY
                        ELSE ''::text
                    END AS tribunalfilingoffice
                FROM geohistory.adjudicationlocation
                JOIN geohistory.adjudicationlocationtype
                    ON adjudicationlocation.adjudicationlocationtype = adjudicationlocationtype.adjudicationlocationtypeid
                JOIN geohistory.adjudication
                    ON adjudicationlocation.adjudication = adjudication.adjudicationid
                JOIN geohistory.adjudicationtype
                    ON adjudication.adjudicationtype = adjudicationtype.adjudicationtypeid
                JOIN geohistory.tribunal
                    ON adjudicationlocationtype.tribunal = tribunal.tribunalid
                JOIN geohistory.tribunaltype
                    ON tribunal.tribunaltype = tribunaltype.tribunaltypeid
                JOIN geohistory.government
                    ON tribunal.government = government.governmentid
                JOIN geohistory.government governmentstate
                    ON government.governmentcurrentleadstateid = governmentstate.governmentid
                WHERE adjudicationlocation.adjudication = ?
                ORDER BY adjudicationlocation.adjudicationlocationid
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }
}
