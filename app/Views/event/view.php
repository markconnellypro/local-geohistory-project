<?php if (is_array($query ?? '') && $query !== []) {
    $row = $query[0]; ?>
<section>
    <h2>Summary</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if (\App\Controllers\BaseController::isLive()) { ?>
                    <th>ID</th>
                <?php } ?>
                <th>Type <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventtype" aria-label="Type Key" title="Type Key"><span class="keyiconfill">vpn_key</span></a></th>
                <?php if ($row->eventgranted !== 'government') { ?>
                    <th>Method</th>
                <?php } ?>
                <th>Description</th>
                <?php if ($row->eventgranted !== 'government') { ?>
                    <th>Successful? <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventgranted" aria-label="Successful? Key" title="Successful? Key"><span class="keyiconfill">vpn_key</span></a></th>
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
                <?php if ($row->eventgranted !== 'government') { ?>
                    <td><?= $row->eventmethodlong ?></td>
                <?php } ?>
                <td><?= $row->eventlong ?></td>
                <?php if ($row->eventgranted !== 'government') { ?>
                    <td><?= $row->eventgranted ?></td>
                <?php } else { ?>
                    <td><?php echo view('core/link', [
                        'type' => 'government',
                        'link' => $row->government,
                        'text' => 'View',
                    ]) ?></td>
                <?php } ?>
            </tr>
        </tbody>
    </table>
</section>
<?php if ($row->textflag === 't') { ?>
    <section>
        <h2>Dates</h2>
        <table class="normal cell-border compact stripe">
            <thead>
                <tr>
                    <th>Event Year(s) <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#date" aria-label="Date Key" title="Date Key"><span class="keyiconfill">vpn_key</span></a></th>
                    <th><?= (is_null($row->otherdatetype) ? 'Final Decree' : $row->otherdatetype) ?> Date</th>
                    <th>Effective Date <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#date" aria-label="Date Key" title="Date Key"><span class="keyiconfill">vpn_key</span></a></th>
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
<?php }
} ?>