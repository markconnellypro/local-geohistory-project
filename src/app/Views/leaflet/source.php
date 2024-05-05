<link rel="stylesheet" href="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_leaflet') : 'asset/dependency') ?>/leaflet.css" crossorigin="anonymous">
<script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_leaflet') : 'asset/dependency') ?>/leaflet.js"></script>
<script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_maplibre_gl') : 'asset/dependency') ?>/maplibre-gl.js"></script>
<script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_maplibre_gl_leaflet') : 'asset/dependency') ?>/leaflet-maplibre-gl.js"></script>
<link rel="stylesheet" href="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_maplibre_gl') : 'asset/dependency') ?>/maplibre-gl.css" crossorigin="anonymous">
<?php if (str_starts_with(getenv('map_tile'), 'pmtiles')) { ?>
<script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_pmtiles') : 'asset/dependency') ?>/pmtiles.js"></script>
<script>
    let protocol = new pmtiles.Protocol();
    maplibregl.addProtocol("pmtiles",protocol.tile);
</script>
<?php } ?>