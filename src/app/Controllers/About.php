<?php

namespace App\Controllers;

use App\Models\DocumentationModel;

class About extends BaseController
{
    private string $title = 'About';

    public function index(string $state = ''): void
    {
        echo view('core/header', ['title' => $this->title]);
        $DocumentationModel = new DocumentationModel();
        echo view('about/index', ['query' => $DocumentationModel->getAboutDetail($state)]);
        echo view('core/footer');
    }
}
