<?php

namespace App\Models;

use CodeIgniter\Model;

class AffectedGovernmentGroupModel extends Model
{
    // extra.ci_model_government_affectedgovernmentform(integer, character varying, boolean)

    // FUNCTION: extra.eventsortdate
    // FUNCTION: extra.governmentformlong
    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate
    // VIEW: extra.eventextracache
    // VIEW: extra.governmentsubstitute

    public function getByGovernmentForm($id, $state, $isLive)
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
            $isLive,
            strtoupper($state),
            $id,
        ])->getResult();

        return $query ?? [];
    }

    // extra.ci_model_government_affectedgovernment(integer, character varying, character varying)

    // FUNCTION: extra.eventsortdate
    // FUNCTION: extra.governmentlong
    // FUNCTION: extra.governmentstatelink
    // FUNCTION: extra.governmentsubstitutedcache
    // FUNCTION: extra.rangefix
    // FUNCTION: extra.shortdate
    // VIEW: extra.eventextracache
    // VIEW: extra.governmentsubstitutecache

    public function getByGovernmentGovernment($id, $state, $locale)
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
            $locale,
            strtoupper($state),
            $id,
            $id,
            $id,
            $id,
        ])->getResult();

        return $query ?? [];
    }
}