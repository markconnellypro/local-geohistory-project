<?php

namespace App\Controllers;

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
        echo view('welcome/index', ['icons' => $icons]);
        echo view('core/footer');
    }

    public function language(): RedirectResponse
    {
        $this->response->setStatusCode(301);
        return redirect()->to("/en");
    }
}
