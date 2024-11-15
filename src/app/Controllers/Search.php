<?php

namespace App\Controllers;

use App\Models\EventTypeModel;
use App\Models\GovernmentIdentifierTypeModel;
use App\Models\GovernmentModel;
use App\Models\SourceModel;
use CodeIgniter\HTTP\RedirectResponse;

class Search extends BaseController
{
    private string $title = 'Search';

    private array $categoryType = [
        'event' => 'Event',
        'government' => 'Government',
        'governmentidentifier' => 'Government',
        'law' => 'Law',
    ];

    private array $parameterType = [
        'date' => 'Date',
        'eventtype' => 'Event Type',
        'government' => 'Government',
        'governmentjurisdiction' => 'Government',
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

    private array $typeType = [
        'dateEvent' => 'Date and Event Type',
        'government' => 'Government',
        'identifier' => 'Identifier',
        'reference' => 'Reference',
        'statewide' => 'Statewide',
    ];

    private function governmentLevel(string $a): int
    {
        return match ($a) {
            'State' => 2,
            'County' => 3,
            'Municipality' => 4,
            default => 0,
        };
    }

    public function governmentlookup(string $government = '', string $type = ''): void
    {
        $GovernmentModel = new GovernmentModel();
        $type = 'getLookupByGovernment' . ucwords($type);
        $this->response->setHeader('Content-Type', 'application/json');
        echo json_encode($GovernmentModel->$type($government));
    }

    public function index(): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('core/ui');
        $EventTypeModel = new EventTypeModel();
        $GovernmentIdentifierTypeModel = new GovernmentIdentifierTypeModel();
        $SourceModel = new SourceModel();
        $months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
        foreach ($months as $k => $m) {
            $months[$k] = [
                'monthNumber' => $k + 1,
                'monthName' => $m,
            ];
        }
        $GovernmentModel = new GovernmentModel();
        echo view('search/index', [
            'eventTypeQuery' => $EventTypeModel->getSearch(),
            'governmentIdentifierTypeQuery' => $GovernmentIdentifierTypeModel->getSearch(),
            'months' => $months,
            'reporterQuery' => $SourceModel->getSearch(),
            'tribunalgovernmentshortQuery' => $GovernmentModel->getSearch(),
        ]);
        echo view('core/footer');
    }

    public function noRecord(): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('core/norecord');
        echo view('core/footer');
    }

    public function redirect(): RedirectResponse
    {
        return redirect()->to('/' . $this->request->getLocale() . '/search/', 301);
    }

    public function view(string $category): void
    {
        $type = $this->request->getPost('type');
        $fields = [];
        $model = '';

        switch ($category) {
            case 'event':
                $fields = [
                    $this->request->getPost('government'),
                    $this->request->getPost('governmentparent'),
                    $this->request->getPost('eventtype'),
                    (int) $this->request->getPost('year', FILTER_SANITIZE_NUMBER_INT),
                    (int) $this->request->getPost('plusminus', FILTER_SANITIZE_NUMBER_INT),
                ];
                $model = 'EventModel';
                break;
            case 'government':
                switch ($type) {
                    case 'statewide':
                    case 'government':
                        $fields = [
                            $this->request->getPost('government'),
                            ($type === 'statewide' ? $this->request->getPost('governmentjurisdiction') : $this->request->getPost('governmentparent')),
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
                            (int) $this->request->getPost('page'),
                            (int) $this->request->getPost('numberchapter'),
                        ];
                        break;
                    case 'dateEvent':
                        $fields = [
                            $this->request->getPost('date'),
                            $this->request->getPost('eventtype'),
                        ];
                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }

        if ($fields !== [] && $model !== '') {
            echo view('core/header', ['title' => $this->title]);
            $model = "App\\Models\\" . $model;
            $model = new $model();
            $modelType = 'getSearchBy' . ucwords($type);
            $searchParameter = [
                'Search For' => $this->categoryType[$category],
                'Search By' => $this->typeType[$this->request->getPost('type')],
            ];
            foreach ($this->request->getPost() as $key => $value) {
                if ($value !== '' && $key !== 'type') {
                    $searchParameter[$this->parameterType[$key]] = $value;
                }
            }
            echo view('core/parameter', ['searchParameter' => $searchParameter]);
            echo view($category . '/table', ['query' => $model->$modelType($fields), 'title' => 'Results:', 'type' => $type]);
            echo view('core/footer');
        } else {
            $this->response->setHeader('Content-Type', 'application/json');
            echo json_encode($this->request->getPost());
        }
    }
}
