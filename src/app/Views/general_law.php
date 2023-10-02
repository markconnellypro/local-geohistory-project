<section>
    <?php if (!isset($omitTitle)) { ?>
        <h2><?= $title ?></h2>
    <?php } ?>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>Detail</th>
                <th>Citation <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#law" aria-label="Law Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
                <th><?php if ($type == 'relationship') {
                    if (isset($includeLawGroup)) { ?>
                        Group</th>
                        <th><?php } ?>Relationship <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventrelationship" aria-label="Relationship Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a>
                    <?php } else { ?>
                        Type
                    <?php } ?>
                </th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <td><a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/law/<?= $row->lawsectionslug ?>/"><?= (empty($row->lawsectionslug) ? '' : 'View') ?></a></td>
                    <td data-sort="<?= $row->lawapproved ?>"><?= $row->lawsectioncitation ?></td>
                    <?php if ($type == 'relationship' AND isset($includeLawGroup)) { ?>
                        <td><?= $row->lawgrouplong ?></td>
                    <?php } ?>
                    <td><?= (($type == 'relationship') ? $row->lawsectioneventrelationship : $row->eventtypeshort) ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>