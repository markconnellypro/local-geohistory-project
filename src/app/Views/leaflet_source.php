<link rel="stylesheet" href="/<?= ($online ? '/unpkg.com/leaflet@1.9.4/dist' : 'asset/map') ?>/leaflet.css" crossorigin="anonymous">
<script src="/<?= ($online ? '/unpkg.com/leaflet@1.9.4/dist' : 'asset/map') ?>/leaflet.js"></script>
<script src="/<?= ($online ? '/unpkg.com/maplibre-gl@3.3.1/dist' : 'asset/map') ?>/maplibre-gl.js"></script>
<script src="/<?= ($online ? '/unpkg.com/@maplibre/maplibre-gl-leaflet@0.0.19' : 'asset/map') ?>/leaflet-maplibre-gl.js"></script>
<link rel="stylesheet" href="/<?= ($online ? '/unpkg.com/maplibre-gl@3.3.1/dist' : 'asset/map') ?>/maplibre-gl.css" crossorigin="anonymous">
<?php if (substr(getenv('map_tile'), 0, 7) == 'pmtiles') { ?>
<script src="https://unpkg.com/pmtiles@2.10.0/dist/index.js"></script>
<script>
    let protocol = new pmtiles.Protocol();
    maplibregl.addProtocol("pmtiles",protocol.tile);
</script>
<?php } ?>