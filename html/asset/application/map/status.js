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

    statusText = '<ul>';
    layer.feature.properties.TASK.forEach((element) => statusText += '<li>' + element + '</li>');
    statusText += '</ul>';
    $('#status-task').html(statusText);
}

var lastClickedLayer;

function onEachFeature(feature, layer) {
    layer.on({
        click: highlightFeature
    });
}

var statusLayer = L.geoJson(null, {
    onEachFeature: onEachFeature,
    style: function (feature) {
        return {
            color: "#000000",
            fillColor: getFillColor(feature.properties.STATUS),
            weight: 1,
            fillOpacity: 0.3,
            smoothFactor: 0,
        }
    }
});

var fillColor = {
    "Studying": "#000000",
    "Started": "#FF9E00",
    "In-Person Research": "#0000FF",
    "Online": "#00FF00"
};

function getFillColor(data) {
    return fillColor[data];
}

var map = L.map('map', {
    layers: [statusLayer],
    zoomSnap: 0,
    zoomControl: false,
    dragging: false,
    doubleClickZoom: false,
    scrollWheelZoom: false,
    trackResize: true
});

var statusdata = [];
var mapPathDone = 0;
$.each(mapPath, function (file) {
    $.getJSON(mapPath[file], function (data) {
        $.each(data.features, function (index, feature) {
            partPart = partData[feature.properties.NAME];
            feature.properties.OPENDATA = partPart.OPENDATA;
            feature.properties.STATUS = partPart.STATUS;
            feature.properties.TASK = partPart.TASK;
            statusdata.push(feature);
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
    statusdata = { "type": "FeatureCollection", "crs": { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } }, "features": statusdata };
    statusLayer.addData(statusdata);
    statusBounds = statusLayer.getBounds();
    map.fitBounds(statusBounds);
    legend = L.control({ position: 'bottomright' });
    legend.onAdd = function (map) {
        var div = L.DomUtil.create('div', 'infolegend legend');
        var labels = [];

        for (const [key, value] of Object.entries(fillColor)) {
            labels.push('<i class="statuskey" style="background: ' + value + ';">&nbsp;</i> ' + key);
        }

        div.innerHTML = '<span class="b">Legend: </span> ' + labels.join(' ');
        return div;
    };
    legend.addTo(map);
}

map.attributionControl.setPrefix('');

var info = L.control();

info.onAdd = function (map) {
    this._div = L.DomUtil.create('div', 'info');
    this.update();
    return this._div;
};

info.update = function (props) {
    this._div.innerHTML = (props ? '<span class="b">Government: </span>' + (props.NAME + ' ' + props.TYPE).trim() + '</span><br><span class="b">Status: </span>' + props.STATUS : '<span class="b">'
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
    this._div.innerHTML = '<span class="b">Select a layer to download:</span><br><a class="datadownload" id="status" href="#">Status</a>';
};
downloadBox.addTo(map);
