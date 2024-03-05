<link rel="stylesheet" href="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_c3') : 'asset/dependency') ?>/c3.min.css" crossorigin="anonymous">
<script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_d3') : 'asset/dependency') ?>/d3.min.js"></script>
<script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_c3') : 'asset/dependency') ?>/c3.min.js"></script>
<script>
    var columnData = [<?php
                        foreach ($query as $row) {
                            echo $row->datarow . ",\r\n";
                        }
?>];

    var xLabel = "<?= $xLabel ?>";
    var yLabel = "<?= $yLabel ?>";
    var showLegend = <?= (count($query) == 2 ? 'false' : 'true') ?>;
</script>
<script src="/asset/map/chart.js"></script>