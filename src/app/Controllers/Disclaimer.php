<?php

namespace App\Controllers;

class Disclaimer extends BaseController
{
    private $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'Disclaimers',
            'isInternetExplorer' => $this->isInternetExplorer(),
            'live' => $this->isLive(),
            'online' => $this->isOnline(),
            'updated' => $this->lastUpdated()->fulldate,
        ];
    }

    public function index($state = ''): void
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);
        echo view('disclaimer');
        echo view('footer');
    }
}
