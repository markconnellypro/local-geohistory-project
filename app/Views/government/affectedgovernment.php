<?php if (is_array($query ?? '') && $query !== []) {
    $isHistory ??= false;
    $isMultiple ??= false;
    ?>
<section>
    <?php if (!$isHistory) { ?>
        <h2>Affected Government</h2>
    <?php } ?>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th><?= ($isHistory ? 'Label' : 'Detail') ?></th>
                <?php if ($isMultiple) { ?>
                    <th>Government</th>
                <?php } ?>
                <th>How Affected <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#affectedtype" aria-label="Affected Type Key" title="Affected Type Key"><span class="keyiconfill">vpn_key</span></a></th>
                <th>Adverse Government</th>
                <th>How Adverse Affected <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#affectedtype" aria-label="Affected Type Key" title="Affected Type Key"><span class="keyiconfill">vpn_key</span></a></th>
                <th>Date <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#date" aria-label="Date Key" title="Date Key"><span class="keyiconfill">vpn_key</span></a></th>
            </tr>
        </thead>
        <tbody>
            <?php $i = 1;
    foreach ($query as $row) { ?>
                <tr>
                    <td data-sort="<?= $row->eventsort ?>"><?= ($isHistory ? $i : '<a href="/' . \Config\Services::request()->getLocale() . '/event/' . $row->eventslug . '/">View</a>') ?></td>
                    <?php if ($isMultiple) { ?>
                        <td><?= $row->governmentaffectedlong ?></td>
                    <?php } ?>
                    <td><?= $row->affectedtypesame . ($row->eventreconstructed === 't' ? '?' : '') ?></td>
                    <td><?php echo view('core/link', [
                        'type' => 'government',
                        'link' => $row->governmentslug,
                        'text' => $row->governmentlong,
                    ]) ?></td>
                    <td><?= $row->affectedtypeother . ($row->eventreconstructed === 't' ? '?' : '') ?></td>
                    <td data-sort="<?= $row->eventsort ?>"><?= ($row->eventeffective === '' ? $row->eventyear : $row->eventeffective) ?></td>
                </tr>
            <?php $i++;
    } ?>
        </tbody>
    </table>
</section>
<?php } ?>