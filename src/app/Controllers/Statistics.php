<?php

namespace App\Controllers;

use App\Models\EventTypeModel;
use App\Models\GovernmentModel;
use CodeIgniter\HTTP\RedirectResponse;

class Statistics extends BaseController
{
    private string $title = 'Statistics';

    private array $byType = [
        'current' => 'Modern-Day Jurisdictions',
        'historic' => 'Contemporaneous Jurisdictions',
        'incorporated' => 'Incorporated Municipalities',
        'total' => 'Total Municipalities',
    ];

    private array $forType = [
        'eventtype' => 'Events by Event Type',
        'created' => 'Created Municipalities',
        'dissolved' => 'Dissolved Municipalities',
        'net' => 'Net Created-Dissolved Municipalities',
        'mapped' => 'Mapped Municipalities',
        'mapped_review' => 'Reviewed Municipalities',
    ];

    public function index(): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('core/ui');
        $EventTypeModel = new EventTypeModel();
        $GovernmentModel = new GovernmentModel();
        echo view('statistics/index', [
            'eventTypeQuery' => $EventTypeModel->getManyByStatistics(),
            'jurisdictions' => $GovernmentModel->getByStatisticsJurisdiction(),
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
        return redirect()->to('/' . $this->request->getLocale() . '/statistics/', 301);
    }

    public function view(): void
    {
        echo view('core/header', ['title' => $this->title]);

        $by = $this->request->getPost('by');
        $for = $this->request->getPost('for');
        $for = explode('_', $for);
        if (isset($for[1])) {
            $by = $for[1];
        }
        $byExtra = '';
        if (isset($for[2])) {
            $byExtra = '_' . $for[2];
        }
        $for = $for[0];

        $searchParameter = [];
        if (!isset($this->byType[$by])) {
            echo view('core/error');
            echo view('core/footer');
            die();
        } else {
            $searchParameter['byType'] = $this->byType[$by];
            $by .= $byExtra;
        }

        $from = (int) $this->request->getPost('from', FILTER_SANITIZE_NUMBER_INT);
        $to = (int) $this->request->getPost('to', FILTER_SANITIZE_NUMBER_INT);
        if ($from === 0 && $to === 0) {
            $to = (int) date('Y');
        } elseif ($from === 0) {
            $from = $to;
        } elseif ($to === 0) {
            $to = $from;
        } elseif ($from > $to) {
            $temporary = $to;
            $to = $from;
            $from = $temporary;
        }
        if ($from === 0 || $from === $to) {
            $dateRange = $from === 0 ? '' : (string) $from;
            $dateRangePlural = '';
        } else {
            $dateRange = $from . '&ndash;' . $to;
            $dateRangePlural = 's';
        }

        if (!isset($this->forType[$for])) {
            echo view('core/error');
            echo view('core/footer');
            die();
        } else {
            $searchParameter = [
                'Metric' => $this->forType[$for . $byExtra],
                'Grouped By' => $searchParameter['byType'],
            ];
        }

        $fields = [$from, $to, $by];
        if ($for === 'eventtype') {
            $eventType = (string) $this->request->getPost('eventtype');
            $EventTypeModel = new EventTypeModel();
            $query = $EventTypeModel->getOneByStatistics($eventType);
            if (count($query) !== 1) {
                echo view('core/error');
                echo view('core/footer');
                die();
            }
            array_unshift($fields, $eventType);
            $searchParameter['Event Type'] = $query[0]->eventtypeshort;
        } else {
            $eventType = '';
            array_unshift($fields, $for);
            if ($for !== 'mapped') {
                $for = 'createddissolved';
            }
        }

        if ($dateRange !== '') {
            $searchParameter['Year' . $dateRangePlural] = $dateRange;
        }

        $jurisdiction = $this->request->getPost('governmentjurisdiction') ?? '';
        $fields[] = $jurisdiction;

        $types = [
            'createddissolved' => 'Government',
            'eventtype' => 'Event',
            'mapped' => 'GovernmentShape',
        ];
        if ($types[$for] === 'GovernmentShape' && class_exists("App\\Models\\Development\\GovernmentShapeModel")) {
            $model = "App\\Models\\Development\\GovernmentShapeModel";
        } else {
            $model = "App\\Models\\" . $types[$for] . 'Model';
        }
        $model = new $model();
        $type = 'getByStatistics' . ($jurisdiction === '' ? 'Nation' : 'State') . 'Whole';

        $wholeQuery = $model->$type($fields);
        if ($wholeQuery[0]->datarow === '["x"]') {
            $wholeQuery = [];
            $query = [];
        } else {
            $type = str_replace('Whole', 'Part', $type);
            $query = $model->$type($fields);
            foreach ($query as $key => $row) {
                $query[$key] = '"' . $row->series . '":{"xrow":' . $row->xrow . ',"yrow":' . $row->yrow . ',"ysum":' . $row->ysum . '}';
            }
            $query = '{' . implode(',', $query) . '}';
        }
        echo view('core/parameter', ['searchParameter' => $searchParameter]);
        echo view('statistics/view', [
            'wholeQuery' => $wholeQuery,
            'isContemporaneous' => ($searchParameter['Grouped By'] === 'Contemporaneous Jurisdictions'),
            'notEvent' => ($searchParameter['Metric'] === 'Events by Event Type'),
            'query' => $query,
            'jurisdiction' => $jurisdiction,
        ]);
        echo view('core/chartjs', ['query' => $wholeQuery, 'xLabel' => 'Year', 'yLabel' => ($for === 'createddissolved' ? 'Governments' : 'Events')]);
        echo view('core/footer');
    }
}
