var baseMaps = {
    "Street": baseMap
};

var usgsATT = 'Base map: <a href="http://www.nationalmap.gov/">USGS</a>.';

var usgsImagery = L.tileLayer('https://basemap.nationalmap.gov/arcgis/rest/services/USGSImageryOnly/MapServer/tile/{z}/{y}/{x}', {
    attribution: usgsATT,
    minZoom: 1,
    maxZoom: 23
});

var usgsTopo = L.tileLayer('https://basemap.nationalmap.gov/arcgis/rest/services/USGSTopo/MapServer/tile/{z}/{y}/{x}', {
    attribution: usgsATT,
    minZoom: 1,
    maxZoom: 23
});

baseMaps["Imagery (USGS)"] = usgsImagery;
baseMaps["Topographic (USGS)"] = usgsTopo;

Object.keys(stateBaseMaps).forEach(function (element) {
    baseMaps[element] = stateBaseMaps[element];
});

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
    $('.imagedownload').click(function (event) {
        event.preventDefault();
        function filter(node) {
            if (node.classList === undefined) {
                return true;
            } else {
                return (!(node.classList.contains('keyicontext') || (node.classList.contains('leaflet-control') && !node.classList.contains('info') && !node.classList.contains('leaflet-control-attribution'))));
            }
        }
        var mapElement = document.getElementById('map');
        var mapWidth = mapElement.offsetWidth;
        var mapHeight = mapElement.offsetHeight;
        attributionElement = $('.leaflet-control-attribution')[0];
        attributionElement.innerHTML = '<div class="temporarySpace" style="display: inline;"><span style="font-family: ' + "'Fredericka the Great'" + ', serif; color: #003A70; font-size: 15px;">Local Geohistory Project</span> | </div>' + attributionElement.innerHTML + '<div class="temporarySpace" style="width: 5px; float: right;">&nbsp;</div>';
        temporaryElement = $('.temporarySpace');
        htmlToImage.toPng(mapElement, { width: mapWidth, height: mapHeight, filter: filter })
            .then(function (url) {
                temporaryElement.each(function (index, el) {
                    el.parentNode.removeChild(el);
                });
                var a = document.createElement('a');
                document.body.appendChild(a);
                a.style = 'display: none';
                a.href = url;
                a.download = 'Image.png';
                a.click();
                setTimeout(function () {
                    window.URL.revokeObjectURL(url);
                }, 1000);
            });
    });
});

var downloadActive = false;
L.Control.DownloadButton = L.Control.extend({
    onAdd: function (map) {
        // Create download control
        var controlDiv = L.DomUtil.create("div", "leaflet-bar leaflet-control");
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
    }
});
