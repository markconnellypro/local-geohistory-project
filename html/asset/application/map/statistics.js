function highlightFeature(e) {
    if (lastClickedLayer != null) {
        lastClickedLayer.setStyle({
            weight: 1,
            color: '#000000'
        });
    }

    var layer = e.target;

    layer.setStyle({
        weight: 4,
        color: '#BE3A34'
    });

    if (!L.Browser.ie && !L.Browser.opera) {
        layer.bringToFront();
    }

    lastClickedLayer = layer;

    info.update(layer.feature.properties);

    var newChartData = partData[layer.feature.properties.ID];
    if (typeof newChartData !== 'undefined') {
        reloadData((layer.feature.properties.NAME + ' ' + layer.feature.properties.TYPE).trim(), newChartData.xrow, newChartData.yrow);
    } else {
        reloadData((layer.feature.properties.NAME + ' ' + layer.feature.properties.TYPE).trim(), [0], [0]);
    }
}

var lastClickedLayer;

function onEachFeature(feature, layer) {
    layer.on({
        click: highlightFeature
    });
}

var statistics = L.geoJson(null, {
    onEachFeature: onEachFeature,
    style: function (feature) {
        return {
            color: "#000000",
            fillColor: "#003A70",
            weight: 1,
            fillOpacity: getFillOpacity(feature.properties.COUNT),
            smoothFactor: 0,
        }
    }
});

var fillOpacities = [0, 0.2, 0.55, 0.9];

function getFillOpacity(data) {
    if (data == 0) {
        return fillOpacities[0];
    } else if (colorBreaks[1] !== 'X' && data <= colorBreaks[1]) {
        return fillOpacities[1];
    } else if (colorBreaks[2] !== 'X' && data <= colorBreaks[2]) {
        return fillOpacities[2];
    } else {
        return fillOpacities[3];
    }
}

var map = L.map('map', {
    layers: [statistics],
    zoomSnap: 0,
    zoomControl: false,
    dragging: false,
    doubleClickZoom: false,
    scrollWheelZoom: false,
    trackResize: true
});

var statisticsdata = [];
var statisticsHasZero = false;
var statisticsSeries = [];
var statisticsValues = {};
var mapPathDone = 0;
$.each(mapPath, function (file) {
    $.getJSON(mapPath[file], function (data) {
        $.each(data.features, function (index, feature) {
            partSum = partData[feature.properties.ID];
            if (typeof partSum !== 'undefined') {
                partSum = partSum.ysum;
                partData[feature.properties.ID].addedToMap = true;
                if (partSum == 0) {
                    statisticsHasZero = true;
                } else {
                    statisticsSeries.push(partSum);
                }
            } else {
                partSum = 0;
                statisticsHasZero = true;
            }
            feature.properties.COUNT = partSum;
            statisticsdata.push(feature);
            if (index == data.features.length - 1) {
                mapPathDone++;
                if (mapPathDone == mapPath.length) {
                    updateMap();
                }
            }
        });
    });
});

