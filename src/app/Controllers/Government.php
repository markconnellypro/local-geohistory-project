<?php

namespace App\Controllers;

use App\Models\AffectedGovernmentGroupModel;
use App\Models\AppModel;
use App\Models\EventModel;
use App\Models\GovernmentIdentifierModel;
use App\Models\GovernmentShapeModel;
use App\Models\GovernmentSourceModel;
use App\Models\NationalArchivesModel;
use App\Models\ResearchLogModel;

class Government extends BaseController
{
    private string $title = 'Government Detail';

    public function noRecord(string $state): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('core/norecord');
        echo view('core/footer');
    }

    public function view(string $state, int|string $id, bool $isHistory = false): void
    {
        $id = $this->getIdInt($id);
        if ($this->isLive()) {
            $GovernmentFormGovernmentModel = new \App\Models\Development\GovernmentFormGovernmentModel();
            $GovernmentMapStatusModel = new \App\Models\Development\GovernmentMapStatusModel();
            $GovernmentModel = new \App\Models\Development\GovernmentModel();
            $GovernmentPopulationModel = new \App\Models\Development\GovernmentPopulationModel();
            $MetesDescriptionLineModel = new \App\Models\Development\MetesDescriptionLineModel();
            $SourceModel = new \App\Models\Development\SourceModel();
            $SourceCitationModel = new \App\Models\Development\SourceCitationModel();
        } else {
            $GovernmentFormGovernmentModel = new \App\Models\GovernmentFormGovernmentModel();
            $GovernmentMapStatusModel = new \App\Models\GovernmentMapStatusModel();
            $GovernmentModel = new \App\Models\GovernmentModel();
            $GovernmentPopulationModel = new \App\Models\GovernmentPopulationModel();
            $MetesDescriptionLineModel = new \App\Models\MetesDescriptionLineModel();
            $SourceModel = new \App\Models\SourceModel();
            $SourceCitationModel = new \App\Models\SourceCitationModel();
        }
        $query = $GovernmentModel->getDetail($id, $state);
        if (count($query) !== 1 || $query[0]->governmentlevel === 'placeholder') {
            $this->noRecord($state);
        } elseif (!is_null($query[0]->governmentsubstituteslug)) {
            header("HTTP/1.1 301 Moved Permanently");
            header("Location: /" . $this->request->getLocale() . "/" . $state . "/government/" . $query[0]->governmentsubstituteslug . "/");
            exit();
        } else {
            $id = $query[0]->governmentid;
            $isMultiple = ($query[0]->governmentsubstitutemultiple === 't');
            echo view('core/header', ['title' => $this->title, 'pageTitle' => $query[0]->governmentlong]);
            $isMunicipalityOrLower = ($query[0]->governmentlevel === 'municipality or lower');
            $isCountyOrLower = ($query[0]->governmentlevel === 'municipality or lower' || $query[0]->governmentlevel === 'county');
            $isCountyOrState = ($query[0]->governmentlevel === 'state' || $query[0]->governmentlevel === 'county');
            $isStateOrHigher = (($query[0]->governmentlevel === 'state' || $query[0]->governmentlevel === 'country'));
            $hasMap = ($isCountyOrLower && $query[0]->hasmap === 't');
            $showTimeline = ($query[0]->governmentmapstatustimelapse === 't');
            $statusQuery = $GovernmentMapStatusModel->getDetails();
            echo view('government/view', ['query' => $query, 'state' => $state, 'statuses' => $statusQuery]);
            if (!$isHistory) {
                $query = $SourceCitationModel->getByGovernment($id, $state);
                if ($query !== []) {
                    echo view(ENVIRONMENT . '/government/' . $state, ['query' => $query]);
                }
            }
            if ($hasMap) {
                echo view('core/map', ['includeBase' => true]);
            }
            if (!$isHistory) {
                $populationQuery = $GovernmentPopulationModel->getByGovernment($id, $state);
                if ($populationQuery !== []) {
                    echo view('core/chart');
                }
                echo view('government/related', ['query' => $GovernmentModel->getRelated($id, $state)]);
                $GovernmentIdentifierModel = new GovernmentIdentifierModel();
                echo view('governmentidentifier/table', ['query' => $GovernmentIdentifierModel->getByGovernment($id, $state), 'title' => 'Identifier', 'isMultiple' => $isMultiple]);
            }
            $AffectedGovernmentGroupModel = new AffectedGovernmentGroupModel();
            $query = $AffectedGovernmentGroupModel->getByGovernmentGovernment($id, $state);
            $events = [];
            echo view('government/affectedgovernment', ['query' => $query, 'isMultiple' => $isMultiple]);
            foreach ($query as $row) {
                $events[] = $row->event;
            }
            $query = $AffectedGovernmentGroupModel->getByGovernmentForm($id, $state);
            echo view('event/table_affectedgovernmentform', ['includeGovernment' => false, 'query' => $query]);
            foreach ($query as $row) {
                $events[] = $row->event;
            }
            $events = array_unique($events);
            $EventModel = new EventModel();
            if (!$isHistory) {
                if ($isCountyOrLower) {
                    echo view('event/table', ['query' => $EventModel->getByGovernmentSuccess($id, $events), 'state' => $state, 'title' => 'Other Successful Event Links', 'tableId' => 'successfulevent']);
                }
                $GovernmentSourceModel = new GovernmentSourceModel();
                echo view('governmentsource/table', ['query' => $GovernmentSourceModel->getByGovernment($id, $state), 'state' => $state, 'type' => 'government', 'isMultiple' => $isMultiple]);
                $query = $GovernmentModel->getNote($id, $state);
                if ($query !== []) {
                    echo view(ENVIRONMENT . '/government/note', ['query' => $query, 'isMultiple' => $isMultiple]);
                }
                $query = $GovernmentFormGovernmentModel->getByGovernment($id, $state);
                if ($query !== []) {
                    echo view(ENVIRONMENT . '/government/governmentform', ['query' => $query, 'isMultiple' => $isMultiple]);
                }
                $query = $GovernmentModel->getSchoolDistrict($id, $state);
                if ($query !== []) {
                    echo view(ENVIRONMENT . '/government/schooldistrict', ['query' => $query, 'isMultiple' => $isMultiple]);
                }
                echo view('source/table', ['query' => $SourceModel->getByGovernment($id), 'hasLink' => true]);
                $ResearchLogModel = new ResearchLogModel();
                echo view('government/researchlog', ['query' => $ResearchLogModel->getByGovernment($id, $state), 'isMultiple' => $isMultiple]);
                $NationalArchivesModel = new NationalArchivesModel();
                echo view('government/nationalarchives', ['query' => $NationalArchivesModel->getByGovernment($id, $state), 'isMultiple' => $isMultiple]);
                if ($isCountyOrLower) {
                    echo view('event/table', ['query' => $EventModel->getByGovernmentFailure($id, $events), 'state' => $state, 'title' => 'Other Event Links', 'tableId' => 'otherevent']);
                }
                $query = $GovernmentModel->getOffice($id, $state);
                if ($query !== []) {
                    echo view(ENVIRONMENT . '/government/office', ['query' => $query, 'isMultiple' => $isMultiple]);
                }
                if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/government/live.php')) {
                    echo view(ENVIRONMENT . '/government/live', ['id' => $id, 'state' => $state, 'isMunicipalityOrLower' => $isMunicipalityOrLower, 'isCountyOrLower' => $isCountyOrLower, 'isCountyOrState' => $isCountyOrState, 'isState' => $isStateOrHigher, 'includeGovernment' => false]);
                }
                echo view('core/chartjs', ['query' => $populationQuery, 'xLabel' => 'Year', 'yLabel' => 'Population']);
            }
            if ($hasMap) {
                echo view('leaflet/start', ['type' => 'government', 'includeBase' => true, 'needRotation' => false]);
                $query = $MetesDescriptionLineModel->getGeometryByGovernment($id);
                $layers = [];
                $primaryLayer = '';
                if ($query !== []) {
                    echo view('core/gis', [
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
                $GovernmentShapeModel = new GovernmentShapeModel();
                $query = $GovernmentShapeModel->getCurrentByGovernment($id);
                if ($query !== []) {
                    echo view('core/gis', [
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
                $query = $GovernmentShapeModel->getPartByGovernment($id, $state);
                if ($query !== []) {
                    echo view('core/gis', [
                        'query' => $query,
                        'element' => 'shape',
                        'onEachFeature' => false,
                        'onEachFeature2' => true,
                        'customStyle' => 'dispositionStyle'
                    ]);
                    $layers['shape'] = 'Government Area';
                    $primaryLayer = 'shape';
                }
                date_default_timezone_set('America/New_York');
                $AppModel = new AppModel();
                $updatedParts = $AppModel->getLastUpdated()[0];
                echo view('government/end', ['layers' => $layers, 'primaryLayer' => $primaryLayer, 'state' => $state, 'updatedParts' => $updatedParts, 'showTimeline' => $showTimeline]);
                echo view('leaflet/end');
            }
            echo view('core/footer');
        }
    }
}
