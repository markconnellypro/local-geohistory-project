<?php /* Verified May 11, 2023 */ ?>

var stateImageryNjUrl = 'https://maps.nj.gov/arcgis/rest/services/Basemap/Orthos_Natural_2020_NJ_WM/MapServer/tile/{z}/{y}/{x}';
var stateImageryNjAtt = 'Base map: <a href="https://newjersey.maps.arcgis.com/home/item.html?id=5d558e0ad9274c558ce2cabd19afaed9">NJOGIS</a>.';

var stateImageryNj = L.tileLayer(stateImageryNjUrl, {
attribution: stateImageryNjAtt,
maxZoom: 20
});

stateBaseMaps["Imagery (NJ)"] = stateImageryNj;

var stateParcelNjUrl = 'https://services2.arcgis.com/XVOqAjTOJ5P6ngMu/arcgis/rest/services/Hosted_Parcels_Test_WebMer_20201016/FeatureServer/0/';
var stateParcelNjAtt = 'Parcel map: <a href="https://njogis-newjersey.opendata.arcgis.com/datasets/newjersey::parcels-and-mod-iv-composite-of-nj-web-mercator-3857/about">NJOGIS</a>.';

var stateParcelNj = L.esri.featureLayer({
url: stateParcelNjUrl,
attribution: stateParcelNjAtt,
style: {
fillOpacity: 0,
color: 'black',
weight: 1
}
});

stateOverlayMaps["Parcels (NJ)"] = stateParcelNj;