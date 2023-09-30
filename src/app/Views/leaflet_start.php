<?php
echo view('leaflet_source');
if ($needRotation) { /* Version 0.9.3 */ ?>
    <script src="/asset/development/map/leaflet.geometryutil.js"></script>
<?php } ?>
<script src="/<?= ($online ? '/unpkg.com/leaflet-fullscreen@1.0.2/dist' : 'asset/map') ?>/Leaflet.fullscreen.min.js"></script>
<link rel="stylesheet" href="/<?= ($online ? '/unpkg.com/leaflet-fullscreen@1.0.2/dist' : 'asset/map') ?>/leaflet.fullscreen.css">
<script src="//unpkg.com/dom-to-image@2.6.0/dist/dom-to-image.min.js"></script>
<?php if ($state == 'de' or $state == 'nj') { ?>
    <script src="/<?= ($online ? '/unpkg.com/esri-leaflet@3.0.11/dist' : 'asset/map') ?>/esri-leaflet.js"></script>
<?php } ?>
<script src="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/leaflet/"></script>
<script src="/asset/map/leaflet-start.js"></script>
<?php if ($type != 'area') { ?>
    <script src="/asset/<?= ($type == 'governmentmap' ? 'development/' : '') ?>map/<?= $type ?>-start.js"></script>
<?php } ?>
<script>