<?php

namespace App\Models;

use CodeIgniter\Model;

class AffectedGovernmentGroupModel extends Model
{
    // extra.ci_model_event_affectedgovernmentform(integer, character varying, boolean, character varying)

    // FUNCTION: extra.governmentformlong
    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentstatelink

    public function getByEventForm($id, $state)
    {
        $query = <<<QUERY
            SELECT DISTINCT extra.governmentstatelink(affectedgovernmentpart.governmentto, ?, ?) AS governmentstatelink,
                extra.governmentlong(affectedgovernmentpart.governmentto, ?) AS governmentlong,
                extra.governmentformlong(affectedgovernmentpart.governmentformto, ?) governmentformlong
            FROM geohistory.affectedgovernmentgroup
            JOIN geohistory.affectedgovernmentgrouppart
                ON affectedgovernmentgroup.event = ?
                AND affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
            JOIN geohistory.affectedgovernmentpart
                ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
                AND affectedgovernmentpart.governmentformto IS NOT NULL
            ORDER BY 3, 2
        QUERY;

        $query = $this->db->query($query, [
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            \App\Controllers\BaseController::isLive(),
            $id,
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_event_affectedgovernment(integer)

    public function getByEventGeometry($id)
    {
        $query = <<<QUERY
            SELECT DISTINCT affectedgovernmentgroup.affectedgovernmentgroupid AS id,
                public.st_asgeojson(public.st_buffer(public.st_collect(governmentshape.governmentshapegeometry), 0)) AS geometry
            FROM geohistory.affectedgovernmentgroup
            JOIN gis.affectedgovernmentgis
                ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgis.affectedgovernment
                AND affectedgovernmentgroup.event = ?
            JOIN gis.governmentshape
                ON affectedgovernmentgis.governmentshape = governmentshape.governmentshapeid
            GROUP BY 1
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ])->getResultArray();

        return $query ?? [];
    }

    // extra.ci_model_event_affectedgovernment_part(integer, character varying, character varying)

    // FUNCTION: extra.governmentstatelink
    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.affectedtypeshort
    
    public function getByEventGovernment($id, $state)
    {
        $query = <<<QUERY
            SELECT DISTINCT affectedgovernmentgrouppart.affectedgovernmentgroup AS id,
                affectedgovernmentlevel.affectedgovernmentlevellong AS affectedgovernmentlevellong,
                affectedgovernmentlevel.affectedgovernmentleveldisplayorder AS affectedgovernmentleveldisplayorder,
                affectedgovernmentlevel.affectedgovernmentlevelgroup = 4 AS includelink,
                COALESCE(extra.governmentstatelink(affectedgovernmentpart.governmentfrom, ?, ?), '') AS governmentfrom,
                COALESCE(extra.governmentlong(affectedgovernmentpart.governmentfrom, ?), '') AS governmentfromlong,
                COALESCE(extra.affectedtypeshort(affectedgovernmentpart.affectedtypefrom), '') AS affectedtypefrom,
                COALESCE(extra.governmentstatelink(affectedgovernmentpart.governmentto, ?, ?), '') AS governmentto,
                COALESCE(extra.governmentlong(affectedgovernmentpart.governmentto, ?), '') AS governmenttolong,
                COALESCE(extra.affectedtypeshort(affectedgovernmentpart.affectedtypeto), '') AS affectedtypeto
            FROM geohistory.affectedgovernmentgroup
            JOIN geohistory.affectedgovernmentgrouppart
                ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
                AND affectedgovernmentgroup.event = ?
            JOIN geohistory.affectedgovernmentlevel
                ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
            JOIN geohistory.affectedgovernmentpart
                ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
            ORDER BY 1, 2
        QUERY;

        $query = $this->db->query($query, [
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $id,
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_government_affectedgovernmentform(integer, character varying, boolean)

    // FUNCTION: extra.eventsortdate
    // FUNCTION: extra.governmentformlong
    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate
    // VIEW: extra.eventextracache
    // VIEW: extra.governmentsubstitute

    public function getByGovernmentForm($id, $state)
    {
        $query = <<<QUERY
            SELECT DISTINCT extra.eventsortdate(event.eventid) AS eventsortdate,
                event.eventid AS event,
                eventextracache.eventslug,
                extra.governmentformlong(affectedgovernmentpart.governmentformto, ?) governmentformlong,
                extra.rangefix(event.eventfrom::text, event.eventto::text) AS eventrange,
                extra.shortdate(event.eventeffective) AS eventeffective,
                event.eventeffective AS eventeffectivesort,
                NOT eventgranted.eventgrantedcertainty AS eventreconstructed,
                extra.governmentlong(affectedgovernmentpart.governmentto, ?) AS governmentaffectedlong
            FROM geohistory.event
            JOIN extra.eventextracache
                ON event.eventid = eventextracache.eventid
                AND eventextracache.eventslugnew IS NULL
            JOIN geohistory.eventgranted
                ON event.eventgranted = eventgranted.eventgrantedid
                AND eventgranted.eventgrantedsuccess
            JOIN geohistory.affectedgovernmentgroup
                ON event.eventid = affectedgovernmentgroup.event
            JOIN geohistory.affectedgovernmentgrouppart
                ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
            JOIN geohistory.affectedgovernmentpart
                ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
                AND affectedgovernmentpart.governmentformto IS NOT NULL
            JOIN extra.governmentsubstitute
                ON affectedgovernmentpart.governmentto = governmentsubstitute.governmentid
                AND governmentsubstitute.governmentsubstitute = ?
            ORDER BY 1, 4
        QUERY;

        $query = $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            strtoupper($state),
            $id,
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_government_affectedgovernment(integer, character varying, character varying)
    // NOT REMOVED

    // FUNCTION: extra.eventsortdate
    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentstatelink
    // FUNCTION: extra.governmentsubstitutedcache
    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate
    // VIEW: extra.eventextracache
    // VIEW: extra.governmentsubstitutecache

    public function getByGovernmentGovernment($id, $state)
    {
        $query = <<<QUERY
            SELECT DISTINCT extra.eventsortdate(event.eventid) AS eventsortdate,
                affectedgovernment.event,
                eventextracache.eventslug,
                affectedtypesame.affectedtypeshort || CASE
                    WHEN affectedgovernment.affectedtypesamewithin THEN ' (Within)'
                    ELSE ''
                END AS affectedtypesame,
                extra.governmentlong(affectedgovernment.government, ?) AS governmentlong,
                CASE
                    WHEN affectedgovernment.government = ANY (extra.governmentsubstitutedcache(?)) THEN ''
                    ELSE extra.governmentstatelink(affectedgovernment.government, ?, ?)
                END AS governmentstatelink,
                affectedtypeother.affectedtypeshort || CASE
                    WHEN affectedgovernment.affectedtypeotherwithin THEN ' (Within)'
                    ELSE ''
                END AS affectedtypeother,
                extra.rangefix(event.eventfrom::text, event.eventto::text) AS eventrange,
                extra.shortdate(event.eventeffective) AS eventeffective,
                event.eventeffective AS eventeffectivesort,
                NOT eventgranted.eventgrantedcertainty AS eventreconstructed,
                extra.governmentlong(affectedgovernment.governmentaffected, ?) AS governmentaffectedlong
            FROM (
                -- To-From
                    SELECT DISTINCT affectedgovernmentgroup.event,
                        affectedgovernmentpart.affectedtypeto AS affectedtypesame,
                        FALSE AS affectedtypesamewithin,
                        affectedgovernmentpart.governmentfrom AS government,
                        affectedgovernmentpart.affectedtypefrom AS affectedtypeother,
                        FALSE AS affectedtypeotherwithin,
                        affectedgovernmentpart.governmentto AS governmentaffected
                    FROM geohistory.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentpart
                        ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
                    JOIN extra.governmentsubstitutecache
                        ON affectedgovernmentpart.governmentto = governmentsubstitutecache.governmentid
                        AND governmentsubstitutecache.governmentsubstitute = ?
                    UNION
                -- From-To
                    SELECT DISTINCT affectedgovernmentgroup.event,
                        affectedgovernmentpart.affectedtypefrom AS affectedtypesame,
                        FALSE AS affectedtypesamewithin,
                        affectedgovernmentpart.governmentto AS government,
                        affectedgovernmentpart.affectedtypeto AS affectedtypeother,
                        FALSE AS affectedtypeotherwithin,
                        affectedgovernmentpart.governmentfrom AS governmentaffected
                    FROM geohistory.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentpart
                        ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
                    JOIN extra.governmentsubstitutecache
                        ON affectedgovernmentpart.governmentfrom = governmentsubstitutecache.governmentid
                        AND governmentsubstitutecache.governmentsubstitute = ?
                    UNION
                -- From-To (Different Level)
                    SELECT DISTINCT affectedgovernmentgroup.event,
                        affectedgovernmentpart.affectedtypefrom AS affectedtypesame,
                        affectedgovernmentlevel.affectedgovernmentleveldisplayorder < otherlevel.affectedgovernmentleveldisplayorder AS affectedtypesamewithin,
                        otherpart.governmentto AS government,
                        otherpart.affectedtypeto AS affectedtypeother,
                        affectedgovernmentlevel.affectedgovernmentleveldisplayorder > otherlevel.affectedgovernmentleveldisplayorder AS affectedtypeotherwithin,
                        affectedgovernmentpart.governmentfrom AS governmentaffected
                    FROM geohistory.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentpart
                        ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
                    JOIN extra.governmentsubstitutecache
                        ON affectedgovernmentpart.governmentfrom = governmentsubstitutecache.governmentid
                        AND governmentsubstitutecache.governmentsubstitute = ?
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                    JOIN geohistory.affectedgovernmentlevel otherlevel
                        ON affectedgovernmentlevel.affectedgovernmentlevelgroup = otherlevel.affectedgovernmentlevelgroup
                        AND affectedgovernmentlevel.affectedgovernmentlevelid <> otherlevel.affectedgovernmentlevelid
                    JOIN geohistory.affectedgovernmentgrouppart othergrouppart
                        ON affectedgovernmentgroup.affectedgovernmentgroupid = othergrouppart.affectedgovernmentgroup
                        AND othergrouppart.affectedgovernmentlevel = otherlevel.affectedgovernmentlevelid
                    JOIN geohistory.affectedgovernmentpart otherpart
                        ON othergrouppart.affectedgovernmentpart = otherpart.affectedgovernmentpartid
                        AND otherpart.governmentto IS NOT NULL
                    UNION
                -- To-From (Different Level)
                    SELECT DISTINCT affectedgovernmentgroup.event,
                        affectedgovernmentpart.affectedtypeto AS affectedtypesame,
                        affectedgovernmentlevel.affectedgovernmentleveldisplayorder < otherlevel.affectedgovernmentleveldisplayorder AS affectedtypesamewithin,
                        otherpart.governmentfrom AS government,
                        otherpart.affectedtypefrom AS affectedtypeother,
                        affectedgovernmentlevel.affectedgovernmentleveldisplayorder > otherlevel.affectedgovernmentleveldisplayorder AS affectedtypeotherwithin,
                        affectedgovernmentpart.governmentto AS governmentaffected
                    FROM geohistory.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentgrouppart
                        ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
                    JOIN geohistory.affectedgovernmentpart
                        ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
                    JOIN extra.governmentsubstitutecache
                        ON affectedgovernmentpart.governmentto = governmentsubstitutecache.governmentid
                        AND governmentsubstitutecache.governmentsubstitute = ?
                    JOIN geohistory.affectedgovernmentlevel
                        ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
                    JOIN geohistory.affectedgovernmentlevel otherlevel
                        ON affectedgovernmentlevel.affectedgovernmentlevelgroup = otherlevel.affectedgovernmentlevelgroup
                        AND affectedgovernmentlevel.affectedgovernmentlevelid <> otherlevel.affectedgovernmentlevelid
                    JOIN geohistory.affectedgovernmentgrouppart othergrouppart
                        ON affectedgovernmentgroup.affectedgovernmentgroupid = othergrouppart.affectedgovernmentgroup
                        AND othergrouppart.affectedgovernmentlevel = otherlevel.affectedgovernmentlevelid
                    JOIN geohistory.affectedgovernmentpart otherpart
                        ON othergrouppart.affectedgovernmentpart = otherpart.affectedgovernmentpartid
                        AND otherpart.governmentfrom IS NOT NULL
            ) AS affectedgovernment
                JOIN geohistory.event
                ON affectedgovernment.event = event.eventid
                JOIN extra.eventextracache
                ON event.eventid = eventextracache.eventid
                AND eventextracache.eventslugnew IS NULL
                JOIN geohistory.eventgranted
                ON event.eventgranted = eventgranted.eventgrantedid
                AND eventgranted.eventgrantedsuccess
                JOIN geohistory.affectedtype affectedtypesame
                ON affectedgovernment.affectedtypesame = affectedtypesame.affectedtypeid
                JOIN geohistory.affectedtype affectedtypeother
                ON affectedgovernment.affectedtypeother = affectedtypeother.affectedtypeid
            WHERE affectedgovernment.government <> affectedgovernment.governmentaffected
                AND NOT (
                (
                    affectedtypesame.affectedtypecreationdissolution = ''
                    AND affectedtypeother.affectedtypecreationdissolution = ''
                ) OR (
                    affectedtypesame.affectedtypecreationdissolution IN ('separate', 'subordinate')
                    AND affectedgovernment.affectedtypesamewithin
                ) OR (
                    affectedtypeother.affectedtypecreationdissolution IN ('separate', 'subordinate')
                    AND affectedgovernment.affectedtypeotherwithin
                )
                )
                AND affectedtypesame.affectedtypecreationdissolution <> 'reference'
                AND affectedtypeother.affectedtypecreationdissolution <> 'reference'
            ORDER BY 1, 4, 5, 7
        QUERY;

        $query = $this->db->query($query, [
            strtoupper($state),
            $id,
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $id,
            $id,
            $id,
            $id,
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_area_affectedgovernment(v_governmentshape integer, v_state character varying, v_locale character varying)

    // FUNCTION: extra.affectedtypeshort
    // FUNCTION: extra.eventsortdate
    // FUNCTION: extra.governmentabbreviation
    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentshort
    // FUNCTION: extra.governmentstatelink
    // FUNCTION: extra.nulltoempty
    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate


    public function getByGovernmentShape($id, $state)
    {
        $query = <<<QUERY
            WITH foundaffectedgovernment AS (
                SELECT event.eventid,
                eventextracache.eventslug,
                extra.governmentstatelink(affectedgovernment_reconstructed.municipalityfrom, ?, ?) AS municipalityfrom,
                extra.governmentlong(affectedgovernment_reconstructed.municipalityfrom, ?) AS municipalityfromlong,
                extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypemunicipalityfrom) AS affectedtypemunicipalityfrom,
                extra.governmentstatelink(affectedgovernment_reconstructed.countyfrom, ?, ?) AS countyfrom,
                extra.governmentshort(affectedgovernment_reconstructed.countyfrom, ?) AS countyfromshort,
                extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypecountyfrom) AS affectedtypecountyfrom,
                extra.governmentstatelink(affectedgovernment_reconstructed.statefrom, ?, ?) AS statefrom,
                extra.governmentabbreviation(affectedgovernment_reconstructed.statefrom) AS statefromabbreviation,
                extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypestatefrom) AS affectedtypestatefrom,
                extra.governmentstatelink(affectedgovernment_reconstructed.municipalityto, ?, ?) AS municipalityto,
                extra.governmentlong(affectedgovernment_reconstructed.municipalityto, ?) AS municipalitytolong,
                extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypemunicipalityto) AS affectedtypemunicipalityto,
                extra.governmentstatelink(affectedgovernment_reconstructed.countyto, ?, ?) AS countyto,
                extra.governmentshort(affectedgovernment_reconstructed.countyto, ?) AS countytoshort,
                extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypecountyto) AS affectedtypecountyto,
                extra.governmentstatelink(affectedgovernment_reconstructed.stateto, ?, ?) AS stateto,
                extra.governmentabbreviation(affectedgovernment_reconstructed.stateto) AS statetoabbreviation,
                extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypestateto) AS affectedtypestateto,
                CASE WHEN affectedgovernment_reconstructed.submunicipalityfrom IS NOT NULL 
                    OR affectedgovernment_reconstructed.submunicipalityto IS NOT NULL
                    OR affectedgovernment_reconstructed.subcountyfrom IS NOT NULL
                    OR affectedgovernment_reconstructed.subcountyto IS NOT NULL THEN TRUE ELSE FALSE END AS textflag,
                extra.nulltoempty(extra.governmentstatelink(affectedgovernment_reconstructed.submunicipalityfrom, ?, ?)) AS submunicipalityfrom,
                extra.nulltoempty(extra.governmentlong(affectedgovernment_reconstructed.submunicipalityfrom, ?)) AS submunicipalityfromlong,
                extra.nulltoempty(extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypesubmunicipalityfrom)) AS affectedtypesubmunicipalityfrom,
                extra.nulltoempty(extra.governmentstatelink(affectedgovernment_reconstructed.submunicipalityto, ?, ?)) AS submunicipalityto,
                extra.nulltoempty(extra.governmentlong(affectedgovernment_reconstructed.submunicipalityto, ?)) AS submunicipalitytolong,
                extra.nulltoempty(extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypesubmunicipalityto)) AS affectedtypesubmunicipalityto,
                extra.nulltoempty(extra.governmentstatelink(affectedgovernment_reconstructed.subcountyfrom, ?, ?)) AS subcountyfrom,
                extra.nulltoempty(extra.governmentshort(affectedgovernment_reconstructed.subcountyfrom, ?)) AS subcountyfromshort,
                extra.nulltoempty(extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypesubcountyfrom)) AS affectedtypesubcountyfrom,
                extra.nulltoempty(extra.governmentstatelink(affectedgovernment_reconstructed.subcountyto, ?, ?)) AS subcountyto,
                extra.nulltoempty(extra.governmentshort(affectedgovernment_reconstructed.subcountyto, ?)) AS subcountytoshort,
                extra.nulltoempty(extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypesubcountyto)) AS affectedtypesubcountyto,
                extra.rangefix(event.eventfrom::text, event.eventto::text) AS eventrange,
                extra.shortdate(event.eventeffective) AS eventeffective,
                extra.eventsortdate(event.eventid) AS eventsortdate,
                (ROW_NUMBER () OVER (ORDER BY extra.eventsortdate(event.eventid), event.eventid))::integer AS eventorder,
                (ROW_NUMBER () OVER (ORDER BY extra.eventsortdate(event.eventid) DESC, event.eventid DESC))::integer AS eventorderreverse
                FROM geohistory.event
                JOIN geohistory.eventgranted
                ON event.eventgranted = eventgranted.eventgrantedid
                AND eventgranted.eventgrantedsuccess
                JOIN extra.eventextracache
                ON event.eventid = eventextracache.eventid
                AND eventextracache.eventslugnew IS NULL
                JOIN extra.affectedgovernment_reconstructed
                ON affectedgovernment_reconstructed.event = event.eventid
                JOIN gis.affectedgovernmentgis
                ON affectedgovernment_reconstructed.affectedgovernmentid = affectedgovernmentgis.affectedgovernment
                WHERE affectedgovernmentgis.governmentshape = ?
                GROUP BY 1, eventslug, municipalityfrom, municipalityfromlong, affectedtypemunicipalityfrom, countyfrom, countyfromshort, affectedtypecountyfrom, statefrom, statefromabbreviation, affectedtypestatefrom, municipalityto, municipalitytolong, affectedtypemunicipalityto, countyto, countytoshort, affectedtypecountyto, stateto, statetoabbreviation, affectedtypestateto, submunicipalityfrom, submunicipalityfromlong, affectedtypesubmunicipalityfrom, submunicipalityto, submunicipalitytolong, affectedtypesubmunicipalityto, subcountyfrom, subcountyfromshort, affectedtypesubcountyfrom, subcountyto, subcountytoshort, affectedtypesubcountyto, extra.rangefix(event.eventfrom::text, event.eventto::text), extra.shortdate(event.eventeffective), extra.eventsortdate(event.eventid)
            ), currentgovernment AS (
                -- Taken from GovernmentShapeModel->getDetail
                SELECT DISTINCT governmentshape.governmentshapeid,
                    COALESCE(extra.governmentstatelink(governmentshape.governmentsubmunicipality, ?, ?), '') AS governmentsubmunicipality,
                    COALESCE(extra.governmentlong(governmentshape.governmentsubmunicipality, ?), '') AS governmentsubmunicipalitylong,
                    extra.governmentstatelink(governmentshape.governmentmunicipality, ?, ?) AS governmentmunicipality,
                    extra.governmentlong(governmentshape.governmentmunicipality, ?) AS governmentmunicipalitylong,
                    extra.governmentstatelink(governmentshape.governmentcounty, ?, ?) AS governmentcounty,
                    extra.governmentshort(governmentshape.governmentcounty, ?) AS governmentcountyshort,
                    extra.governmentstatelink(governmentshape.governmentstate, ?, ?) AS governmentstate,
                    extra.governmentabbreviation(governmentshape.governmentstate) AS governmentstateabbreviation,
                    governmentshape.governmentshapeid AS id,
                    public.st_asgeojson(governmentshape.governmentshapegeometry) AS geometry
                FROM gis.governmentshape
                LEFT JOIN extra.areagovernmentcache
                ON governmentshape.governmentshapeid = areagovernmentcache.governmentshapeid
                WHERE governmentshape.governmentshapeid = ?
                AND (governmentrelationstate = ? OR governmentrelationstate IS NULL)
            )
            SELECT eventid, eventslug, municipalityfrom, municipalityfromlong, affectedtypemunicipalityfrom, countyfrom, countyfromshort, affectedtypecountyfrom, statefrom, statefromabbreviation, affectedtypestatefrom, municipalityto, municipalitytolong, affectedtypemunicipalityto, countyto, countytoshort, affectedtypecountyto, stateto, statetoabbreviation, affectedtypestateto, textflag, submunicipalityfrom, submunicipalityfromlong, affectedtypesubmunicipalityfrom, submunicipalityto, submunicipalitytolong, affectedtypesubmunicipalityto, subcountyfrom, subcountyfromshort, affectedtypesubcountyfrom, subcountyto, subcountytoshort, affectedtypesubcountyto, eventrange, eventeffective, eventsortdate, 
               (eventorder * 2 - 1) AS eventorder
            FROM foundaffectedgovernment
            UNION
            SELECT NULL AS eventid,
               '' AS eventslug,
               oldg.municipalityto AS municipalityfrom,
               oldg.municipalitytolong AS municipalityfromlong,
               'Missing' AS affectedtypemunicipalityfrom,
               oldg.countyto AS countyfrom,
               oldg.countytoshort AS countyfromshort,
               'Missing' AS affectedtypecountyfrom,
               oldg.stateto AS statefrom,
               oldg.statetoabbreviation AS statefromabbreviation,
               'Missing' AS affectedtypestatefrom,
               newg.municipalityfrom AS municipalityto,
               newg.municipalityfromlong AS municipalitytolong,
               'Missing' AS affectedtypemunicipalityto,
               newg.countyfrom AS countyto,
               newg.countyfromshort AS countytoshort,
               'Missing' AS affectedtypecountyto,
               newg.statefrom AS stateto,
               newg.statefromabbreviation AS statetoabbreviation,
               'Missing' AS affectedtypestateto,
               oldg.textflag OR newg.textflag AS textflag,
               oldg.submunicipalityto AS submunicipalityfrom,
               oldg.submunicipalitytolong AS submunicipalityfromlong,
               CASE WHEN oldg.submunicipalityto = '' THEN '' ELSE 'Missing' END AS affectedtypesubmunicipalityfrom,
               newg.submunicipalityfrom AS submunicipalityto,
               newg.submunicipalityfromlong AS submunicipalitytolong,
               CASE WHEN newg.submunicipalityfrom = '' THEN '' ELSE 'Missing' END AS affectedtypesubmunicipalityto,
               oldg.subcountyto AS subcountyfrom,
               oldg.subcountytoshort AS subcountyfromshort,
               CASE WHEN oldg.subcountyto = '' THEN '' ELSE 'Missing' END AS affectedtypesubcountyfrom,
               newg.subcountyfrom AS subcountyto,
               newg.subcountyfromshort AS subcountytoshort,
               CASE WHEN newg.subcountyfrom = '' THEN '' ELSE 'Missing' END AS affectedtypesubcountyto,
               '' AS eventrange,
               '' AS eventeffective,
               NULL AS eventsortdate,
               (oldg.eventorder * 2) AS eventorder
            FROM foundaffectedgovernment oldg
            JOIN foundaffectedgovernment newg
               ON oldg.eventorder = newg.eventorder - 1
               AND NOT (
                 oldg.submunicipalityto = newg.submunicipalityfrom AND
                 oldg.subcountyto = newg.subcountyfrom AND
                 oldg.municipalityto = newg.municipalityfrom AND
                 oldg.countyto = newg.countyfrom AND
                 (oldg.stateto = newg.statefrom OR oldg.statetoabbreviation ~ ('^' || newg.statefromabbreviation || '[\-][A-Z]$'))
               )
            UNION
            SELECT NULL AS eventid,
               '' AS eventslug,
               oldg.municipalityto AS municipalityfrom,
               oldg.municipalitytolong AS municipalityfromlong,
               'Missing' AS affectedtypemunicipalityfrom,
               oldg.countyto AS countyfrom,
               oldg.countytoshort AS countyfromshort,
               'Missing' AS affectedtypecountyfrom,
               oldg.stateto AS statefrom,
               oldg.statetoabbreviation AS statefromabbreviation,
               'Missing' AS affectedtypestatefrom,
               newg.governmentmunicipality AS municipalityto,
               newg.governmentmunicipalitylong AS municipalitytolong,
               'Missing' AS affectedtypemunicipalityto,
               newg.governmentcounty AS countyto,
               newg.governmentcountyshort AS countytoshort,
               'Missing' AS affectedtypecountyto,
               newg.governmentstate AS stateto,
               newg.governmentstateabbreviation AS statetoabbreviation,
               'Missing' AS affectedtypestateto,
               oldg.textflag OR newg.governmentsubmunicipality <> '' AS textflag,
               oldg.submunicipalityto AS submunicipalityfrom,
               oldg.submunicipalitytolong AS submunicipalityfromlong,
               CASE WHEN oldg.submunicipalityto = '' THEN '' ELSE 'Missing' END AS affectedtypesubmunicipalityfrom,
               newg.governmentsubmunicipality AS submunicipalityto,
               newg.governmentsubmunicipalitylong AS submunicipalitytolong,
               CASE WHEN newg.governmentsubmunicipality = '' THEN '' ELSE 'Missing' END AS affectedtypesubmunicipalityto,
               oldg.subcountyto AS subcountyfrom,
               oldg.subcountytoshort AS subcountyfromshort,
               CASE WHEN oldg.subcountyto = '' THEN '' ELSE 'Missing' END AS affectedtypesubcountyfrom,
               '' AS subcountyto,
               '' AS subcountytoshort,
               '' AS affectedtypesubcountyto,
               '' AS eventrange,
               '' AS eventeffective,
               NULL AS eventsortdate,
               (oldg.eventorder * 2) AS eventorder
            FROM foundaffectedgovernment oldg,
               currentgovernment newg
            WHERE oldg.eventorderreverse = 1
               AND NOT (
                 oldg.submunicipalityto = newg.governmentsubmunicipality AND
                 oldg.municipalityto = newg.governmentmunicipality AND
                 oldg.countyto = newg.governmentcounty AND
                 (oldg.stateto = newg.governmentstate OR oldg.statetoabbreviation ~ ('^' || newg.governmentstateabbreviation || '[\-][A-Z]$'))
               )
            ORDER BY 37
        QUERY;

        $query = $this->db->query($query, [
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $state,
            \Config\Services::request()->getLocale(), 
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $state,
            \Config\Services::request()->getLocale(), 
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $id,
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $state,
            \Config\Services::request()->getLocale(),
            strtoupper($state),
            $state,
            \Config\Services::request()->getLocale(),
            $id,
            strtoupper($state),
        ])->getResult();

        return $query ?? [];
    }
}