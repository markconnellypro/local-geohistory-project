<?php /* Verified February 1, 2021 */ ?>
var stateImageryURL = 'https://maps.nj.gov/arcgis/rest/services/Basemap/Orthos_Natural_2015_NJ_WM/MapServer/tile/{z}/{y}/{x}';
var stateImageryATT = 'Base map: <a href="https://newjersey.maps.arcgis.com/home/item.html?id=2e35eb33c1fe4c13b2ce00d818b21e80">NJOGIS</a>.';

var stateImagery = L.tileLayer(stateImageryURL, {
attribution: stateImageryATT,
maxZoom: 20
});

var stateParcelURL = 'https://services2.arcgis.com/XVOqAjTOJ5P6ngMu/arcgis/rest/services/Hosted_Parcels_Test_WebMer_20201016/FeatureServer/0/';
var stateParcelATT = 'Parcel map: <a href="https://newjersey.maps.arcgis.com/home/item.html?id=8c82b9cd19ef4b2992161c41bab9761c">NJOGIS</a>.';

var stateParcel = L.esri.featureLayer({
url: stateParcelURL,
attribution: stateParcelATT,
style: {
color: 'white'
}
});

var stateBaseMaps = {
"Imagery (State)": stateImagery
};

var stateOverlayMaps = {
"Parcels (State)": stateParcel
};