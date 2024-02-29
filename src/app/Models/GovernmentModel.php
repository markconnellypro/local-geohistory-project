<?php

namespace App\Models;

use CodeIgniter\Model;

class GovernmentModel extends Model
{
    // extra.governmentabbreviationid(text)
    // NOT REMOVED

    public function getAbbreviationId($id)
    {
        $query = <<<QUERY
            SELECT governmentid
            FROM geohistory.government
            WHERE governmentabbreviation = ?
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

    // extra.ci_model_search_lookup_government(character varying, character varying)

    // FUNCTION: extra.punctuationnone
    // FUNCTION: extra.punctuationnonefuzzy
    // VIEW: extra.governmentextracache
    // VIEW: extra.governmentrelationcache

    public function getLookupByGovernment($state, $government)
    {
        if (strlen($government) < 3) {
            return [];
        }

        $query = <<<QUERY
            SELECT DISTINCT governmentrelationcache.governmentshort,
                extra.punctuationnone(governmentrelationcache.governmentshort) AS governmentsearch
            FROM extra.governmentrelationcache
            JOIN extra.governmentextracache
                ON governmentrelationcache.governmentid = governmentextracache.governmentid
                AND NOT governmentextracache.governmentisplaceholder
            WHERE governmentrelationcache.governmentlevel > 2
                AND (governmentrelationcache.governmentrelationstate = ?
                OR governmentrelationcache.governmentrelationstate IS NULL)
                AND extra.punctuationnone(governmentrelationcache.governmentshort) LIKE extra.punctuationnonefuzzy(?)
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            strtoupper($state),
            rawurldecode($government) . '%',
        ])->getResultArray();

