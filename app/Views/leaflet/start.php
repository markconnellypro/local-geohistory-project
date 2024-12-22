<?php
$needRotation ??= false;
$jurisdictions ??= [];
$type ??= '';
echo view('leaflet/source');
if (ENVIRONMENT === 'development' && $needRotation) {
    echo view('Localgeohistoryproject\Development\leaflet/rotation');
} ?>
<script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_leaflet_fullscreen') : 'asset/application/dependency') ?>/Leaflet.fullscreen.min.js"></script>
<link rel="stylesheet" href="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_leaflet_fullscreen') : 'asset/application/dependency') ?>/leaflet.fullscreen.css">
<script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_html_to_image') : 'asset/application/dependency') ?>/html-to-image.js"></script>
<?php if (array_intersect($jurisdictions, ['de', 'nj']) !== []) { /* Version 3.0.10, with forked modifications */ ?>
    <script src="/asset/application/map/esri-leaflet.js"></script>
<?php } ?>
<script src="/<?= \Config\Services::request()->getLocale() ?>/leaflet/<?php if ($jurisdictions !== []) {
    $jurisdictions = implode(',', $jurisdictions);
    echo '?jurisdictions=' . urlencode($jurisdictions);
} ?>"></script>
<script src="/asset/application/map/leaflet-start.js"></script>
<?php if ($type !== 'area') { ?>
    <script src="/asset/<?= ($type === 'governmentmap' ? 'development' : 'application') ?>/map/<?= $type ?>-start.js"></script>
<?php } ?>
<script>