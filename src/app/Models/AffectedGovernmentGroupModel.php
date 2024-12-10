<?php

namespace App\Models;

use App\Models\BaseModel;

class AffectedGovernmentGroupModel extends BaseModel
{
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
            $id,
        ]);

        return $this->getObject($query);
    }

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
                JOIN geohistory.government governmentsubstitute
                    ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                    AND governmentsubstitute.governmentid = ?
                JOIN geohistory.governmentform
                    ON affectedgovernmentpart.governmentformto = governmentform.governmentformid
                ORDER BY 1, 4
            QUERY;

        $query = $this->db->query($query, [
            $id,
        ]);

        return $this->getObject($query);
    }

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
                        WHEN government.governmentslugsubstitute = governmentaffected.governmentslugsubstitute THEN ''
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
                        JOIN geohistory.government
                            ON affectedgovernmentpart.governmentto = government.governmentid
                        JOIN geohistory.government governmentsubstitute
                            ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                            AND governmentsubstitute.governmentid = ?
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
                        JOIN geohistory.government
                            ON affectedgovernmentpart.governmentfrom = government.governmentid
                        JOIN geohistory.government governmentsubstitute
                            ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                            AND governmentsubstitute.governmentid = ?
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
                        JOIN geohistory.government
                            ON affectedgovernmentpart.governmentfrom = government.governmentid
                        JOIN geohistory.government governmentsubstitute
                            ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                            AND governmentsubstitute.governmentid = ?
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
                        JOIN geohistory.government
                            ON affectedgovernmentpart.governmentto = government.governmentid
                        JOIN geohistory.government governmentsubstitute
                            ON government.governmentslugsubstitute = governmentsubstitute.governmentslugsubstitute
                            AND governmentsubstitute.governmentid = ?
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
        ]);

        return $this->getObject($query);
    }

    public function getByGovernmentShape(int $id): array
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
                    COALESCE(affectedtypeto.affectedtypeshort, '') AS affectedtypeto,
                    event.eventid,
                    event.eventslug,
                    event.eventdatetext,
                    event.eventsort
                FROM gis.affectedgovernmentgis
                JOIN geohistory.affectedgovernmentgroup
                    ON affectedgovernmentgis.affectedgovernment = affectedgovernmentgroup.affectedgovernmentgroupid
                    AND affectedgovernmentgis.governmentshape = ?
                JOIN geohistory.event
                    ON affectedgovernmentgroup.event = event.eventid
                JOIN geohistory.eventgranted
                    ON event.eventgranted = eventgranted.eventgrantedid
                    AND eventgranted.eventgrantedsuccess
                JOIN geohistory.affectedgovernmentgrouppart
                    ON affectedgovernmentgroup.affectedgovernmentgroupid = affectedgovernmentgrouppart.affectedgovernmentgroup
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
        $query = $this->getProcess($query);

        return $this->getEventProcess($query);
    }

    private function eventSortIncrement(string $input): string
    {
        $input = mb_str_split($input);
        $character = array_pop($input);
        $character = intval($character) + 1;
        $input[] = (string) $character;
        return implode('', $input);
    }

    private function getEventProcess(array $query): array
    {
        $eventSort = [];
        foreach ($query['event'] as $event) {
            $event['affectedgovernmentgroupids'] = array_keys($event['affectedgovernmentgroupids']);
            $eventSort[$event['eventsort']][] = $event;
        }
        $query['event'] = $eventSort;
        $eventIds = [];
        $eventSort = [];
        foreach ($query['event'] as $date) {
            $sortOrder = 0;
            foreach ($date as $event) {
                foreach ($event['affectedgovernmentgroupids'] as $affectedGovernment) {
                    $eventSortOrder = $event['eventsort'] . $sortOrder;
                    $eventSort[$eventSortOrder] = (object) array_merge([
                        'eventeffective' => $event['eventdatetext'],
                        'eventslug' => $event['eventslug'],
                        'eventsort' => $eventSortOrder,
                    ], (array) $query['affectedGovernment']['rows'][$affectedGovernment]);
                }
                $eventIds[$event['eventid']] = true;
            }
            $sortOrder += 2;
        }
        $query['affectedGovernment']['rows'] = $eventSort;
        ksort($query['affectedGovernment']['rows']);
        $query['event'] = array_keys($eventIds);
        $emptyRow = [
            'eventeffective' => '',
            'eventslug' => '',
            'eventsort' => '',
        ];
        foreach ($query['affectedGovernment']['types']['from'] ?? [] as $governmentType) {
            $emptyRow['From ' . $governmentType . ' Affected'] = 'Missing';
            $emptyRow['From ' . $governmentType . ' Link'] = '';
            $emptyRow['From ' . $governmentType . ' Long'] = '';
            $emptyRow['To ' . $governmentType . ' Affected'] = 'Missing';
            $emptyRow['To ' . $governmentType . ' Link'] = '';
            $emptyRow['To ' . $governmentType . ' Long'] = '';
        }
        ksort($emptyRow);
        $emptyRow = (object) $emptyRow;
        $lastRow = null;
        $isFirstRow = true;
        foreach ($query['affectedGovernment']['rows'] as $row) {
            if ($isFirstRow) {
                $isFirstRow = false;
            } else {
                $addRow = false;
                $newRow = clone $emptyRow;
                $newRow->eventsort = $this->eventSortIncrement($lastRow->eventsort);
                foreach ($query['affectedGovernment']['types']['from'] as $governmentType) {
                    $newRow->{'From ' . $governmentType . ' Link'} = $lastRow->{'To ' . $governmentType . ' Link'} ?? '';
                    $newRow->{'From ' . $governmentType . ' Long'} = $lastRow->{'To ' . $governmentType . ' Long'} ?? '';
                    $newRow->{'To ' . $governmentType . ' Link'} = $row->{'From ' . $governmentType . ' Link'} ?? '';
                    $newRow->{'To ' . $governmentType . ' Long'} = $row->{'From ' . $governmentType . ' Long'} ?? '';
                    if ($newRow->{'From ' . $governmentType . ' Long'} !== $newRow->{'To ' . $governmentType . ' Long'}) {
                        $addRow = true;
                    }
                }
                if ($addRow) {
                    $query['affectedGovernment']['rows'][$newRow->eventsort] = $newRow;
                }
            }
            $lastRow = $row;
        }
        ksort($query['affectedGovernment']['rows']);
        return $query;
    }

    public function getProcess(array $query, array $gisQuery = []): array
    {
        $linkTypes = [];
        $rows = [];
        $types = [];
        $event = [];

        foreach ($query as $row) {
            if ($row['governmentfromlong'] !== '') {
                $types['from'][$row['affectedgovernmentleveldisplayorder']] = $row['affectedgovernmentlevellong'];
                if (isset($row['eventid'])) {
                    $types['to'][$row['affectedgovernmentleveldisplayorder']] = $row['affectedgovernmentlevellong'];
                }
                if (isset($row['includelink']) && $row['includelink']  === 't') {
                    $linkTypes['from'][$row['affectedgovernmentleveldisplayorder']] = $row['affectedgovernmentlevellong'];
                }
                $rows[$row['id']]['From ' . $row['affectedgovernmentlevellong'] . ' Link'] = $row['governmentfrom'];
                $rows[$row['id']]['From ' . $row['affectedgovernmentlevellong'] . ' Long'] = $row['governmentfromlong'];
                $rows[$row['id']]['From ' . $row['affectedgovernmentlevellong'] . ' Affected'] = $row['affectedtypefrom'];
            }
            if ($row['governmenttolong'] !== '') {
                $types['to'][$row['affectedgovernmentleveldisplayorder']] = $row['affectedgovernmentlevellong'];
                if (isset($row['eventid'])) {
                    $types['from'][$row['affectedgovernmentleveldisplayorder']] = $row['affectedgovernmentlevellong'];
                }
                if (isset($row['includelink']) && $row['includelink']  === 't') {
                    $linkTypes['to'][$row['affectedgovernmentleveldisplayorder']] = $row['affectedgovernmentlevellong'];
                }
                $rows[$row['id']]['To ' . $row['affectedgovernmentlevellong'] . ' Link'] = $row['governmentto'];
                $rows[$row['id']]['To ' . $row['affectedgovernmentlevellong'] . ' Long'] = $row['governmenttolong'];
                $rows[$row['id']]['To ' . $row['affectedgovernmentlevellong'] . ' Affected'] = $row['affectedtypeto'];
            }
            if (isset($row['eventid'])) {
                if (!isset($event[$row['eventid']])) {
                    $event[$row['eventid']] = [
                        'eventid' => $row['eventid'],
                        'eventslug' => $row['eventslug'],
                        'eventdatetext' => $row['eventdatetext'],
                        'eventsort' => $row['eventsort'],
                        'affectedgovernmentgroupids' => [],
                    ];
                }
                $event[$row['eventid']]['affectedgovernmentgroupids'][$row['id']] = true;
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
            ksort($value);
            $rows[$key] = (object) $value;
        }

        return [
            'affectedGovernment' => [
                'linkTypes' => $linkTypes,
                'rows' => $rows,
                'types' => $types,
            ],
            'event' => $event,
            'hasMap' => $hasMap,
            'jurisdictions' => $jurisdictions,
        ];
    }
}
