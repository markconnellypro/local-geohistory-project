<?php if (is_array($query ?? '') && $query !== []) { ?>
<section>
    <?= (isset($title) && $title !== '' ? '<h2>' . $title . '</h2>' : '') ?>
    <table id="<?= ($tableId ?? 'event') ?>" class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>Detail</th>
                <th>Type <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventtype" aria-label="Type Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
                <th>Description</th>
                <th>Successful? <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventgranted" aria-label="Successful? Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
                <th>Date <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#date" aria-label="Date Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
                <?php if (isset($includeLawGroup)) { ?>
                    <th>Group</th>
                <?php } if (isset($eventRelationship)) { ?>
                    <th>Relationship <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventrelationship" aria-label="Relationship Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
                <?php } ?>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <td><a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/event/<?= $row->eventslug ?>/">View</a></td>
                    <td><?= $row->eventtypeshort ?></td>
                    <td><?= $row->eventlong ?></td>
                    <td><?= $row->eventgranted ?></td>
                    <td data-sort="<?= $row->eventsort ?>"><?= ($row->eventeffective === '' ? $row->eventyear : $row->eventeffective) ?></td>
                    <?php if (isset($includeLawGroup)) { ?>
                        <td><?= $row->lawgrouplong ?></td>
                    <?php } if (isset($eventRelationship)) { ?>
                        <td><?= $row->eventrelationship ?></td>
                    <?php } ?>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>