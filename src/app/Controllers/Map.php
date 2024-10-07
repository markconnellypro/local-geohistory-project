<?php

namespace App\Controllers;

use App\Models\GovernmentShapeModel;
use CodeIgniter\HTTP\ResponseInterface;

class Map extends BaseController
{
    public function baseStyle(int $maxZoom = 14, ResponseInterface $response = null): void
    {
        if (!$response instanceof \CodeIgniter\HTTP\ResponseInterface) {
            $response = $this->response;
        }
        $response->removeHeader('Cache-Control');
        $response->setHeader('Cache-Control', 'max-age=86400');
        $response->setHeader('Content-Type', 'application/json');
        $json = json_decode(file_get_contents(__DIR__ . '/../../html/asset/map/map_style_base.json'), true);
        if (str_contains(getenv('map_tile'), '.json') || str_contains(getenv('map_tile'), '.pmtiles')) {
            $json['sources']['street-tile']['url'] = getenv('map_tile');
            unset($json['sources']['street-tile']['tiles']);
        } else {
            $json['sources']['street-tile']['tiles'][] = getenv('map_tile');
            unset($json['sources']['street-tile']['url']);
        }
        $json['glyphs'] = getenv('map_glyph');
        if (getenv('map_elevation') !== '' && $maxZoom === 14 && !($this->isLive() && !$this->isOnline())) {
            $json['sources']['elevation-tile']['tiles'][] = getenv('map_elevation');
        } else {
            unset($json['sources']['elevation-tile']);
            for ($i = count($json['layers']) - 1; $i >= 0; $i--) {
                if ($json['layers'][$i]['id'] === 'hillshading') {
                    unset($json['layers'][$i]);
                    break;
                }
            }
        }
        foreach ($json['layers'] as $layerNumber => $layerContent) {
            if (($layerContent['layout']['text-field'] ?? '') === '{name}') {
                $json['layers'][$layerNumber]['layout']['text-field'] = [
                    'coalesce',
                    ['get', 'name_' . \Config\Services::request()->getLocale()],
                    ['get', 'name:' . \Config\Services::request()->getLocale()],
                    ['get', 'name']
                ];
                if (!in_array(\Config\Services::request()->getLocale(), ['de', 'en'])) {
                    $json['layers'][$layerNumber]['layout']['text-field'][] = ['get', 'name_en'];
                }
            }
        }
        if ($maxZoom < 14) {
            $json['sources']['street-tile']['maxzoom'] = $maxZoom;
        }
        echo json_encode($json);
    }

    public function leaflet(string $state = ''): void
    {
        $zoom = ($state === 'zoom');
        $this->response->removeHeader('Cache-Control');
        $this->response->setHeader('Cache-Control', 'max-age=86400');
        $this->response->setHeader('Content-Type', 'application/javascript');
        echo view('leaflet/state_base', ['state' => $state, 'zoom' => $zoom]);
        try {
            echo view('leaflet/state_' . $state);
        } catch (\Throwable) {
            try {
                echo view('development/leaflet/state_' . $state);
            } catch (\Throwable) {
                echo view('leaflet/state');
            }
        }
    }

    public function overlayStyle(string $state = ''): void
    {
        $this->response->removeHeader('Cache-Control');
        $this->response->setHeader('Cache-Control', 'max-age=86400');
        $this->response->setHeader('Content-Type', 'application/json');
        $json = json_decode(file_get_contents(__DIR__ . '/../../html/asset/map/map_style_overlay.json'), true);
        $json['sources']['localgeohistoryproject']['tiles'][0] = getenv('app_baseLocalGeohistoryProjectUrl') . '/' . \Config\Services::request()->getLocale() . '/' . $state . $json['sources']['localgeohistoryproject']['tiles'][0];
        echo json_encode($json);
    }

    public function tile(float $z, float $x, float $y, string $state = ''): void
    {
        $this->response->setHeader('Content-Type', 'application/x-protobuf');
        $GovernmentShapeModel = new GovernmentShapeModel();
        $query = $GovernmentShapeModel->getTile($state, $z, $x, $y);
        foreach ($query as $row) {
            echo pg_unescape_bytea($row->mvt);
        }
    }
}
