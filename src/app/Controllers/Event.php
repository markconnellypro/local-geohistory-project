<?php

namespace App\Controllers;

class Event extends BaseController
{

    private $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'Event Detail',
            'isInternetExplorer' => $this->isInternetExplorer(),
            'live' => $this->isLive(),
            'online' => $this->isOnline(),
            'updated' => $this->lastUpdated()->fulldate,
        ];
    }

    public function noRecord($state)
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);
        echo view('norecord');
        echo view('footer');
    }

    public function view($state, $id)
    {
        $this->data['state'] = $state;
        $id = $this->getIdInt($id);
        $query = $this->db->query('SELECT * FROM extra.ci_model_event_detail(?, ?)', [$id, $state])->getResult();

        if (count($query) != 1 or ($query[0]->eventgranted == 'placeholder' and !$this->data['live'])) {
            $this->noRecord($state);
        } elseif (!empty($query[0]->eventslugnew)) {
            header("HTTP/1.1 301 Moved Permanently");
            header("Location: /" . $this->request->getLocale() . "/" . $state . "/event/" . $query[0]->eventslugnew . "/");
            exit();
        } else {
            $id = $query[0]->eventid;
            $eventIsMapped = ($query[0]->eventismapped == 't');
            $this->data['pageTitle'] = $query[0]->eventlong;
            $this->data['pageTitleType'] = $query[0]->eventtypeshort;
            echo view('header', $this->data);
            echo view('event_detail', ['row' => $query[0]]);
            $query = $this->db->query('SELECT * FROM extra.ci_model_event_affectedgovernment_part(?, ?, ?)', [$id, $state, $this->request->getLocale()])->getResult();
            $affectedgovernmentgisquery = $this->db->query('SELECT * FROM extra.ci_model_event_affectedgovernment(?)', [$id])->getResultArray();
            $affectedGovernment = $this->affectedGovernmentProcess($query, $affectedgovernmentgisquery);
            $hasMap = (count($affectedgovernmentgisquery) > 0);
            $hasAffectedGovernmentMap = (count($affectedgovernmentgisquery) > 0);
            if ($this->data['live']) {
                $metesdescriptiongisquery = $this->db->query('SELECT * FROM extra_development.ci_model_event_metesdescription_gis(?, ?)', [$id, $state])->getResult();
                if (count($metesdescriptiongisquery) > 0) {
                    $hasMap = true;
                }
            }
            if (!$this->data['live'] and !$eventIsMapped) {
                $hasMap = false;
            }
            if ($hasMap) {
                echo view('general_map', ['live' => $this->data['live'], 'includeBase' => true, 'eventIsMapped' => $eventIsMapped]);
            }
            if (count($query) > 0) {
                echo view('general_affectedgovernment2', ['affectedGovernment' => $affectedGovernment, 'state' => $state, 'includeDate' => false, 'live' => $this->data['live'], 'isComplete' => true]);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_event_affectedgovernmentform(?, ?, ?, ?)', [$id, $state, $this->data['live'], $this->request->getLocale()])->getResult();
            if (count($query) > 0) {
                echo view('general_affectedgovernmentform', ['includeGovernment' => true, 'query' => $query]);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_event_currentgovernment(?, ?, ?)', [$id, $state, $this->request->getLocale()])->getResult();
            if (count($query) > 0) {
                echo view('general_currentgovernment', ['query' => $query, 'state' => $state]);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_event_metesdescription(?)', [$id])->getResult();
            if (count($query) > 0) {
                echo view('general_metes', ['query' => $query, 'hasLink' => true, 'state' => $state, 'title' => 'Metes and Bounds Description']);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_event_plss(?)', [$id])->getResult();
            if (count($query) > 0) {
                echo view('event_plss', ['query' => $query]);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_event_adjudication(?)', [$id])->getResult();
            if (count($query) > 0) {
                echo view('general_adjudication', ['query' => $query, 'state' => $state, 'eventRelationship' => true]);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_event_law(?)', [$id])->getResult();
            if (count($query) > 0) {
                echo view('general_law', ['query' => $query, 'state' => $state, 'title' => 'Law', 'type' => 'relationship', 'includeLawGroup' => true]);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_event_recording(?, ?, ?)', [$id, $state, $this->request->getLocale()])->getResult();
            if (count($query) > 0) {
                echo view('event_recording', ['query' => $query]);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_event_governmentsource(?, ?, ?, ?)', [$id, $state, $this->data['live'], $this->request->getLocale()])->getResult();
            if (count($query) > 0) {
                echo view('general_governmentsource', ['query' => $query, 'state' => $state, 'type' => 'event']);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_event_source(?)', [$id])->getResult();
            if (count($query) > 0) {
                echo view('general_sourcecitation', ['query' => $query, 'state' => $state, 'hasColor' => false, 'hasLink' => true, 'title' => 'Source']);
            }
            if ($hasMap) {
                $i = 0;
                echo view('leaflet_start', ['type' => 'event', 'includeBase' => true, 'needRotation' => false, 'online' => $this->data['online']]);
                echo view('event_affectedgovernmenttype', ['query' => $affectedGovernment['types']]);
                if ($hasAffectedGovernmentMap) {
                    echo view('general_gis', [
                        'query' => $affectedGovernment['rows'],
                        'element' => 'affectedgovernment',
                        'onEachFeature' => true,
                        'onEachFeature2' => false,
                        'weight' => 1.25,
                        'color' => 'D5103F',
                        'fillOpacity' => 0.1
                    ]);
                }
                $layers = [];
                if ($this->data['live'] and count($metesdescriptiongisquery) > 0) {
                    echo view('general_gis', [
                        'query' => $metesdescriptiongisquery,
                        'element' => 'metesdescription',
                        'onEachFeature' => false,
                        'onEachFeature2' => false,
                        'weight' => 1.25,
                        'color' => 'D5103F',
                        'fillOpacity' => 0.1
                    ]);
                    $layers['metesdescription'] = 'Descriptions';
                }
                if ($hasAffectedGovernmentMap) {
                    echo view('event_end', ['layers' => $layers]);
                } else {
                    echo view('event_end_metesdescription');
                }
                echo view('leaflet_end', ['live' => $this->data['live']]);
            }
            echo view('footer');
        }
    }
}
