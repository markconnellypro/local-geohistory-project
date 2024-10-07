<?php

namespace App\Controllers;

class Disclaimer extends BaseController
{
    private string $title = 'Disclaimers';

    public function index(string $state = ''): void
    {
        echo view('core/header', ['state' => $state, 'title' => $this->title]);
        echo view('disclaimer/index');
        echo view('core/footer');
    }
}
