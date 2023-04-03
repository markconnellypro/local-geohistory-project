<?php

namespace App\Controllers;

class About extends BaseController
{

    private $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'About',
            'isInternetExplorer' => $this->isInternetExplorer(),
            'live' => $this->isLive(),
            'online' => $this->isOnline(),
            'updated' => $this->lastUpdated()->fulldate,
        ];
    }

    public function index($state = '')
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);
        $query = $this->db->query('SELECT * FROM extra.ci_model_about(?)', [$state])->getResult();
        echo view('about', ['query' => $query]);
        echo view('footer');
    }
}
