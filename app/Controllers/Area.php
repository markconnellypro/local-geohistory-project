<?php

namespace App\Controllers;

use App\Models\AffectedGovernmentGroupModel;
use App\Models\EventModel;
use App\Models\GovernmentShapeModel;
use App\Models\MetesDescriptionModel;
use CodeIgniter\HTTP\RedirectResponse;

class Area extends BaseController
{
    private string $extraAttribution = '';

    private string $title = 'Area';

    public function address(): void
    {
        $addressText = $this->request->getPost('address', FILTER_SANITIZE_STRING);
        try {
            $data = file_get_contents('https://us1.locationiq.com/v1/search.php?key=' . getenv('locationiq_key') . '&format=json&countrycodes=us&dedupe=1&q=' . urlencode($addressText));
            if (($data = json_decode($data, true)) !== false) {
                if (count($data) === 1) {
                    $this->extraAttribution = 'Address searching courtesy of <a href="https://locationiq.com/attribution/">LocationIQ</a>.';
                    $this->point($data[0]['lat'], $data[0]['lon'], $addressText);
                } else {
                    $this->addressCensusBureau($addressText);
                }
            }
        } catch (\Throwable) {
            $this->addressCensusBureau($addressText);
        }
    }

    public function addressCensusBureau(string $addressText): void
    {
        try {
            $data = file_get_contents('https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?benchmark=9&format=json&address=' . $addressText);
            if (($data = json_decode($data, true)) !== false) {
                if (count($data['result']['addressMatches']) === 1) {
                    $this->extraAttribution = 'Address searching courtesy of the <a href="https://geocoding.geo.census.gov/geocoder/">U.S. Census Bureau</a>.';
                    $this->point($data['result']['addressMatches'][0]['coordinates']['y'], $data['result']['addressMatches'][0]['coordinates']['x'], $addressText);
                } else {
                    $this->noRecord();
                }
            }
        } catch (\Throwable) {
            $this->noRecord();
        }
    }

    public function noRecord(): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('core/norecord');
        echo view('core/footer');
    }

    public function point(float $y = 0, float $x = 0, string $addressText = ''): void
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
            $this->noRecord();
        } else {
            $this->view($query[0]->governmentshapeid, $y, $x, $addressText);
        }
    }

    public function redirect(int|string $id): RedirectResponse
    {
        return redirect()->to('/' . $this->request->getLocale() . '/area/' . $id . '/', 301);
    }

    public function view(int|string $id, float $y = 0, float $x = 0, string $addressText = ''): void
    {
        if (($this->isLive() || $y !== 0.0 || $x !== 0.0) && is_string($id) && preg_match('/^\d{1,9}$/', $id) === 1) {
            $id = (int) $id;
        }
        $GovernmentShapeModel = new GovernmentShapeModel();
        $currentQuery = $GovernmentShapeModel->getDetail($id);
        if (count($currentQuery) !== 1) {
            $this->noRecord();
        } else {
            $id = $currentQuery[0]->governmentshapeid;
            $governmentArray = [
                $currentQuery[0]->governmentsubmunicipalitylong,
                $currentQuery[0]->governmentmunicipalitylong,
                $currentQuery[0]->governmentcountyshort,
                $currentQuery[0]->governmentstateabbreviation,
            ];
            $jurisdictions = [
                strtolower($currentQuery[0]->governmentstateabbreviation),
            ];
            $pageTitle = '';
            foreach ($governmentArray as $g) {
                if ($g !== '' && !str_starts_with($g, 'Unincorporated') && !str_starts_with($g, 'Unorganized') && !str_starts_with($g, 'Unknown')) {
                    $pageTitle = $g;
                    break;
                }
            }
            echo view('core/header', ['title' => $this->title, 'pageTitle' => $pageTitle]);
            $searchParameter = [];
            if ($addressText !== '') {
                $searchParameter['Address'] = $addressText;
            } elseif ($x !== 0.0 || $y !== 0.0) {
                $searchParameter['Coordinates'] = $y . ', ' . $x;
            }
            if ($searchParameter === []) {
                echo view('core/parameter', ['searchParameter' => $searchParameter, 'omitColon' => true]);
            }
            echo view('event/table_currentgovernment', ['query' => $currentQuery]);
            echo view('core/map', ['includeBase' => true]);
            $AffectedGovernmentGroupModel = new AffectedGovernmentGroupModel();
            $query = $AffectedGovernmentGroupModel->getByGovernmentShape($id);
            $events = $query['event'];
            if (is_array($query['affectedGovernment']['rows'] ?? '') && $query['affectedGovernment']['rows'] !== []) {
                echo view('event/table_affectedgovernment', ['affectedGovernment' => $query['affectedGovernment'], 'includeDate' => true, 'isComplete' => true]);
            }
            $MetesDescriptionModel = new MetesDescriptionModel();
            $query = $MetesDescriptionModel->getByGovernmentShape($id);
            $events = array_merge($events, $query['event']);
            echo view('metes/table', ['query' => $query['query'], 'hasLink' => true, 'title' => 'Metes and Bounds Description']);
            $EventModel = new EventModel();
            echo view('event/table', ['query' => $EventModel->getByGovernmentShapeFailure($id, $events), 'title' => 'Other Event Links']);
            echo view('leaflet/start', ['type' => 'area', 'jurisdictions' => $jurisdictions, 'includeBase' => true, 'needRotation' => false]);
            echo view('core/gis', [
                'query' => $currentQuery,
                'element' => 'area',
                'onEachFeature' => false,
                'onEachFeature2' => false,
                'weight' => 0,
                'color' => '07517D',
                'fillOpacity' => 0.5,
            ]);
            $includePoint = false;
            if ($x !== 0.0 && $y !== 0.0) {
                $includePoint = true;
                echo view('core/gis', [
                    'query' => [(object) [
                        'line' => '',
                        'pointdescription' => '',
                        'pointgeometry' => '{"type":"Point","coordinates":[' . $x . ',' . $y . ']}',
                    ]],
                    'element' => 'point',
                    'onEachFeature' => false,
                    'onEachFeature2' => false,
                    'weight' => 3,
                    'color' => 'D5103F',
                    'fillOpacity' => .5,
                    'radius' => 6,
                    'attribution' => $this->extraAttribution,
                ]);
            }
            echo view('area/end', ['includePoint' => $includePoint]);
            echo view('leaflet/end');
            echo view('core/footer');
        }
    }
}
