<?php
$includeBase ??= true;
$includePoint ??= false;
$layerArray = [];
?>
var map = L.map("map", {
layers: [<?php
            echo($includeBase ? 'baseMap, ' : '');
$layerArray[] = 'arealayer';
if ($includePoint) {
    $layerArray[] = 'pointlayer';
}
echo implode(', ', $layerArray);
?>]
});

map.fitBounds(arealayer.getBounds());

var overlayMaps = {
"Shape Area": arealayer<?= ($includePoint ? ',
  "Point": pointlayer' : ''); ?>
};

Object.keys(stateOverlayMaps).forEach(function (element) {
overlayMaps[element] = stateOverlayMaps[element];
});

L.control.layers(baseMaps, overlayMaps).addTo(map);

arealayer.bringToFront();