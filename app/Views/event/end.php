<?php
$layers ??= ['default' => 'default'];
?>
var map = L.map("map", {
layers: [baseMap, governmentOverlayMap, affectedgovernmentlayer<?php foreach ($layers as $key => $layer) {
    echo ', ', $key, 'layer';
} ?>]
});

map.fitBounds(affectedgovernmentlayer.getBounds());

var overlayMaps = {
"Approximate Current Boundaries": governmentOverlayMap,
"Affected Government Portion": affectedgovernmentlayer<?php
                                                        foreach ($layers as $key => $layer) {
                                                            echo ",\n  ", '"', $layer, '": ', $key, 'layer';
                                                        } ?>

};

Object.keys(stateOverlayMaps).forEach(function (element) {
overlayMaps[element] = stateOverlayMaps[element];
});

L.control.layers(baseMaps, overlayMaps).addTo(map);

<?php if (is_array($layers) && $layers !== []) {
    foreach (array_keys(array_reverse($layers)) as $key) {
        echo $key, "layer.bringToFront();\n";
    }
} ?>
affectedgovernmentlayer.bringToFront();

<?php if (isset($layers['metesdescription'])) { ?>
    metesdescriptionlayer.removeFrom(map);
<?php } ?>

var info = L.control();

info.onAdd = function (map) {
this._div = L.DomUtil.create('div', 'info');
this.update();
return this._div;
};

info.update = function (props) {
affectedGovernmentString = '';
if (props) {
affectedGovernmentString += '<div id="mapinfo">';
Object.keys(affectedgovernmenttype).forEach(key => {
keyNumber = 0;
keyText = key[0].toUpperCase() + key.substring(1);
Object.values(affectedgovernmenttype[key]).forEach(value => {
if (props[keyText + ' ' + value + ' Long']) {
affectedGovernmentString += '<div class="mapwidth">' + (keyNumber == 0 ? keyText + ':' : '') + '</div><div>';
affectedGovernmentString += (props[keyText + ' ' + value + ' Link'] ? '<a href="/<?= \Config\Services::request()->getLocale() ?>/government/' + props[keyText + ' ' + value + ' Link'] + '/">' : '');
    affectedGovernmentString += props[keyText + ' ' + value + ' Long'];
    affectedGovernmentString += (props[keyText + ' ' + value + ' Link'] ? '</a>' : '');
affectedGovernmentString += ' (<span class="i">' + props[keyText + ' ' + value + ' Affected'] + '</span>)';
affectedGovernmentString += '</div>';
keyNumber++;
}
});
});
affectedGovernmentString += '</div>';

} else {
affectedGovernmentString = '<div class="b">Click for more info.</span>';
    }
    this._div.innerHTML = affectedGovernmentString;
    };

    info.addTo(map);