<?php

namespace App\Controllers;

class Metes extends BaseController
{

    private $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'Metes and Bounds Description Detail',
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
        if ($this->data['live'] and preg_match('/^\d{1,9}$/', $id)) {
            $id = intval($id);
        }
        $areaQuery = $this->db->query('SELECT * FROM extra.ci_model_metes_detail(?, ?)', [$id, $state])->getResult();
        if (count($areaQuery) != 1) {
            $this->noRecord($state);
        } else {
            $id = $areaQuery[0]->metesdescriptionid;
            $this->data['pageTitle'] = $areaQuery[0]->metesdescriptionlong;
            echo view('header', $this->data);
            echo view('general_metes', ['query' => $areaQuery, 'hasLink' => false, 'title' => 'Detail']);
            $hasMap = false;
            $hasMetes = false;
            $hasArea = (!is_null($areaQuery[0]->geometry));
            $hasBegin = ($areaQuery[0]->hasbeginpoint == 't' or $hasArea);
            if ($this->data['live']) {
                $geometryQuery = $this->db->query('SELECT * FROM extra_development.ci_model_metes_line(?)', [$id])->getResult();
                $hasMetes = (count($geometryQuery) > 1);
            }
            if ($hasArea or $hasMetes) {
                $hasMap = true;
                echo view('general_map', ['live' => $this->data['live'], 'includeBase' => $hasBegin, 'includeDisclaimer' => true]);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_metes_row(?)', [$id])->getResult();
            if (count($query) > 0) {
                echo view('metes_row', ['query' => $query]);
            }
            echo view('general_event', ['query' => $areaQuery, 'state' => $state, 'title' => 'Event Links']);
            if ($hasMap) {
                echo view('leaflet_start', ['type' => 'metes', 'includeBase' => $hasBegin, 'needRotation' => false, 'online' => $this->data['online']]);
                if ($hasArea) {
                    echo view('general_gis', [
                        'query' => $areaQuery,
                        'element' => 'area',
                        'onEachFeature' => false,
                        'onEachFeature2' => false,
                        'weight' => 0,
                        'color' => '07517D',
                        'fillOpacity' => 0.5
                    ]);
                }
                if ($hasMetes) {
                    echo view('general_gis', [
                        'query' => $geometryQuery,
                        'element' => 'line',
                        'onEachFeature' => true,
                        'onEachFeature2' => false,
                        'weight' => 3,
                        'color' => 'D5103F',
                        'fillOpacity' => 0
                    ]);
                    echo view('general_gis', [
                        'query' => $geometryQuery,
                        'element' => 'point',
                        'onEachFeature' => true,
                        'onEachFeature2' => false,
                        'weight' => 3,
                        'color' => 'D5103F',
                        'fillOpacity' => 0,
                        'radius' => 6
                    ]);
                }
                echo view('metes_end', ['includeBase' => $hasBegin, 'includeArea' => $hasArea, 'includeMetes' => $hasMetes]);
                echo view('leaflet_end', ['includeBase' => $hasBegin, 'live' => $this->data['live']]);
            }
            echo view('footer');
        }
    }
}
