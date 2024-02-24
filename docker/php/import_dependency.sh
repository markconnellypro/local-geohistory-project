#!/bin/bash
asset_folder=./src/html/asset/dependency
license_folder=./license/dependency

wget "/${dependency_c3}/c3.min.css" -P "${asset_folder}"
wget "/${dependency_c3}/c3.min.js" -P "${asset_folder}"
wget "/${dependency_c3}/LICENSE" -O "${license_folder}/c3.txt"

wget "/${dependency_classybrew}/classybrew.js" -P "${asset_folder}"
wget "/${dependency_classybrew}/../LICENSE.txt" -O "${license_folder}/classybrew.txt"

wget "/${dependency_d3}/d3.min.js" -P "${asset_folder}"
wget "/${dependency_d3}/../LICENSE" -O "${license_folder}/D3.txt"

wget "/${dependency_datatables}/css/dataTables.dataTables.min.css" -P "${asset_folder}/css"
wget "/${dependency_datatables}/js/dataTables.min.js" -P "${asset_folder}/js"
wget "https://datatables.net/license/" -O "${license_folder}/DataTables.html"
wget "https://datatables.net/license/mit" -O "${license_folder}/DataTables-MIT.html"

wget "/${dependency_html-to-image}/html-to-image.js" -P "${asset_folder}"
wget "/${dependency_html-to-image}/../LICENSE" -O "${license_folder}/Html to Image.txt"

wget "/${dependency_jquery}/jquery.min.js" -P "${asset_folder}"
wget "/${dependency_jquery}/../LICENSE.txt" -O "${license_folder}/JQuery.txt"

wget "/${dependency_leaflet}/images/layers.png" -P "${asset_folder}/images"
wget "/${dependency_leaflet}/images/marker-icon.png" -P "${asset_folder}/images"
wget "/${dependency_leaflet}/images/marker-shadow.png" -P "${asset_folder}/images"
wget "/${dependency_leaflet}/leaflet.css" -P "${asset_folder}"
wget "/${dependency_leaflet}/leaflet.js" -P "${asset_folder}"
wget "/${dependency_leaflet}/../LICENSE" -O "${license_folder}/Leaflet.txt"

wget "/${dependency_leaflet-fullscreen}/fullscreen.png" -P "${asset_folder}"
wget "/${dependency_leaflet-fullscreen}/leaflet.fullscreen.css" -P "${asset_folder}"
wget "/${dependency_leaflet-fullscreen}/Leaflet.fullscreen.min.js" -P "${asset_folder}"
wget "/${dependency_leaflet-fullscreen}/../LICENSE" -O "${license_folder}/Leaflet.fullscreen.txt"

wget "/${dependency_maplibre-gl}/maplibre-gl.css" -P "${asset_folder}"
wget "/${dependency_maplibre-gl}/maplibre-gl.js" -P "${asset_folder}"
wget "/${dependency_maplibre-gl}/../LICENSE.txt" -O "${license_folder}/MapLibre GL JS.txt"

wget "/${dependency_maplibre-gl-leaflet}/leaflet-maplibre-gl.js" -P "${asset_folder}"
wget "/${dependency_maplibre-gl}/LICENSE" -O "${license_folder}/Leaflet MapLibre GL.txt"

wget "/${dependency_pmtiles}/pmtiles.js" -P "${asset_folder}"
wget "https://raw.githubusercontent.com/protomaps/PMTiles/main/LICENSE" -O "${license_folder}/PMTiles.txt"

wget "/${dependency_selectize}/css/selectize.css" -P "${asset_folder}/css"
wget "/${dependency_selectize}/js/standalone/selectize.min.js" -P "${asset_folder}/js/standalone"
wget "/${dependency_selectize}/../LICENSE" -O "${license_folder}/Selectize.txt"
