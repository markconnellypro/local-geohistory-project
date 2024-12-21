var lastClickedLayer;

function valueStatus(sid) {
    document.getElementById("idholder").value = sid;
}

function highlightFeature(e) {

    if (lastClickedLayer != null) {
        lastClickedLayer.setStyle({
            fillOpacity: 0.1
        });
    }

    var layer = e.target;

    layer.setStyle({
        fillOpacity: 0.2
    });

    if (!L.Browser.ie && !L.Browser.opera) {
        layer.bringToFront();
    }

    lastClickedLayer = layer;
    valueStatus(e.target.feature.properties.id);
    info.update(layer.feature.properties);

}

function onEachFeature(feature, layer) {
    layer.on({
        click: highlightFeature
    });
}
