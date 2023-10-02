<link rel="stylesheet" href="/<?= ($online ? '/unpkg.com/c3@0.7.20' : 'asset/tool/css') ?>/c3.min.css" crossorigin="anonymous">
<script src="/<?= ($online ? '/unpkg.com/d3@5.16.0/dist' : 'asset/tool/js') ?>/d3.min.js"></script>
<script src="/<?= ($online ? '/unpkg.com/c3@0.7.20' : 'asset/tool/js') ?>/c3.min.js"></script>
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