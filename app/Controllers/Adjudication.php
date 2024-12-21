<?php

namespace App\Controllers;

use App\Models\AdjudicationLocationModel;
use App\Models\AdjudicationModel;
use App\Models\AdjudicationSourceCitationModel;
use App\Models\EventModel;
use App\Models\FilingModel;
use CodeIgniter\HTTP\RedirectResponse;

class Adjudication extends BaseController
{
    private string $title = 'Adjudication';

    public function noRecord(): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('core/norecord');
        echo view('core/footer');
    }

    public function redirect(int|string $id): RedirectResponse
    {
        return redirect()->to('/' . $this->request->getLocale() . '/adjudication/' . $id . '/', 301);
    }

    public function view(int|string $id): void
    {
        $id = $this->getIdInt($id);
        $AdjudicationModel = new AdjudicationModel();
        $query = $AdjudicationModel->getDetail($id);
        if (count($query) !== 1) {
            $this->noRecord();
        } else {
            $id = $query[0]->adjudicationid;
            echo view('core/header', ['title' => $this->title, 'pageTitle' => $query[0]->adjudicationtitle]);
            echo view('adjudication/view', ['query' => $query]);
            $AdjudicationLocationModel = new AdjudicationLocationModel();
            echo view('adjudication/location', ['query' => $AdjudicationLocationModel->getByAdjudication($id)]);
            $FilingModel = new FilingModel();
            echo view('adjudication/filing', ['query' => $FilingModel->getByAdjudication($id)]);
            $AdjudicationSourceCitationModel = new AdjudicationSourceCitationModel();
            echo view('reporter/table', ['query' => $AdjudicationSourceCitationModel->getByAdjudication($id), 'hasLink' => true, 'title' => 'Reporter Links']);
            $EventModel = new EventModel();
            echo view('event/table', ['query' => $EventModel->getByAdjudication($id), 'title' => 'Event Links', 'eventRelationship' => true]);
            echo view('core/footer');
        }
    }
}
