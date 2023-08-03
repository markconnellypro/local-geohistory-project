<?php if (count($wholeQuery) > 0) { ?>
    <section>
        <h2>By Jurisdiction:</h2>
        <div id="map" class="map"></div>
    </section>
    <section>
        <h2>By Year: <a href="#" class="chartdownload"><img style="vertical-align: middle;" src="/asset/map/baseline_save_alt_black_24dp.png" alt="Download" /></a></h2>
        <div id="chart" class="chart"></div>
    </section>
    <section>
        <h2>Notes:</h2>
        <ol id="notes">
            <li>Data presented may be incomplete due to missing information or due to certain events being outside of the scope of the project.</li>
            <li>Only information for events determined to be successful is presented.</li>
            <li>See the <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#date">Date section of the Key</a> for more information on how dates are determined.</li>
            <?php if ($isContemporaneous) { ?>
                <li>Jurisdictions used for statistical purposes are those that existed at the time of the pertinent events.</li>
                <?php if ($notEvent) { ?>
                    <li>Creation and dissolution events include changes in the names of municipalities, and may include certain changes in municipalities' forms of government.</li>
                    <li>If a parent jurisdiction boundary change occurred as part of a creation or dissolution event, the parent jurisdictions immediately before dissolution or after creation are used.</li>
            <?php }
            } ?>
        </ol>
    </section>
    <script>
        var mapPath = [
            <?php if ($state == 'ma' and (empty($dateRange) or substr($dateRange, 0, 4) < '1821')) { ?> '/asset/development/map/statistics/me.geojson',
            <?php } ?> '/asset/<?= (($live and (empty($state) or !in_array($state, \App\Controllers\BaseController::getProductionJurisdictions()))) ? 'development/' : '') ?>map/statistics/<?= (empty($state) ? ($live ? 'development' : 'production') : $state) ?>.geojson'
        ];
        var partData = <?= $query ?>;
        var lastLayer = "";
    </script>
    <?= view('leaflet_source'); ?>
    <style>
        .leaflet-container {
            background-color: rgba(255, 0, 0, 0.0);
        }
    </style>
    <!-- https://github.com/tannerjt/classybrew/blob/master/src/classybrew.js -->
    <script src="/asset/map/classybrew.js"></script>
    <script src="/asset/map/statistics.js"></script>
<?php } else { ?>
    <br />No results found!
<?php } ?>