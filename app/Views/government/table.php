<?php if (is_array($query ?? '') && $query !== []) {
    $title ??= '';
    $type ??= '';
    ?>
<section>
    <h2><?= $title ?></h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>Name</th>
                <?php if ($type !== 'government') { ?>
                    <th>Relationship <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventrelationship" aria-label="Relationship Key" title="Relationship Key"><span class="keyiconfill">vpn_key</span></a></th>
                <?php } ?>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <td><?php echo view('core/link', [
                        'type' => 'government',
                        'link' => $row->governmentslug,
                        'text' => $row->governmentlong,
                    ]) ?></td>
                    <?php if ($type !== 'government') { ?>
                        <td><?= $row->governmentparentstatus ?></td>
                    <?php } ?>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>