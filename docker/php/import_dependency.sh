#!/bin/bash
source /env/.env
asset_folder=/var/www/html/asset/dependency
license_folder=/license/dependency

curl -s -S --output-dir ${asset_folder} -O "https:/${dependency_c3}/c3.min.css"
curl -s -S --output-dir ${asset_folder} -O "https:/${dependency_c3}/c3.min.js"
curl -s -S -o "${license_folder}/c3.txt" "https:/${dependency_c3}/LICENSE"

curl -s -S --output-dir ${asset_folder} -O "https:/${dependency_classybrew}/classybrew.js"
curl -s -S -o "${license_folder}/classybrew.txt" "https:/${dependency_classybrew}/../LICENSE.txt"

curl -s -S --output-dir ${asset_folder} -O "https:/${dependency_d3}/d3.min.js"
curl -s -S -o "${license_folder}/D3.txt" "https:/${dependency_d3}/../LICENSE"

curl -s -S -o ${asset_folder}/css/dataTables.dataTables.min.css "https:/${dependency_datatables}/css/dataTables.dataTables.min.css"
curl -s -S -o ${asset_folder}/js/dataTables.min.js "https:/${dependency_datatables}/js/dataTables.min.js"
curl -s -S -o "${license_folder}/DataTables.html" "https://datatables.net/license/"
curl -s -S -o "${license_folder}/DataTables-MIT.html" "https://datatables.net/license/mit"

curl -s -S --output-dir ${asset_folder} -O "https:/${dependency_html_to_image}/html-to-image.js"
curl -s -S -o "${license_folder}/Html to Image.txt" "https:/${dependency_html_to_image}/../LICENSE"

curl -s -S --output-dir ${asset_folder} -O "https:/${dependency_jquery}/jquery.min.js"
curl -s -S -o "${license_folder}/JQuery.txt" "https:/${dependency_jquery}/../LICENSE.txt"

curl -s -S -o ${asset_folder}/images/layers.png "https:/${dependency_leaflet}/images/layers.png"
curl -s -S -o ${asset_folder}/images/marker-icon.png "https:/${dependency_leaflet}/images/marker-icon.png"
curl -s -S -o ${asset_folder}/images/marker-shadow.png "https:/${dependency_leaflet}/images/marker-shadow.png"
curl -s -S --output-dir ${asset_folder} -O "https:/${dependency_leaflet}/leaflet.css"
curl -s -S --output-dir ${asset_folder} -O "https:/${dependency_leaflet}/leaflet.js"
curl -s -S -o "${license_folder}/Leaflet.txt" "https:/${dependency_leaflet}/../LICENSE"

curl -s -S --output-dir ${asset_folder} -O "https:/${dependency_leaflet_fullscreen}/fullscreen.png"
curl -s -S --output-dir ${asset_folder} -O "https:/${dependency_leaflet_fullscreen}/leaflet.fullscreen.css"
curl -s -S --output-dir ${asset_folder} -O "https:/${dependency_leaflet_fullscreen}/Leaflet.fullscreen.min.js"
curl -s -S -o "${license_folder}/Leaflet.fullscreen.txt" "https:/${dependency_leaflet_fullscreen}/../LICENSE"

curl -s -S --output-dir ${asset_folder} -O "https:/${dependency_maplibre_gl}/maplibre-gl.css"
curl -s -S --output-dir ${asset_folder} -O "https:/${dependency_maplibre_gl}/maplibre-gl.js"
curl -s -S -o "${license_folder}/MapLibre GL JS.txt" "https:/${dependency_maplibre_gl}/../LICENSE.txt"

curl -s -S --output-dir ${asset_folder} -O "https:/${dependency_maplibre_gl_leaflet}/leaflet-maplibre-gl.js"
curl -s -S -o "${license_folder}/Leaflet MapLibre GL.txt" "https:/${dependency_maplibre_gl}/LICENSE"

curl -s -S --output-dir ${asset_folder} -O "https:/${dependency_pmtiles}/pmtiles.js"
curl -s -S -o "${license_folder}/PMTiles.txt" "https://raw.githubusercontent.com/protomaps/PMTiles/main/LICENSE"

curl -s -S -o ${asset_folder}/css/selectize.css "https:/${dependency_selectize}/css/selectize.css"
curl -s -S -o ${asset_folder}/js/standalone/selectize.min.js "https:/${dependency_selectize}/js/standalone/selectize.min.js"
curl -s -S -o "${license_folder}/Selectize.txt" "https:/${dependency_selectize}/../LICENSE"
