<?php

namespace App\Controllers;

class SurveyTownship extends BaseController
{

    private $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'Survey Township Detail',
            'isInternetExplorer' => $this->isInternetExplorer(),
            'live' => $this->isLive(),
            'online' => $this->isOnline(),
            'updated' => $this->lastUpdated()->fulldate,
            'updatedParts' => $this->lastUpdated(),
        ];
    }

    public function noRecord($state)
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);
        echo view('norecord');
        echo view('footer');
    }

    public function view($state, $id)
    {
        $this->data['state'] = $state;
        if ($this->data['live'] and preg_match('/^\d{1,9}$/', $id)) {
            $id = intval($id);
        }
        $query = $this->db->query('SELECT * FROM extra.ci_model_surveytownship_detail(?, ?, ?)', [$id, $state, $this->data['live']])->getResult();
        if (count($query) != 1) {
            $this->noRecord($state);
        } else {
            $id = $query[0]->governmentid;
            $this->data['pageTitle'] = $query[0]->governmentlong;
            echo view('header', $this->data);
            echo view('footer');
        }
    }
}
