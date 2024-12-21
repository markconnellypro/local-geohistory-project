<?php if (is_array($query ?? '') && $query !== []) { ?>
<section>
    <h2>Filings</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>Type/Detail</th>
                <th>Date</th>
                <th>Filed</th>
                <th>Other</th>
                <th>Notes</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr<?= ($row->filingnotpresent === 't' ? ' style="color: red;"' : '') ?>>
                    <td><span class="b"><?= $row->filingtypelong . ($row->filingspecific !== '' ?
                                            ':</span> ' . $row->filingspecific :
                                            '</span>') ?></td>
                    <td data-sort="<?= $row->filingdatesort ?>"><?= $row->filingdate ?></td>
                    <td data-sort="<?= $row->filingfiledsort ?>"><?= $row->filingfiled ?></td>
                    <td data-sort="<?= $row->filingothersort ?>"><?= $row->filingothertype . ' ' . $row->filingother ?></td>
                    <td><?= $row->filingnotes ?></td>
                    </tr>
                <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>