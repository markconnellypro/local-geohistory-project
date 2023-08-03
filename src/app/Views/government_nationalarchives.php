<section>
    <h2>National Archives</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>Detail</th>
                <?php if ($isMultiple) { ?>
                    <th>Government</th>
                <?php } ?>
                <th>Source</th>
                <th>Set</th>
                <th>Description</th>
                <th>File Unit</th>
                <th>From</th>
                <th>To</th>
                <?php if ($live) { ?>
                    <th>Examined?</th>
                <?php } ?>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <td><?php if ($row->url <> '') { ?><a href="<?= $row->url ?>">View</a><?php } ?></td>
                    <?php if ($isMultiple) { ?>
                        <td><?= $row->governmentlong ?></td>
                    <?php } ?>
                    <td><?= $row->sourceabbreviation ?></td>
                    <td><?= $row->nationalarchivesset ?></td>
                    <td><?= $row->nationalarchivesgovernment ?></td>
                    <td><?= $row->nationalarchivesunit ?></td>
                    <td><?= $row->nationalarchivesunitfrom ?></td>
                    <td><?= $row->nationalarchivesunitto ?></td>
                    <?php if ($live) { ?>
                        <td><?= ($row->nationalarchivesexamined == 't' ? 'yes' : 'no') ?></td>
                    <?php } ?>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>