<?php

namespace App\Controllers;

use App\Models\EventModel;
use App\Models\GovernmentSourceModel;
use App\Models\SourceItemPartModel;

class Governmentsource extends BaseController
{
    private array $data = [
        'title' => 'Government Source Detail',
    ];

    public function __construct()
    {
    }

    public function noRecord(string $state): void
    {
        $this->data['state'] = $state;
        echo view('core/header', $this->data);
        echo view('core/norecord');
        echo view('core/footer');
    }

    public function view(string $state, int|string $id): void
    {
        $this->data['state'] = $state;
        $id = $this->getIdInt($id);
        $GovernmentSourceModel = new GovernmentSourceModel();
        $query = $GovernmentSourceModel->getDetail($id, $state);
        if (count($query) !== 1) {
            $this->noRecord($state);
        } else {
            $id = $query[0]->governmentsourceid;
            echo view('core/header', $this->data);
            echo view('governmentsource/table', ['query' => $query, 'state' => $state, 'type' => 'source']);
            echo view('source/table', ['query' => $query, 'hasLink' => $this->isLive()]);
            $SourceItemPartModel = new SourceItemPartModel();
            $query = $SourceItemPartModel->getByGovernmentSource($id);
            echo view('core/url', ['query' => $query, 'state' => $state, 'title' => 'Calculated URL']);
            $EventModel = new EventModel();
            $query = $EventModel->getByGovernmentSource($id);
            echo view('event/table', ['query' => $query, 'state' => $state, 'title' => 'Event Links']);
            echo view('core/footer');
        }
    }
}
