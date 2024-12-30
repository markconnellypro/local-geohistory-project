<?php

namespace App\Controllers;

use App\Models\DocumentationModel;

class Status extends BaseController
{
    private string $title = 'Status';

    public function index(): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('core/ui');
        $DocumentationModel = new DocumentationModel();
        echo view('status/index', [
            'jurisdictions' => $DocumentationModel->getStatus(),
        ]);
        echo view('core/footer');
    }

    public function noRecord(): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('core/norecord');
        echo view('core/footer');
    }
}
