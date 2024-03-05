<?php

namespace App\Controllers;

class Fourofour extends BaseController
{
    private array $data;

    public function __construct()
    {
        $this->data = [
            'title' => '404',
            'isInternetExplorer' => $this->isInternetExplorer(),
            'live' => $this->isLive(),
            'online' => $this->isOnline(),
            'updated' => $this->lastUpdated()->fulldate,
        ];
    }

    public function index($state = ''): void
    {
        $this->response->setStatusCode(404);
        $this->data['state'] = $state;
        echo view('header', $this->data);
        echo view('error');
        echo view('footer');
    }
}
