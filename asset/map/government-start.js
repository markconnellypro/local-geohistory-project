function highlightFeature(e) {
    metesdescriptionlayer.setStyle({
        color: "#d5103f",
        weight: 1.25
    });
    var layer = e.target;
    layer.setStyle({
        color: "#d5103f",
        weight: 4,
    });
    if (!L.Browser.ie && !L.Browser.opera) {
        layer.bringToFront();
    }
    info2.update(layer.feature.properties);
}

function onEachFeature(feature, layer) {
    layer.on({
        click: highlightFeature
    });
}

var lastClickedLayer2;
var lastClickedRank;
var valueStatus;

function dispositionColor(r) {
    return r == 1 ? "#AAC000" :
        r == 2 ? "#C56C00" :
            r == 3 ? "#07517D" :
                "#6F0381";
}

function dispositionColorName(r) {
    return r == 1 ? "Proposed" :
        r == 2 ? "Former" :
            r == 3 ? "Current" :
                "Mapped";
}

function dispositionStyleTemplate(colorValue) {
    return {
        weight: 0,
        color: "#000000",
        fillColor: colorValue,
        opacity: 0,
        fillOpacity: 0.5
    };
}

function dispositionStyle(feature) {
    return dispositionStyleTemplate(dispositionColor(feature.properties.disposition));
}

function highlightFeature2(e) {
    if (lastClickedLayer2 != null) {
        lastClickedLayer2.setStyle(dispositionStyleTemplate(dispositionColor(lastClickedRank)));
    }
    var layer2 = e.target;
    layer2.setStyle({
        fillColor: "#D5103F"
    });
    if (!L.Browser.ie && !L.Browser.opera) {
        layer2.bringToFront();
    }
    lastClickedLayer2 = layer2;
    lastClickedRank = e.target.feature.properties.disposition;
    valueStatus = e.target.feature.properties.id;
    info.update(layer2.feature.properties);
}

function onEachFeature2(feature, layer) {
    layer.on({
        click: highlightFeature2
    });
}
