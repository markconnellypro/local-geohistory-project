<?php

namespace App\Controllers;

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
        'dateevent' => 'Date and Event Type',
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

    private function emptyToArray($a)
    {
        if (empty($a)) {
            return '{}';
        } else {
            return '{' . $a . '}';
        }
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
        return (empty($a) ? 0 : intval($a));
    }

    private function governmentLevel($a): int
    {
        switch ($a) {
            case 'State':
                return 2;
            case 'County':
                return 3;
            case 'Municipality':
                return 4;
            default:
                return 0;
        }
    }

    public function governmentlookup($state, $government = '', $type = '')
    {
        $this->data['state'] = $state;
        if ($type == 'governmentparent') {
            $this->data['query'] = $this->db->query('SELECT * FROM extra.ci_model_search_lookup_governmentparent(?, ?)', [$state, rawurldecode($government)])->getResultArray();
        } elseif (strlen($government) < 3) {
            $this->data['query'] = [];
        } else {
            $this->data['query'] = $this->db->query('SELECT * FROM extra.ci_model_search_lookup_government(?, ?)', [$state, rawurldecode($government) . '%'])->getResultArray();
        }
        $this->response->setHeader('Content-Type', 'application/json');
        echo json_encode($this->data['query']);
    }

    public function index($state = '')
    {
        if ($this->data['live']) {
            $stateArray = ['de', 'me', 'ma', 'md', 'mi', 'mn', 'nj', 'ny', 'oh', 'pa', 'wi'];
        } else {
            $stateArray = ['nj', 'pa'];
        }
        $this->data['state'] = $state;
        echo view('header', $this->data);
        if (!$this->data['live'] and !in_array($state, $stateArray)) {
            echo view('search_unavailable');
        } else {
            $this->data['id'] = $this->db->query('SELECT * FROM extra.ci_model_search_form_detail(?)', [$state])->getResult()[0]->governmentslug;
            $this->data['eventTypeQuery'] = $this->db->query('SELECT * FROM extra.ci_model_search_form_eventtype(?)', [$state])->getResultArray();
            $this->data['months'] = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
            foreach ($this->data['months'] as $k => $m) {
                $this->data['months'][$k] = [
                    'monthNumber' => $k + 1,
                    'monthName' => $m
                ];
            }
            $this->data['tribunalgovernmentshortQuery'] = $this->db->query('SELECT * FROM extra.ci_model_search_form_tribunalgovernmentshort(?)', [$state])->getResultArray();
            $this->data['governmentIdentifierTypeQuery'] = $this->db->query('SELECT * FROM extra.ci_model_search_form_governmentidentifiertype(?)', [$state])->getResultArray();
            $this->data['reporterQuery'] = $this->db->query('SELECT * FROM extra.ci_model_search_form_reporter(?)', [$state])->getResultArray();
            echo view('general_ui', $this->data);
            echo view('search', $this->data);
            if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/government_live.php')) {
                echo view(ENVIRONMENT . '/government_live', ['id' => $this->data['id'], 'state' => $state, 'isMunicipalityOrLower' => false, 'isCountyOrLower' => false, 'isCountyOrState' => false, 'isState' => true, 'includeGovernment' => true]);
            }
        }
        echo view('footer');
    }

    public function view($state, $category)
    {
        $this->data['state'] = $state;
        $type = $this->request->getPost('type');
        $fields = [];

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
                            $this->request->getLocale(),
                        ];
                        $type = 'government';
                        break;
                    case 'identifier':
                        $fields = [
                            $this->request->getPost('governmentidentifiertype'),
                            $this->request->getPost('identifier'),
                            $state,
                        ];
                        $category = 'governmentidentifier';
                        break;
                    default:
                        break;
                }
                break;
            case 'law':
                switch ($type) {
                    case 'reference':
                        $fields = [
                            $this->request->getPost('yearvolume'),
                            $this->emptyToZero($this->request->getPost('page')),
                            $this->emptyToZero($this->request->getPost('numberchapter')),
                            $state,
                        ];
                        break;
                    case 'dateevent':
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

        if (count($fields) > 0) {
            echo view('header', $this->data);
            $fieldEmpty = [];
            foreach ($fields as $f) {
                $fieldEmpty[] = '?';
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_search_' . $category . '_' . $type . '(' . implode(', ', $fieldEmpty) . ')', $fields)->getResult();
            $searchParameter = [
                'Search For' => $this->categoryType[$category],
                'Search By' => $this->typeType[$this->request->getPost('type')],
            ];
            foreach ($this->request->getPost() as $key => $value) {
                if (!empty($value) and $key != 'type') {
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
