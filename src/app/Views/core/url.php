<?php if (is_array($query ?? '') && $query !== []) {
    $title ??= ''; ?>
<section>
    <h2><?= $title ?></h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>URL</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <td><a href="<?= $row->url ?>"><?= $row->url ?></a></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>