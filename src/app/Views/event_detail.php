<section>
    <h2>Summary</h2>
    <table class="normal row-border cell-border compact stripe">
        <thead>
            <tr>
                <?php if ($live) { ?>
                    <th>ID</th>
                <?php } ?>
                <th>Type <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventtype" aria-label="Type Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
                <th>Method</th>
                <th>Description</th>
                <th>Successful? <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventgranted" aria-label="Successful? Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <?php if ($live) { ?>
                    <td><?= $row->eventid ?></td>
                <?php } ?>
                <td><?= $row->eventtypeshort ?></td>
                <td><?= $row->eventmethodlong ?></td>
                <td><?= $row->eventlong ?></td>
                <td><?= $row->eventgranted ?></td>
            </tr>
        </tbody>
    </table>
</section>
<?php if ($row->textflag == 't') { ?>
    <section>
        <h2>Dates</h2>
        <table class="normal row-border cell-border compact stripe">
            <thead>
                <tr>
                    <th>Event Year(s) <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#date" aria-label="Date Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
                    <th><?= (is_null($row->otherdatetype) ? 'Final Decree' : $row->otherdatetype) ?> Date</th>
                    <th>Effective Date <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#date" aria-label="Date Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
                    <th>How Effective Date Determined</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><?= $row->eventrange ?></td>
                    <td><?= $row->otherdate ?></td>
                    <td><?= $row->eventeffective ?></td>
                    <td><?= $row->eventeffectivetype ?></td>
                </tr>
            </tbody>
        </table>
    </section>
<?php } ?>