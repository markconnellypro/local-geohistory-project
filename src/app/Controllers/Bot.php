<?php

namespace App\Controllers;

class Bot extends BaseController
{

    private $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'Bot',
            'isInternetExplorer' => $this->isInternetExplorer(),
            'live' => $this->isLive(),
            'online' => $this->isOnline(),
            'updated' => $this->lastUpdated()->fulldate,
        ];
    }

    public function index($state = '')
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);
        echo view('bot');
        echo view('footer');
    }

    public function robotsTxt()
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
