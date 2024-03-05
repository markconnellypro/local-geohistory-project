<?php

namespace App\Controllers;

use App\Models\DocumentationModel;

class Key extends BaseController
{
    private array $data = [
        'title' => 'Key',
    ];

    public function __construct()
    {
    }

    public function index(string $state = ''): void
    {
        $this->data['state'] = $state;
        echo view('header', $this->data);

        $keyQueries = [];

        $keys = [
            'Government Level' => 'governmentlevel',
            'Government Map Status' => 'governmentmapstatus',
            'Government Timelapse Map Color' => 'governmenttimelapsemapcolor',
            'Law' => 'law',
        ];
        $DocumentationModel = new DocumentationModel();
        foreach ($keys as $k => $v) {
            $keyQueries[$k] = $DocumentationModel->getKey($v);
        }

        $modelKeys = [
            'Event Type' => 'EventType',
            'How Affected' => 'AffectedType',
            'Relationship' => 'EventRelationship',
            'Successful?' => 'EventGranted'
        ];
        $keys = array_merge($keys, $modelKeys);
        foreach ($modelKeys as $k => $v) {
            $model = "App\\Models\\" . $v . 'Model';
            $model = new $model();
            $keyQueries[$k] = $model->getKey();
        }

        ksort($keys);
        ksort($keyQueries);
        echo view('key_start', ['keys' => $keys]);
        foreach ($keys as $k => $v) {
            echo view('general_key', ['query' => $keyQueries[$k], 'type' => strtolower($v), 'title' => $k]);
        }
        echo view('footer');
    }
}
