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
use CodeIgniter\HTTP\RedirectResponse;

class Event extends BaseController
{
    private string $title = 'Event';

    public function noRecord(): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('core/norecord');
        echo view('core/footer');
    }

    public function redirect(int|string $id): RedirectResponse
    {
        return redirect()->to('/' . $this->request->getLocale() . '/event/' . $id . '/', 301);
    }

    public function view(int|string $id): void
    {
        $id = $this->getIdInt($id);
        $EventModel = new EventModel();
        $query = $EventModel->getDetail($id);
        if (count($query) !== 1 || $query[0]->eventgranted === 'placeholder' && !$this->isLive()) {
            $this->noRecord();
        } else {
            $id = $query[0]->eventid;
            $eventIsMapped = ($query[0]->eventismapped === 't');
            echo view('core/header', ['title' => $this->title, 'pageTitle' => $query[0]->eventlong, 'pageTitleType' => $query[0]->eventtypeshort]);
            echo view('event/view', ['query' => $query]);
            $AffectedGovernmentGroupModel = new AffectedGovernmentGroupModel();
            $affectedGovernment = $AffectedGovernmentGroupModel->getByEventGovernment($id);
            $hasMap = $affectedGovernment['hasMap'];
            $jurisdictions = $affectedGovernment['jurisdictions'];
            $hasAffectedGovernmentMap = $hasMap;
            $affectedGovernment = $affectedGovernment['affectedGovernment'];
            if ($this->isLive()) {
                $MetesDescriptionLineModel = new \Localgeohistoryproject\Development\Models\MetesDescriptionLineModel();
            } else {
                $MetesDescriptionLineModel = new \App\Models\MetesDescriptionLineModel();
            }
            $metesDescriptionGisQuery = $MetesDescriptionLineModel->getGeometryByEvent($id);
            if ($metesDescriptionGisQuery !== []) {
                $hasMap = true;
            }
            if (!$this->isLive() && !$eventIsMapped) {
                $hasMap = false;
            }
            if ($hasMap) {
                echo view('core/map', ['includeBase' => true, 'eventIsMapped' => $eventIsMapped]);
            }
            if (isset($affectedGovernment['rows']) && count($affectedGovernment['rows']) > 0) {
                echo view('event/table_affectedgovernment', ['affectedGovernment' => $affectedGovernment, 'includeDate' => false, 'isComplete' => true]);
            }
            echo view('event/table_affectedgovernmentform', ['includeGovernment' => true, 'query' => $AffectedGovernmentGroupModel->getByEventForm($id)]);
            $CurrentGovernmentModel = new CurrentGovernmentModel();
            echo view('event/table_currentgovernment', ['query' => $CurrentGovernmentModel->getByEvent($id)]);
            $MetesDescriptionModel = new MetesDescriptionModel();
            echo view('metes/table', ['query' => $MetesDescriptionModel->getByEvent($id), 'hasLink' => true, 'title' => 'Metes and Bounds Description']);
            $PlssModel = new PlssModel();
            echo view('event/plss', ['query' => $PlssModel->getByEvent($id)]);
            $AdjudicationModel = new AdjudicationModel();
            echo view('adjudication/table', ['query' => $AdjudicationModel->getByEvent($id), 'eventRelationship' => true]);
            $LawSectionModel = new LawSectionModel();
            echo view('law/table', ['query' => $LawSectionModel->getByEvent($id), 'title' => 'Law', 'type' => 'relationship', 'includeLawGroup' => true]);
            $RecordingModel = new RecordingModel();
            echo view('event/recording', ['query' => $RecordingModel->getByEvent($id)]);
            $GovernmentSourceModel = new GovernmentSourceModel();
            echo view('governmentsource/table', ['query' => $GovernmentSourceModel->getByEvent($id), 'type' => 'event']);
            $SourceCitationModel = new SourceCitationModel();
            echo view('source/table_citation', ['query' => $SourceCitationModel->getByEvent($id), 'hasColor' => false, 'hasLink' => true, 'title' => 'Source']);
            if ($this->isLive()) {
                $FileSourceModel = new \Localgeohistoryproject\Development\Models\FileSourceModel();
                echo view('Localgeohistoryproject\Development\filesource/table', ['query' => $FileSourceModel->getByEvent($id)]);
            }
            if ($hasMap) {
                $i = 0;
                echo view('leaflet/start', ['type' => 'event', 'jurisdictions' => $jurisdictions, 'includeBase' => true, 'needRotation' => false]);
                echo view('event/affectedgovernmenttype', ['query' => $affectedGovernment['types']]);
                if ($hasAffectedGovernmentMap) {
                    echo view('core/gis', [
                        'query' => $affectedGovernment['rows'],
                        'element' => 'affectedgovernment',
                        'onEachFeature' => true,
                        'onEachFeature2' => false,
                        'weight' => 1.25,
                        'color' => 'D5103F',
                        'fillOpacity' => 0.1,
                    ]);
                }
                $layers = [];
                if ($this->isLive() && $metesDescriptionGisQuery !== []) {
                    echo view('core/gis', [
                        'query' => $metesDescriptionGisQuery,
                        'element' => 'metesdescription',
                        'onEachFeature' => false,
                        'onEachFeature2' => false,
                        'weight' => 1.25,
                        'color' => 'D5103F',
                        'fillOpacity' => 0.1,
                    ]);
                    $layers['metesdescription'] = 'Descriptions';
                }
                if ($hasAffectedGovernmentMap) {
                    echo view('event/end', ['layers' => $layers]);
                } else {
                    echo view('event/end_metesdescription');
                }
                echo view('leaflet/end');
            }
            echo view('core/footer');
        }
    }
}
