    <section>
        <h2>Jurisdiction:</h2>
        <div id="map" class="map"></div>
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