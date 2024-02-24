<link rel="stylesheet" href="/<?= ($online ? '/' . getenv('dependency_leaflet') : 'asset/dependency') ?>/leaflet.css" crossorigin="anonymous">
<script src="/<?= ($online ? '/' . getenv('dependency_leaflet') : 'asset/dependency') ?>/leaflet.js"></script>
<script src="/<?= ($online ? '/' . getenv('dependency_maplibre_gl') : 'asset/dependency') ?>/maplibre-gl.js"></script>
<script src="/<?= ($online ? '/' . getenv('dependency_maplibre_gl_leaflet') : 'asset/dependency') ?>/leaflet-maplibre-gl.js"></script>
<link rel="stylesheet" href="/<?= ($online ? '/' . getenv('dependency_maplibre_gl') : 'asset/dependency') ?>/maplibre-gl.css" crossorigin="anonymous">
<?php if (substr(getenv('map_tile'), 0, 7) == 'pmtiles') { ?>
<script src="/<?= ($online ? '/' . getenv('dependency_pmtiles') : 'asset/dependency') ?>/pmtiles.js"></script>
<script>
    let protocol = new pmtiles.Protocol();
    maplibregl.addProtocol("pmtiles",protocol.tile);
</script>
<?php } ?>