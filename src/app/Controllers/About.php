<?php

namespace App\Controllers;

use App\Models\DocumentationModel;

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
        $DocumentationModel = new DocumentationModel();
        $query = $DocumentationModel->getAboutDetail($state);
        echo view('about', ['query' => $query]);
        echo view('footer');
    }
}
