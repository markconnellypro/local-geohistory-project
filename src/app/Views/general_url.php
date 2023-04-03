<section>
    <h2><?= $title ?></h2>
    <table class="normal row-border cell-border compact stripe">
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