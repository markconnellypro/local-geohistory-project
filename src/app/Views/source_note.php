<?php if (is_array($query ?? '') && $query !== []) { ?>
<section>
    <h2>Summarized Source Data</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>Type</th>
                <th>Summary</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <td><?= (($row->sourcecitationnotegroup < 1) ? '' : '(#' . $row->sourcecitationnotegroup . ') ') . $row->sourcecitationnotetypetext ?></td>
                    <td><?= $row->sourcecitationnotetext ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>