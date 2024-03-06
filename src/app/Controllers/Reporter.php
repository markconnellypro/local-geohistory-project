<?php

namespace App\Controllers;

use App\Models\AdjudicationModel;
use App\Models\AdjudicationSourceCitationModel;
use App\Models\EventModel;
use App\Models\SourceItemPartModel;

class Reporter extends BaseController
{
    private array $data = [
        'title' => 'Reporter Details',
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

    public function view(string $state, int|string $id): void
    {
        $this->data['state'] = $state;
        $id = $this->getIdInt($id);
        $AdjudicationSourceCitationModel = new AdjudicationSourceCitationModel();
        $query = $AdjudicationSourceCitationModel->getDetail($id, $state);
        if (count($query) !== 1) {
            $this->noRecord($state);
        } else {
            $id = $query[0]->adjudicationsourcecitationid;
            echo view('header', $this->data);
            echo view('general_reporter', ['query' => $query, 'state' => $state, 'hasLink' => false, 'title' => 'Detail']);
            echo view('general_source', ['query' => $query, 'hasLink' => false]);
            echo view('reporter_authorship', ['query' => $query]);
            if ($query[0]->url !== '') {
                echo view('general_url', ['query' => $query, 'title' => 'Actual URL']);
            }
            $SourceItemPartModel = new SourceItemPartModel();
            $query = $SourceItemPartModel->getByAdjudicationSourceCitation($id);
            echo view('general_url', ['query' => $query, 'state' => $state, 'title' => 'Calculated URL']);
            $AdjudicationModel = new AdjudicationModel();
            $query = $AdjudicationModel->getByAdjudicationSourceCitation($id);
            echo view('general_adjudication', ['query' => $query, 'state' => $state]);
            $EventModel = new EventModel();
            $query = $EventModel->getByAdjudicationSourceCitation($id);
            echo view('general_event', ['query' => $query, 'state' => $state, 'title' => 'Event Links']);
            echo view('footer');
        }
    }
}
