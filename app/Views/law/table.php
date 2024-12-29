<?php if (is_array($query ?? '') && $query !== []) {
    $title ??= '';
    $type ??= '';
    ?>
<section>
    <?php if (!isset($omitTitle)) { ?>
        <h2><?= $title ?></h2>
    <?php } ?>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>Detail</th>
                <th>Citation <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#law" aria-label="Law Key" title="Law Key"><span class="keyiconfill">vpn_key</span></a></th>
                <th><?php if ($type === 'relationship') {
                    if (isset($includeLawGroup)) { ?>
                        Group</th>
                        <th><?php } ?>Relationship <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventrelationship" aria-label="Relationship Key" title="Relationship Key"><span class="keyiconfill">vpn_key</span></a>
                    <?php } else { ?>
                        Type
                    <?php } ?>
                </th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <td><a href="/<?= \Config\Services::request()->getLocale() ?>/law/<?= $row->lawsectionslug ?>/"><?= ($row->lawsectionslug === '' ? '' : 'View') ?></a></td>
                    <td data-sort="<?= $row->lawapproved ?>"><?= $row->lawsectioncitation ?></td>
                    <?php if ($type === 'relationship' && isset($includeLawGroup)) { ?>
                        <td><?= $row->lawgrouplong ?></td>
                    <?php } ?>
                    <td><?= (($type === 'relationship') ? $row->lawsectioneventrelationship : $row->eventtypeshort) ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>