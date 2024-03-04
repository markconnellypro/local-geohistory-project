<section>
    <h2>Survey System</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>Township</th>
                <th>First Division</th>
                <th>Part</th>
                <th>Relationship <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventrelationship" aria-label="Relationship Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
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