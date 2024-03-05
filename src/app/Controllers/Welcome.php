<?php

namespace App\Controllers;

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
        echo view('header', $this->data);
        echo view('welcome', ['stateArray' => $stateArray]);
        echo view('footer');
    }

    public function language()
    {
        $this->response->setStatusCode(301);
        return redirect()->to("/en");
    }
}
