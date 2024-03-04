<?php

namespace App\Controllers;

use App\Models\EventTypeModel;
use App\Models\GovernmentIdentifierTypeModel;
use App\Models\GovernmentModel;
use App\Models\SourceModel;

class Search extends BaseController
{
    private $data;

    private $categoryType = [
        'event' => 'Event',
        'government' => 'Government',
        'governmentidentifier' => 'Government',
        'law' => 'Law',
    ];

    private $parameterType = [
        'date' => 'Date',
        'eventtype' => 'Event Type',
        'government' => 'Government',
        'governmentidentifiertype' => 'Identifier Source',
        'governmentlevel' => 'Level',
        'governmentparent' => 'Parent',
        'identifier' => 'Identifier',
        'numberchapter' => 'Number/Chapter',
        'page' => 'Page',
        'plusminus' => '+/-',
        'year' => 'Year',
        'yearvolume' => 'Year/Volume',
    ];

    private $typeType = [
        'dateEvent' => 'Date and Event Type',
        'government' => 'Government',
        'identifier' => 'Identifier',
        'reference' => 'Reference',
        'statewide' => 'Statewide',
    ];

    public function __construct()
    {
        $this->data = [
            'title' => 'Search',
            'isInternetExplorer' => $this->isInternetExplorer(),
            'live' => $this->isLive(),
            'online' => $this->isOnline(),
            'updated' => $this->lastUpdated()->fulldate,
        ];
    }

    private function emptyToEmpty($a)
    {
        if (empty($a)) {
            return '';
        } else {
            return $a;
        }
    }

    private function emptyToZero($a): int
    {
        return (empty($a) ? 0 : (int) $a);
    }

    private function governmentLevel($a): int
    {
        return match ($a) {
            'State' => 2,
            'County' => 3,
            'Municipality' => 4,
            default => 0,
        };
    }

    public function governmentlookup($state, $government = '', $type = ''): void
    {
        $this->data['state'] = $state;
        $GovernmentModel = new GovernmentModel();
        $type = 'getLookupBy' . ucwords(str_replace('parent', 'Parent', $type));
        $this->data['query'] = $GovernmentModel->$type($state, $government);
        $this->response->setHeader('Content-Type', 'application/json');
        echo json_encode($this->data['query']);
    }

    public function index($state = ''): void
    {
        $stateArray = $this->getJurisdictions();
        $this->data['state'] = $state;
        echo view('header', $this->data);
        if (!$this->data['live'] && !in_array($state, $stateArray)) {
            echo view('search_unavailable');
        } else {
            $GovernmentModel = new GovernmentModel();
            $this->data['id'] = $GovernmentModel->getSlug($GovernmentModel->getAbbreviationId($state));
            $EventTypeModel = new EventTypeModel();
            $this->data['eventTypeQuery'] = $EventTypeModel->getSearch($state);
            $this->data['months'] = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
            foreach ($this->data['months'] as $k => $m) {
                $this->data['months'][$k] = [
                    'monthNumber' => $k + 1,
                    'monthName' => $m
                ];
            }
            $this->data['tribunalgovernmentshortQuery'] = $GovernmentModel->getSearch($state);
            $GovernmentIdentifierTypeModel = new GovernmentIdentifierTypeModel();
            $this->data['governmentIdentifierTypeQuery'] = $GovernmentIdentifierTypeModel->getSearch($state);
            $SourceModel = new SourceModel();
            $this->data['reporterQuery'] = $SourceModel->getSearch($state);
            echo view('general_ui', $this->data);
            echo view('search', $this->data);
            if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/government_live.php')) {
                echo view(ENVIRONMENT . '/government_live', ['id' => $this->data['id'], 'state' => $state, 'isMunicipalityOrLower' => false, 'isCountyOrLower' => false, 'isCountyOrState' => false, 'isState' => true, 'includeGovernment' => true]);
            }
        }
        echo view('footer');
    }

    public function view($state, $category): void
    {
        $this->data['state'] = $state;
        $type = $this->request->getPost('type');
        $fields = [];
        $model = '';

        switch ($category) {
            case 'event':
                $fields = [
                    $state,
                    $this->request->getPost('government'),
                    $this->request->getPost('governmentparent'),
                    $this->request->getPost('eventtype'),
                    $this->emptyToZero($this->request->getPost('year', FILTER_SANITIZE_NUMBER_INT)),
                    $this->emptyToZero($this->request->getPost('plusminus', FILTER_SANITIZE_NUMBER_INT)),
                ];
                $model = 'EventModel';
                break;
            case 'government':
                switch ($type) {
                    case 'statewide':
                    case 'government':
                        $fields = [
                            $state,
                            ($type == 'statewide' ? $state : $this->request->getPost('government')),
                            $this->emptyToEmpty($this->request->getPost('governmentparent')),
                            $this->governmentLevel($this->request->getPost('governmentlevel')),
                            $type,
                        ];
                        $model = 'GovernmentModel';
                        $type = 'government';
                        break;
                    case 'identifier':
                        $fields = [
                            $this->request->getPost('governmentidentifiertype'),
                            $this->request->getPost('identifier'),
                            $state,
                        ];
                        $model = 'GovernmentIdentifierModel';
                        $category = 'governmentidentifier';
                        break;
                    default:
                        break;
                }
                break;
            case 'law':
                $model = 'LawSectionModel';
                switch ($type) {
                    case 'reference':
                        $fields = [
                            $this->request->getPost('yearvolume'),
                            $this->emptyToZero($this->request->getPost('page')),
                            $this->emptyToZero($this->request->getPost('numberchapter')),
                            $state,
                        ];
                        break;
                    case 'dateEvent':
                        $fields = [
                            $this->request->getPost('date'),
                            $this->request->getPost('eventtype'),
                            $state,
                        ];
                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }

        if ($fields !== [] && $model != '') {
            echo view('header', $this->data);
            $model = "App\\Models\\" . $model;
            $model = new $model();
            $modelType = 'getSearchBy'. ucwords($type);
            $query = $model->$modelType($fields);
            $searchParameter = [
                'Search For' => $this->categoryType[$category],
                'Search By' => $this->typeType[$this->request->getPost('type')],
            ];
            foreach ($this->request->getPost() as $key => $value) {
                if (!empty($value) && $key != 'type') {
                    $searchParameter[$this->parameterType[$key]] = $value;
                }
            }
            echo view('general_parameter', ['searchParameter' => $searchParameter]);
            echo view('general_' . $category, ['query' => $query, 'state' => $state, 'title' => 'Results:', 'type' => $type]);
            echo view('footer');
        } else {
            $this->response->setHeader('Content-Type', 'application/json');
            echo json_encode($this->request->getPost());
        }
    }
}
