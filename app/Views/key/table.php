<?php if (is_array($query ?? '') && $query !== []) {
    $title ??= '';
    $type ??= '';
    ?>
<section id="<?= $type ?>">
    <h2><?= $title ?></h2>
    <?php if (isset($query['Text'])) {
        echo $query['Text']->keylong;
        unset($query['Text']);
    } if (count($query) > 0) { 
?>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>Term</th>
                <th>Description</th>
                <?php if ($type === 'EventType') { ?>
                    <th>Only<br>Border<br>Changes?</th>
                <?php } ?>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <td data-sort="<?= $row->keysort ?>" <?= (isset($row->keycolor) && $row->keycolor !== '' ? ' style="background-color: ' . $row->keycolor . '"' : '') ?>><?= $row->keyshort ?></td>
                    <td><?= $row->keylong ?></td>
                    <?php if ($type === 'EventType') { ?>
                        <td><?= $row->keyincluded ?></td>
                    <?php } ?>
                </tr>
            <?php } ?>
        </tbody>
    </table>
<?php } ?>
</section>
<?php } ?>