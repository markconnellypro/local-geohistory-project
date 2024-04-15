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
    private array $data = [
        'title' => 'Government Detail',
    ];

    public function __construct()
    {
    }

    public function noRecord(string $state): void
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);
        echo view('norecord');
        echo view('footer');
    }

    public function view(string $state, int|string $id, bool $isHistory = false): void
    {
        $this->data['state'] = $state;
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
            $this->data['isHistory'] = $isHistory;
            $this->data['pageTitle'] = $query[0]->governmentlong;
            $this->data['isMultiple'] = ($query[0]->governmentsubstitutemultiple === 't');
            echo view('header', $this->data);
            $isMunicipalityOrLower = ($query[0]->governmentlevel === 'municipality or lower');
            $isCountyOrLower = ($query[0]->governmentlevel === 'municipality or lower' || $query[0]->governmentlevel === 'county');
            $isCountyOrState = ($query[0]->governmentlevel === 'state' || $query[0]->governmentlevel === 'county');
            $isStateOrHigher = (($query[0]->governmentlevel === 'state' || $query[0]->governmentlevel === 'country'));
            $hasMap = ($isCountyOrLower && $query[0]->hasmap === 't');
            $showTimeline = ($query[0]->governmentmapstatustimelapse === 't');
            $statusQuery = $GovernmentMapStatusModel->getDetails();
            echo view('government/detail', ['query' => $query, 'state' => $state, 'statuses' => $statusQuery]);
            if (!$isHistory) {
                $query = $SourceCitationModel->getByGovernment($id, $state);
                if ($query !== []) {
                    echo view(ENVIRONMENT . '/government_' . $state, ['query' => $query]);
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
                $query = $GovernmentModel->getRelated($id, $state);
                echo view('government/related', ['query' => $query]);
                $GovernmentIdentifierModel = new GovernmentIdentifierModel();
                $query = $GovernmentIdentifierModel->getByGovernment($id, $state);
                echo view('core/governmentidentifier', ['query' => $query, 'title' => 'Identifier', 'isMultiple' => $this->data['isMultiple']]);
            }
            $AffectedGovernmentGroupModel = new AffectedGovernmentGroupModel();
            $query = $AffectedGovernmentGroupModel->getByGovernmentGovernment($id, $state);
            $events = [];
            echo view('government/affectedgovernment', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
            foreach ($query as $row) {
                $events[] = $row->event;
            }
            $query = $AffectedGovernmentGroupModel->getByGovernmentForm($id, $state);
            echo view('core/affectedgovernmentform', ['includeGovernment' => false, 'query' => $query]);
            foreach ($query as $row) {
                $events[] = $row->event;
            }
            $events = array_unique($events);
            $EventModel = new EventModel();
            if (!$isHistory) {
                if ($isCountyOrLower) {
                    $query = $EventModel->getByGovernmentSuccess($id, $events);
                    echo view('core/event', ['query' => $query, 'state' => $state, 'title' => 'Other Successful Event Links', 'tableId' => 'successfulevent']);
                }
                $GovernmentSourceModel = new GovernmentSourceModel();
                $query = $GovernmentSourceModel->getByGovernment($id, $state);
                echo view('core/governmentsource', ['query' => $query, 'state' => $state, 'type' => 'government', 'isMultiple' => $this->data['isMultiple']]);
                $query = $GovernmentModel->getNote($id, $state);
                if ($query !== []) {
                    echo view(ENVIRONMENT . '/government_note', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                }
                $query = $GovernmentFormGovernmentModel->getByGovernment($id, $state);
                if ($query !== []) {
                    echo view(ENVIRONMENT . '/government_governmentform', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                }
                $query = $GovernmentModel->getSchoolDistrict($id, $state);
                if ($query !== []) {
                    echo view(ENVIRONMENT . '/government_schooldistrict', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                }
                $query = $SourceModel->getByGovernment($id);
                echo view('core/source', ['query' => $query, 'hasLink' => true]);
                $ResearchLogModel = new ResearchLogModel();
                $query = $ResearchLogModel->getByGovernment($id, $state);
                echo view('government/researchlog', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                $NationalArchivesModel = new NationalArchivesModel();
                $query = $NationalArchivesModel->getByGovernment($id, $state);
                echo view('government/nationalarchives', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                if ($isCountyOrLower) {
                    $query = $EventModel->getByGovernmentFailure($id, $events);
                    echo view('core/event', ['query' => $query, 'state' => $state, 'title' => 'Other Event Links', 'tableId' => 'otherevent']);
                }
                $query = $GovernmentModel->getOffice($id, $state);
                if ($query !== []) {
                    echo view(ENVIRONMENT . '/government_office', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                }
                if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/government_live.php')) {
                    echo view(ENVIRONMENT . '/government_live', ['id' => $id, 'state' => $state, 'isMunicipalityOrLower' => $isMunicipalityOrLower, 'isCountyOrLower' => $isCountyOrLower, 'isCountyOrState' => $isCountyOrState, 'isState' => $isStateOrHigher, 'includeGovernment' => false]);
                }
                echo view('core/chartjs', ['query' => $populationQuery, 'xLabel' => 'Year', 'yLabel' => 'Population']);
            }
            if ($hasMap) {
                echo view('leaflet_start', ['type' => 'government', 'includeBase' => true, 'needRotation' => false]);
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
                echo view('leaflet_end');
            }
            echo view('footer');
        }
    }
}
