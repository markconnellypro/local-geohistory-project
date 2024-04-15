<?php /* Verified May 11, 2023 */ ?>

var stateImageryURL = 'https://imagery.pasda.psu.edu/arcgis/services/pasda/PEMAImagery2018_2020/MapServer/WMSServer';
var stateImageryATT = 'Base map: <a href="https://www.pasda.psu.edu/uci/DataSummary.aspx?dataset=5158">PASDA</a>.';

var stateImagery = L.tileLayer.wms(stateImageryURL, {
layers: "1",
attribution: stateImageryATT,
maxZoom: 20
});

var stateParcelURL = 'https://apps.pasda.psu.edu/arcgis/services/PA_Parcels_Vector/MapServer/WMSServer';
var stateParcelATT = 'Parcels: <a href="https://www.pasda.psu.edu/uci/DataSummary.aspx?dataset=1696">PASDA</a>.';

var stateParcel = L.tileLayer.wms(stateParcelURL, {
layers: "1",
transparent: true,
format: "image/png",
attribution: stateParcelATT,
minZoom: 12
});

var stateBaseMaps = {
"Imagery (State)": stateImagery
};

var stateOverlayMaps = {
"Parcels (State)": stateParcel
};