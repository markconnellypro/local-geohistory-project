<link rel="stylesheet" href="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_leaflet') : 'asset/application/dependency') ?>/leaflet.css" crossorigin="anonymous">
<script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_leaflet') : 'asset/application/dependency') ?>/leaflet.js"></script>
<script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_maplibre_gl') : 'asset/application/dependency') ?>/maplibre-gl.js"></script>
<script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_maplibre_gl_leaflet') : 'asset/application/dependency') ?>/leaflet-maplibre-gl.js"></script>
<link rel="stylesheet" href="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_maplibre_gl') : 'asset/application/dependency') ?>/maplibre-gl.css" crossorigin="anonymous">
<?php if (str_starts_with(getenv('map_tile'), 'pmtiles')) { ?>
<script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_pmtiles') : 'asset/application/dependency') ?>/pmtiles.js"></script>
<script>
    let protocol = new pmtiles.Protocol();
    maplibregl.addProtocol("pmtiles",protocol.tile);
</script>
<?php } ?>