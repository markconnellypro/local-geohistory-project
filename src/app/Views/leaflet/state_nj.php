<?php /* Verified May 11, 2023 */ ?>

var stateImageryURL = 'https://maps.nj.gov/arcgis/rest/services/Basemap/Orthos_Natural_2020_NJ_WM/MapServer/tile/{z}/{y}/{x}';
var stateImageryATT = 'Base map: <a href="https://newjersey.maps.arcgis.com/home/item.html?id=5d558e0ad9274c558ce2cabd19afaed9">NJOGIS</a>.';

var stateImagery = L.tileLayer(stateImageryURL, {
attribution: stateImageryATT,
maxZoom: 20
});

var stateParcelURL = 'https://services2.arcgis.com/XVOqAjTOJ5P6ngMu/arcgis/rest/services/Hosted_Parcels_Test_WebMer_20201016/FeatureServer/0/';
var stateParcelATT = 'Parcel map: <a href="https://njogis-newjersey.opendata.arcgis.com/datasets/newjersey::parcels-and-mod-iv-composite-of-nj-web-mercator-3857/about">NJOGIS</a>.';

var stateParcel = L.esri.featureLayer({
url: stateParcelURL,
attribution: stateParcelATT,
style: {
fillOpacity: 0,
color: 'black',
weight: 1
}
});

var stateBaseMaps = {
"Imagery (State)": stateImagery
};

var stateOverlayMaps = {
"Parcels (State)": stateParcel
};