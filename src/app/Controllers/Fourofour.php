<?php

namespace App\Controllers;

class Fourofour extends BaseController
{
    private array $data = [
        'title' => '404',
    ];

    public function __construct()
    {
    }

    public function index(string $state = ''): void
    {
        $this->response->setStatusCode(404);
        $this->data['state'] = $state;
        echo view('core/header', $this->data);
        echo view('core/error');
        echo view('core/footer');
    }
}
