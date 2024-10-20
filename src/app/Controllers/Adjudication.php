<?php

namespace App\Controllers;

use App\Models\AdjudicationLocationModel;
use App\Models\AdjudicationModel;
use App\Models\AdjudicationSourceCitationModel;
use App\Models\EventModel;
use App\Models\FilingModel;

class Adjudication extends BaseController
{
    private string $title = 'Adjudication Detail';

    public function noRecord(string $state): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('core/norecord');
        echo view('core/footer');
    }

    public function view(string $state, int|string $id): void
    {
        $id = $this->getIdInt($id);
        $AdjudicationModel = new AdjudicationModel();
        $query = $AdjudicationModel->getDetail($id, $state);
        if (count($query) !== 1) {
            $this->noRecord($state);
        } else {
            $id = $query[0]->adjudicationid;
            echo view('core/header', ['title' => $this->title, 'pageTitle' => $query[0]->adjudicationtitle]);
            echo view('adjudication/view', ['query' => $query]);
            $AdjudicationLocationModel = new AdjudicationLocationModel();
            echo view('adjudication/location', ['query' => $AdjudicationLocationModel->getByAdjudication($id)]);
            $FilingModel = new FilingModel();
            echo view('adjudication/filing', ['query' => $FilingModel->getByAdjudication($id)]);
            $AdjudicationSourceCitationModel = new AdjudicationSourceCitationModel();
            echo view('reporter/table', ['query' => $AdjudicationSourceCitationModel->getByAdjudication($id), 'state' => $state, 'hasLink' => true, 'title' => 'Reporter Links']);
            $EventModel = new EventModel();
            echo view('event/table', ['query' => $EventModel->getByAdjudication($id), 'state' => $state, 'title' => 'Event Links', 'eventRelationship' => true]);
            echo view('core/footer');
        }

    }
}
