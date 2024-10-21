<?php

namespace App\Controllers;

use App\Models\AdjudicationModel;
use App\Models\AdjudicationSourceCitationModel;
use App\Models\EventModel;
use App\Models\SourceItemPartModel;
use CodeIgniter\HTTP\RedirectResponse;

class Reporter extends BaseController
{
    private string $title = 'Reporter';

    public function noRecord(): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('core/norecord');
        echo view('core/footer');
    }

    public function redirect(int|string $id): RedirectResponse
    {
        return redirect()->to('/' . $this->request->getLocale() . '/reporter/' . $id . '/', 301);
    }

    public function view(int|string $id): void
    {
        $id = $this->getIdInt($id);
        $AdjudicationSourceCitationModel = new AdjudicationSourceCitationModel();
        $query = $AdjudicationSourceCitationModel->getDetail($id);
        if (count($query) !== 1) {
            $this->noRecord();
        } else {
            $id = $query[0]->adjudicationsourcecitationid;
            echo view('core/header', ['title' => $this->title]);
            echo view('reporter/table', ['query' => $query, 'hasLink' => false, 'title' => 'Detail']);
            echo view('source/table', ['query' => $query, 'hasLink' => false]);
            echo view('reporter/authorship', ['query' => $query]);
            if ($query[0]->url !== '') {
                echo view('core/url', ['query' => $query, 'title' => 'Actual URL']);
            }
            $SourceItemPartModel = new SourceItemPartModel();
            echo view('core/url', ['query' => $SourceItemPartModel->getByAdjudicationSourceCitation($id), 'title' => 'Calculated URL']);
            $AdjudicationModel = new AdjudicationModel();
            echo view('adjudication/table', ['query' => $AdjudicationModel->getByAdjudicationSourceCitation($id)]);
            $EventModel = new EventModel();
            echo view('event/table', ['query' => $EventModel->getByAdjudicationSourceCitation($id), 'title' => 'Event Links']);
            echo view('core/footer');
        }
    }
}
