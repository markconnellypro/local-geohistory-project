<?php

namespace App\Models;

use CodeIgniter\Model;

class LawAlternateSectionModel extends Model
{
    // extra.ci_model_lawalternate_detail(integer, character varying, boolean)
    // extra.ci_model_lawalternate_detail(text, character varying, boolean)

    // FUNCTION: extra.lawalternatesectioncitation
    // VIEW: extra.lawsectiongovernmentcache
    // VIEW: extra.sourceextra

    public function getDetail($id, $state): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = <<<QUERY
            SELECT DISTINCT lawalternatesection.lawalternatesectionid AS lawsectionid,
                lawalternatesection.lawalternatesectionpagefrom AS lawsectionpagefrom,
                extra.lawalternatesectioncitation(lawalternatesection.lawalternatesectionid) AS lawsectioncitation,
                CASE
                    WHEN (NOT ?) AND left(law.lawtitle, 1) = '~' THEN ''
                    ELSE law.lawtitle
                END AS lawtitle,
                '' AS url,
                source.sourcetype,
                sourceextra.sourceabbreviation,
                sourceextra.sourcefullcitation
            FROM geohistory.source
            JOIN extra.sourceextra
                ON source.sourceid = sourceextra.sourceid
            JOIN geohistory.lawalternate
                ON source.sourceid = lawalternate.source
            JOIN geohistory.law
                ON lawalternate.law = law.lawid
            JOIN geohistory.lawalternatesection
                ON lawalternate.lawalternateid = lawalternatesection.lawalternate
                AND lawalternatesection.lawalternatesectionid = ?
            LEFT JOIN extra.lawsectiongovernmentcache 
                ON lawalternatesection.lawsection = lawsectiongovernmentcache.lawsectionid
            WHERE governmentrelationstate = ?
                OR governmentrelationstate IS NULL
        QUERY;

        $query = $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            $id,
            strtoupper($state),
        ])->getResult();

        return $query;
    }

    // extra.ci_model_lawalternate_related(integer)

    // VIEW: extra.lawalternatesectionextracache
    // VIEW: extra.lawsectionextracache

    public function getRelated($id): array
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
            JOIN geohistory.lawalternatesection
                ON currentlawsection.lawsectionid = lawalternatesection.lawsection
                AND lawalternatesection.lawalternatesectionid = ?
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
            JOIN geohistory.lawalternatesection
                ON lawsection.lawsectionamend = lawalternatesection.lawsection
                AND lawalternatesection.lawalternatesectionid = ?
            JOIN extra.lawsectionextracache
                ON lawsection.lawsectionid = lawsectionextracache.lawsectionid
            UNION
            SELECT DISTINCT lawsectionextracache.lawsectionslug,
                law.lawapproved,
                lawsectionextracache.lawsectioncitation,
                'Lead'::text AS lawsectioneventrelationship,
                lawsection.lawsectionfrom,
                law.lawnumberchapter
            FROM geohistory.law
            JOIN geohistory.lawsection
                ON law.lawid = lawsection.law
            JOIN extra.lawsectionextracache
                ON lawsection.lawsectionid = lawsectionextracache.lawsectionid
            JOIN geohistory.lawalternatesection
                ON lawsection.lawsectionid = lawalternatesection.lawsection
                AND lawalternatesection.lawalternatesectionid = ?
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
            JOIN geohistory.lawalternatesection currentlawsection
                ON lawalternatesection.lawsection = currentlawsection.lawsection
                AND lawalternatesection.lawalternatesectionid <> currentlawsection.lawalternatesectionid
                AND currentlawsection.lawalternatesectionid = ?
            JOIN extra.lawalternatesectionextracache
                ON lawalternatesection.lawalternatesectionid = lawalternatesectionextracache.lawsectionid
            ORDER BY 4, 3
        QUERY;

        $query = $this->db->query($query, [
            $id,
            $id,
            $id,
            $id,
        ])->getResult();

        return $query;
    }

    // extra.lawalternatesectionslugid(text)

    // VIEW: extra.lawalternatesectionextracache

    private function getSlugId($id): int
    {
        $query = <<<QUERY
            SELECT lawalternatesectionextracache.lawsectionid AS id
                FROM extra.lawalternatesectionextracache
            WHERE lawalternatesectionextracache.lawsectionslug = ?
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        $id = -1;

        if (count($query) == 1) {
            $id = $query[0]->id;
        }

        return $id;
    }
}
