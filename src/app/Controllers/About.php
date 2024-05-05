<?php

namespace App\Controllers;

use App\Models\DocumentationModel;

class About extends BaseController
{
    private array $data = [
        'title' => 'About',
    ];

    public function __construct()
    {
    }

    public function index(string $state = ''): void
    {
        $this->data['state'] = $state;
        echo view('core/header', $this->data);
        $DocumentationModel = new DocumentationModel();
        $query = $DocumentationModel->getAboutDetail($state);
        echo view('about/index', ['query' => $query]);
        echo view('core/footer');
    }
}
