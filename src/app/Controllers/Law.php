<?php

namespace App\Controllers;

use App\Models\EventModel;
use App\Models\SourceItemPartModel;

class Law extends BaseController
{
    private $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'Law Detail',
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
        if (str_ends_with($id, '-alternate')) {
            $function = 'getByLawAlternateSection';
            $LawSectionModel = new \App\Models\LawAlternateSectionModel();
        } else {
            $function = 'getByLawSection';
            $LawSectionModel = new \App\Models\LawSectionModel();
        }
        $id = $this->getIdInt($id);
        $query = $LawSectionModel->getDetail($id, $state);
        if (count($query) != 1) {
            $this->noRecord($state);
        } else {
            $id = $query[0]->lawsectionid;
            $this->data['pageTitle'] = $query[0]->lawsectioncitation;
            echo view('header', $this->data);
            echo view('law_detail', ['query' => $query]);
            echo view('general_source', ['query' => $query, 'hasLink' => false]);
            if ($query[0]->url != '') {
                echo view('general_url', ['query' => $query, 'title' => 'Actual URL']);
            }
            if ($this->data['live']) {
                $LawGroupSectionModel = new \App\Models\Development\LawGroupSectionModel();
                $SourceCitationModel = new \App\Models\Development\SourceCitationModel();
            } else {
                $LawGroupSectionModel = new \App\Models\LawGroupSectionModel();
                $SourceCitationModel = new \App\Models\SourceCitationModel();
            }
            $query = $SourceCitationModel->getByLawNation($id);
            if (!empty($query)) {
                echo view(ENVIRONMENT . '/usa_newberrylaw', ['query' => $query]);
            }
            $query = $SourceCitationModel->getByLawState($id, $state);
            if (!empty($query)) {
                echo view(ENVIRONMENT . '/ny_law_detail', ['query' => $query]);
            }
            $query = $LawGroupSectionModel->getByLawSection($id, $state);
            if (!empty($query)) {
                echo view(ENVIRONMENT . '/general_lawgroup', ['query' => $query, 'includeForm' => false]);
            }
            $query = $LawSectionModel->getRelated($id);
            if (count($query) > 0) {
                echo view('general_law', ['query' => $query, 'state' => $state, 'title' => 'Related Law', 'type' => 'relationship']);
            }
            $SourceItemPartModel = new SourceItemPartModel();
            $query = $SourceItemPartModel->$function($id);
            if (count($query) > 0) {
                echo view('general_url', ['query' => $query, 'state' => $state, 'title' => 'Calculated URL']);
            }
            $EventModel = new EventModel();
            $query = $EventModel->$function($id);
            if (count($query) > 0) {
                echo view('general_event', ['query' => $query, 'state' => $state, 'title' => 'Event Links', 'eventRelationship' => true, 'includeLawGroup' => true]);
            }
            echo view('footer');
        }
    }
}
