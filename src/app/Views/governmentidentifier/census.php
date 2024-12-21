<?php if (is_array($query ?? '') && $query !== []) {
    $type ??= ''; ?>
<section>
    <h2>Census Gazetteer</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if ($type === 'usgs') { ?>
                    <th>Type</th>
                <?php } ?>
                <th>From</th>
                <th>To</th>
                <th>Name</th>
                <th>Related Identifier</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <?php if ($type === 'usgs') { ?>
                        <td><?= $row->gazetteertype ?></td>
                    <?php } ?>
                    <td><?= $row->gazetteerfrom ?></td>
                    <td><?= $row->gazetteerto ?></td>
                    <td><?= $row->governmentfullname ?></td>
                    <td><?= $row->governmentidentifier ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>