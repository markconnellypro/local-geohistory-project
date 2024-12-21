<?php if (is_array($query ?? '') && $query !== []) {
    $isMultiple ??= false; ?>
<section>
    <h2>Research Log</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if ($isMultiple) { ?>
                    <th>Government</th>
                <?php } ?>
                <th>Type/Notes</th>
                <th>Log Date</th>
                <th>Coverage</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr<?= ($row->researchlogismissing === 't' ? ' class="warning"' : '') ?>>
                    <?php if ($isMultiple) { ?>
                        <td><?= $row->governmentlong ?></td>
                    <?php } ?>
                    <td>
                        <span class="b"><?= $row->researchlogtypelong . ($row->researchlognotes === '' ? '</span>' :
                                            ':</span> ' . $row->researchlognotes) ?>
                    </td>
                    <td data-sort="<?= $row->researchlogdatesort ?>"><?= $row->researchlogdate ?></td>
                    <td data-sort="<?= $row->researchlogyear ?>">
                        <?= ($row->researchlogvolume === '' ? '' : 'bk. ') . $row->researchlogvolume .
                            ($row->researchlogyear === '' ? '' : ' (' . $row->researchlogyear . ')') ?>
                    </td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>