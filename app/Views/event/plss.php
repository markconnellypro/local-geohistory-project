<?php if (is_array($query ?? '') && $query !== []) { ?>
<section>
    <h2>Survey System</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>Township</th>
                <th>First Division</th>
                <th>Part</th>
                <th>Relationship <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventrelationship" aria-label="Relationship Key" title="Relationship Key"><span class="keyiconfill">vpn_key</span></a></th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { /* Need to add support for second division and special survey */ ?>
                <tr>
                    <td><?= $row->plsstownship ?></td>
                    <td><?= $row->plssfirstdivision ?></td>
                    <td><?= $row->plssfirstdivisionpart ?></td>
                    <td><?= $row->plssrelationship ?></td>
                </tr>
<?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>