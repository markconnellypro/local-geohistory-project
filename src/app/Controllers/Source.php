<?php

namespace App\Controllers;

use App\Models\EventModel;
use App\Models\SourceCitationModel;
use App\Models\SourceCitationNoteModel;
use App\Models\SourceItemPartModel;
use CodeIgniter\HTTP\RedirectResponse;

class Source extends BaseController
{
    private string $title = 'Source Detail';

    public function noRecord(): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('core/norecord');
        echo view('core/footer');
    }

    public function redirect(int|string $id): RedirectResponse
    {
        return redirect()->to('/' . $this->request->getLocale() . '/source/' . $id . '/', 301);
    }

    public function view(string $state, int|string $id): void
    {
        $id = $this->getIdInt($id);
        $SourceCitationModel = new SourceCitationModel();
        $query = $SourceCitationModel->getDetail($id, $state);
        if (count($query) !== 1) {
            $this->noRecord();
        } else {
            $id = $query[0]->sourcecitationid;
            $pageTitle = $query[0]->sourceabbreviation . ($query[0]->sourcecitationpage === '' ? '' : ' ' . $query[0]->sourcecitationpage);
            echo view('core/header', ['title' => $this->title, 'pageTitle' => $pageTitle]);
            echo view('source/table_citation', ['query' => $query, 'state' => $state, 'hasColor' => false, 'hasLink' => false, 'title' => 'Detail']);
            echo view('source/table', ['query' => $query, 'hasLink' => $this->isLive()]);
            if ($query[0]->url !== '') {
                echo view('core/url', ['query' => $query, 'title' => 'Actual URL']);
            }
            $SourceCitationNoteModel = new SourceCitationNoteModel();
            echo view('source/note', ['query' => $SourceCitationNoteModel->getBySourceCitation($id), 'state' => $state]);
            $SourceItemPartModel = new SourceItemPartModel();
            echo view('core/url', ['query' => $SourceItemPartModel->getBySourceCitation($id), 'state' => $state, 'title' => 'Calculated URL']);
            $EventModel = new EventModel();
            echo view('event/table', ['query' => $EventModel->getBySourceCitation($id), 'state' => $state, 'title' => 'Event Links']);
            echo view('core/footer');
        }
    }
}
