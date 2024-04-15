<?php

namespace App\Controllers;

class Bot extends BaseController
{
    private array $data = [
        'title' => 'Bot',
    ];

    public function __construct()
    {
    }

    public function index(string $state = ''): void
    {
        $this->data['state'] = $state;
        echo view('core/header', $this->data);
        echo view('bot');
        echo view('core/footer');
    }

    public function robotsTxt(): void
    {
        $this->response->setHeader('Content-Type', 'text/plain');
        if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/bot_robotstxt.php')) {
            echo view(ENVIRONMENT . '/bot_robotstxt');
        } else {
            echo view('bot_robotstxt_localgeohistory');
        }
        echo view('bot_robotstxt');
    }
}
