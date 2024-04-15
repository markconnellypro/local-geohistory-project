<?php

namespace App\Controllers;

use CodeIgniter\HTTP\RedirectResponse;

class Welcome extends BaseController
{
    private readonly array $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'Welcome',
        ];
    }

    public function index(): void
    {
        $stateArray = $this->getJurisdictions();
        echo view('core/header', $this->data);
        echo view('welcome/detail', ['stateArray' => $stateArray]);
        echo view('core/footer');
    }

    public function language(): RedirectResponse
    {
        $this->response->setStatusCode(301);
        return redirect()->to("/en");
    }
}
