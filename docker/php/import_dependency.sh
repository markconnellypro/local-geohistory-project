#!/bin/bash
source /env/.env
asset_folder=/var/www/html/asset/dependency
license_folder=/license/dependency

curl --create-dirs --output-dir "${asset_folder}" -O "https:/${dependency_c3}/c3.min.css"
curl --create-dirs --output-dir "${asset_folder}" -O "https:/${dependency_c3}/c3.min.js"
curl --create-dirs -o "${license_folder}/c3.txt" "https:/${dependency_c3}/LICENSE"

curl --create-dirs --output-dir "${asset_folder}" -O "https:/${dependency_classybrew}/classybrew.js"
curl --create-dirs -o "${license_folder}/classybrew.txt" "https:/${dependency_classybrew}/../LICENSE.txt"

curl --create-dirs --output-dir "${asset_folder}" -O "https:/${dependency_d3}/d3.min.js"
curl --create-dirs -o "${license_folder}/D3.txt" "https:/${dependency_d3}/../LICENSE"

curl --create-dirs --output-dir "${asset_folder}/css" "https:/${dependency_datatables}/css/dataTables.dataTables.min.css"
curl --create-dirs --output-dir "${asset_folder}/js" "https:/${dependency_datatables}/js/dataTables.min.js"
curl --create-dirs -o "${license_folder}/DataTables.html" "https://datatables.net/license/"
curl --create-dirs -o "${license_folder}/DataTables-MIT.html" "https://datatables.net/license/mit"

curl --create-dirs --output-dir "${asset_folder}" -O "https:/${dependency_html_to_image}/html-to-image.js"
curl --create-dirs -o "${license_folder}/Html to Image.txt" "https:/${dependency_html_to_image}/../LICENSE"

curl --create-dirs --output-dir "${asset_folder}" -O "https:/${dependency_jquery}/jquery.min.js"
curl --create-dirs -o "${license_folder}/JQuery.txt" "https:/${dependency_jquery}/../LICENSE.txt"

curl --create-dirs --output-dir "${asset_folder}/images" "https:/${dependency_leaflet}/images/layers.png"
curl --create-dirs --output-dir "${asset_folder}/images" "https:/${dependency_leaflet}/images/marker-icon.png"
curl --create-dirs --output-dir "${asset_folder}/images" "https:/${dependency_leaflet}/images/marker-shadow.png"
curl --create-dirs --output-dir "${asset_folder}" -O "https:/${dependency_leaflet}/leaflet.css"
curl --create-dirs --output-dir "${asset_folder}" -O "https:/${dependency_leaflet}/leaflet.js"
curl --create-dirs -o "${license_folder}/Leaflet.txt" "https:/${dependency_leaflet}/../LICENSE"

curl --create-dirs --output-dir "${asset_folder}" -O "https:/${dependency_leaflet_fullscreen}/fullscreen.png"
curl --create-dirs --output-dir "${asset_folder}" -O "https:/${dependency_leaflet_fullscreen}/leaflet.fullscreen.css"
curl --create-dirs --output-dir "${asset_folder}" -O "https:/${dependency_leaflet_fullscreen}/Leaflet.fullscreen.min.js"
curl --create-dirs -o "${license_folder}/Leaflet.fullscreen.txt" "https:/${dependency_leaflet_fullscreen}/../LICENSE"

curl --create-dirs --output-dir "${asset_folder}" -O "https:/${dependency_maplibre_gl}/maplibre-gl.css"
curl --create-dirs --output-dir "${asset_folder}" -O "https:/${dependency_maplibre_gl}/maplibre-gl.js"
curl --create-dirs -o "${license_folder}/MapLibre GL JS.txt" "https:/${dependency_maplibre_gl}/../LICENSE.txt"

curl --create-dirs --output-dir "${asset_folder}" -O "https:/${dependency_maplibre_gl_leaflet}/leaflet-maplibre-gl.js"
curl --create-dirs -o "${license_folder}/Leaflet MapLibre GL.txt" "https:/${dependency_maplibre_gl}/LICENSE"

curl --create-dirs --output-dir "${asset_folder}" -O "https:/${dependency_pmtiles}/pmtiles.js"
curl --create-dirs -o "${license_folder}/PMTiles.txt" "https://raw.githubusercontent.com/protomaps/PMTiles/main/LICENSE"

curl --create-dirs --output-dir "${asset_folder}/css" "https:/${dependency_selectize}/css/selectize.css"
curl --create-dirs --output-dir "${asset_folder}/js/standalone" "https:/${dependency_selectize}/js/standalone/selectize.min.js"
curl --create-dirs -o "${license_folder}/Selectize.txt" "https:/${dependency_selectize}/../LICENSE"
