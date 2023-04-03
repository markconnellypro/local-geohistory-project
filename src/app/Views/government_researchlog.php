<section>
    <h2>Research Log</h2>
    <table class="normal row-border cell-border compact stripe">
        <thead>
            <tr>
                <th>Detail</th>
                <?php if ($isMultiple) { ?>
                    <th>Government</th>
                <?php } ?>
                <th>Type/Notes</th>
                <th>Log Date</th>
                <th>Coverage</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) {
                $handleArray = str_getcsv(str_replace(['{', '}'], '', $row->internetarchivehandle), ',', "'");
            ?>
                <tr<?= ($row->researchlogismissing == 't' ? ' class="warning"' : '') ?>>
                    <td><?php if (!empty($handleArray[0])) {
                            foreach ($handleArray as $h) { ?>
                                <a href="https://archive.org/details/<?= $h ?>">View</a><br />
                        <?php }
                        } ?>
                    </td>
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