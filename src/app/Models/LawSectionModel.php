<?php

namespace App\Models;

use App\Models\BaseModel;

class LawSectionModel extends BaseModel
{
    // extra.ci_model_law_detail(integer, character varying, boolean)
    // extra.ci_model_law_detail(text, character varying, boolean)

    public function getDetail(int|string $id): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = <<<QUERY
            SELECT DISTINCT lawsection.lawsectionid,
                lawsection.lawsectionpagefrom,
                lawsection.lawsectioncitation,
                CASE
                    WHEN (NOT ?) AND left(law.lawtitle, 1) = '~' THEN ''
                    ELSE law.lawtitle
                END AS lawtitle,
                law.lawurl AS url,
                source.sourcetype,
                source.sourceabbreviation,
                source.sourcefullcitation
            FROM geohistory.source
            JOIN geohistory.law
                ON source.sourceid = law.source
            JOIN geohistory.lawsection
                ON law.lawid = lawsection.law
                AND lawsection.lawsectionid = ?
        QUERY;

        $query = $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            $id,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_event_law(integer)

    public function getByEvent(int $id): array
    {
        $query = <<<QUERY
            SELECT DISTINCT lawsection.lawsectionslug,
                law.lawapproved,
                lawsection.lawsectioncitation,
                eventrelationship.eventrelationshipshort AS lawsectioneventrelationship,
                lawsection.lawsectionfrom,
                law.lawnumberchapter,
                lawgroup.lawgrouplong
            FROM geohistory.law
            JOIN geohistory.lawsection
                ON law.lawid = lawsection.law   
            JOIN geohistory.lawsectionevent
                ON lawsection.lawsectionid = lawsectionevent.lawsection 
                AND lawsectionevent.event = ?
            JOIN geohistory.eventrelationship
                ON lawsectionevent.eventrelationship = eventrelationship.eventrelationshipid
            LEFT JOIN geohistory.lawgroup
                ON lawsectionevent.lawgroup = lawgroup.lawgroupid
            ORDER BY 4, 2, 1
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_law_related(integer)

    // FUNCTION: extra.rangefix

    public function getRelated(int $id): array
    {
        $query = <<<QUERY
            SELECT DISTINCT lawsection.lawsectionslug,
                law.lawapproved,
                lawsection.lawsectioncitation,
                'Amends'::text AS lawsectioneventrelationship,
                lawsection.lawsectionfrom,
                law.lawnumberchapter
            FROM geohistory.law
            JOIN geohistory.lawsection
                ON law.lawid = lawsection.law   
            JOIN geohistory.lawsection currentlawsection
                ON lawsection.lawsectionid = currentlawsection.lawsectionamend
                AND currentlawsection.lawsectionid = ?
            UNION
            SELECT DISTINCT lawsection.lawsectionslug,
                law.lawapproved,
                lawsection.lawsectioncitation,
                'Amended By'::text AS lawsectioneventrelationship,
                lawsection.lawsectionfrom,
                law.lawnumberchapter
            FROM geohistory.law
            JOIN geohistory.lawsection
                ON law.lawid = lawsection.law
                AND lawsection.lawsectionamend = ?
            UNION
            SELECT DISTINCT lawalternatesection.lawalternatesectionslug AS lawsectionslug,
                law.lawapproved,
                lawalternatesection.lawalternatesectioncitation AS lawsectioncitation,
                'Alternate'::text AS lawsectioneventrelationship,
                lawsection.lawsectionfrom,
                law.lawnumberchapter
            FROM geohistory.law
            JOIN geohistory.lawsection
                ON law.lawid = lawsection.law
            JOIN geohistory.lawalternatesection
                ON lawsection.lawsectionid = lawalternatesection.lawsection
                AND lawalternatesection.lawsection = ?
            UNION
            SELECT DISTINCT NULL AS lawsectionslug,
                law.lawapproved,
                law.lawcitation AS lawsectioncitation,
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

        $query = $this->db->query($query, [
            $id,
            $id,
            $id,
            $id,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_search_law_dateevent(character varying, text, character varying)

    public function getSearchByDateEvent(array $parameters): array
    {
        $date = $parameters[0];
        $eventType = $parameters[1];

        $query = <<<QUERY
            SELECT lawsection.lawsectionslug,
               lawsection.lawsectioncitation,
               lawapproved,
               eventtypeshort
              FROM geohistory.lawsection
                JOIN geohistory.eventtype
                  ON lawsection.eventtype = eventtype.eventtypeid
                  AND (? = ''::text 
                 OR ? = 'Any Type'::text
                 OR (? = 'Only Border Changes'::text AND eventtype.eventtypeborders ~~ 'yes%')
                 OR eventtype.eventtypeshort = ?)
                JOIN geohistory.law
                  ON lawsection.law = law.lawid
                  AND law.lawapproved = ?
                JOIN geohistory.source
                  ON law.source = source.sourceid
                  AND source.sourcetype = 'session laws';
        QUERY;

        $query = $this->db->query($query, [
            $eventType,
            $eventType,
            $eventType,
            $eventType,
            $date,
        ]);

        return $this->getObject($query);
    }

    // extra_removed.ci_model_search_law_reference(character varying, integer, integer, character varying)

    public function getSearchByReference(array $parameters): array
    {
        $yearVolume = $parameters[0];
        $page = $parameters[1];
        $numberChapter = $parameters[2];

        $query = <<<QUERY
            SELECT lawsection.lawsectionslug,
               lawsection.lawsectioncitation,
               lawapproved,
               eventtypeshort
              FROM geohistory.lawsection  
                JOIN geohistory.eventtype
                  ON lawsection.eventtype = eventtype.eventtypeid
                JOIN geohistory.law
                  ON lawsection.law = law.lawid
                  AND (law.lawvolume = ? OR left(law.lawapproved, 4) = ?)
                JOIN geohistory.source
                  ON law.source = source.sourceid
                  AND source.sourcetype = 'session laws'
             WHERE (0 = ? OR law.lawpage = ? OR (lawsection.lawsectionpagefrom >= ? AND lawsection.lawsectionpageto <= ?))
               AND (0 = ? OR law.lawnumberchapter = ?)
        QUERY;

        $query = $this->db->query($query, [
            $yearVolume,
            $yearVolume,
            $page,
            $page,
            $page,
            $page,
            $numberChapter,
            $numberChapter,
        ]);

        return $this->getObject($query);
    }

    // extra.lawsectionslugid(text)

    private function getSlugId(string $id): int
    {
        $query = <<<QUERY
            SELECT lawsection.lawsectionid AS id
                FROM geohistory.lawsection
            WHERE lawsection.lawsectionslug = ?
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
