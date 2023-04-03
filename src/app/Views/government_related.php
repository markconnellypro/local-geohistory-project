<section>
    <h2>Related</h2>
    <table class="normal row-border cell-border compact stripe">
        <thead>
            <tr>
                <th>Government</th>
                <th>Relationship</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <td class="folder<?= ($live ? $row->governmentcolor : 'none') ?>"><?php echo view('general_link', ['link' => $row->governmentstatelink, 'text' => $row->governmentlong]) ?></td>
                    <td class="folder<?= ($live ? $row->governmentcolor : 'none') ?>"><?= $row->governmentrelationship ?></td>
                    <td class="folder<?= ($live ? $row->governmentcolor : 'none') ?>"><?= $row->governmentparentstatus ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>