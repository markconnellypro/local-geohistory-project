<?php

namespace App\Controllers;

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
        $queryType = '';
        if (substr($id, -10) == '-alternate') {
            $queryType = 'alternate';
        }
        $id = $this->getIdInt($id);
        $query = $this->db->query('SELECT * FROM extra.ci_model_law' . $queryType . '_detail(?, ?, ?)', [$id, $state, $this->data['live']])->getResult();

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
            if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/usa_newberrylaw.php')) {
                $query = $this->db->query('SELECT * FROM reference_usa.ci_model_law_newberry(?)', [$id])->getResult();
                if (!empty($query)) {
                    echo view(ENVIRONMENT . '/usa_newberrylaw', ['query' => $query]);
                }
            }
            if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/ny_law_detail.php')) {
                $query = $this->db->query('SELECT * FROM reference_usa_state.ci_model_ny_law(?)', [$id])->getResult();
                if (!empty($query)) {
                    echo view(ENVIRONMENT . '/ny_law_detail', ['query' => $query]);
                }
            }
            if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/general_lawgroup.php')) {
                $query = $this->db->query('SELECT * FROM extra_development.ci_model_law_lawgroup(?, ?)', [$id, $state])->getResult();
                if (!empty($query)) {
                    echo view(ENVIRONMENT . '/general_lawgroup', ['query' => $query, 'includeForm' => false]);
                }
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_law' . $queryType . '_related(?)', [$id])->getResult();
            if (count($query) > 0) {
                echo view('general_law', ['query' => $query, 'state' => $state, 'title' => 'Related Law', 'type' => 'relationship']);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_law' . $queryType . '_url(?, ?)', [$id, $this->data['live']])->getResult();
            if (count($query) > 0) {
                echo view('general_url', ['query' => $query, 'state' => $state, 'title' => 'Calculated URL']);
            }
            $query = $this->db->query('SELECT * FROM extra.ci_model_law' . $queryType . '_event(?)', [$id])->getResult();
            if (count($query) > 0) {
                echo view('general_event', ['query' => $query, 'state' => $state, 'title' => 'Event Links', 'eventRelationship' => true, 'includeLawGroup' => true]);
            }
            echo view('footer');
        }
    }
}
