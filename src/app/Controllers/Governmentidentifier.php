<?php

namespace App\Controllers;

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
        $query = $this->db->query('SELECT * FROM extra.ci_model_governmentidentifier_detail(?, ?, ?)', [$type, $id, \Config\Services::request()->getLocale()])->getResult();
        if (count($query) != 1) {
            $this->noRecord();
        } else {
            $governmentidentifierids = $query[0]->governmentidentifierids;
            $governments = $query[0]->governments;
            echo view('header', $this->data);
            echo view('general_governmentidentifier', ['query' => $query, 'title' => 'Detail']);
            $query = $this->db->query('SELECT * FROM extra.ci_model_governmentidentifier_government(?, ?)', [$governmentidentifierids, $this->request->getLocale()])->getResult();
            if (count($query) > 0) {
                echo view('general_government', ['query' => $query, 'title' => 'Government', 'type' => 'identifier']);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_governmentidentifier_related(?, ?, ?)', [$governments, $governmentidentifierids, \Config\Services::request()->getLocale()])->getResult();
            if (count($query) > 0) {
                echo view('general_governmentidentifier', ['query' => $query, 'title' => 'Related']);
            }
            if ($this->data['live'] and $type == 'usgs') {
                $query = $this->db->query('SELECT * FROM reference_usa.ci_model_governmentidentifier_usgs(?)', [$governmentidentifierids])->getResult();
                if (count($query) > 0) {
                    echo view('governmentidentifier_census', ['query' => $query, 'type' => 'usgs']);
                }
            }
            if ($this->data['live'] and $type == 'us-census') {
                $query = $this->db->query('SELECT * FROM reference_usa.ci_model_governmentidentifier_census(?)', [$governmentidentifierids])->getResult();
                if (count($query) > 0) {
                    echo view('governmentidentifier_census', ['query' => $query, 'type' => 'census']);
                }
            }
            echo view('footer');
        }
    }
}
