<?php

namespace App\Controllers;

class Governmentsource extends BaseController
{

    private $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'Government Source Detail',
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
        $query = $this->db->query('SELECT * FROM extra.ci_model_governmentsource_detail(?, ?, ?, ?)', [$id, $state, $this->data['live'], $this->request->getLocale()])->getResult();
        if (count($query) != 1) {
            $this->noRecord($state);
        } else {
            $id = $query[0]->governmentsourceid;
            // $this->data['pageTitle'] = $query[0]->sourceabbreviation . (empty($query[0]->sourcecitationpage) ? '' : ' ' . $query[0]->sourcecitationpage);
            echo view('header', $this->data);
            echo view('general_governmentsource', ['query' => $query, 'state' => $state, 'type' => 'source']);
            echo view('general_source', ['query' => $query, 'hasLink' => $this->data['live']]);
            $query = $this->db->query('SELECT * FROM extra.ci_model_governmentsource_url(?)', [$id])->getResult();
            if (count($query) > 0) {
                echo view('general_url', ['query' => $query, 'state' => $state, 'title' => 'Calculated URL']);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_governmentsource_event(?)', [$id])->getResult();
            if (count($query) > 0) {
                echo view('general_event', ['query' => $query, 'state' => $state, 'title' => 'Event Links']);
            }
            echo view('footer');
        }
    }
}
