<?php

namespace App\Controllers;

use App\Models\EventModel;
use App\Models\SourceItemPartModel;
use CodeIgniter\HTTP\RedirectResponse;

class Law extends BaseController
{
    private string $title = 'Law';

    public function noRecord(): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('core/norecord');
        echo view('core/footer');
    }

    public function redirect(int|string $id): RedirectResponse
    {
        return redirect()->to('/' . $this->request->getLocale() . '/law/' . $id . '/', 301);
    }

    public function view(int|string $id): void
    {
        if (str_ends_with($id, '-alternate')) {
            $function = 'getByLawAlternateSection';
            $LawSectionModel = new \App\Models\LawAlternateSectionModel();
        } else {
            $function = 'getByLawSection';
            $LawSectionModel = new \App\Models\LawSectionModel();
        }
        $id = $this->getIdInt($id);
        $query = $LawSectionModel->getDetail($id);
        if (count($query) !== 1) {
            $this->noRecord();
        } else {
            $id = $query[0]->lawsectionid;
            echo view('core/header', ['title' => $this->title, 'pageTitle' => $query[0]->lawsectioncitation]);
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
                echo view(ENVIRONMENT . '/usa/newberrylaw', ['query' => $query]);
            }
            $query = $SourceCitationModel->getByLawState($id);
            if ($query !== []) {
                echo view(ENVIRONMENT . '/law/ny', ['query' => $query]);
            }
            $query = $LawGroupSectionModel->getByLawSection($id);
            if ($query !== []) {
                echo view(ENVIRONMENT . '/lawgroup/table', ['query' => $query, 'includeForm' => false]);
            }
            echo view('law/table', ['query' => $LawSectionModel->getRelated($id), 'title' => 'Related Law', 'type' => 'relationship']);
            $SourceItemPartModel = new SourceItemPartModel();
            echo view('core/url', ['query' => $SourceItemPartModel->$function($id), 'title' => 'Calculated URL']);
            $EventModel = new EventModel();
            echo view('event/table', ['query' => $EventModel->$function($id), 'title' => 'Event Links', 'eventRelationship' => true, 'includeLawGroup' => true]);
            echo view('core/footer');
        }
    }
}
