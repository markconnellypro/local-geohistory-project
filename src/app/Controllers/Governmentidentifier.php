<?php

namespace App\Controllers;

use App\Models\GovernmentModel;

class Governmentidentifier extends BaseController
{

    private $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'Government Identifier Detail',
            'isInternetExplorer' => $this->isInternetExplorer(),
            'live' => $this->isLive(),
            'online' => $this->isOnline(),
            'updated' => $this->lastUpdated()->fulldate,
        ];
    }

    public function noRecord()
    {
        echo view('header', $this->data);
        echo view('norecord');
        echo view('footer');
    }

    public function view($type, $id)
    {
        if ($id != strtolower($id)) {
            $this->response->setStatusCode(301);
            return redirect()->to("/" . $this->request->getLocale() . '/governmentidentifier/' . $type . '/' . strtolower($id) . '/');
        }
        if ($this->data['live']) {
            $GovernmentIdentifierModel = new \App\Models\Development\GovernmentIdentifierModel;
        } else {
            $GovernmentIdentifierModel = new \App\Models\GovernmentIdentifierModel;
        }
        $query = $GovernmentIdentifierModel->getDetail($type, $id);
        if (count($query) != 1) {
            $this->noRecord();
        } else {
            $governmentidentifierids = $query[0]->governmentidentifierids;
            $governments = $query[0]->governments;
            echo view('header', $this->data);
            echo view('general_governmentidentifier', ['query' => $query, 'title' => 'Detail']);
            $GovernmentModel = new GovernmentModel;
            $query = $GovernmentModel->getByGovernmentIdentifier($governmentidentifierids);
            if (count($query) > 0) {
                echo view('general_government', ['query' => $query, 'title' => 'Government', 'type' => 'identifier']);
            }
            $query = $GovernmentIdentifierModel->getRelated($governments, $governmentidentifierids);
            if (count($query) > 0) {
                echo view('general_governmentidentifier', ['query' => $query, 'title' => 'Related']);
            }
            if ($type == 'us-census' or $type == 'usgs') {
                if ($type == 'us-census') {
                    $query = $GovernmentIdentifierModel->getCensus($governmentidentifierids);
                } else {
                    $query = $GovernmentIdentifierModel->getUsgs($governmentidentifierids);
                }
                if (count($query) > 0) {
                    echo view('governmentidentifier_census', ['query' => $query, 'type' => $type]);
                }
            }
            echo view('footer');
        }
    }
}
