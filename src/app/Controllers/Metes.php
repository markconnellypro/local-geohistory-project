<?php

namespace App\Controllers;

use App\Models\MetesDescriptionModel;

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

    public function noRecord($state): void
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);
        echo view('norecord');
        echo view('footer');
    }

    public function view($state, $id): void
    {
        $this->data['state'] = $state;
        $id = $this->getIdInt($id);
        $MetesDescriptionModel = new MetesDescriptionModel();
        $areaQuery = $MetesDescriptionModel->getDetail($id, $state);
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
            $hasBegin = ($areaQuery[0]->hasbeginpoint == 't' || $hasArea);
            if ($this->data['live']) {
                $MetesDescriptionLineModel = new \App\Models\Development\MetesDescriptionLineModel();
            } else {
                $MetesDescriptionLineModel = new \App\Models\MetesDescriptionLineModel();
            }
            $geometryQuery = $MetesDescriptionLineModel->getGeometryByMetesDescription($id);
            $hasMetes = (count($geometryQuery) > 1);
            if ($hasArea || $hasMetes) {
                $hasMap = true;
                echo view('general_map', ['live' => $this->data['live'], 'includeBase' => $hasBegin, 'includeDisclaimer' => true]);
            }
            $query = $MetesDescriptionLineModel->getByMetesDescription($id);
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
