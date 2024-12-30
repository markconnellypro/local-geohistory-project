<?php $jurisdictions ??= []; ?>
    <section>
        <h2>Jurisdiction:</h2>
        <style>
            @media screen and (max-width: 499px) {
                #map {
                    height: 370px;
                }
            }
            @media screen and (min-width: 500px) and (max-width: 649px) {
                #map {
                    height: 470px;
                }
            }
            @media screen and (min-width: 650px) and (max-width: 799px) {
                #map {
                    height: 570px;
                }
            }
            @media screen and (min-width: 800px) {
                #map {
                    height: 670px;
                }
            }
        </style>
        <div id="map" class="map" style="margin: 0 auto;"></div>
    </section>
    <section>
        <h2>Detail:</h2>
        <div id="status-task"></div>
    </section>
    <script>
        var mapPath = [
            '/asset/application/map/statistics/development.geojson'
        ];
        var partData = <?= json_encode($jurisdictions) ?>;
        var lastLayer = "";
    </script>
    <?= view('leaflet/source'); ?>
    <style>
        .leaflet-container {
            background-color: rgba(255, 0, 0, 0.0);
        }
    </style>
    <script src="/asset/application/map/status.js"></script>