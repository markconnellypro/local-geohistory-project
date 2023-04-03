<?php

namespace App\Controllers;

class Key extends BaseController
{

    private $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'Key',
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
        $keys = [
            'eventtype' => 'Event Type',
            'governmentlevel' => 'Government Level',
            'governmentmapstatus' => 'Government Map Status',
            'governmenttimelapsemapcolor' => 'Government Timelapse Map Color',
            'affectedtype' => 'How Affected',
            'law' => 'Law',
            'eventrelationship' => 'Relationship',
            'eventgranted' => 'Successful?',
        ];
        echo view('key_start', ['keys' => $keys]);
        foreach ($keys as $k => $v) {
            $query = $this->db->query('SELECT * FROM extra.ci_model_key_' . $k . '()', [])->getResult();
            echo view('general_key', ['query' => $query, 'type' => $k, 'title' => $v]);
        }
        echo view('footer');
    }
}
