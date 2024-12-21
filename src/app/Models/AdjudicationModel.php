<?php

namespace App\Models;

use App\Models\BaseModel;
use App\Models\TribunalModel;

class AdjudicationModel extends BaseModel
{
    private function getFields(): string
    {
        $TribunalModel = new TribunalModel();

        return <<<QUERY
                SELECT DISTINCT adjudication.adjudicationid,
                    adjudication.adjudicationslug,
                    adjudicationtype.adjudicationtypelong,
                    adjudication.adjudicationnumber,
                    calendar.historicdatetextformat((adjudication.adjudicationterm || CASE
                        WHEN length(adjudication.adjudicationterm) = 4 THEN '-~07-~28'
                        WHEN length(adjudication.adjudicationterm) = 7 THEN '-~28'
                        ELSE ''
                    END)::calendar.historicdate, 'short', ?) AS adjudicationterm,
                    adjudication.adjudicationterm AS adjudicationtermsort,
                    adjudication.adjudicationlong,
                    adjudication.adjudicationshort,
                    adjudication.adjudicationnotes,
                    adjudication.adjudicationtitle,
            QUERY . $TribunalModel->getLong() . <<<QUERY
                    AS tribunallong,
            QUERY . $TribunalModel->getFilingOffice() . <<<QUERY
                    AS tribunalfilingoffice
            QUERY;
    }

    private function getTables(): string
    {
        return <<<QUERY
                FROM geohistory.adjudication
                JOIN geohistory.adjudicationtype
                    ON adjudication.adjudicationtype = adjudicationtype.adjudicationtypeid
                JOIN geohistory.tribunal
                    ON adjudicationtype.tribunal = tribunal.tribunalid
                JOIN geohistory.tribunaltype
                    ON tribunal.tribunaltype = tribunaltype.tribunaltypeid
                JOIN geohistory.government
                    ON tribunal.government = government.governmentid
                JOIN geohistory.government governmentstate
                    ON government.governmentcurrentleadstateid = governmentstate.governmentid
            QUERY;
    }

    public function getDetail(int|string $id): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = $this->getFields() . <<<QUERY
                    , CASE
                        WHEN adjudication.adjudicationlong = '' AND adjudication.adjudicationshort = '' AND adjudication.adjudicationnotes = '' THEN FALSE
                        ELSE TRUE
                    END AS textflag
            QUERY . $this->getTables() . <<<QUERY
                WHERE adjudication.adjudicationid = ?
            QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getByAdjudicationSourceCitation(int $id): array
    {
        $query = $this->getFields() . $this->getTables() . <<<QUERY
                JOIN geohistory.adjudicationsourcecitation
                    ON adjudication.adjudicationid = adjudicationsourcecitation.adjudication
                    AND adjudicationsourcecitation.adjudicationsourcecitationid = ?
            QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getByEvent(int $id): array
    {
        $query = $this->getFields() . <<<QUERY
                    , eventrelationship.eventrelationshipshort AS eventrelationship
            QUERY . $this->getTables() . <<<QUERY
                JOIN geohistory.adjudicationevent
                    ON adjudication.adjudicationid = adjudicationevent.adjudication
                    AND adjudicationevent.event = ?
                JOIN geohistory.eventrelationship
                    ON adjudicationevent.eventrelationship = eventrelationship.eventrelationshipid
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
                SELECT adjudication.adjudicationid AS id
                    FROM geohistory.adjudication
                WHERE adjudication.adjudicationslug = ?
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
