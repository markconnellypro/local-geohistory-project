<?php

namespace App\Controllers;

class Reporter extends BaseController
{

    private $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'Reporter Details',
            'isInternetExplorer' => $this->isInternetExplorer(),
            'live' => $this->isLive(),
            'online' => $this->isOnline(),
            'updated' => $this->lastUpdated()->fulldate,
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
        $id = $this->getIdInt($id);
        $query = $this->db->query('SELECT * FROM extra.ci_model_reporter_detail(?, ?)', [$id, $state])->getResult();
        if (count($query) != 1) {
            $this->noRecord($state);
        } else {
            $id = $query[0]->adjudicationsourcecitationid;
            echo view('header', $this->data);
            echo view('general_reporter', ['query' => $query, 'state' => $state, 'hasLink' => false, 'title' => 'Detail']);
            echo view('general_source', ['query' => $query, 'hasLink' => false]);
            echo view('reporter_authorship', ['query' => $query]);
            if ($query[0]->url != '') {
                echo view('general_url', ['query' => $query, 'title' => 'Actual URL']);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_reporter_url(?)', [$id])->getResult();
            if (count($query) > 0) {
                echo view('general_url', ['query' => $query, 'state' => $state, 'title' => 'Calculated URL']);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_reporter_adjudication(?)', [$id])->getResult();
            if (count($query) > 0) {
                echo view('general_adjudication', ['query' => $query, 'state' => $state]);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_reporter_event(?)', [$id])->getResult();
            if (count($query) > 0) {
                echo view('general_event', ['query' => $query, 'state' => $state, 'title' => 'Event Links']);
            }
            echo view('footer');
        }
    }
}
