<?php

namespace App\Controllers;

use App\Models\MetesDescriptionModel;

class Metes extends BaseController
{
    private string $title = 'Metes and Bounds Description Detail';

    public function noRecord(string $state): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('core/norecord');
        echo view('core/footer');
    }

    public function view(string $state, int|string $id): void
    {
        $id = $this->getIdInt($id);
        $MetesDescriptionModel = new MetesDescriptionModel();
        $areaQuery = $MetesDescriptionModel->getDetail($id, $state);
        if (count($areaQuery) !== 1) {
            $this->noRecord($state);
        } else {
            $id = $areaQuery[0]->metesdescriptionid;
            echo view('core/header', ['title' => $this->title, 'pageTitle' => $areaQuery[0]->metesdescriptionlong]);
            echo view('metes/table', ['query' => $areaQuery, 'hasLink' => false, 'title' => 'Detail']);
            $hasMap = false;
            $hasMetes = false;
            $hasArea = (!is_null($areaQuery[0]->geometry));
            $hasBegin = ($areaQuery[0]->hasbeginpoint === 't' || $hasArea);
            if ($this->isLive()) {
                $MetesDescriptionLineModel = new \App\Models\Development\MetesDescriptionLineModel();
            } else {
                $MetesDescriptionLineModel = new \App\Models\MetesDescriptionLineModel();
            }
            $geometryQuery = $MetesDescriptionLineModel->getGeometryByMetesDescription($id);
            $hasMetes = (count($geometryQuery) > 1);
            if ($hasArea || $hasMetes) {
                $hasMap = true;
                echo view('core/map', ['includeBase' => $hasBegin, 'includeDisclaimer' => true]);
            }
            echo view('metes/row', ['query' => $MetesDescriptionLineModel->getByMetesDescription($id)]);
            echo view('event/table', ['query' => $areaQuery, 'state' => $state, 'title' => 'Event Links']);
            if ($hasMap) {
                echo view('leaflet/start', ['type' => 'metes', 'includeBase' => $hasBegin, 'needRotation' => false]);
                if ($hasArea) {
                    echo view('core/gis', [
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
                    echo view('core/gis', [
                        'query' => $geometryQuery,
                        'element' => 'line',
                        'onEachFeature' => true,
                        'onEachFeature2' => false,
                        'weight' => 3,
                        'color' => 'D5103F',
                        'fillOpacity' => 0
                    ]);
                    echo view('core/gis', [
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
                echo view('metes/end', ['includeBase' => $hasBegin, 'includeArea' => $hasArea, 'includeMetes' => $hasMetes]);
                echo view('leaflet/end', ['includeBase' => $hasBegin]);
            }
            echo view('core/footer');
        }
    }
}
