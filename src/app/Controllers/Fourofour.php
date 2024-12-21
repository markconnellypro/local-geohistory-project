<?php

namespace App\Controllers;

class Fourofour extends BaseController
{
    private string $title = '404';

    public function index(): void
    {
        $this->response->setStatusCode(404);
        echo view('core/header', ['title' => $this->title]);
        echo view('core/error');
        echo view('core/footer');
    }
}
