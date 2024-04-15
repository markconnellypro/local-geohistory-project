<?php

namespace App\Controllers;

use App\Models\AffectedGovernmentGroupModel;
use App\Models\EventModel;
use App\Models\GovernmentShapeModel;
use App\Models\MetesDescriptionModel;

class Area extends BaseController
{
    private array $data = [
        'title' => 'Area Detail',
        'extraAttribution' => '',
    ];

    public function __construct()
    {
    }

    public function address(string $state): void
    {
        $addressText = $this->request->getPost('address', FILTER_SANITIZE_STRING);
        try {
            $data = file_get_contents('https://us1.locationiq.com/v1/search.php?key=' . getenv('locationiq_key') . '&format=json&countrycodes=us&dedupe=1&q=' . urlencode($addressText));
            if (($data = json_decode($data, true)) !== false) {
                if (count($data) === 1) {
                    $this->data['extraAttribution'] = 'Address searching courtesy of <a href="https://locationiq.com/attribution/">LocationIQ</a>.';
                    $this->point($state, $data[0]['lat'], $data[0]['lon'], $addressText);
                } else {
                    $this->addressCensusBureau($state, $addressText);
                }
            }
        } catch (\Throwable) {
            $this->addressCensusBureau($state, $addressText);
        }
    }

    public function addressCensusBureau(string $state, string $addressText): void
    {
        try {
            $data = file_get_contents('https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?benchmark=9&format=json&address=' . $addressText);
            if (($data = json_decode($data, true)) !== false) {
                if (count($data['result']['addressMatches']) === 1 && strtolower($data['result']['addressMatches'][0]['addressComponents']['state']) === $state) {
                    $this->data['extraAttribution'] = 'Address searching courtesy of the <a href="https://geocoding.geo.census.gov/geocoder/">U.S. Census Bureau</a>.';
                    $this->point($state, $data['result']['addressMatches'][0]['coordinates']['y'], $data['result']['addressMatches'][0]['coordinates']['x'], $addressText);
                } else {
                    $this->noRecord($state);
                }
            }
        } catch (\Throwable) {
            $this->noRecord($state);
        }
    }

    public function noRecord(string $state): void
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);
        echo view('norecord');
        echo view('footer');
    }

    public function point(string $state, float $y = 0, float $x = 0, string $addressText = ''): void
    {
        if ($y === 0.0 && $this->request->getPost('y', FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION) !== '') {
            $y = (float) $this->request->getPost('y', FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION);
        }
        if ($x === 0.0 && $this->request->getPost('x', FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION) !== '') {
            $x = (float) $this->request->getPost('x', FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION);
        }
        // Only applies in US
        if ($y < 0 || $x > 0) {
            $newX = $y;
            $y = $x;
            $x = $newX;
        }
        $GovernmentShapeModel = new GovernmentShapeModel();
        $query = $GovernmentShapeModel->getPointId($y, $x);
        if (count($query) !== 1) {
            $this->noRecord($state);
        } else {
            $this->view($state, $query[0]->governmentshapeid, $y, $x, $addressText);
        }
    }

    public function view(string $state, int|string $id, float $y = 0, float $x = 0, string $addressText = ''): void
    {
        $this->data['state'] = $state;
        if (($this->isLive() || $y !== 0.0 || $x !== 0.0) && preg_match('/^\d{1,9}$/', $id)) {
            $id = (int) $id;
        }
        $GovernmentShapeModel = new GovernmentShapeModel();
        $currentQuery = $GovernmentShapeModel->getDetail($id, $state);
        if (count($currentQuery) !== 1) {
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
                if ($g !== '' && !str_starts_with($g, 'Unincorporated') && !str_starts_with($g, 'Unorganized') && !str_starts_with($g, 'Unknown')) {
                    $this->data['pageTitle'] = $g;
                    break;
                }
            }
            echo view('header', $this->data);
            $searchParameter = [];
            if ($addressText !== '') {
                $searchParameter['Address'] = $addressText;
            } elseif ($x !== 0.0 || $y !== 0.0) {
                $searchParameter['Coordinates'] = $y . ', ' . $x;
            }
            if ($searchParameter === []) {
                echo view('core/parameter', ['searchParameter' => $searchParameter, 'omitColon' => true]);
            }
            echo view('core/currentgovernment', ['query' => $currentQuery, 'state' => $state]);
            echo view('core/map', ['includeBase' => true]);
            $AffectedGovernmentGroupModel = new AffectedGovernmentGroupModel();
            $query = $AffectedGovernmentGroupModel->getByGovernmentShape($id, $state);
            $events = [];
            echo view('core/affectedgovernment', ['query' => $query, 'state' => $state, 'includeDate' => true, 'isComplete' => true]);
            foreach ($query as $row) {
                if (!is_null($row->eventid)) {
                    $events[] = $row->eventid;
                }
            }
            $MetesDescriptionModel = new MetesDescriptionModel();
            $query = $MetesDescriptionModel->getByGovernmentShape($id);
            echo view('core/metes', ['query' => $query, 'hasLink' => true, 'state' => $state, 'title' => 'Metes and Bounds Description']);
            $events = array_unique($events);
            $EventModel = new EventModel();
            $query = $EventModel->getByGovernmentShapeFailure($id, $events);
            echo view('core/event', ['query' => $query, 'state' => $state, 'title' => 'Other Event Links']);
            echo view('leaflet/start', ['type' => 'area', 'includeBase' => true, 'needRotation' => false]);
            echo view('core/gis', [
                'query' => $currentQuery,
                'element' => 'area',
                'onEachFeature' => false,
                'onEachFeature2' => false,
                'weight' => 0,
                'color' => '07517D',
                'fillOpacity' => 0.5
            ]);
            $includePoint = false;
            if ($x !== 0.0 && $y !== 0.0) {
                $includePoint = true;
                $query = [(object)[
                    'line' => '',
                    'pointdescription' => '',
                    'pointgeometry' => '{"type":"Point","coordinates":[' . $x . ',' . $y . ']}',
                ]];
                echo view('core/gis', [
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
            echo view('area/end', ['includePoint' => $includePoint]);
            echo view('leaflet/end');
            echo view('footer');
        }
    }
}