        return $query ?? [];
    }

    // extra.ci_model_search_lookup_governmentparent(text, text)

    // FUNCTION: extra.punctuationnone
    // FUNCTION: extra.punctuationnonefuzzy
    // VIEW: extra.governmentextracache
    // VIEW: extra.governmentrelationcache

    public function getLookupByGovernmentParent($state, $government)
    {
        $query = <<<QUERY
            SELECT DISTINCT governmentextracache.governmentshort,
                extra.punctuationnone(governmentrelationcache.governmentshort) AS governmentsearch
            FROM extra.governmentrelationcache
            JOIN extra.governmentrelationcache lookupgovernment
                ON governmentrelationcache.governmentid = lookupgovernment.governmentid
                AND lookupgovernment.governmentid <> lookupgovernment.governmentrelation
                AND lookupgovernment.governmentrelationlevel > 2
                AND lookupgovernment.governmentlevel <> lookupgovernment.governmentrelationlevel
            JOIN extra.governmentextracache
                ON lookupgovernment.governmentrelation = governmentextracache.governmentid
                AND NOT governmentextracache.governmentisplaceholder
            WHERE (governmentrelationcache.governmentrelationstate = ?
                OR governmentrelationcache.governmentrelationstate IS NULL)
                AND extra.punctuationnone(governmentrelationcache.governmentshort) LIKE extra.punctuationnonefuzzy(?)
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            strtoupper($state),
            rawurldecode($government),
        ])->getResultArray();

        return $query ?? [];
    }

    // extra.ci_model_search_form_tribunalgovernmentshort(character varying)
    
    // FUNCTION: extra.governmentabbreviationid
    // FUNCTION: extra.governmentcurrentleadparent
    // VIEW: governmentrelationcache

    public function getSearch($state)
    {
        $query = <<<QUERY
            SELECT DISTINCT governmentrelationcache.governmentshort,
                lpad(governmentrelationcache.governmentid::text, 6, '0') AS governmentid,
                governmentrelationcache.governmentlevel
            FROM extra.governmentrelationcache
            WHERE (governmentrelationcache.governmentlevel = 3
                AND (governmentrelationcache.governmentrelationstate = ?
                OR governmentrelationcache.governmentrelationstate IS NULL))
                OR (governmentrelationcache.governmentlevel = 2
                AND governmentrelationcache.governmentrelationstate = ?)
                OR (governmentrelationcache.governmentlevel = 1
                AND governmentrelationcache.governmentid = extra.governmentcurrentleadparent(extra.governmentabbreviationid(?)))
            ORDER BY governmentrelationcache.governmentlevel, 1
        QUERY;

        $query = $this->db->query($query, [
            strtoupper($state),
            strtoupper($state),
            strtoupper($state),
        ])->getResultArray();

        return $query ?? [];
    }

    // extra.ci_model_search_government_government(text, text, text, integer, text, character varying)

    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentstatelink
    // VIEW: extra.governmentextracache
    // VIEW: extra.governmentrelationcache

    public function getSearchByGovernment($parameters)
    {
        $state = $parameters[0];
        $government = $parameters[1];
        $parent = $parameters[2];
        $level = $parameters[3];
        $type = $parameters[4];
        $locale = $parameters[5];

        $query = <<<QUERY
            WITH selectedgovernment AS (
                SELECT DISTINCT governmentrelationcache.governmentid
                FROM extra.governmentrelationcache
                JOIN extra.governmentrelationcache lookupgovernment
                    ON governmentrelationcache.governmentid = lookupgovernment.governmentid
                    AND lookupgovernment.governmentid <> lookupgovernment.governmentrelation
                JOIN extra.governmentextracache governmentparentextracache
                    ON lookupgovernment.governmentrelation = governmentparentextracache.governmentid
                    AND (? = ''::text OR governmentparentextracache.governmentshort = ?)
                WHERE (
                    governmentrelationcache.governmentrelationstate = ?
                    OR governmentrelationcache.governmentrelationstate IS NULL
                ) AND (
                    governmentrelationcache.governmentshort ILIKE ?
                    OR (? = 'statewide' AND governmentrelationcache.governmentlevel = 2)
                )
            )
            SELECT DISTINCT extra.governmentstatelink(CASE
                    WHEN government.governmentstatus IN ('alternate', 'language') THEN government.governmentsubstitute
                    ELSE government.governmentid
                END, ?, ?) AS governmentstatelink,
                extra.governmentlong(government.governmentid, ?) AS governmentlong
                FROM selectedgovernment
                JOIN extra.governmentrelationcache
                ON selectedgovernment.governmentid = governmentrelationcache.governmentid 
                AND governmentrelationcache.governmentrelationlevel = ?
                AND (? = 'government' OR governmentrelationcache.governmentrelationlevel < 4)
                JOIN geohistory.government
                ON governmentrelationcache.governmentrelation = government.governmentid
            UNION DISTINCT
            SELECT DISTINCT extra.governmentstatelink(CASE
                    WHEN government.governmentstatus IN ('alternate', 'language') THEN government.governmentsubstitute
                    ELSE government.governmentid
                END, ?, ?) AS governmentstatelink,
                extra.governmentlong(government.governmentid, ?) AS governmentlong
                FROM selectedgovernment
                JOIN extra.governmentrelationcache
                ON selectedgovernment.governmentid = governmentrelationcache.governmentrelation
                AND governmentrelationcache.governmentlevel = ?
                AND (? = 'government' OR governmentrelationcache.governmentlevel < 4)
                JOIN geohistory.government
                ON governmentrelationcache.governmentid = government.governmentid
            ORDER BY 2
        QUERY;

        $query = $this->db->query($query, [
            $parent,
            $parent,
            strtoupper($state),
            $government,
            $type,
            $state,
            $locale,
            strtoupper($state),
            $level,
            $type,
            $state,
            $locale,
            strtoupper($state),
            $level,
            $type
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_search_form_detail(character varying)
    // REMOVED
    // extra.governmentslug(integer)
    // NOT REMOVED

    // VIEW: extra.governmentextracache

    public function getSlug($id)
    {
        $query = <<<QUERY
            SELECT CASE
                WHEN governmentextracache.governmentsubstituteslug IS NULL THEN governmentextracache.governmentslug
                ELSE governmentextracache.governmentsubstituteslug
            END AS id
            FROM extra.governmentextracache
            WHERE governmentextracache.governmentid = ?
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResult();

        $id = '';

        if (count($query) == 1) {
            $id = $query[0]->id;
        }
        
        return $id;
    }
}