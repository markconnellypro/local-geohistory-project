<?php
$includeArea ??= false;
$includeBase ??= true;
$includeMetes ??= false;
$layerArray = [];
$overlayArray = [];
?>
var map = L.map("map", {
layers: [<?php
            echo($includeBase ? 'baseMap, ' : '');
if ($includeArea) {
    $layerArray[] = 'arealayer';
}
if ($includeMetes) {
    $layerArray[] = 'linelayer';
    $layerArray[] = 'pointlayer';
}
echo implode(', ', $layerArray);
?>]
});

map.fitBounds(<?= ($includeMetes ? 'point' : 'area') ?>layer.getBounds());

<?php if ($includeBase) { ?>
    var overlayMaps = {
    <?php
    if ($includeArea) {
        $overlayArray[] = '"Description Area": arealayer';
    }
    if ($includeMetes) {
        $overlayArray[] = '"Description Line": linelayer';
        $overlayArray[] = '"Description Point": pointlayer';
    }
    echo "\t" . implode(',' . PHP_EOL . "\t", $overlayArray) . PHP_EOL;
    ?>
    };

    Object.keys(stateOverlayMaps).forEach(function (element) {
    overlayMaps[element] = stateOverlayMaps[element];
    });

    L.control.layers(baseMaps, overlayMaps).addTo(map);
<?php }
if ($includeMetes) { ?>

    var info = L.control({position: 'topright'});

    info.onAdd = function(map) {
    this._div = L.DomUtil.create('div', 'info');
    this.update();
    return this._div;
    };

    info.update = function(props) {
    this._div.innerHTML = (props ? '<span class="b">' + props.type + ' ' + props.line + ':</span> ' + props.description :
    '<div class="b">Click for more info.</span>');
        };

        info.addTo(map);
    <?php } ?>