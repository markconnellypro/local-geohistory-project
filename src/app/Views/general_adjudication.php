<section>
    <h2>Adjudication</h2>
    <table class="normal row-border cell-border compact stripe">
        <thead>
            <tr>
                <th>Detail</th>
                <th>Tribunal</th>
                <th>Type</th>
                <th>No.</th>
                <th>Term</th>
                <?php if (isset($eventRelationship)) { ?>
                    <th>Relationship <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventrelationship" aria-label="Relationship Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
                <?php } ?>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <td><a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/adjudication/<?= $row->adjudicationslug ?>/">View</a></td>
                    <td><?= $row->tribunallong ?></td>
                    <td><?= $row->adjudicationtypelong ?></td>
                    <td><?= $row->adjudicationnumber ?></td>
                    <td data-sort="<?= $row->adjudicationtermsort ?>"><?= $row->adjudicationterm ?></td>
                    <?php if (isset($eventRelationship)) { ?>
                        <td><?= $row->eventrelationship ?></td>
                    <?php } ?>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>