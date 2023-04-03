<?php

namespace App\Controllers;

class Area extends BaseController
{

    private $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'Area Detail',
            'isInternetExplorer' => $this->isInternetExplorer(),
            'live' => $this->isLive(),
            'online' => $this->isOnline(),
            'updated' => $this->lastUpdated()->fulldate,
            'extraAttribution' => '',
        ];
    }

    public function address($state)
    {
        try {
            $addressText = $this->request->getPost('address', FILTER_SANITIZE_STRING);
            $data = file_get_contents('https://us1.locationiq.com/v1/search.php?key=' . getenv('locationiq_key') . '&format=json&countrycodes=us&dedupe=1&q=' . urlencode($addressText));
            if (($data = json_decode($data, TRUE)) !== FALSE) {
                if (count($data) == 1) {
                    $this->data['extraAttribution'] = 'Address searching courtesy of <a href="https://locationiq.com/attribution/">LocationIQ</a>.';
                    $this->point($state, $data[0]['lat'], $data[0]['lon'], $addressText);
                } else {
                    $this->addressCensusBureau($state, $addressText);
                }
            }
        } catch (\Throwable $t) {
            $this->addressCensusBureau($state, $addressText);
        }
    }

    public function addressCensusBureau($state, $addressText)
    {
        try {
            $data = file_get_contents('https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?benchmark=9&format=json&address=' . $addressText);
            if (($data = json_decode($data, TRUE)) !== FALSE) {
                if (count($data['result']['addressMatches']) == 1 and strtolower($data['result']['addressMatches'][0]['addressComponents']['state']) == $state) {
                    $this->data['extraAttribution'] = 'Address searching courtesy of the <a href="https://geocoding.geo.census.gov/geocoder/">U.S. Census Bureau</a>.';
                    $this->point($state, $data['result']['addressMatches'][0]['coordinates']['y'], $data['result']['addressMatches'][0]['coordinates']['x'], $addressText);
                } else {
                    $this->noRecord($state);
                }
            }
        } catch (\Throwable $t) {
            $this->noRecord($state);
        }
    }

    public function noRecord($state)
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);
        echo view('norecord');
        echo view('footer');
    }

    public function point($state, $y = 0, $x = 0, $addressText = '')
    {
        if (empty($y) and !empty($this->request->getPost('y', FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION))) {
            $y = $this->request->getPost('y', FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION);
        }
        if (empty($x) and !empty($this->request->getPost('x', FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION))) {
            $x = $this->request->getPost('x', FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION);
        }
        // Only applies in US
        if ($y < 0 or $x > 0) {
            $newX = $y;
            $y = $x;
            $x = $newX;
        }
        $query = $this->db->query('SELECT * FROM extra.ci_model_area_point(?, ?)', [$y, $x])->getResult();
        if (count($query) != 1) {
            $this->noRecord($state);
        } else {
            $this->view($state, $query[0]->governmentshapeid, $y, $x, $addressText);
        }
    }

    public function view($state, $id, $y = 0, $x = 0, $addressText = '')
    {
        $this->data['state'] = $state;
        if (($this->data['live'] or !empty($y) or !empty($x)) and preg_match('/^\d{1,9}$/', $id)) {
            $id = intval($id);
        }
        $currentQuery = $this->db->query('SELECT * FROM extra.ci_model_area_currentgovernment(?, ?, ?)', [$id, $state, $this->request->getLocale()])->getResult();
        if (count($currentQuery) != 1) {
            $this->noRecord($state);
        } else {
            $id = $currentQuery[0]->governmentshapeid;
            $governmentArray = [
                $currentQuery[0]->governmentsubmunicipalitylong,
                $currentQuery[0]->governmentmunicipalitylong,
                $currentQuery[0]->governmentcountyshort,
                $currentQuery[0]->governmentstateabbreviation
            ];
            foreach ($governmentArray as $g) {
                if (!empty($g) and substr($g, 0, 14) !== 'Unincorporated' and substr($g, 0, 11) !== 'Unorganized' and substr($g, 0, 7) !== 'Unknown') {
                    $this->data['pageTitle'] = $g;
                    break;
                }
            }
            echo view('header', $this->data);
            if (!empty($addressText)) {
                $searchParameter['Address'] = $addressText;
            } elseif (!empty($x) or !empty($y)) {
                $searchParameter['Coordinates'] = $y . ', ' . $x;
            }
            if (isset($searchParameter)) {
                echo view('general_parameter', ['searchParameter' => $searchParameter, 'omitColon' => true]);
            }
            echo view('general_currentgovernment', ['query' => $currentQuery, 'state' => $state]);
            echo view('general_map', ['live' => $this->data['live'], 'includeBase' => true]);
            $query = $this->db->query('SELECT * FROM extra.ci_model_area_affectedgovernment(?, ?, ?)', [$id, $state, $this->request->getLocale()])->getResult();
            $events = [];
            if (count($query) > 0) {
                echo view('general_affectedgovernment', ['query' => $query, 'state' => $state, 'includeDate' => true, 'isComplete' => true]);
                foreach ($query as $row) {
                    if (!empty($row->eventid)) {
                        $events[] = $row->eventid;
                    }
                }
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_area_metesdescription(?)', [$id])->getResult();
            if (count($query) > 0) {
                echo view('general_metes', ['query' => $query, 'hasLink' => true, 'state' => $state, 'title' => 'Metes and Bounds Description']);
            }
            $events = array_unique($events);
            $events = '{' . implode(',', $events) . '}';
            $query = $this->db->query('SELECT * FROM extra.ci_model_area_event_failure(?, ?)', [$id, $events])->getResult();
            if (count($query) > 0) {
                echo view('general_event', ['query' => $query, 'state' => $state, 'title' => 'Other Event Links']);
            }
            echo view('leaflet_start', ['type' => 'area', 'includeBase' => true, 'needRotation' => false, 'online' => $this->data['online']]);
            echo view('general_gis', [
                'query' => $currentQuery,
                'element' => 'area',
                'onEachFeature' => false,
                'onEachFeature2' => false,
                'weight' => 0,
                'color' => '07517D',
                'fillOpacity' => 0.5
            ]);
            $includePoint = false;
            if (!empty($x) and !empty($y)) {
                $includePoint = true;
                $query = [(object)[
                    'line' => '',
                    'pointdescription' => '',
                    'pointgeometry' => '{"type":"Point","coordinates":[' . $x . ',' . $y . ']}',
                ]];
                echo view('general_gis', [
                    'query' => $query,
                    'element' => 'point',
                    'onEachFeature' => false,
                    'onEachFeature2' => false,
                    'weight' => 3,
                    'color' => 'D5103F',
                    'fillOpacity' => .5,
                    'radius' => 6,
                    'attribution' => $this->data['extraAttribution']
                ]);
            }
            echo view('area_end', ['includePoint' => $includePoint]);
            echo view('leaflet_end', ['live' => $this->data['live']]);
            echo view('footer');
        }
    }
}
