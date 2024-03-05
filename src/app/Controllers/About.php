<?php

namespace App\Controllers;

use App\Models\DocumentationModel;

class About extends BaseController
{
    private $data = [
        'title' => 'About',
    ];

    public function __construct()
    {
    }

    public function index($state = ''): void
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);
        $DocumentationModel = new DocumentationModel();
        $query = $DocumentationModel->getAboutDetail($state);
        echo view('about', ['query' => $query]);
        echo view('footer');
    }
}
