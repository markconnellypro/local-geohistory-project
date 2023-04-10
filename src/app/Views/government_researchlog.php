<section>
    <h2>Research Log</h2>
    <table class="normal row-border cell-border compact stripe">
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
                <tr<?= ($row->researchlogismissing == 't' ? ' class="warning"' : '') ?>>
                    <?php if ($isMultiple) { ?>
                        <td><?= $row->governmentlong ?></td>
                    <?php } ?>
                    <td>
                        <span class="b"><?= $row->researchlogtypelong . ($row->researchlognotes == '' ? '</span>' :
                                            ':</span> ' . $row->researchlognotes) ?>
                    </td>
                    <td data-sort="<?= $row->researchlogdatesort ?>"><?= $row->researchlogdate ?></td>
                    <td data-sort="<?= $row->researchlogrange ?>">
                        <?= ($row->researchlogvolume == '' ? '' : 'bk. ') . $row->researchlogvolume .
                            ($row->researchlogrange == '' ? '' : ' (' . $row->researchlogrange . ')') ?>
                    </td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>