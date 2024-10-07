<?php

namespace App\Controllers;

use App\Models\GovernmentModel;
use CodeIgniter\HTTP\RedirectResponse;

class Governmentidentifier extends BaseController
{
    private string $title = 'Government Identifier Detail';

    public function noRecord(): void
    {
        echo view('core/header', ['state' => '', 'title' => $this->title]);
        echo view('core/norecord');
        echo view('core/footer');
    }

    public function view(string $type, string $id): null|RedirectResponse
    {
        if ($id !== strtolower($id)) {
            $this->response->setStatusCode(301);
            return redirect()->to("/" . $this->request->getLocale() . '/governmentidentifier/' . $type . '/' . strtolower($id) . '/');
        }
        if ($this->isLive()) {
            $GovernmentIdentifierModel = new \App\Models\Development\GovernmentIdentifierModel();
        } else {
            $GovernmentIdentifierModel = new \App\Models\GovernmentIdentifierModel();
        }
        $query = $GovernmentIdentifierModel->getDetail($type, $id);
        if (count($query) !== 1) {
            $this->noRecord();
        } else {
            $governmentidentifierids = $query[0]->governmentidentifierids;
            $governments = $query[0]->governments;
            echo view('core/header', ['state' => '', 'title' => $this->title]);
            echo view('governmentidentifier/table', ['query' => $query, 'title' => 'Detail']);
            $GovernmentModel = new GovernmentModel();
            echo view('government/table', ['query' => $GovernmentModel->getByGovernmentIdentifier($governmentidentifierids), 'title' => 'Government', 'type' => 'identifier']);
            echo view('governmentidentifier/table', ['query' => $GovernmentIdentifierModel->getRelated($governments, $governmentidentifierids), 'title' => 'Related']);
            if ($type === 'us-census' || $type === 'usgs') {
                if ($type === 'us-census') {
                    $query = $GovernmentIdentifierModel->getCensus($governmentidentifierids);
                } else {
                    $query = $GovernmentIdentifierModel->getUsgs($governmentidentifierids);
                }
                echo view('governmentidentifier/census', ['query' => $query, 'type' => $type]);
            }
            echo view('core/footer');
        }
        return null;
    }
}
