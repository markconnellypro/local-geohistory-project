<?php

namespace App\Models;

use App\Models\BaseModel;

class GovernmentSourceModel extends BaseModel
{
    private function getFields(): string
    {
        return <<<QUERY
                SELECT DISTINCT governmentsource.governmentsourcetype,
                    governmentsource.governmentsourcenumber,
                        CASE
                            WHEN (NOT ?) AND (governmentsource.governmentsourcetitle ~* '^[~#]' OR governmentsource.governmentsourcetitle ~~ '[Type %') THEN ''
                            ELSE governmentsource.governmentsourcetitle
                        END AS governmentsourcetitle,
                    calendar.historicdatetextformat(governmentsource.governmentsourcedate::calendar.historicdate, 'short', ?) AS governmentsourcedate,
                    governmentsource.governmentsourcedate AS governmentsourcedatesort,
                    calendar.historicdatetextformat(governmentsource.governmentsourceapproveddate::calendar.historicdate, 'short', ?) AS governmentsourceapproveddate,
                    governmentsource.governmentsourceapproveddate AS governmentsourceapproveddatesort,
                    calendar.historicdatetextformat(governmentsource.governmentsourceeffectivedate::calendar.historicdate, 'short', ?) AS governmentsourceeffectivedate,
                    governmentsource.governmentsourceeffectivedate AS governmentsourceeffectivedatesort,
                        CASE
                            WHEN governmentsource.governmentsourceapproveddate <> '' THEN governmentsource.governmentsourceapproveddate
                            WHEN governmentsource.governmentsourcedate <> '' THEN governmentsource.governmentsourcedate
                            WHEN governmentsource.governmentsourceeffectivedate <> '' THEN governmentsource.governmentsourceeffectivedate
                            ELSE ''
                        END || governmentsource.governmentsourcetype || lpad(governmentsource.governmentsourcenumber, 5, '0') AS governmentsourcesort,
                    governmentsource.governmentsourcebody,
                    governmentsource.governmentsourceterm,
                    governmentsource.governmentsourceapproved,
                    trim(CASE
                        WHEN governmentsource.governmentsourcevolumetype = '' OR governmentsource.governmentsourcevolume = '' THEN ''
                        ELSE governmentsource.governmentsourcevolumetype
                    END ||
                    CASE
                        WHEN governmentsource.governmentsourcevolume = '' THEN ''
                        ELSE ' v. ' || governmentsource.governmentsourcevolume
                    END ||
                    CASE
                        WHEN governmentsource.governmentsourcevolume <> '' AND governmentsource.governmentsourcepagefrom <> '' AND governmentsource.governmentsourcepagefrom <> '0' THEN ', '
                        ELSE ''
                    END ||
                    CASE
                        WHEN governmentsource.governmentsourcepagefrom = '' OR governmentsource.governmentsourcepagefrom = '0' THEN ''
                        ELSE ' p. ' || governmentsource.governmentsourcepage
                    END) AS governmentsourcelocation,
                    trim(CASE
                        WHEN governmentsource.sourcecitationvolumetype = '' OR governmentsource.sourcecitationvolume = '' THEN ''
                        ELSE governmentsource.sourcecitationvolumetype
                    END ||
                    CASE
                        WHEN governmentsource.sourcecitationvolume = '' THEN ''
                        ELSE ' v. ' || governmentsource.sourcecitationvolume
                    END ||
                    CASE
                        WHEN governmentsource.sourcecitationvolume <> '' AND governmentsource.sourcecitationpagefrom <> '' AND governmentsource.sourcecitationpagefrom <> '0' THEN ', '
                        ELSE ''
                    END ||
                    CASE
                        WHEN governmentsource.sourcecitationpagefrom = '' OR governmentsource.sourcecitationpagefrom = '0' THEN ''
                        ELSE ' p. ' || governmentsource.sourcecitationpage
                    END) AS sourcecitationlocation,
                    government.governmentlong,
            QUERY;
    }

    public function getDetail(int|string $id): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = $this->getFields() . <<<QUERY
                    government.governmentslugsubstitute AS governmentslug,
                    governmentsource.governmentsourceid,
                    source.sourceabbreviation,
                    source.sourcetype,
                    source.sourcefullcitation,
                    source.sourceid,
                    'sourceitem' AS linktype
                FROM geohistory.governmentsource
                JOIN geohistory.government
                    ON governmentsource.government = government.governmentid
                JOIN geohistory.source
                    ON governmentsource.source = source.sourceid
                WHERE governmentsource.governmentsourceid = ?
            QUERY;

        $query = $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            \Config\Services::request()->getLocale(),
            \Config\Services::request()->getLocale(),
            \Config\Services::request()->getLocale(),
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getByEvent(int $id): array
    {
        $query = $this->getFields() . <<<QUERY
                    government.governmentslugsubstitute AS governmentslug,
                    CASE
                        WHEN governmentsource.hassource THEN governmentsource.governmentsourceslug
                        ELSE NULL
                    END AS governmentsourceslug
                FROM geohistory.governmentsource
                JOIN geohistory.government
                    ON governmentsource.government = government.governmentid
                JOIN geohistory.governmentsourceevent
                    ON governmentsource.governmentsourceid = governmentsourceevent.governmentsource
                    AND governmentsourceevent.event = ?
                ORDER BY 10
            QUERY;

        $query = $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            \Config\Services::request()->getLocale(),
            \Config\Services::request()->getLocale(),
            \Config\Services::request()->getLocale(),
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getByGovernment(int $id): array
    {
        $query = $this->getFields() . <<<QUERY
                    '' AS governmentslug,
                    array_agg(event.eventslug) AS eventslug,
                    array_agg(event.eventid) AS eventid
                FROM geohistory.governmentsource
                JOIN geohistory.government
                    ON governmentsource.government = government.governmentid
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentid = ?
                LEFT JOIN geohistory.governmentsourceevent
                    ON governmentsource.governmentsourceid = governmentsourceevent.governmentsource
                LEFT JOIN geohistory.event
                    ON governmentsourceevent.event = event.eventid
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17
                ORDER BY 10
            QUERY;

        $query = $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            \Config\Services::request()->getLocale(),
            \Config\Services::request()->getLocale(),
            \Config\Services::request()->getLocale(),
            $id,
        ]);

        return $this->getObject($query);
    }

    private function getSlugId(string $id): int
    {
        $query = <<<QUERY
                SELECT governmentsource.governmentsourceid AS id
                    FROM geohistory.governmentsource
                WHERE governmentsource.governmentsourceslug = ?
                    AND governmentsource.hassource
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
