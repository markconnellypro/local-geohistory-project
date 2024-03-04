<?php

namespace App\Controllers;

use App\Models\AdjudicationModel;
use App\Models\AffectedGovernmentGroupModel;
use App\Models\CurrentGovernmentModel;
use App\Models\EventModel;
use App\Models\GovernmentSourceModel;
use App\Models\LawSectionModel;
use App\Models\MetesDescriptionModel;
use App\Models\PlssModel;
use App\Models\RecordingModel;
use App\Models\SourceCitationModel;

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
        $EventModel = new EventModel();
        $query = $EventModel->getDetail($id, $state);
        if (count($query) != 1 || $query[0]->eventgranted == 'placeholder' && !$this->data['live']) {
            $this->noRecord($state);
        } else {
            $id = $query[0]->eventid;
            $eventIsMapped = ($query[0]->eventismapped == 't');
            $this->data['pageTitle'] = $query[0]->eventlong;
            $this->data['pageTitleType'] = $query[0]->eventtypeshort;
            echo view('header', $this->data);
            echo view('event_detail', ['row' => $query[0]]);
            $AffectedGovernmentGroupModel = new AffectedGovernmentGroupModel();
            $query = $AffectedGovernmentGroupModel->getByEventGovernment($id, $state);
            $affectedgovernmentgisquery = $AffectedGovernmentGroupModel->getByEventGeometry($id);
            $affectedGovernment = $this->affectedGovernmentProcess($query, $affectedgovernmentgisquery);
            $hasMap = (count($affectedgovernmentgisquery) > 0);
            $hasAffectedGovernmentMap = (count($affectedgovernmentgisquery) > 0);
            if ($this->data['live']) {
                $MetesDescriptionLineModel = new \App\Models\Development\MetesDescriptionLineModel();
            } else {
                $MetesDescriptionLineModel = new \App\Models\MetesDescriptionLineModel();
            }
            $metesdescriptiongisquery = $MetesDescriptionLineModel->getGeometryByEvent($id, $state);
            if (count($metesdescriptiongisquery) > 0) {
                $hasMap = true;
            }
            if (!$this->data['live'] && !$eventIsMapped) {
                $hasMap = false;
            }
            if ($hasMap) {
                echo view('general_map', ['live' => $this->data['live'], 'includeBase' => true, 'eventIsMapped' => $eventIsMapped]);
            }
            if (count($query) > 0) {
                echo view('general_affectedgovernment2', ['affectedGovernment' => $affectedGovernment, 'state' => $state, 'includeDate' => false, 'live' => $this->data['live'], 'isComplete' => true]);
            }
            $query = $AffectedGovernmentGroupModel->getByEventForm($id, $state);
            if (count($query) > 0) {
                echo view('general_affectedgovernmentform', ['includeGovernment' => true, 'query' => $query]);
            }
            $CurrentGovernmentModel = new CurrentGovernmentModel();
            $query = $CurrentGovernmentModel->getByEvent($id, $state);
            if (count($query) > 0) {
                echo view('general_currentgovernment', ['query' => $query, 'state' => $state]);
            }
            $MetesDescriptionModel = new MetesDescriptionModel();
            $query = $MetesDescriptionModel->getByEvent($id);
            if (count($query) > 0) {
                echo view('general_metes', ['query' => $query, 'hasLink' => true, 'state' => $state, 'title' => 'Metes and Bounds Description']);
            }
            $PlssModel = new PlssModel();
            $query = $PlssModel->getByEvent($id);
            if (count($query) > 0) {
                echo view('event_plss', ['query' => $query]);
            }
            $AdjudicationModel = new AdjudicationModel();
            $query = $AdjudicationModel->getByEvent($id);
            if (count($query) > 0) {
                echo view('general_adjudication', ['query' => $query, 'state' => $state, 'eventRelationship' => true]);
            }
            $LawSectionModel = new LawSectionModel();
            $query = $LawSectionModel->getByEvent($id);
            if (count($query) > 0) {
                echo view('general_law', ['query' => $query, 'state' => $state, 'title' => 'Law', 'type' => 'relationship', 'includeLawGroup' => true]);
            }
            $RecordingModel = new RecordingModel();
            $query = $RecordingModel->getByEvent($id, $state);
            if (count($query) > 0) {
                echo view('event_recording', ['query' => $query]);
            }
            $GovernmentSourceModel = new GovernmentSourceModel();
            $query = $GovernmentSourceModel->getByEvent($id, $state);
            if (count($query) > 0) {
                echo view('general_governmentsource', ['query' => $query, 'state' => $state, 'type' => 'event']);
            }
            $SourceCitationModel = new SourceCitationModel();
            $query = $SourceCitationModel->getByEvent($id);
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
                if ($this->data['live'] && count($metesdescriptiongisquery) > 0) {
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
