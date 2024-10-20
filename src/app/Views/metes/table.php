<?php if (is_array($query ?? '') && $query !== []) {
    $hasLink ??= false;
    $title ??= '';
    ?>
<section>
    <h2><?= $title ?></h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if ($hasLink) { ?>
                    <th>Detail</th>
                <?php } elseif (\App\Controllers\BaseController::isLive()) { ?>
                    <th>ID</th>
                <?php } ?>
                <th>Description</th>
                <th>Type</th>
                <th>Source</th>
                <th>Acres</th>
                <th>Beginning Point</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <?php if ($hasLink) { ?>
                        <td><a href="/<?= \Config\Services::request()->getLocale() ?>/metes/<?= $row->metesdescriptionslug ?>/">View</a></td>
                    <?php } elseif (\App\Controllers\BaseController::isLive()) { ?>
                        <td><?= $row->metesdescriptionid ?></td>
                    <?php } ?>
                    <td><?= $row->metesdescriptionlong ?></td>
                    <td><?= $row->metesdescriptiontype ?></td>
                    <td><?= $row->metesdescriptionsource ?></td>
                    <td><?= ($row->metesdescriptionacres <= 0 ? '' : $row->metesdescriptionacres) ?></td>
                    <td><?= $row->metesdescriptionbeginningpoint ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>