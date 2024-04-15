<?php

namespace App\Controllers;

class Disclaimer extends BaseController
{
    private array $data = [
        'title' => 'Disclaimers',
    ];

    public function __construct()
    {
    }

    public function index(string $state = ''): void
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);
        echo view('disclaimer/detail');
        echo view('footer');
    }
}
