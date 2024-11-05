<?php

namespace App\Models;

use App\Models\BaseModel;

class AffectedGovernmentGroupModel extends BaseModel
{
    // extra.ci_model_event_affectedgovernmentform(integer, character varying, boolean, character varying)

    public function getByEventForm(int $id): array
    {
        $query = <<<QUERY
            SELECT DISTINCT government.governmentslugsubstitute AS governmentslug,
                government.governmentlong,
                governmentform.governmentformlong
            FROM geohistory.affectedgovernmentgroup
            JOIN geohistory.affectedgovernmentgrouppart
                ON affectedgovernmentgroup.event = ?
                AND affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
            JOIN geohistory.affectedgovernmentpart
                ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
                AND affectedgovernmentpart.governmentformto IS NOT NULL
            JOIN geohistory.government
                ON affectedgovernmentpart.governmentto = government.governmentid
            JOIN geohistory.governmentform
                ON affectedgovernmentpart.governmentformto = governmentform.governmentformid
            ORDER BY 3, 2
        QUERY;

        $query = $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            $id,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_event_affectedgovernment(integer)

    public function getByEventGeometry(int $id): array
    {
        $query = <<<QUERY
            SELECT DISTINCT affectedgovernmentgroup.affectedgovernmentgroupid AS id,
                public.st_asgeojson(public.st_buffer(public.st_collect(governmentshape.governmentshapegeometry), 0)) AS geometry,
                lower(array_to_string(array_agg(DISTINCT government.governmentabbreviation ORDER BY government.governmentabbreviation), ',')) AS jurisdictions
            FROM geohistory.affectedgovernmentgroup
            JOIN gis.affectedgovernmentgis
                ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgis.affectedgovernment
                AND affectedgovernmentgroup.event = ?
            JOIN gis.governmentshape
                ON affectedgovernmentgis.governmentshape = governmentshape.governmentshapeid
            JOIN geohistory.government
                ON governmentshape.governmentstate = government.governmentid
            GROUP BY 1
            ORDER BY 1
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getArray($query);
    }

    // extra.ci_model_event_affectedgovernment_part(integer, character varying, character varying)

    public function getByEventGovernment(int $id): array
    {
        $query = <<<QUERY
            SELECT DISTINCT affectedgovernmentgrouppart.affectedgovernmentgroup AS id,
                affectedgovernmentlevel.affectedgovernmentlevellong AS affectedgovernmentlevellong,
                affectedgovernmentlevel.affectedgovernmentleveldisplayorder AS affectedgovernmentleveldisplayorder,
                affectedgovernmentlevel.affectedgovernmentlevelgroup = 4 AS includelink,
                COALESCE(governmentfrom.governmentslugsubstitute, '') AS governmentfrom,
                COALESCE(governmentfrom.governmentlong, '') AS governmentfromlong,
                COALESCE(affectedtypefrom.affectedtypeshort, '') AS affectedtypefrom,
                COALESCE(governmentto.governmentslugsubstitute, '') AS governmentto,
                COALESCE(governmentto.governmentlong, '') AS governmenttolong,
                COALESCE(affectedtypeto.affectedtypeshort, '') AS affectedtypeto
            FROM geohistory.affectedgovernmentgroup
            JOIN geohistory.affectedgovernmentgrouppart
                ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
                AND affectedgovernmentgroup.event = ?
            JOIN geohistory.affectedgovernmentlevel
                ON affectedgovernmentgrouppart.affectedgovernmentlevel = affectedgovernmentlevel.affectedgovernmentlevelid
            JOIN geohistory.affectedgovernmentpart
                ON affectedgovernmentgrouppart.affectedgovernmentpart = affectedgovernmentpart.affectedgovernmentpartid
            LEFT JOIN geohistory.affectedtype affectedtypefrom
                ON affectedgovernmentpart.affectedtypefrom = affectedtypefrom.affectedtypeid
            LEFT JOIN geohistory.affectedtype affectedtypeto
                ON affectedgovernmentpart.affectedtypeto = affectedtypeto.affectedtypeid
            LEFT JOIN geohistory.government governmentfrom
                ON affectedgovernmentpart.governmentfrom = governmentfrom.governmentid
            LEFT JOIN geohistory.government governmentto
                ON affectedgovernmentpart.governmentto = governmentto.governmentid
            ORDER BY 1, 2
        QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        $query = $this->getArray($query);

        $gisQuery = $this->getByEventGeometry($id);

        return $this->getProcess($query, $gisQuery);
    }

    // extra.ci_model_government_affectedgovernmentform(integer, character varying, boolean)

    // VIEW: extra.governmentsubstitute

    public function getByGovernmentForm(int $id): array
    {
        $query = <<<QUERY
            SELECT DISTINCT event.eventsort,
                event.eventid AS event,
                event.eventslug,
                governmentform.governmentformlong,
                event.eventyear,
                event.eventeffectivetext AS eventeffective,
                event.eventeffective AS eventeffectivesort,
                NOT eventgranted.eventgrantedcertainty AS eventreconstructed,
                government.governmentlong AS governmentaffectedlong
            FROM geohistory.event
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
            JOIN geohistory.government
                ON affectedgovernmentpart.governmentto = government.governmentid
            JOIN geohistory.governmentform
                ON affectedgovernmentpart.governmentformto = governmentform.governmentformid
            JOIN extra.governmentsubstitute
                ON affectedgovernmentpart.governmentto = governmentsubstitute.governmentid
                AND governmentsubstitute.governmentsubstitute = ?
            ORDER BY 1, 4
        QUERY;

        $query = $this->db->query($query, [
            \App\Controllers\BaseController::isLive(),
            $id,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_government_affectedgovernment(integer, character varying, character varying)
    // NOT REMOVED

    // FUNCTION: extra.governmentsubstitutedcache
    // VIEW: extra.governmentsubstitutecache

    public function getByGovernmentGovernment(int $id): array
    {
        $query = <<<QUERY
            SELECT DISTINCT event.eventsort,
                affectedgovernment.event,
                event.eventslug,
                affectedtypesame.affectedtypeshort || CASE
                    WHEN affectedgovernment.affectedtypesamewithin THEN ' (Within)'
                    ELSE ''
                END AS affectedtypesame,
                government.governmentlong,
                CASE
                    WHEN affectedgovernment.government = ANY (extra.governmentsubstitutedcache(?)) THEN ''
                    ELSE government.governmentslugsubstitute
                END AS governmentslug,
                affectedtypeother.affectedtypeshort || CASE
                    WHEN affectedgovernment.affectedtypeotherwithin THEN ' (Within)'
                    ELSE ''
                END AS affectedtypeother,
                event.eventyear,
                event.eventeffectivetext AS eventeffective,
                event.eventeffective AS eventeffectivesort,
                NOT eventgranted.eventgrantedcertainty AS eventreconstructed,
                governmentaffected.governmentlong AS governmentaffectedlong
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
                JOIN geohistory.eventgranted
                    ON event.eventgranted = eventgranted.eventgrantedid
                    AND eventgranted.eventgrantedsuccess
                JOIN geohistory.affectedtype affectedtypesame
                    ON affectedgovernment.affectedtypesame = affectedtypesame.affectedtypeid
                JOIN geohistory.affectedtype affectedtypeother
                    ON affectedgovernment.affectedtypeother = affectedtypeother.affectedtypeid
                JOIN geohistory.government
                    ON affectedgovernment.government = government.governmentid
                JOIN geohistory.government governmentaffected
                    ON affectedgovernment.governmentaffected = governmentaffected.governmentid
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
            $id,
            $id,
            $id,
            $id,
            $id,
        ]);

        return $this->getObject($query);
    }

    // extra.ci_model_area_affectedgovernment(v_governmentshape integer, v_state character varying, v_locale character varying)

    // FUNCTION: extra.affectedtypeshort
    // FUNCTION: extra.governmentabbreviation
    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentshort
    // FUNCTION: extra.governmentslug

    public function getByGovernmentShape(int $id): array
    {
        $query = <<<QUERY
            WITH foundaffectedgovernment AS (
                SELECT event.eventid,
                event.eventslug,
                extra.governmentslug(affectedgovernment_reconstructed.municipalityfrom) AS municipalityfrom,
                extra.governmentlong(affectedgovernment_reconstructed.municipalityfrom) AS municipalityfromlong,
                extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypemunicipalityfrom) AS affectedtypemunicipalityfrom,
                extra.governmentslug(affectedgovernment_reconstructed.countyfrom) AS countyfrom,
                extra.governmentshort(affectedgovernment_reconstructed.countyfrom) AS countyfromshort,
                extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypecountyfrom) AS affectedtypecountyfrom,
                extra.governmentslug(affectedgovernment_reconstructed.statefrom) AS statefrom,
                extra.governmentabbreviation(affectedgovernment_reconstructed.statefrom) AS statefromabbreviation,
                extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypestatefrom) AS affectedtypestatefrom,
                extra.governmentslug(affectedgovernment_reconstructed.municipalityto) AS municipalityto,
                extra.governmentlong(affectedgovernment_reconstructed.municipalityto) AS municipalitytolong,
                extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypemunicipalityto) AS affectedtypemunicipalityto,
                extra.governmentslug(affectedgovernment_reconstructed.countyto) AS countyto,
                extra.governmentshort(affectedgovernment_reconstructed.countyto) AS countytoshort,
                extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypecountyto) AS affectedtypecountyto,
                extra.governmentslug(affectedgovernment_reconstructed.stateto) AS stateto,
                extra.governmentabbreviation(affectedgovernment_reconstructed.stateto) AS statetoabbreviation,
                extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypestateto) AS affectedtypestateto,
                CASE WHEN affectedgovernment_reconstructed.submunicipalityfrom IS NOT NULL 
                    OR affectedgovernment_reconstructed.submunicipalityto IS NOT NULL
                    OR affectedgovernment_reconstructed.subcountyfrom IS NOT NULL
                    OR affectedgovernment_reconstructed.subcountyto IS NOT NULL THEN TRUE ELSE FALSE END AS textflag,
                COALESCE(extra.governmentslug(affectedgovernment_reconstructed.submunicipalityfrom), '') AS submunicipalityfrom,
                COALESCE(extra.governmentlong(affectedgovernment_reconstructed.submunicipalityfrom), '') AS submunicipalityfromlong,
                COALESCE(extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypesubmunicipalityfrom), '') AS affectedtypesubmunicipalityfrom,
                COALESCE(extra.governmentslug(affectedgovernment_reconstructed.submunicipalityto), '') AS submunicipalityto,
                COALESCE(extra.governmentlong(affectedgovernment_reconstructed.submunicipalityto), '') AS submunicipalitytolong,
                COALESCE(extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypesubmunicipalityto), '') AS affectedtypesubmunicipalityto,
                COALESCE(extra.governmentslug(affectedgovernment_reconstructed.subcountyfrom), '') AS subcountyfrom,
                COALESCE(extra.governmentshort(affectedgovernment_reconstructed.subcountyfrom), '') AS subcountyfromshort,
                COALESCE(extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypesubcountyfrom), '') AS affectedtypesubcountyfrom,
                COALESCE(extra.governmentslug(affectedgovernment_reconstructed.subcountyto), '') AS subcountyto,
                COALESCE(extra.governmentshort(affectedgovernment_reconstructed.subcountyto), '') AS subcountytoshort,
                COALESCE(extra.affectedtypeshort(affectedgovernment_reconstructed.affectedtypesubcountyto), '') AS affectedtypesubcountyto,
                event.eventyear,
                event.eventeffectivetext AS eventeffective,
                event.eventsort,
                (ROW_NUMBER () OVER (ORDER BY event.eventsort, event.eventid))::integer AS eventorder,
                (ROW_NUMBER () OVER (ORDER BY event.eventsort DESC, event.eventid DESC))::integer AS eventorderreverse
                FROM geohistory.event
                JOIN geohistory.eventgranted
                ON event.eventgranted = eventgranted.eventgrantedid
                AND eventgranted.eventgrantedsuccess
                JOIN extra.affectedgovernment_reconstructed
                ON affectedgovernment_reconstructed.event = event.eventid
                JOIN gis.affectedgovernmentgis
                ON affectedgovernment_reconstructed.affectedgovernmentid = affectedgovernmentgis.affectedgovernment
                WHERE affectedgovernmentgis.governmentshape = ?
                GROUP BY 1, event.eventslug, municipalityfrom, municipalityfromlong, affectedtypemunicipalityfrom, countyfrom, countyfromshort, affectedtypecountyfrom, statefrom, statefromabbreviation, affectedtypestatefrom, municipalityto, municipalitytolong, affectedtypemunicipalityto, countyto, countytoshort, affectedtypecountyto, stateto, statetoabbreviation, affectedtypestateto, submunicipalityfrom, submunicipalityfromlong, affectedtypesubmunicipalityfrom, submunicipalityto, submunicipalitytolong, affectedtypesubmunicipalityto, subcountyfrom, subcountyfromshort, affectedtypesubcountyfrom, subcountyto, subcountytoshort, affectedtypesubcountyto, event.eventyear, event.eventeffectivetext, event.eventsort
            ), currentgovernment AS (
                -- Taken from GovernmentShapeModel->getDetail
                SELECT DISTINCT governmentshape.governmentshapeid,
                    COALESCE(governmentsubmunicipality.governmentslugsubstitute, '') AS governmentsubmunicipality,
                    COALESCE(governmentsubmunicipality.governmentlong, '') AS governmentsubmunicipalitylong,
                    governmentmunicipality.governmentslugsubstitute AS governmentmunicipality,
                    governmentmunicipality.governmentlong AS governmentmunicipalitylong,
                    governmentcounty.governmentslugsubstitute AS governmentcounty,
                    governmentcounty.governmentshort AS governmentcountyshort,
                    governmentstate.governmentslugsubstitute AS governmentstate,
                    governmentstate.governmentabbreviation AS governmentstateabbreviation,
                    governmentshape.governmentshapeid AS id,
                    public.st_asgeojson(governmentshape.governmentshapegeometry) AS geometry
                FROM gis.governmentshape
                JOIN geohistory.government governmentmunicipality
                    ON governmentshape.governmentmunicipality = governmentmunicipality.governmentid
                JOIN geohistory.government governmentcounty
                    ON governmentshape.governmentcounty = governmentcounty.governmentid
                JOIN geohistory.government governmentstate
                    ON governmentshape.governmentstate = governmentstate.governmentid
                LEFT JOIN geohistory.government governmentsubmunicipality
                    ON governmentshape.governmentsubmunicipality = governmentsubmunicipality.governmentid
                WHERE governmentshape.governmentshapeid = ?
            )
            SELECT eventid, eventslug, municipalityfrom, municipalityfromlong, affectedtypemunicipalityfrom, countyfrom, countyfromshort, affectedtypecountyfrom, statefrom, statefromabbreviation, affectedtypestatefrom, municipalityto, municipalitytolong, affectedtypemunicipalityto, countyto, countytoshort, affectedtypecountyto, stateto, statetoabbreviation, affectedtypestateto, textflag, submunicipalityfrom, submunicipalityfromlong, affectedtypesubmunicipalityfrom, submunicipalityto, submunicipalitytolong, affectedtypesubmunicipalityto, subcountyfrom, subcountyfromshort, affectedtypesubcountyfrom, subcountyto, subcountytoshort, affectedtypesubcountyto, eventyear, eventeffective, eventsort, 
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
               '' AS eventyear,
               '' AS eventeffective,
               NULL AS eventsort,
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
               '' AS eventyear,
               '' AS eventeffective,
               NULL AS eventsort,
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
            $id,
            $id,
        ]);

        return $this->getObject($query);
    }

    public function getProcess(array $query, array $gisQuery = []): array
    {
        $linkTypes = [];
        $rows = [];
        $types = [];

        foreach ($query as $row) {
            if ($row['governmentfromlong'] !== '') {
                $types['from'][$row['affectedgovernmentleveldisplayorder']] = $row['affectedgovernmentlevellong'];
                if (isset($row['includelink']) && $row['includelink']  === 't') {
                    $linkTypes['from'][$row['affectedgovernmentleveldisplayorder']] = $row['affectedgovernmentlevellong'];
                }
                $rows[$row['id']]['From ' . $row['affectedgovernmentlevellong'] . ' Link'] = $row['governmentfrom'];
                $rows[$row['id']]['From ' . $row['affectedgovernmentlevellong'] . ' Long'] = $row['governmentfromlong'];
                $rows[$row['id']]['From ' . $row['affectedgovernmentlevellong'] . ' Affected'] = $row['affectedtypefrom'];
            }
            if ($row['governmenttolong'] !== '') {
                $types['to'][$row['affectedgovernmentleveldisplayorder']] = $row['affectedgovernmentlevellong'];
                if (isset($row['includelink']) && $row['includelink']  === 't') {
                    $linkTypes['to'][$row['affectedgovernmentleveldisplayorder']] = $row['affectedgovernmentlevellong'];
                }
                $rows[$row['id']]['To ' . $row['affectedgovernmentlevellong'] . ' Link'] = $row['governmentto'];
                $rows[$row['id']]['To ' . $row['affectedgovernmentlevellong'] . ' Long'] = $row['governmenttolong'];
                $rows[$row['id']]['To ' . $row['affectedgovernmentlevellong'] . ' Affected'] = $row['affectedtypeto'];
            }
        }

        foreach ($types as $fromTo => $levels) {
            ksort($levels);
            $types[$fromTo] = $levels;
        }
        $kSort = $types;
        ksort($kSort);
        $types = $kSort;

        foreach ($linkTypes as $fromTo => $levels) {
            ksort($levels);
            $linkTypes[$fromTo] = $levels;
        }
        $kSort = $linkTypes;
        ksort($kSort);
        $linkTypes = $kSort;

        $hasMap = false;
        $jurisdictions = [];

        if ($gisQuery !== []) {
            $hasMap = true;
            foreach ($gisQuery as $row) {
                $row['jurisdictions'] = explode(',', $row['jurisdictions']);
                foreach ($row['jurisdictions'] as $jurisdiction) {
                    if ($jurisdiction !== '') {
                        $jurisdictions[$jurisdiction] = true;
                    }
                }
                foreach ($row as $key => $value) {
                    $rows[$row['id']][$key] = $value;
                }
            }
        }

        if ($jurisdictions === []) {
            foreach ($rows as $row) {
                $jurisdiction = explode('-', $row['From County Link']);
                if ($jurisdiction[0] !== '') {
                    $jurisdictions[$jurisdiction[0]] = true;
                }
                $jurisdiction = explode('-', $row['To County Link']);
                if ($jurisdiction[0] !== '') {
                    $jurisdictions[$jurisdiction[0]] = true;
                }
            }
        }

        $jurisdictions = array_keys($jurisdictions);
        sort($jurisdictions);

        foreach ($rows as $key => $value) {
            $rows[$key] = (object) $value;
        }

        return [
            'affectedGovernment' => [
                'linkTypes' => $linkTypes,
                'rows' => $rows,
                'types' => $types,
            ],
            'hasMap' => $hasMap,
            'jurisdictions' => $jurisdictions,
        ];
    }
}
