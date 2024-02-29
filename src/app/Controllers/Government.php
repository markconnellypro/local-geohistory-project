<?php

namespace App\Controllers;

class Government extends BaseController
{

    private $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'Government Detail',
            'isInternetExplorer' => $this->isInternetExplorer(),
            'live' => $this->isLive(),
            'online' => $this->isOnline(),
            'updated' => $this->lastUpdated()->fulldate,
            'updatedParts' => $this->lastUpdated(),
        ];
    }

    public function noRecord($state)
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);
        echo view('norecord');
        echo view('footer');
    }

    public function view($state, $id, $isHistory = false)
    {
        $this->data['state'] = $state;
        $id = $this->getIdInt($id);
        $query = $this->db->query('SELECT * FROM extra' . ($this->data['live'] ? '_development' : '') . '.ci_model_government_detail(?, ?, ?)', [$id, $state, $this->data['live']])->getResult();
        if (count($query) != 1 or $query[0]->governmentlevel == 'placeholder') {
            $this->noRecord($state);
        } elseif (!empty($query[0]->governmentsubstituteslug)) {
            header("HTTP/1.1 301 Moved Permanently");
            header("Location: /" . $this->request->getLocale() . "/" . $state . "/government/" . $query[0]->governmentsubstituteslug . "/");
            exit();
        } else {
            $id = $query[0]->governmentid;
            $this->data['isHistory'] = $isHistory;
            $this->data['pageTitle'] = $query[0]->governmentlong;
            $this->data['isMultiple'] = ($query[0]->governmentsubstitutemultiple == 't');
            echo view('header', $this->data);
            $isMunicipalityOrLower = ($query[0]->governmentlevel == 'municipality or lower');
            $isCountyOrLower = ($query[0]->governmentlevel == 'municipality or lower' or $query[0]->governmentlevel == 'county');
            $isCountyOrState = ($query[0]->governmentlevel == 'state' or $query[0]->governmentlevel == 'county');
            $isStateOrHigher = (($query[0]->governmentlevel == 'state' or $query[0]->governmentlevel == 'country'));
            $hasMap = ($isCountyOrLower ? ($query[0]->hasmap == 't') : false);
            $showTimeline = ($query[0]->governmentmapstatustimelapse == 't');
            if ($this->data['live']) {
                $statusQuery = $this->db->query('SELECT * FROM extra_development.ci_model_government_mapstatus()')->getResult();
            } else {
                $statusQuery = [];
            }
            echo view('government_detail', ['live' => $this->data['live'], 'row' => $query[0], 'state' => $state, 'statuses' => $statusQuery]);

            if (!$isHistory and file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/government_' . $state . '.php')) {
                if ($state == 'ny') {
                    $query = $this->db->query('SELECT * FROM reference_usa_state.ci_model_ny_lawgovernment(?)', [$id])->getResult();
                } else {
                    $query = $this->db->query('SELECT * FROM extra_development.ci_model_government_' . $state . '(?)', [$id])->getResult();
                }
                if (count($query) > 0) {
                    echo view(ENVIRONMENT . '/government_' . $state, ['query' => $query]);
                }
            }
            if ($hasMap) {
                echo view('general_map', ['live' => $this->data['live'], 'includeBase' => true]);
            }
            if (!$isHistory) {
                if ($this->data['live']) {
                    $populationquery = $this->db->query('SELECT * FROM extra_development.ci_model_government_population(?, ?)', [$id, $state])->getResult();
                    if (count($populationquery) > 0) {
                        echo view('general_chart');
                    }
                }
                $query = $this->db->query('SELECT * FROM extra.ci_model_government_related(?, ?, ?)', [$id, $state, $this->request->getLocale()])->getResult();
                if (count($query) > 0) {
                    echo view('government_related', ['query' => $query]);
                }
                $query = $this->db->query('SELECT * FROM extra.ci_model_government_identifier(?, ?, ?)', [$id, $state, $this->request->getLocale()])->getResult();
                if (count($query) > 0) {
                    echo view('general_governmentidentifier', ['query' => $query, 'title' => 'Identifier', 'isMultiple' => $this->data['isMultiple']]);
                }
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_government_affectedgovernment(?, ?, ?)', [$id, $state, $this->request->getLocale()])->getResult();
            $events = [];
            if (count($query) > 0) {
                echo view('government_affectedgovernment', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                foreach ($query as $row) {
                    $events[] = $row->event;
                }
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_government_affectedgovernmentform(?, ?, ?)', [$id, $state, $this->data['live']])->getResult();
            if (count($query) > 0) {
                echo view('general_affectedgovernmentform', ['includeGovernment' => false, 'query' => $query]);
                foreach ($query as $row) {
                    $events[] = $row->event;
                }
            }
            $events = array_unique($events);
            $events = '{' . implode(',', $events) . '}';
            if (!$isHistory) {
                if ($isCountyOrLower) {
                    $query = $this->db->query('SELECT * FROM extra.ci_model_government_event_success(?, ?)', [$id, $events])->getResult();
                    if (count($query) > 0) {
                        echo view('general_event', ['query' => $query, 'state' => $state, 'title' => 'Other Successful Event Links', 'tableId' => 'successfulevent']);
                    }
                }
                $query = $this->db->query('SELECT * FROM extra.ci_model_government_governmentsource(?, ?, ?)', [$id, $state, $this->data['live']])->getResult();
                if (count($query) > 0) {
                    echo view('general_governmentsource', ['query' => $query, 'state' => $state, 'type' => 'government', 'isMultiple' => $this->data['isMultiple']]);
                }
                if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/government_note.php')) {
                    $query = $this->db->query('SELECT * FROM extra_development.ci_model_government_note(?, ?, ?)', [$id, $state, $this->request->getLocale()])->getResult();
                    if (count($query) > 0) {
                        echo view(ENVIRONMENT . '/government_note', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                    }
                }
                if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/government_governmentform.php')) {
                    $query = $this->db->query('SELECT * FROM extra_development.ci_model_government_governmentform(?, ?)', [$id, $state])->getResult();
                    if (count($query) > 0) {
                        echo view(ENVIRONMENT . '/government_governmentform', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                    }
                }
                if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/government_schooldistrict.php')) {
                    $query = $this->db->query('SELECT * FROM extra_development.ci_model_government_schooldistrict(?, ?)', [$id, $state])->getResult();
                    if (count($query) > 0) {
                        echo view(ENVIRONMENT . '/government_schooldistrict', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                    }
                }
                if ($this->data['live']) {
                    $query = $this->db->query('SELECT * FROM extra_development.ci_model_government_source(?)', [$id])->getResult();
                    if (count($query) > 0) {
                        echo view('general_source', ['query' => $query, 'hasLink' => true]);
                    }
                }
                $query = $this->db->query('SELECT * FROM extra.ci_model_government_researchlog(?, ?, ?)', [$id, $state, $this->data['live']])->getResult();
                if (count($query) > 0) {
                    echo view('government_researchlog', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                }
                $query = $this->db->query('SELECT * FROM extra.ci_model_government_nationalarchives(?, ?)', [$id, $state])->getResult();
                if (count($query) > 0) {
                    echo view('government_nationalarchives', ['query' => $query, 'live' => $this->data['live'], 'isMultiple' => $this->data['isMultiple']]);
                }
                if ($isCountyOrLower) {
                    $query = $this->db->query('SELECT * FROM extra.ci_model_government_event_failure(?, ?)', [$id, $events])->getResult();
                    if (count($query) > 0) {
                        echo view('general_event', ['query' => $query, 'state' => $state, 'title' => 'Other Event Links', 'tableId' => 'otherevent']);
                    }
                }
                if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/government_office.php')) {
                    $query = $this->db->query('SELECT * FROM extra_development.ci_model_government_office(?, ?)', [$id, $state])->getResult();
                    if (count($query) > 0) {
                        echo view(ENVIRONMENT . '/government_office', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                    }
                }
                if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/government_live.php')) {
                    echo view(ENVIRONMENT . '/government_live', ['id' => $id, 'state' => $state, 'isMunicipalityOrLower' => $isMunicipalityOrLower, 'isCountyOrLower' => $isCountyOrLower, 'isCountyOrState' => $isCountyOrState, 'isState' => $isStateOrHigher, 'includeGovernment' => false]);
                }
                if (isset($populationquery) and count($populationquery) > 0) {
                    echo view('general_chartjs', ['query' => $populationquery, 'online' => $this->data['online'], 'xLabel' => 'Year', 'yLabel' => 'Population']);
                }
            }
            if ($hasMap) {
                echo view('leaflet_start', ['type' => 'government', 'includeBase' => true, 'needRotation' => false, 'online' => $this->data['online']]);
                if ($this->data['live']) {
                    $query = $this->db->query('SELECT * FROM extra_development.ci_model_government_metesdescription(?)', [$id])->getResult();
                    if (count($query) > 0) {
                        echo view('general_gis', [
                            'query' => $query,
                            'element' => 'metesdescription',
                            'onEachFeature' => true,
                            'onEachFeature2' => false,
                            'weight' => 1.25,
                            'color' => 'D5103F',
                            'fillOpacity' => 0
                        ]);
                        $layers['metesdescription'] = 'Descriptions';
                        $primaryLayer = 'metesdescription';
                    }
                }
                $query = $this->db->query('SELECT * FROM extra.ci_model_government_current(?)', [$id])->getResult();
                if (count($query) > 0) {
                    echo view('general_gis', [
                        'query' => $query,
                        'element' => 'current',
                        'onEachFeature' => false,
                        'onEachFeature2' => false,
                        'weight' => 3,
                        'color' => '000000',
                        'fillOpacity' => 0
                    ]);
                    $layers['current'] = 'Approximate Current Boundary';
                }
                $query = $this->db->query('SELECT * FROM extra.ci_model_government_shape(?, ?, ?)', [$id, $state, $this->request->getLocale()])->getResult();
                if (count($query) > 0) {
                    echo view('general_gis', [
                        'query' => $query,
                        'element' => 'shape',
                        'onEachFeature' => false,
                        'onEachFeature2' => true,
                        'customStyle' => 'dispositionStyle'
                    ]);
                    $layers['shape'] = 'Government Area';
                    $primaryLayer = 'shape';
                }
                echo view('government_end', ['layers' => $layers, 'live' => $this->data['live'], 'primaryLayer' => $primaryLayer, 'state' => $state, 'updatedParts' => $this->data['updatedParts'], 'showTimeline' => $showTimeline]);
                echo view('leaflet_end', ['live' => $this->data['live']]);
            }
            echo view('footer');
        }
    }
}
