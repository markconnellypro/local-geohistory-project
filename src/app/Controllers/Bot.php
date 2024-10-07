<?php

namespace App\Controllers;

class Bot extends BaseController
{
    private string $title = 'Bot';

    public function index(string $state = ''): void
    {
        echo view('core/header', ['state' => $state, 'title' => $this->title]);
        echo view('bot/index');
        echo view('core/footer');
    }

    public function robotsTxt(): void
    {
        $this->response->setHeader('Content-Type', 'text/plain');
        if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/bot_robotstxt.php')) {
            echo view(ENVIRONMENT . '/bot_robotstxt');
        } else {
            echo view('bot/robotstxt_localgeohistory');
        }
        echo view('bot/robotstxt');
    }
}
