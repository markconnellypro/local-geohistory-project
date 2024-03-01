<?php

namespace App\Controllers;

use App\Models\EventTypeModel;

class Statistics extends BaseController
{

    private $data;

    private $byType = [
        'current' => 'Modern-Day Jurisdictions',
        'historic' => 'Contemporaneous Jurisdictions',
        'incorporated' => 'Incorporated Municipalities',
        'total' => 'Total Municipalities',
    ];

    private $forType = [
        'eventtype' => 'Events by Event Type',
        'created' => 'Created Municipalities',
        'dissolved' => 'Dissolved Municipalities',
        'net' => 'Net Created-Dissolved Municipalities',
        'mapped' => 'Mapped Municipalities',
        'mapped_review' => 'Reviewed Municipalities',
    ];

    public function __construct()
    {
        $this->data = [
            'title' => 'Statistics',
            'isInternetExplorer' => $this->isInternetExplorer(),
            'live' => $this->isLive(),
            'online' => $this->isOnline(),
            'updated' => $this->lastUpdated()->fulldate,
        ];
    }

    public function index($state = '')
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);
        echo view('general_ui', $this->data);
        $EventTypeModel = new EventTypeModel;
        $this->data['eventTypeQuery'] = $EventTypeModel->getManyByStatistics($state);
        echo view('statistics_index', $this->data);
        echo view('footer');
    }

    public function noRecord($state = '')
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);
        echo view('norecord');
        echo view('footer');
    }

    public function view($state = '')
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);

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

        if (!isset($this->byType[$by])) {
            echo view('error');
            echo view('footer');
            die();
        } else {
            $searchParameter['byType'] = $this->byType[$by];
            $by .= $byExtra;
        }

        $from = $this->request->getPost('from', FILTER_SANITIZE_NUMBER_INT);
        $to = $this->request->getPost('to', FILTER_SANITIZE_NUMBER_INT);
        if (empty($from) and empty($to)) {
            $from = 0;
            $to = intval(date('Y'));
        } elseif (empty($from)) {
            $from = $to;
        } elseif (empty($to)) {
            $to = $from;
        } elseif ($from > $to) {
            $temporary = $to;
            $to = $from;
            $from = $temporary;
        }
        if ($from == $to or $from == 0) {
            $dateRange = $from;
            $dateRangePlural = '';
        } else {
            $dateRange = $from . '&ndash;' . $to;
            $dateRangePlural = 's';
        }

        if (!isset($this->forType[$for])) {
            echo view('error');
            echo view('footer');
            die();
        } else {
            $searchParameter = [
                'Metric' => $this->forType[$for . $byExtra],
                'Grouped By' => $searchParameter['byType'],
            ];
        }

        $fields = [$from, $to, $by];
        if ($for == 'eventtype') {
            $eventType = $this->request->getPost('eventtype');
            if (empty($eventType)) {
                $eventType = '';
            }
            $EventTypeModel = new EventTypeModel;
            $query = $EventTypeModel->getOneByStatistics($eventType);
            if (count($query) !== 1) {
                echo view('error');
                echo view('footer');
                die();
            }
            array_unshift($fields, $eventType);
            $searchParameter['Event Type'] = $query[0]->eventtypeshort;
        } else {
            $eventType = '';
            array_unshift($fields, $for);
            if ($for != 'mapped') {
                $for = 'createddissolved';
            }
        }

        if (!empty($dateRange)) {
            $searchParameter['Year' . $dateRangePlural] = $dateRange;
        }

        $fields[] = $state;

        $types = [
            'createddissolved' => 'Government',
            'eventtype' => 'Event',
            'mapped' => 'GovernmentShape',
        ];
        $model = "App\\Models\\" . $types[$for] . 'Model';
        $model = new $model;
        $type = 'getByStatistics' . (empty($state) ? 'Nation' : 'State') . 'Whole';

        $this->data['wholeQuery'] = $model->$type($fields);
        if ($this->data['wholeQuery'][0]->datarow == '["x"]') {
            $this->data['wholeQuery'] = [];
        } else {
            $type = str_replace('Whole', 'Part', $type);
            $this->data['query'] = $model->$type($fields);
            foreach ($this->data['query'] as $key => $row) {
                $this->data['query'][$key] = '"' . $row->series . '":{"xrow":' . $row->xrow . ',"yrow":' . $row->yrow . ',"ysum":' . $row->ysum . '}';
            }
            $this->data['query'] = '{' . implode(',',  $this->data['query']) . '}';
        }

        $this->data['isContemporaneous'] = ($searchParameter['Grouped By'] == 'Contemporaneous Jurisdictions');
        $this->data['notEvent'] = ($searchParameter['Metric'] == 'Events by Event Type');
        echo view('general_parameter', ['searchParameter' => $searchParameter]);
        echo view('statistics_view', $this->data);
        if (count($this->data['wholeQuery']) > 0) {
            echo view('general_chartjs', ['query' => $this->data['wholeQuery'], 'online' => $this->data['online'], 'xLabel' => 'Year', 'yLabel' => ($for == 'createddissolved' ? 'Governments' : 'Events')]);
        }
        echo view('footer');
    }
}
