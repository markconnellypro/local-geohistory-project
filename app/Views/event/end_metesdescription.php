var map = L.map("map", {
layers: [baseMap, governmentOverlayMap, metesdescriptionlayer]
});

map.fitBounds(metesdescriptionlayer.getBounds());

var overlayMaps = {
"Approximate Current Boundaries": governmentOverlayMap,
"Descriptions": metesdescriptionlayer
};

Object.keys(stateOverlayMaps).forEach(function (element) {
overlayMaps[element] = stateOverlayMaps[element];
});

L.control.layers(baseMaps, overlayMaps).addTo(map);