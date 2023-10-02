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

<?php foreach (array_reverse($layers) as $key => $layer) {
    echo $key, "layer.bringToFront();\n";
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
Object.keys(affectedgovernmenttype).forEach(key => {
keyNumber = 0;
keyText = key[0].toUpperCase() + key.substring(1);
Object.values(affectedgovernmenttype[key]).forEach(value => {
if (props[keyText + ' ' + value + ' Long']) {
affectedGovernmentString += (keyText == 'To' || keyNumber > 0 ? '<br>' : '') + '<div class="mapwidth">' + (keyNumber == 0 ? keyText + ': ' : '') + '</div>';
affectedGovernmentString += (props[keyText + ' ' + value + ' Link'] ? '<a href="' + props[keyText + ' ' + value + ' Link'] + '">' : '');
    affectedGovernmentString += props[keyText + ' ' + value + ' Long'];
    affectedGovernmentString += (props[keyText + ' ' + value + ' Link'] ? '</a>' : '');
affectedGovernmentString += ' (<span class="i">' + props[keyText + ' ' + value + ' Affected'] + '</span>)';
keyNumber++;
}
});
});
} else {
affectedGovernmentString = '<div class="b">Click on any area in<br>red for more info.</span>';
    }
    this._div.innerHTML = affectedGovernmentString;
    };

    info.addTo(map);