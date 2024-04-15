<?php if (is_array($query ?? '') && $query !== []) { ?>
<section>
    <h2>Authorship</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>Reporter</th>
                <th>Opinion Adjudicator(s)</th>
                <th>Dissenting Adjudicator(s)</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <td><?= $row->adjudicationsourcecitationauthor ?></td>
                    <td><?= $row->adjudicationsourcecitationjudge ?></td>
                    <td><?= $row->adjudicationsourcecitationdissentjudge ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>