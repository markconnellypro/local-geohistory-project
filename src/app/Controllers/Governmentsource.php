<?php

namespace App\Controllers;

use App\Models\EventModel;
use App\Models\GovernmentSourceModel;
use App\Models\SourceItemPartModel;
use CodeIgniter\HTTP\RedirectResponse;

class Governmentsource extends BaseController
{
    private string $title = 'Government Source Detail';

    public function noRecord(): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('core/norecord');
        echo view('core/footer');
    }

    public function redirect(int|string $id): RedirectResponse
    {
        return redirect()->to('/' . $this->request->getLocale() . '/governmentsource/' . $id . '/', 301);
    }

    public function view(string $state, int|string $id): void
    {
        $id = $this->getIdInt($id);
        $GovernmentSourceModel = new GovernmentSourceModel();
        $query = $GovernmentSourceModel->getDetail($id, $state);
        if (count($query) !== 1) {
            $this->noRecord();
        } else {
            $id = $query[0]->governmentsourceid;
            echo view('core/header', ['title' => $this->title]);
            echo view('governmentsource/table', ['query' => $query, 'state' => $state, 'type' => 'source']);
            echo view('source/table', ['query' => $query, 'hasLink' => $this->isLive()]);
            $SourceItemPartModel = new SourceItemPartModel();
            echo view('core/url', ['query' => $SourceItemPartModel->getByGovernmentSource($id), 'state' => $state, 'title' => 'Calculated URL']);
            $EventModel = new EventModel();
            echo view('event/table', ['query' => $EventModel->getByGovernmentSource($id), 'state' => $state, 'title' => 'Event Links']);
            echo view('core/footer');
        }
    }
}
