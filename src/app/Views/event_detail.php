<section>
    <h2>Summary</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if (\App\Controllers\BaseController::isLive()) { ?>
                    <th>ID</th>
                <?php } ?>
                <th>Type <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventtype" aria-label="Type Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
                <?php if ($row->eventgranted != 'government') { ?>
                    <th>Method</th>
                <?php } ?>
                <th>Description</th>
                <?php if ($row->eventgranted != 'government') { ?>
                    <th>Successful? <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventgranted" aria-label="Successful? Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
                <?php } else { ?>
                    <th>Government</th>
                <?php } ?>
            </tr>
        </thead>
        <tbody>
            <tr>
                <?php if (\App\Controllers\BaseController::isLive()) { ?>
                    <td><?= $row->eventid ?></td>
                <?php } ?>
                <td><?= $row->eventtypeshort ?></td>
                <?php if ($row->eventgranted != 'government') { ?>
                    <td><?= $row->eventmethodlong ?></td>
                <?php } ?>
                <td><?= $row->eventlong ?></td>
                <?php if ($row->eventgranted != 'government') { ?>
                    <td><?= $row->eventgranted ?></td>
                <?php } else { ?>
                    <td><?php echo view('general_link', ['link' => $row->government, 'text' => 'View']) ?></td>
                <?php } ?>
            </tr>
        </tbody>
    </table>
</section>
<?php if ($row->textflag == 't') { ?>
    <section>
        <h2>Dates</h2>
        <table class="normal cell-border compact stripe">
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
                    <td><?= $row->eventyear ?></td>
                    <td><?= $row->otherdate ?></td>
                    <td><?= $row->eventeffective ?></td>
                    <td><?= $row->eventeffectivetype ?></td>
                </tr>
            </tbody>
        </table>
    </section>
<?php } ?>