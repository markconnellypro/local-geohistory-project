<?php

namespace App\Controllers;

class Welcome extends BaseController
{
    private array $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'Welcome',
            'isInternetExplorer' => $this->isInternetExplorer(),
            'live' => $this->isLive(),
            'online' => $this->isOnline(),
            'updated' => $this->lastUpdated()->fulldate,
        ];
    }

    public function index(): void
    {
        $stateArray = $this->getJurisdictions();
        echo view('header', $this->data);
        echo view('welcome', ['isInternetExplorer' => $this->data['isInternetExplorer'], 'stateArray' => $stateArray]);
        echo view('footer');
    }

    public function language()
    {
        $this->response->setStatusCode(301);
        return redirect()->to("/en");
    }
}
