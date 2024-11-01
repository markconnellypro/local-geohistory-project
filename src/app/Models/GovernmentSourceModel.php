<?php

namespace App\Models;

use App\Models\BaseModel;

class GovernmentSourceModel extends BaseModel
{
    // extra.ci_model_governmentsource_detail(integer, character varying, boolean, character varying)
    // extra.ci_model_governmentsource_detail(text, character varying, boolean, character varying)

    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate

    public function getDetail(int|string $id): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = <<<QUERY
            SELECT DISTINCT governmentsource.governmentsourceid,
                government.governmentslug,
                government.governmentlong,
                governmentsource.governmentsourcetype,
                governmentsource.governmentsourcenumber,
                    CASE
                        WHEN (NOT ?) AND (governmentsource.governmentsourcetitle ~* '^[~#]' OR governmentsource.governmentsourcetitle ~~ '[Type %') THEN ''
                        ELSE governmentsource.governmentsourcetitle
                    END AS governmentsourcetitle,
                extra.shortdate(governmentsource.governmentsourcedate) AS governmentsourcedate,
                governmentsource.governmentsourcedate AS governmentsourcedatesort,
                extra.shortdate(governmentsource.governmentsourceapproveddate) AS governmentsourceapproveddate,
                governmentsource.governmentsourceapproveddate AS governmentsourceapproveddatesort,
                extra.shortdate(governmentsource.governmentsourceeffectivedate) AS governmentsourceeffectivedate,
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
                    ELSE ' p. ' || extra.rangefix(governmentsource.governmentsourcepagefrom, governmentsource.governmentsourcepageto)
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
                    ELSE ' p. ' || extra.rangefix(governmentsource.sourcecitationpagefrom, governmentsource.sourcecitationpageto)
                END) AS sourcecitationlocation,
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
            $id
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_event_governmentsource(integer, character varying, boolean, character varying)

    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate
    // VIEW: extra.governmentsourceextracache

    public function getByEvent(int $id): array
    {
        $query = <<<QUERY
            SELECT DISTINCT government.governmentslug,
                government.governmentlong,
                governmentsource.governmentsourcetype,
                governmentsource.governmentsourcenumber,
                    CASE
                        WHEN (NOT ?) AND (governmentsource.governmentsourcetitle ~* '^[~#]' OR governmentsource.governmentsourcetitle ~~ '[Type %') THEN ''
                        ELSE governmentsource.governmentsourcetitle
                    END AS governmentsourcetitle,
                extra.shortdate(governmentsource.governmentsourcedate) AS governmentsourcedate,
                governmentsource.governmentsourcedate AS governmentsourcedatesort,
                extra.shortdate(governmentsource.governmentsourceapproveddate) AS governmentsourceapproveddate,
                governmentsource.governmentsourceapproveddate AS governmentsourceapproveddatesort,
                extra.shortdate(governmentsource.governmentsourceeffectivedate) AS governmentsourceeffectivedate,
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
                governmentsourceextracache.governmentsourceslug,
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
                    ELSE ' p. ' || extra.rangefix(governmentsource.governmentsourcepagefrom, governmentsource.governmentsourcepageto)
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
                    ELSE ' p. ' || extra.rangefix(governmentsource.sourcecitationpagefrom, governmentsource.sourcecitationpageto)
                END) AS sourcecitationlocation
            FROM geohistory.governmentsource
            JOIN geohistory.government
                ON governmentsource.government = government.governmentid
            JOIN geohistory.governmentsourceevent
                ON governmentsource.governmentsourceid = governmentsourceevent.governmentsource
                AND governmentsourceevent.event = ?
            LEFT JOIN extra.governmentsourceextracache
                ON governmentsource.governmentsourceid = governmentsourceextracache.governmentsourceid
                AND governmentsourceextracache.hassource
            ORDER BY 12
        QUERY;

        $query = $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            $id,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_government_governmentsource(integer, character varying, boolean)

    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate
    // VIEW: extra.governmentsubstitutecache

    public function getByGovernment(int $id): array
    {
        $query = <<<QUERY
            SELECT DISTINCT array_agg(event.eventslug) AS eventslug,
                array_agg(event.eventid) AS eventid,
                governmentsource.governmentsourcetype,
                governmentsource.governmentsourcenumber,
                    CASE
                        WHEN (NOT ?) AND (governmentsource.governmentsourcetitle ~* '^[~#]' OR governmentsource.governmentsourcetitle ~~ '[Type %') THEN ''
                        ELSE governmentsource.governmentsourcetitle
                    END AS governmentsourcetitle,
                extra.shortdate(governmentsource.governmentsourcedate) AS governmentsourcedate,
                governmentsource.governmentsourcedate AS governmentsourcedatesort,
                extra.shortdate(governmentsource.governmentsourceapproveddate) AS governmentsourceapproveddate,
                governmentsource.governmentsourceapproveddate AS governmentsourceapproveddatesort,
                extra.shortdate(governmentsource.governmentsourceeffectivedate) AS governmentsourceeffectivedate,
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
                    ELSE ' p. ' || extra.rangefix(governmentsource.governmentsourcepagefrom, governmentsource.governmentsourcepageto)
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
                    ELSE ' p. ' || extra.rangefix(governmentsource.sourcecitationpagefrom, governmentsource.sourcecitationpageto)
                END) AS sourcecitationlocation,
                government.governmentlong,
                '' AS governmentslug
            FROM geohistory.governmentsource
            JOIN geohistory.government
                ON governmentsource.government = government.governmentid
            JOIN extra.governmentsubstitutecache
                ON governmentsource.government = governmentsubstitutecache.governmentid
                AND governmentsubstitutecache.governmentsubstitute = ?
            LEFT JOIN geohistory.governmentsourceevent
                ON governmentsource.governmentsourceid = governmentsourceevent.governmentsource
            LEFT JOIN geohistory.event
                ON governmentsourceevent.event = event.eventid
            GROUP BY 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19
            ORDER BY 12
        QUERY;

        $query = $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            $id,
        ]);

        return $this->getObject($query);
    }

    // extra.governmentsourceslugid(text)

    // VIEW: extra.governmentsourceextracache

    private function getSlugId(string $id): int
    {
        $query = <<<QUERY
            SELECT governmentsourceextracache.governmentsourceid AS id
                FROM extra.governmentsourceextracache
            WHERE governmentsourceextracache.governmentsourceslug = ?
                AND governmentsourceextracache.hassource
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
