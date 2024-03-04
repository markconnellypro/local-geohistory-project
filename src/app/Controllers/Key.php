<?php

namespace App\Controllers;

use App\Models\AffectedTypeModel;
use App\Models\DocumentationModel;
use App\Models\EventGrantedModel;
use App\Models\EventRelationshipModel;
use App\Models\EventTypeModel;

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

    public function index($state = ''): void
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);

        $keys = [
            'EventType' => ['Event Type', 'table'],
            'governmentlevel' => ['Government Level', 'documentation'],
            'governmentmapstatus' => ['Government Map Status', 'documentation'],
            'governmenttimelapsemapcolor' => ['Government Timelapse Map Color', 'documentation'],
            'AffectedType' => ['How Affected', 'table'],
            'law' => ['Law', 'documentation'],
            'EventRelationship' => ['Relationship', 'table'],
            'EventGranted' => ['Successful?', 'table'],
        ];
        echo view('key_start', ['keys' => $keys]);
        $DocumentationModel = new DocumentationModel;
        foreach ($keys as $k => $v) {
            if ($v[1] == 'table') {
                $model = "App\\Models\\" . $k . 'Model';
                $model = new $model;
                $query = $model->getKey();
            } else {
                $query = $DocumentationModel->getKey($k);
            }
            echo view('general_key', ['query' => $query, 'type' => strtolower($k), 'title' => $v[0]]);
        }
        echo view('footer');
    }
}
