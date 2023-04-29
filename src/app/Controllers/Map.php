<?php

namespace App\Controllers;

class Map extends BaseController
{

    private $data;

    public function __construct()
    {
        $this->data = [
            'title' => 'Map',
            'isInternetExplorer' => $this->isInternetExplorer(),
            'live' => $this->isLive(),
            'online' => $this->isOnline(),
            'updated' => $this->lastUpdated()->fulldate,
        ];
    }

    public function baseStyle($state = '')
    {
        $this->response->removeHeader('Cache-Control');
        $this->response->setHeader('Cache-Control', 'max-age=86400');
        $this->response->setHeader('Content-Type', 'application/json');
        $json = json_decode(file_get_contents(__DIR__ . '/../../html/asset/map/map_style_base.json'), true);
        $json['sources']['openmaptiles']['url'] .= getenv('maptiler_key');
        $json['glyphs'] .= getenv('maptiler_key');
        echo json_encode($json);
    }

    public function leaflet($state = '')
    {
        $this->data['state'] = $state;
        $this->response->removeHeader('Cache-Control');
        $this->response->setHeader('Cache-Control', 'max-age=86400');
        $this->response->setHeader('Content-Type', 'application/javascript');
        echo view('leaflet_state_base', $this->data);
        try {
            echo view('leaflet_state_' . $state, $this->data);
        } catch (\Throwable $t) {
            try {
                echo view('development/leaflet_state_' . $state, $this->data);
            } catch (\Throwable $t) {
                echo view('leaflet_state', $this->data);
            }
        }
    }

    public function overlayStyle($state = '')
    {
        $this->response->removeHeader('Cache-Control');
        $this->response->setHeader('Cache-Control', 'max-age=86400');
        $this->response->setHeader('Content-Type', 'application/json');
        $json = json_decode(file_get_contents(__DIR__ . '/../../html/asset/map/map_style_overlay.json'), true);
        $json['sources']['localgeohistoryproject']['tiles'][0] = getenv('app_baseLocalGeohistoryProjectUrl') . '/' . \Config\Services::request()->getLocale() . '/' . $state . $json['sources']['localgeohistoryproject']['tiles'][0];
        echo json_encode($json);
    }

    public function tile($z, $x, $y, $state = '')
    {
        $this->response->setHeader('Content-Type', 'application/x-protobuf');
        $query = $this->db->query('SELECT * FROM extra.ci_model_map_tile(?, ?, ?, ?)', [$state, $z, $x, $y])->getResult();
        foreach ($query as $row) {
            echo pg_unescape_bytea($row->mvt);
        }
    }
}
