<?php

namespace App\Models;

use CodeIgniter\Model;

class LawSectionModel extends Model
{
    // extra.ci_model_law_detail(integer, character varying, boolean)
    // extra.ci_model_law_detail(text, character varying, boolean)

    // FUNCTION: extra.lawsectioncitation
    // VIEW: extra.sourceextra

    public function getDetail(int|string $id): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = <<<QUERY
            SELECT DISTINCT lawsection.lawsectionid,
                lawsection.lawsectionpagefrom,
                extra.lawsectioncitation(lawsection.lawsectionid) AS lawsectioncitation,
                CASE
                    WHEN (NOT ?) AND left(law.lawtitle, 1) = '~' THEN ''
                    ELSE law.lawtitle
                END AS lawtitle,
                law.lawurl AS url,
                source.sourcetype,
                sourceextra.sourceabbreviation,
                sourceextra.sourcefullcitation
            FROM geohistory.source
            JOIN extra.sourceextra
                ON source.sourceid = sourceextra.sourceid
            JOIN geohistory.law
                ON source.sourceid = law.source
            JOIN geohistory.lawsection
                ON law.lawid = lawsection.law
                AND lawsection.lawsectionid = ?
        QUERY;

        return $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            $id,
        ])->getResult();
    }

    // extra.ci_model_event_law(integer)

    // VIEW: extra.lawsectionextracache

    public function getByEvent(int $id): array
    {
        $query = <<<QUERY
            SELECT DISTINCT lawsectionextracache.lawsectionslug,
                law.lawapproved,
                lawsectionextracache.lawsectioncitation,
                eventrelationship.eventrelationshipshort AS lawsectioneventrelationship,
                lawsection.lawsectionfrom,
                law.lawnumberchapter,
                lawgroup.lawgrouplong
            FROM geohistory.law
            JOIN geohistory.lawsection
                ON law.lawid = lawsection.law   
            JOIN extra.lawsectionextracache
                ON lawsection.lawsectionid = lawsectionextracache.lawsectionid
            JOIN geohistory.lawsectionevent
                ON lawsection.lawsectionid = lawsectionevent.lawsection 
                AND lawsectionevent.event = ?
            JOIN geohistory.eventrelationship
                ON lawsectionevent.eventrelationship = eventrelationship.eventrelationshipid
            LEFT JOIN geohistory.lawgroup
                ON lawsectionevent.lawgroup = lawgroup.lawgroupid
            ORDER BY 4, 2, 1
        QUERY;

        return $this->db->query($query, [
            $id,
        ])->getResult();
    }

    // extra.ci_model_law_related(integer)

    // FUNCTION: extra.lawcitation
    // FUNCTION: extra.rangefix
    // VIEW: extra.lawalternatesectionextracache
    // VIEW: extra.lawsectionextracache

    public function getRelated(int $id): array
    {
        $query = <<<QUERY
            SELECT DISTINCT lawsectionextracache.lawsectionslug,
                law.lawapproved,
                lawsectionextracache.lawsectioncitation,
                'Amends'::text AS lawsectioneventrelationship,
                lawsection.lawsectionfrom,
                law.lawnumberchapter
            FROM geohistory.law
            JOIN geohistory.lawsection
                ON law.lawid = lawsection.law
            JOIN extra.lawsectionextracache
                ON lawsection.lawsectionid = lawsectionextracache.lawsectionid     
            JOIN geohistory.lawsection currentlawsection
                ON lawsection.lawsectionid = currentlawsection.lawsectionamend
                AND currentlawsection.lawsectionid = ?
            UNION
            SELECT DISTINCT lawsectionextracache.lawsectionslug,
                law.lawapproved,
                lawsectionextracache.lawsectioncitation,
                'Amended By'::text AS lawsectioneventrelationship,
                lawsection.lawsectionfrom,
                law.lawnumberchapter
            FROM geohistory.law
            JOIN geohistory.lawsection
                ON law.lawid = lawsection.law
                AND lawsection.lawsectionamend = ?
            JOIN extra.lawsectionextracache
                ON lawsection.lawsectionid = lawsectionextracache.lawsectionid
            UNION
            SELECT DISTINCT lawalternatesectionextracache.lawsectionslug,
                law.lawapproved,
                lawalternatesectionextracache.lawsectioncitation,
                'Alternate'::text AS lawsectioneventrelationship,
                lawsection.lawsectionfrom,
                law.lawnumberchapter
            FROM geohistory.law
            JOIN geohistory.lawsection
                ON law.lawid = lawsection.law
            JOIN geohistory.lawalternatesection
                ON lawsection.lawsectionid = lawalternatesection.lawsection
                AND lawalternatesection.lawsection = ?
            JOIN extra.lawalternatesectionextracache
                ON lawalternatesection.lawalternatesectionid = lawalternatesectionextracache.lawsectionid
            UNION
            SELECT DISTINCT NULL AS lawsectionslug,
                law.lawapproved,
                extra.lawcitation(law.lawid) AS lawsectioncitation,
                'Amended To Add ' || lawsection.lawsectionnewsymbol || CASE
                    WHEN lawsection.lawsectionnewfrom <> lawsection.lawsectionnewto THEN lawsection.lawsectionnewsymbol
                    ELSE ''
                END || ' ' || extra.rangefix(lawsection.lawsectionnewfrom, lawsection.lawsectionnewto) AS lawsectioneventrelationship,
                lawsection.lawsectionnewfrom AS lawsectionfrom,
                law.lawnumberchapter
            FROM geohistory.law
            JOIN geohistory.lawsection
                ON law.lawid = lawsection.lawsectionnewlaw
                AND lawsection.lawsectionid = ?
            ORDER BY 4, 3
        QUERY;

        return $this->db->query($query, [
            $id,
            $id,
            $id,
            $id,
        ])->getResult();
    }

    // extra.ci_model_search_law_dateevent(character varying, text, character varying)

    // FUNCTION: extra.governmentabbreviation
    // FUNCTION: extra.governmentabbreviationid
    // FUNCTION: extra.governmentcurrentleadparent
    // VIEW: extra.lawsectionextracache

    public function getSearchByDateEvent(array $parameters): array
    {
        $date = $parameters[0];
        $eventType = $parameters[1];
        $state = $parameters[2];

        $query = <<<QUERY
            WITH source AS (
                SELECT source.sourceid,
                sourcegovernment.government
                FROM geohistory.source
                LEFT JOIN geohistory.sourcegovernment
                ON source.sourceid = sourcegovernment.source
                AND sourcegovernment.sourceorder = 1
                WHERE source.sourcetype = 'session laws'
            )
            SELECT lawsectionextracache.lawsectionslug,
               lawsectionextracache.lawsectioncitation,
               lawapproved,
               eventtypeshort
              FROM geohistory.lawsection
                JOIN extra.lawsectionextracache
                  ON lawsection.lawsectionid = lawsectionextracache.lawsectionid
                JOIN geohistory.eventtype
                  ON lawsection.eventtype = eventtype.eventtypeid
                  AND (? = ''::text 
                 OR ? = 'Any Type'::text
                 OR (? = 'Only Border Changes'::text AND eventtype.eventtypeborders ~~ 'yes%')
                 OR eventtype.eventtypeshort = ?)
                JOIN geohistory.law
                  ON lawsection.law = law.lawid
                  AND law.lawapproved = ?
                JOIN source
                  ON law.source = source.sourceid
                  AND (extra.governmentabbreviation(source.government) = ?
                OR source.government = extra.governmentcurrentleadparent(extra.governmentabbreviationid(?))
                OR source.government IS NULL);
        QUERY;

        return $this->db->query($query, [
            $eventType,
            $eventType,
            $eventType,
            $eventType,
            $date,
            strtoupper($state),
            strtoupper($state),
        ])->getResult();
    }

    // extra_removed.ci_model_search_law_reference(character varying, integer, integer, character varying)

    // FUNCTION: extra.governmentabbreviation
    // FUNCTION: extra.governmentabbreviationid
    // FUNCTION: extra.governmentcurrentleadparent
    // VIEW: extra.lawsectionextracache

    public function getSearchByReference(array $parameters): array
    {
        $yearVolume = $parameters[0];
        $page = $parameters[1];
        $numberChapter = $parameters[2];
        $state = $parameters[3];

        $query = <<<QUERY
            WITH source AS (
                SELECT source.sourceid,
                sourcegovernment.government
                FROM geohistory.source
                LEFT JOIN geohistory.sourcegovernment
                ON source.sourceid = sourcegovernment.source
                AND sourcegovernment.sourceorder = 1
                WHERE source.sourcetype = 'session laws'
            )
            SELECT lawsectionextracache.lawsectionslug,
               lawsectionextracache.lawsectioncitation,
               lawapproved,
               eventtypeshort
              FROM geohistory.lawsection
                JOIN extra.lawsectionextracache
                  ON lawsection.lawsectionid = lawsectionextracache.lawsectionid   
                JOIN geohistory.eventtype
                  ON lawsection.eventtype = eventtype.eventtypeid
                JOIN geohistory.law
                  ON lawsection.law = law.lawid
                  AND (law.lawvolume = ? OR left(law.lawapproved, 4) = ?)
                JOIN source
                  ON law.source = source.sourceid
                  AND (extra.governmentabbreviation(source.government) = ?
                OR source.government = extra.governmentcurrentleadparent(extra.governmentabbreviationid(?))
                OR source.government IS NULL)
             WHERE (0 = ? OR law.lawpage = ? OR (lawsection.lawsectionpagefrom >= ? AND lawsection.lawsectionpageto <= ?))
               AND (0 = ? OR law.lawnumberchapter = ?)
        QUERY;

        return $this->db->query($query, [
            $yearVolume,
            $yearVolume,
            strtoupper($state),
            strtoupper($state),
            $page,
            $page,
            $page,
            $page,
            $numberChapter,
            $numberChapter,
        ])->getResult();
    }

    // extra.lawsectionslugid(text)

    // VIEW: extra.lawsectionextracache

    private function getSlugId(string $id): int
    {
        $query = <<<QUERY
            SELECT lawsectionextracache.lawsectionid AS id
                FROM extra.lawsectionextracache
            WHERE lawsectionextracache.lawsectionslug = ?
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        $id = -1;

        if (count($query) === 1) {
            $id = $query[0]->id;
        }

        return $id;
    }
}
