<?php if (is_array($query ?? '') && $query !== []) {
    $title ??= ''; ?>
<section>
    <h2><?= $title ?></h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if ($title !== 'Detail') { ?>
                    <th>Detail</th>
                <?php }
                if (isset($isMultiple) && !$isMultiple) { ?>
                    <th>Government</th>
                <?php } ?>
                <th>Type</th>
                <th>Source</th>
                <th>Identifier</th>
                <?php if ($title === 'Identifier') { ?>
                    <th>Relationship</th>
                <?php } ?>
                <th>Web Link</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <?php if ($title !== 'Detail') { ?>
                        <td><a href="/<?= \Config\Services::request()->getLocale() ?>/governmentidentifier/<?= $row->governmentidentifiertypeslug . '/' . strtolower($row->governmentidentifier) ?>/">View</a></td>
                    <?php }
                    if (isset($isMultiple) && !$isMultiple) { ?>
                        <td><?= $row->governmentlong ?></td>
                    <?php } ?>
                    <td><?= $row->governmentidentifiertypetype ?></td>
                    <td><?= $row->governmentidentifiertypeshort ?></td>
                    <td><?= $row->governmentidentifier ?></td>
                    <?php if ($title === 'Identifier') { ?>
                        <td><?= $row->governmentidentifierstatus ?></td>
                    <?php } ?>
                    <td><?= ($row->governmentidentifiertypeurl === '' ? '' : '<a href="' . $row->governmentidentifiertypeurl . '">View</a>') ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>