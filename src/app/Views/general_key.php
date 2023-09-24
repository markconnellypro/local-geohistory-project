<section>
    <h2 id="<?= $type ?>"><?= $title ?></h2>
    <?php if ($type == 'law') {
        echo view('key_law');
    } ?>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>Term</th>
                <th>Description</th>
                <?php if ($type == 'eventtype') { ?>
                    <th>Only<br>Border<br>Changes?</th>
                <?php } ?>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <td data-sort="<?= $row->keysort ?>" <?= (isset($row->keycolor) ? ' style="background-color: ' . $row->keycolor . '"' : '') ?>><?= $row->keyshort ?></td>
                    <td><?= $row->keylong ?></td>
                    <?php if ($type == 'eventtype') { ?>
                        <td><?= $row->keyincluded ?></td>
                    <?php } ?>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>