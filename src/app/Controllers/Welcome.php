<?php

namespace App\Controllers;

use App\Models\DocumentationModel;
use CodeIgniter\HTTP\RedirectResponse;

class Welcome extends BaseController
{
    private string $title = 'Welcome';

    public function index(): void
    {
        $icons = [
            'about',
            'key',
            'search',
            'statistics',
        ];
        echo view('core/header', ['state' => '', 'title' => $this->title]);
        $DocumentationModel = new DocumentationModel();
        echo view('welcome/index', ['icons' => $icons, 'welcome' => $DocumentationModel->getWelcome()]);
        echo view('core/footer');
    }

    public function language(): RedirectResponse
    {
        $this->response->setStatusCode(301);
        return redirect()->to("/en");
    }
}
