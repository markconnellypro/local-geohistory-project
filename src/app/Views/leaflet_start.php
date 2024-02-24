<?php
echo view('leaflet_source');
if (file_exists(APPPATH . 'Views/' . ENVIRONMENT . '/leaflet_rotation.php') AND $needRotation) {
    echo view(ENVIRONMENT . '/leaflet_rotation');
} ?>
<script src="/<?= ($online ? '/' . getenv('dependency_leaflet-fullscreen') : 'asset/dependency') ?>/Leaflet.fullscreen.min.js"></script>
<link rel="stylesheet" href="/<?= ($online ? '/' . getenv('dependency_leaflet-fullscreen') : 'asset/dependency') ?>/leaflet.fullscreen.css">
<script src="/<?= ($online ? '/' . getenv('dependency_html_to_image') : 'asset/dependency') ?>/html-to-image.js"></script>
<?php if ($state == 'de' or $state == 'nj') /* Version 3.0.10, with forked modifications */ { ?>
    <script src="/asset/map/esri-leaflet.js"></script>
<?php } ?>
<script src="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/leaflet/"></script>
<script src="/asset/map/leaflet-start.js"></script>
<?php if ($type != 'area') { ?>
    <script src="/asset/<?= ($type == 'governmentmap' ? 'development/' : '') ?>map/<?= $type ?>-start.js"></script>
<?php } ?>
<script>