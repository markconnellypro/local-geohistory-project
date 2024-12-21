function highlightFeature(e) {
    linelayer.setStyle({
        color: "#d5103f",
        weight: 3
    });

    pointlayer.setStyle({
        color: "#d5103f",
        radius: 6,
        weight: 3
    });

    var layer = e.target;

    layer.setStyle({
        color: "#d5103f",
        weight: 6,
        radius: 9
    });

    if (!L.Browser.ie && !L.Browser.opera) {
        layer.bringToFront();
    }

    info.update(layer.feature.properties);
}

function onEachFeature(feature, layer) {
    layer.on({
        click: highlightFeature
    });
}
