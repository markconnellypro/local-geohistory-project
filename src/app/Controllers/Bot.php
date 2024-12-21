<?php

namespace App\Controllers;

class Bot extends BaseController
{
    private string $title = 'Bot';

    public function index(): void
    {
        echo view('core/header', ['title' => $this->title]);
        echo view('bot/index');
        echo view('core/footer');
    }

    public function robotsTxt(): void
    {
        $this->response->setHeader('Content-Type', 'text/plain');
        echo view('bot/robotstxt');
        echo view('bot/robotstxt_app');
    }
}
