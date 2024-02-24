#!/bin/bash
asset_folder=/var/www/html/asset/dependency
license_folder=/license/dependency

curl --create-dirs --output-dir "${asset_folder}" -O "/${dependency_c3}/c3.min.css"
curl --create-dirs --output-dir "${asset_folder}" -O "/${dependency_c3}/c3.min.js"
curl --create-dirs -o "${license_folder}/c3.txt" "/${dependency_c3}/LICENSE"

curl --create-dirs --output-dir "${asset_folder}" -O "/${dependency_classybrew}/classybrew.js"
curl --create-dirs -o "${license_folder}/classybrew.txt" "/${dependency_classybrew}/../LICENSE.txt"

curl --create-dirs --output-dir "${asset_folder}" -O "/${dependency_d3}/d3.min.js"
curl --create-dirs -o "${license_folder}/D3.txt" "/${dependency_d3}/../LICENSE"

curl --create-dirs --output-dir "${asset_folder}/css" "/${dependency_datatables}/css/dataTables.dataTables.min.css"
curl --create-dirs --output-dir "${asset_folder}/js" "/${dependency_datatables}/js/dataTables.min.js"
curl --create-dirs -o "${license_folder}/DataTables.html" "https://datatables.net/license/"
curl --create-dirs -o "${license_folder}/DataTables-MIT.html" "https://datatables.net/license/mit"

curl --create-dirs --output-dir "${asset_folder}" -O "/${dependency_html-to-image}/html-to-image.js"
curl --create-dirs -o "${license_folder}/Html to Image.txt" "/${dependency_html-to-image}/../LICENSE"

curl --create-dirs --output-dir "${asset_folder}" -O "/${dependency_jquery}/jquery.min.js"
curl --create-dirs -o "${license_folder}/JQuery.txt" "/${dependency_jquery}/../LICENSE.txt"

curl --create-dirs --output-dir "${asset_folder}/images" "/${dependency_leaflet}/images/layers.png"
curl --create-dirs --output-dir "${asset_folder}/images" "/${dependency_leaflet}/images/marker-icon.png"
curl --create-dirs --output-dir "${asset_folder}/images" "/${dependency_leaflet}/images/marker-shadow.png"
curl --create-dirs --output-dir "${asset_folder}" -O "/${dependency_leaflet}/leaflet.css"
curl --create-dirs --output-dir "${asset_folder}" -O "/${dependency_leaflet}/leaflet.js"
curl --create-dirs -o "${license_folder}/Leaflet.txt" "/${dependency_leaflet}/../LICENSE"

curl --create-dirs --output-dir "${asset_folder}" -O "/${dependency_leaflet-fullscreen}/fullscreen.png"
curl --create-dirs --output-dir "${asset_folder}" -O "/${dependency_leaflet-fullscreen}/leaflet.fullscreen.css"
curl --create-dirs --output-dir "${asset_folder}" -O "/${dependency_leaflet-fullscreen}/Leaflet.fullscreen.min.js"
curl --create-dirs -o "${license_folder}/Leaflet.fullscreen.txt" "/${dependency_leaflet-fullscreen}/../LICENSE"

curl --create-dirs --output-dir "${asset_folder}" -O "/${dependency_maplibre-gl}/maplibre-gl.css"
curl --create-dirs --output-dir "${asset_folder}" -O "/${dependency_maplibre-gl}/maplibre-gl.js"
curl --create-dirs -o "${license_folder}/MapLibre GL JS.txt" "/${dependency_maplibre-gl}/../LICENSE.txt"

curl --create-dirs --output-dir "${asset_folder}" -O "/${dependency_maplibre-gl-leaflet}/leaflet-maplibre-gl.js"
curl --create-dirs -o "${license_folder}/Leaflet MapLibre GL.txt" "/${dependency_maplibre-gl}/LICENSE"

curl --create-dirs --output-dir "${asset_folder}" -O "/${dependency_pmtiles}/pmtiles.js"
curl --create-dirs -o "${license_folder}/PMTiles.txt" "https://raw.githubusercontent.com/protomaps/PMTiles/main/LICENSE"

curl --create-dirs --output-dir "${asset_folder}/css" "/${dependency_selectize}/css/selectize.css"
curl --create-dirs --output-dir "${asset_folder}/js/standalone" "/${dependency_selectize}/js/standalone/selectize.min.js"
curl --create-dirs -o "${license_folder}/Selectize.txt" "/${dependency_selectize}/../LICENSE"
