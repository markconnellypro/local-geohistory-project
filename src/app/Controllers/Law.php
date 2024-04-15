<?php

namespace App\Controllers;

use App\Models\EventModel;
use App\Models\SourceItemPartModel;

class Law extends BaseController
{
    private array $data = [
        'title' => 'Law Detail',
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
        if (str_ends_with($id, '-alternate')) {
            $function = 'getByLawAlternateSection';
            $LawSectionModel = new \App\Models\LawAlternateSectionModel();
        } else {
            $function = 'getByLawSection';
            $LawSectionModel = new \App\Models\LawSectionModel();
        }
        $id = $this->getIdInt($id);
        $query = $LawSectionModel->getDetail($id, $state);
        if (count($query) !== 1) {
            $this->noRecord($state);
        } else {
            $id = $query[0]->lawsectionid;
            $this->data['pageTitle'] = $query[0]->lawsectioncitation;
            echo view('core/header', $this->data);
            echo view('law/view', ['query' => $query]);
            echo view('source/table', ['query' => $query, 'hasLink' => false]);
            if ($query[0]->url !== '') {
                echo view('core/url', ['query' => $query, 'title' => 'Actual URL']);
            }
            if ($this->isLive()) {
                $LawGroupSectionModel = new \App\Models\Development\LawGroupSectionModel();
                $SourceCitationModel = new \App\Models\Development\SourceCitationModel();
            } else {
                $LawGroupSectionModel = new \App\Models\LawGroupSectionModel();
                $SourceCitationModel = new \App\Models\SourceCitationModel();
            }
            $query = $SourceCitationModel->getByLawNation($id);
            if ($query !== []) {
                echo view(ENVIRONMENT . '/usa_newberrylaw', ['query' => $query]);
            }
            $query = $SourceCitationModel->getByLawState($id, $state);
            if ($query !== []) {
                echo view(ENVIRONMENT . '/ny_law_detail', ['query' => $query]);
            }
            $query = $LawGroupSectionModel->getByLawSection($id, $state);
            if ($query !== []) {
                echo view(ENVIRONMENT . '/general_lawgroup', ['query' => $query, 'includeForm' => false]);
            }
            $query = $LawSectionModel->getRelated($id);
            echo view('law/table', ['query' => $query, 'state' => $state, 'title' => 'Related Law', 'type' => 'relationship']);
            $SourceItemPartModel = new SourceItemPartModel();
            $query = $SourceItemPartModel->$function($id);
            echo view('core/url', ['query' => $query, 'state' => $state, 'title' => 'Calculated URL']);
            $EventModel = new EventModel();
            $query = $EventModel->$function($id);
            echo view('event/table', ['query' => $query, 'state' => $state, 'title' => 'Event Links', 'eventRelationship' => true, 'includeLawGroup' => true]);
            echo view('core/footer');
        }
    }
}
