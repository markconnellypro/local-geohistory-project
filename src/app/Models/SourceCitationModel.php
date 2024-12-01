<?php

namespace App\Models;

use App\Models\BaseModel;

class SourceCitationModel extends BaseModel
{
    public function getDetail(int|string $id): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = <<<QUERY
                SELECT DISTINCT sourcecitation.sourcecitationid,
                    source.sourceabbreviation,
                    sourcecitation.sourcecitationdatetype ||
                        CASE WHEN sourcecitation.sourcecitationdatetype = '' THEN '' ELSE ' ' END ||
                        calendar.historicdatetextformat(sourcecitation.sourcecitationdate::calendar.historicdate, 'short', ?) AS sourcecitationdate,
                    sourcecitation.sourcecitationdate AS sourcecitationdatesort,
                    sourcecitation.sourcecitationdaterangetype ||
                        CASE WHEN sourcecitation.sourcecitationdaterangetype = '' THEN '' ELSE ' ' END ||
                    calendar.historicdatetextformat(sourcecitation.sourcecitationdaterange::calendar.historicdate, 'short', ?) AS sourcecitationdaterange,
                    sourcecitation.sourcecitationdaterange AS sourcecitationdaterangesort,
                    sourcecitation.sourcecitationvolume,
                    sourcecitation.sourcecitationpage,
                    sourcecitation.sourcecitationtypetitle,
                    sourcecitation.sourcecitationperson,
                    sourcecitation.sourcecitationurl AS url,
                    source.sourcetype,
                    source.sourcefullcitation,
                    source.sourceid,
                    'sourceitem' AS linktype
                FROM geohistory.source
                JOIN geohistory.sourcecitation
                    ON source.sourceid = sourcecitation.source
                    AND sourcecitation.sourcecitationid = ?
            QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
            \Config\Services::request()->getLocale(),
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getByEvent(int $id): array
    {
        $query = <<<QUERY
                SELECT sourcecitation.sourcecitationslug,
                    source.sourceabbreviation,
                    sourcecitation.sourcecitationdatetype ||
                        CASE WHEN sourcecitation.sourcecitationdatetype = '' THEN '' ELSE ' ' END ||
                        calendar.historicdatetextformat(sourcecitation.sourcecitationdate::calendar.historicdate, 'short', ?) AS sourcecitationdate,
                    sourcecitation.sourcecitationdate AS sourcecitationdatesort,
                    sourcecitation.sourcecitationdaterangetype ||
                        CASE WHEN sourcecitation.sourcecitationdaterangetype = '' THEN '' ELSE ' ' END ||
                    calendar.historicdatetextformat(sourcecitation.sourcecitationdaterange::calendar.historicdate, 'short', ?) AS sourcecitationdaterange,
                    sourcecitation.sourcecitationdaterange AS sourcecitationdaterangesort,
                    sourcecitation.sourcecitationvolume,
                    sourcecitation.sourcecitationpage,
                    sourcecitation.sourcecitationtypetitle,
                    sourcecitation.sourcecitationperson
                FROM geohistory.source
                JOIN geohistory.sourcecitation
                    ON source.sourceid = sourcecitation.source
                JOIN geohistory.sourcecitationevent
                    ON sourcecitation.sourcecitationid = sourcecitationevent.sourcecitation
                    AND sourcecitationevent.event = ?
                ORDER BY 1, 6, 7, 10
            QUERY;

        $query = $this->db->query($query, [
            \Config\Services::request()->getLocale(),
            \Config\Services::request()->getLocale(),
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getByGovernment(int $id, array $jurisdictions): array
    {
        return [];
    }

    public function getByLawNation(int $id): array
    {
        return [];
    }

    public function getByLawState(int $id): array
    {
        return [];
    }

    private function getSlugId(string $id): int
    {
        $query = <<<QUERY
                SELECT sourcecitation.sourcecitationid AS id
                    FROM geohistory.sourcecitation
                WHERE sourcecitation.sourcecitationslug = ?
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
