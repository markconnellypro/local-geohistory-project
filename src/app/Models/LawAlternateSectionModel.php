<?php

namespace App\Models;

use App\Models\BaseModel;

class LawAlternateSectionModel extends BaseModel
{
    public function getDetail(int|string $id): array
    {
        if (!is_int($id)) {
            $id = $this->getSlugId($id);
        }

        $query = <<<QUERY
                SELECT DISTINCT lawalternatesection.lawalternatesectionid AS lawsectionid,
                    lawalternatesection.lawalternatesectionpagefrom AS lawsectionpagefrom,
                    lawalternatesection.lawalternatesectioncitation AS lawsectioncitation,
                    CASE
                        WHEN (NOT ?) AND left(law.lawtitle, 1) = '~' THEN ''
                        ELSE law.lawtitle
                    END AS lawtitle,
                    '' AS url,
                    source.sourcetype,
                    source.sourceabbreviation,
                    source.sourcefullcitation
                FROM geohistory.source
                JOIN geohistory.lawalternate
                    ON source.sourceid = lawalternate.source
                JOIN geohistory.law
                    ON lawalternate.law = law.lawid
                JOIN geohistory.lawalternatesection
                    ON lawalternate.lawalternateid = lawalternatesection.lawalternate
                    AND lawalternatesection.lawalternatesectionid = ?
            QUERY;

        $query = $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            $id,
        ]);

        return $this->getObject($query);
    }

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
                JOIN geohistory.lawalternatesection
                    ON currentlawsection.lawsectionid = lawalternatesection.lawsection
                    AND lawalternatesection.lawalternatesectionid = ?
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
                JOIN geohistory.lawalternatesection
                    ON lawsection.lawsectionamend = lawalternatesection.lawsection
                    AND lawalternatesection.lawalternatesectionid = ?
                UNION
                SELECT DISTINCT lawsection.lawsectionslug,
                    law.lawapproved,
                    lawsection.lawsectioncitation,
                    'Lead'::text AS lawsectioneventrelationship,
                    lawsection.lawsectionfrom,
                    law.lawnumberchapter
                FROM geohistory.law
                JOIN geohistory.lawsection
                    ON law.lawid = lawsection.law
                JOIN geohistory.lawalternatesection
                    ON lawsection.lawsectionid = lawalternatesection.lawsection
                    AND lawalternatesection.lawalternatesectionid = ?
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
                JOIN geohistory.lawalternatesection currentlawsection
                    ON lawalternatesection.lawsection = currentlawsection.lawsection
                    AND lawalternatesection.lawalternatesectionid <> currentlawsection.lawalternatesectionid
                    AND currentlawsection.lawalternatesectionid = ?
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

    private function getSlugId(string $id): int
    {
        $query = <<<QUERY
                SELECT lawalternatesection.lawsectionid AS id
                    FROM geohistory.lawalternatesection
                WHERE lawalternatesection.lawalternatesectionslug = ?
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
