<?php

namespace App\Controllers;

use App\Models\AffectedGovernmentGroupModel;
use App\Models\EventModel;
use App\Models\GovernmentIdentifierModel;
use App\Models\GovernmentShapeModel;
use App\Models\GovernmentSourceModel;
use App\Models\NationalArchivesModel;
use App\Models\ResearchLogModel;

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
        if ($this->data['live']) {
            $GovernmentFormGovernmentModel = new \App\Models\Development\GovernmentFormGovernmentModel;
            $GovernmentMapStatusModel = new \App\Models\Development\GovernmentMapStatusModel;
            $GovernmentModel = new \App\Models\Development\GovernmentModel;
            $GovernmentPopulationModel = new \App\Models\Development\GovernmentPopulationModel;
            $MetesDescriptionLineModel = new \App\Models\Development\MetesDescriptionLineModel;
            $SourceModel = new \App\Models\Development\SourceModel;
            $SourceCitationModel = new \App\Models\Development\SourceCitationModel;
        } else {
            $GovernmentFormGovernmentModel = new \App\Models\GovernmentFormGovernmentModel;
            $GovernmentMapStatusModel = new \App\Models\GovernmentMapStatusModel;
            $GovernmentModel = new \App\Models\GovernmentModel;
            $GovernmentPopulationModel = new \App\Models\GovernmentPopulationModel;
            $MetesDescriptionLineModel = new \App\Models\MetesDescriptionLineModel;
            $SourceModel = new \App\Models\SourceModel;
            $SourceCitationModel = new \App\Models\SourceCitationModel;
        }
        $query = $GovernmentModel->getDetail($id, $state);
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
            $statusQuery = $GovernmentMapStatusModel->getDetails();
            echo view('government_detail', ['live' => $this->data['live'], 'row' => $query[0], 'state' => $state, 'statuses' => $statusQuery]);
            if (!$isHistory) {
                $query = $SourceCitationModel->getByGovernment($id, $state);
                if (count($query) > 0) {
                    echo view(ENVIRONMENT . '/government_' . $state, ['query' => $query]);
                }
            }
            if ($hasMap) {
                echo view('general_map', ['live' => $this->data['live'], 'includeBase' => true]);
            }
            if (!$isHistory) {
                $populationQuery = $GovernmentPopulationModel->getByGovernment($id, $state);
                if (count($populationQuery) > 0) {
                    echo view('general_chart');
                }
                $query = $GovernmentModel->getRelated($id, $state, $this->request->getLocale());
                if (count($query) > 0) {
                    echo view('government_related', ['query' => $query]);
                }
                $GovernmentIdentifierModel = new GovernmentIdentifierModel;
                $query = $GovernmentIdentifierModel->getByGovernment($id, $state, $this->request->getLocale());
                if (count($query) > 0) {
                    echo view('general_governmentidentifier', ['query' => $query, 'title' => 'Identifier', 'isMultiple' => $this->data['isMultiple']]);
                }
            }
            $AffectedGovernmentGroupModel = new AffectedGovernmentGroupModel;
            $query = $AffectedGovernmentGroupModel->getByGovernmentGovernment($id, $state, $this->request->getLocale());
            $events = [];
            if (count($query) > 0) {
                echo view('government_affectedgovernment', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                foreach ($query as $row) {
                    $events[] = $row->event;
                }
            }
            $query = $AffectedGovernmentGroupModel->getByGovernmentForm($id, $state, $this->data['live']);
            if (count($query) > 0) {
                echo view('general_affectedgovernmentform', ['includeGovernment' => false, 'query' => $query]);
                foreach ($query as $row) {
                    $events[] = $row->event;
                }
            }
            $events = array_unique($events);
            $events = '{' . implode(',', $events) . '}';
            $EventModel = new EventModel;
            if (!$isHistory) {
                if ($isCountyOrLower) {
                    $query = $EventModel->getByGovernmentSuccess($id, $events);
                    if (count($query) > 0) {
                        echo view('general_event', ['query' => $query, 'state' => $state, 'title' => 'Other Successful Event Links', 'tableId' => 'successfulevent']);
                    }
                }
                $GovernmentSourceModel = new GovernmentSourceModel;
                $query = $GovernmentSourceModel->getByGovernment($id, $state, $this->data['live']);
                if (count($query) > 0) {
                    echo view('general_governmentsource', ['query' => $query, 'state' => $state, 'type' => 'government', 'isMultiple' => $this->data['isMultiple']]);
                }
                $query = $GovernmentModel->getNote($id, $state, $this->request->getLocale());
                if (count($query) > 0) {
                    echo view(ENVIRONMENT . '/government_note', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                }
                $query = $GovernmentFormGovernmentModel->getByGovernment($id, $state);
                if (count($query) > 0) {
                    echo view(ENVIRONMENT . '/government_governmentform', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                }
                $query = $GovernmentModel->getSchoolDistrict($id, $state);
                if (count($query) > 0) {
                    echo view(ENVIRONMENT . '/government_schooldistrict', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                }
                $query = $SourceModel->getByGovernment($id);
                if (count($query) > 0) {
                    echo view('general_source', ['query' => $query, 'hasLink' => true]);
                }
                $ResearchLogModel = new ResearchLogModel;
                $query = $ResearchLogModel->getByGovernment($id, $state, $this->data['live']);
                if (count($query) > 0) {
                    echo view('government_researchlog', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                }
                $NationalArchivesModel = new NationalArchivesModel;
                $query = $NationalArchivesModel->getByGovernment($id, $state);
                if (count($query) > 0) {
                    echo view('government_nationalarchives', ['query' => $query, 'live' => $this->data['live'], 'isMultiple' => $this->data['isMultiple']]);
                }
                if ($isCountyOrLower) {
                    $query = $EventModel->getByGovernmentFailure($id, $events);
                    if (count($query) > 0) {
                        echo view('general_event', ['query' => $query, 'state' => $state, 'title' => 'Other Event Links', 'tableId' => 'otherevent']);
                    }
                }
                $query = $GovernmentModel->getOffice($id, $state);
                if (count($query) > 0) {
                    echo view(ENVIRONMENT . '/government_office', ['query' => $query, 'isMultiple' => $this->data['isMultiple']]);
                }
                if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/government_live.php')) {
                    echo view(ENVIRONMENT . '/government_live', ['id' => $id, 'state' => $state, 'isMunicipalityOrLower' => $isMunicipalityOrLower, 'isCountyOrLower' => $isCountyOrLower, 'isCountyOrState' => $isCountyOrState, 'isState' => $isStateOrHigher, 'includeGovernment' => false]);
                }
                if (isset($populationQuery) and count($populationQuery) > 0) {
                    echo view('general_chartjs', ['query' => $populationQuery, 'online' => $this->data['online'], 'xLabel' => 'Year', 'yLabel' => 'Population']);
                }
            }
            if ($hasMap) {
                echo view('leaflet_start', ['type' => 'government', 'includeBase' => true, 'needRotation' => false, 'online' => $this->data['online']]);
                $query = $MetesDescriptionLineModel->getGeometryByGovernment($id);
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
                $GovernmentShapeModel = new GovernmentShapeModel;
                $query = $GovernmentShapeModel->getCurrentByGovernment($id);
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
                $query = $GovernmentShapeModel->getPartByGovernment($id, $state, $this->request->getLocale());
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
