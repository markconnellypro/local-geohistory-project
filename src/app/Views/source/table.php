<?php if (is_array($query ?? '') && $query !== []) {
    $hasLink ??= false; ?>
<section>
    <h2>Source</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if ($hasLink) { ?>
                    <th>Detail</th>
                <?php } ?>
                <th>Abbreviation</th>
                <th>Type</th>
                <th>Citation</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <?php if ($hasLink) { ?>
                        <td><a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $row->linktype ?>/<?= $row->sourceid ?>/">View</a></td>
                    <?php } ?>
                    <td><?= $row->sourceabbreviation ?></td>
                    <td><?= $row->sourcetype ?></td>
                    <td><?= $row->sourcefullcitation ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>