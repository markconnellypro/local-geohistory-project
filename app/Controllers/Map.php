<?php

namespace App\Controllers;

use App\Models\GovernmentShapeModel;

class Map extends BaseController
{
    public function baseStyle(int $maxZoom = 14): void
    {
        $this->response->removeHeader('Cache-Control');
        $this->response->setHeader('Cache-Control', 'max-age=86400');
        $this->response->setHeader('Content-Type', 'application/json');
        $json = json_decode(file_get_contents(__DIR__ . '/../../html/asset/application/map/map_style_base.json'), true);
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
                    ['get', 'name'],
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

    public function leaflet(string $zoom = ''): void
    {
        $jurisdictions = strtolower($this->request->getGet('jurisdictions') ?? '');
        $jurisdictions = explode(',', $jurisdictions);
        $jurisdictions = array_unique($jurisdictions);
        foreach ($jurisdictions as $key => $jurisdiction) {
            if (preg_match('/^[a-z\-]{2,}$/', $jurisdiction) !== 1) {
                unset($jurisdictions[$key]);
            }
        }
        sort($jurisdictions);
        $this->response->removeHeader('Cache-Control');
        $this->response->setHeader('Cache-Control', 'max-age=86400');
        $this->response->setHeader('Content-Type', 'application/javascript');
        echo view('leaflet/jurisdiction', ['jurisdictions' => $jurisdictions !== [], 'zoom' => $zoom === 'zoom']);
        foreach ($jurisdictions as $jurisdiction) {
            try {
                echo view('leaflet/jurisdiction_' . $jurisdiction);
            } catch (\Throwable) {
                try {
                    echo view('development/leaflet/jurisdiction_' . $jurisdiction);
                } catch (\Throwable) {
                }
            }
        }
    }

    public function overlayStyle(): void
    {
        $this->response->removeHeader('Cache-Control');
        $this->response->setHeader('Cache-Control', 'max-age=86400');
        $this->response->setHeader('Content-Type', 'application/json');
        $json = json_decode(file_get_contents(__DIR__ . '/../../html/asset/application/map/map_style_overlay.json'), true);
        $json['sources']['localgeohistoryproject']['tiles'][0] = getenv('app_baseLocalGeohistoryProjectUrl') . '/' . \Config\Services::request()->getLocale() . $json['sources']['localgeohistoryproject']['tiles'][0];
        echo json_encode($json);
    }

    public function tile(float $z, float $x, float $y): void
    {
        $this->response->setHeader('Content-Type', 'application/x-protobuf');
        $GovernmentShapeModel = new GovernmentShapeModel();
        $query = $GovernmentShapeModel->getTile($z, $x, $y);
        foreach ($query as $row) {
            echo pg_unescape_bytea($row->mvt);
        }
    }
}
