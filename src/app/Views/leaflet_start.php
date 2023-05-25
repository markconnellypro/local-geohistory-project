<?php
echo view('leaflet_source');
if ($needRotation) { /* Version 0.9.3 */ ?>
    <script src="/asset/development/map/leaflet.geometryutil.js"></script>
<?php } ?>
<script src="/<?= ($online ? '/api.mapbox.com/mapbox.js/plugins/leaflet-fullscreen/v1.0.1' : 'asset/map') ?>/Leaflet.fullscreen.min.js"></script>
<link rel="stylesheet" href="/<?= ($online ? '/api.mapbox.com/mapbox.js/plugins/leaflet-fullscreen/v1.0.1' : 'asset/map') ?>/leaflet.fullscreen.css" crossorigin="anonymous" />
<script src="/<?= ($online ? '/unpkg.com/maplibre-gl@3.0.0/dist' : 'asset/map') ?>/maplibre-gl.js"></script>
<script src="/<?= ($online ? '/unpkg.com/@maplibre/maplibre-gl-leaflet@0.0.19' : 'asset/map') ?>/leaflet-maplibre-gl.js"></script>
<link rel="stylesheet" href="/<?= ($online ? '/unpkg.com/maplibre-gl@3.0.0/dist' : 'asset/map') ?>/maplibre-gl.css" crossorigin="anonymous" />
<script src="//unpkg.com/dom-to-image@2.6.0/dist/dom-to-image.min.js"></script>
<script src="/asset/map/stamen.js"></script>
<?php if ($state == 'de' or $state == 'nj') /* Version 3.0.10, with forked modifications */ { ?>
    <script src="/asset/map/esri-leaflet.js"></script>
<?php } ?>
<script src="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/leaflet/"></script>
<script src="/asset/map/leaflet-start.js"></script>
<?php if ($type != 'area') { ?>
    <script src="/asset/<?= ($type == 'governmentmap' ? 'development/' : '') ?>map/<?= $type ?>-start.js"></script>
<?php } ?>
<script>