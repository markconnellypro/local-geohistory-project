<?php if (is_array($wholeQuery ?? '') && $wholeQuery !== []) {
    $dateRange ??= '';
    $isContemporaneous ??= true;
    $notEvent ??= true;
    $query ??= '{}';
    $jurisdiction ??= '';
    ?>
    <section>
        <h2>By Jurisdiction:</h2>
        <div id="map" class="map"></div>
    </section>
    <section>
        <h2>By Year: <a href="#" class="chartdownload" aria-label="Download" title="Download"><span class="statisticsicon">download</span></a></h2>
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
            '/asset/<?= ((\App\Controllers\BaseController::isLive() && ($jurisdiction !== '' && !in_array($jurisdiction, \App\Controllers\BaseController::getProductionJurisdictions()))) ? 'development' : 'application') ?>/map/statistics/<?= ($jurisdiction === '' ? (\App\Controllers\BaseController::isLive() ? 'development' : 'production') : $jurisdiction) ?>.geojson'
        ];
        var partData = <?= $query ?>;
        var lastLayer = "";
    </script>
    <?= view('leaflet/source'); ?>
    <style>
        .leaflet-container {
            background-color: rgba(255, 0, 0, 0.0);
        }
    </style>
    <script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_classybrew') : 'asset/application/dependency') ?>/classybrew.js"></script>
    <script src="/asset/application/map/statistics.js"></script>
<?php } else { ?>
    <br>No results found!
<?php } ?>