function updateMap() {
    statisticsSeries.sort(function (a, b) {
        return a - b;
    });
    statisticsValues = statisticsSeries.filter(function (item, pos) {
        return statisticsSeries.indexOf(item) == pos;
    });
    statisticsValues.sort(function (a, b) {
        return a - b;
    });
    statisticsValuesCount = statisticsValues.length;
    switch (statisticsValuesCount) {
        case 0:
            colorBreaks = [(statisticsHasZero ? 0 : 'X'), 'X', 'X', 'X'];
            break;
        case 1:
            colorBreaks = [(statisticsHasZero ? 0 : 'X'), 'X', 'X', statisticsValues[0]];
            break;
        case 2:
            colorBreaks = [(statisticsHasZero ? 0 : 'X'), 'X', statisticsValues[0], statisticsValues[1]];
            break;
        case 3:
            colorBreaks = [(statisticsHasZero ? 0 : 'X'), statisticsValues[0], statisticsValues[1], statisticsValues[2]];
            break;
        default:
            var brew = new classyBrew();
            brew.setSeries(statisticsSeries);
            brew.setNumClasses(3);
            colorBreaks = brew.classify('jenks');
            colorBreaks[0] = (statisticsHasZero ? 0 : 'X');
    }
    colorTextBreaks = colorBreaks.slice();
    if (statisticsValuesCount > 3) {
        colorBreakItem = 0;
        for (var i = 0; i < statisticsValues.length; i++) {
            if (colorBreakItem == 0 || statisticsValues[i] > colorBreaks[colorBreakItem]) {
                colorBreakItem++;
                colorTextBreaks[colorBreakItem] = [statisticsValues[i], statisticsValues[i]];
            } else {
                colorTextBreaks[colorBreakItem][1] = statisticsValues[i];
            }
        }
        for (var i = 1; i < 4; i++) {
            if (colorTextBreaks[i][0] == colorTextBreaks[i][1] || colorTextBreaks[i][0] > colorTextBreaks[i][1]) {
                colorTextBreaks[i] = colorTextBreaks[i][0];
            } else {
                colorTextBreaks[i] = colorTextBreaks[i][0] + '&ndash;' + colorTextBreaks[i][1]
            }
        }
    }
    statisticsdata = { "type": "FeatureCollection", "crs": { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } }, "features": statisticsdata };
    statistics.addData(statisticsdata);
    yMissing = 0;
    $.each(partData, function (index, part) {
        if (typeof part.addedToMap === 'undefined') {
            yMissing += part.ysum;
        }
    });
    if (yMissing > 0) {
        $('#notes').append('<li>The above map does not show <span class="b">' + yMissing + '</span> event' + (yMissing > 1 ? 's' : '') + ' not associated with mapped jurisdictions.</li>');
    }
    statisticsBounds = statistics.getBounds();
    map.fitBounds(statisticsBounds);
    var statisticsStart = map.latLngToContainerPoint(statisticsBounds.getNorthWest()).y;
    var statisticsEnd = map.latLngToContainerPoint(statisticsBounds.getSouthEast()).y;
    var mapElement = document.getElementById("map");
    var mapElementHeight = mapElement.offsetHeight;
    var statisticsDifference = statisticsStart + (mapElementHeight - statisticsEnd);
    if (statisticsDifference > 70) {
        mapElement.style.height = (mapElementHeight - (statisticsDifference - 70)) + 'px';
        map.invalidateSize();
    }
    map.fitBounds(statisticsBounds);
    legend = L.control({ position: 'bottomright' });
    legend.onAdd = function (map) {
        var div = L.DomUtil.create('div', 'info legend');
        var labels = [];

        for (var i = 0; i < 4; i++) {
            if (colorTextBreaks[i] != 'X') {
                labels.push('<i class="statisticskey" style="opacity: ' + fillOpacities[i] + '">&nbsp;</i> ' + colorTextBreaks[i]);
            }
        }

        div.innerHTML = '<span class="b">Legend: </span> ' + labels.join(' ');
        return div;
    };

    legend.addTo(map);
    mapElementHeight = mapElement.offsetHeight;
    mapElement.style.height = (mapElementHeight + 50) + 'px';
}

map.attributionControl.setPrefix('');

var info = L.control();

info.onAdd = function (map) {
    this._div = L.DomUtil.create('div', 'info');
    this.update();
    return this._div;
};

info.update = function (props) {
    this._div.innerHTML = (props ? '<span class="b">Government: </span>' + (props.NAME + ' ' + props.TYPE).trim() + '</span><br><span class="b">Count: </span>' + props.COUNT : '<span class="b">'
        + 'Click for more info.</span>');
};

info.addTo(map);

$(function () {
    $('.datadownload').click(function (event) {
        event.preventDefault();
        var a = document.createElement('a');
        document.body.appendChild(a);
        a.style = 'display: none';
        var blob = new Blob([JSON.stringify(eval(this.id + 'data'))], { type: 'application/geo+json' }),
            url = window.URL.createObjectURL(blob);
        a.href = url;
        a.download = this.innerHTML + '.geojson';
        a.click();
        setTimeout(function () {
            window.URL.revokeObjectURL(url);
        }, 1000);
    });
});

var downloadActive = false;
L.Control.DownloadButton = L.Control.extend({
    onAdd: function (map) {
        // Create download control
        var controlDiv = L.DomUtil.create("div", "leaflet-control-download leaflet-bar leaflet-control");
        var controlUI = L.DomUtil.create("a", "leaflet-bar-part", controlDiv);
        controlUI.href = "#";
        controlUI.innerHTML = '<span class="mapicon">download</span>';
        this._button = controlUI;
        this._button.title = "Toggle Download Options";
        this._container = controlDiv;
        this._createTooltip();
        return controlDiv;
    },
    // CreateTooltip()
    _createTooltip: function () {
        var tool = L.DomUtil.create("div", "rotate-feature-tooltip", this._container);
        var that = this;
        L.DomEvent.on(this._button, "click", function (e) {
            L.DomEvent.stopPropagation(e);
            L.DomEvent.preventDefault(e);
            downloadActive = !downloadActive;
            if (downloadActive) {
                document.getElementsByClassName('downloadbox')[0].style.display = 'inherit';
            } else {
                document.getElementsByClassName('downloadbox')[0].style.display = 'none';
            }
            return false;
        });
        return tool;
    }
});

// Add DownloadButton control to map
var downloadButtonControl = new L.Control.DownloadButton();
map.addControl(downloadButtonControl);
var downloadBox = L.control();
downloadBox.onAdd = function (map) {
    this._div = L.DomUtil.create('div', 'downloadbox');
    this.update();
    return this._div;
};
downloadBox.update = function () {
    this._div.innerHTML = '<span class="b">Select a layer to download:</span><br><a class="datadownload" id="statistics" href="#">Statistics</a>';
};
downloadBox.addTo(map);
