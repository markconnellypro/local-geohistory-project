<section>
    <h2>Summarized Source Data</h2>
    <table class="normal row-border cell-border compact stripe">
        <thead>
            <tr>
                <th>Type</th>
                <th>Summary</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <td><?= (($row->sourcecitationnoteorder < 1) ? '' : '(#' . $row->sourcecitationnoteorder . ') ') . $row->sourcecitationnotekey ?></td>
                    <td><?= $row->sourcecitationnotevalue ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>