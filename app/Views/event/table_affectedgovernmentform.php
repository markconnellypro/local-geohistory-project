<?php if (is_array($query ?? '') && $query !== []) {
    $includeGovernment ??= false;
    $isHistory ??= false;
    ?>
<section>
    <h2>Affected Government Form</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if ($includeGovernment) { ?>
                    <th>Government</th>
                <?php } else { ?>
                    <th>Detail</th>
                <?php }
                if (isset($isMultiple) && !$isMultiple) { ?>
                    <th>Government</th>
                <?php } ?>
                <th>Government Form</th>
                <?php if (!$includeGovernment) { ?>
                    <th>Date <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#date" aria-label="Date Key" title="Date Key"><span class="keyiconfill">vpn_key</span></a></th>
                <?php } ?>
            </tr>
        </thead>
        <tbody>
            <?php $i = 1;
    foreach ($query as $row) { ?>
                <tr>
                    <?php if ($includeGovernment) { ?>
                        <td><?php echo view('core/link', [
                            'type' => 'government',
                            'link' => $row->governmentslug,
                            'text' => $row->governmentlong,
                        ]) ?></td>
                    <?php } else { ?>
                        <td data-sort="<?= $row->eventsort ?>"><?= ($isHistory ? $i : '<a href="/' . \Config\Services::request()->getLocale() . '/event/' . $row->eventslug . '/">View</a>') ?></td>
                    <?php }
                    if (isset($isMultiple) && !$isMultiple) { ?>
                        <td><?= $row->governmentaffectedlong ?></td>
                    <?php } ?>
                    <td><?= $row->governmentformlong . ((!$includeGovernment && $row->eventreconstructed === 't') ? '?' : '') ?></td>
                    <?php if (!$includeGovernment) { ?>
                        <td data-sort="<?= $row->eventsort ?>"><?= ($row->eventeffective === '' ? $row->eventyear : $row->eventeffective) ?></td>
                    <?php } ?>
                </tr>
            <?php $i++;
    } ?>
        </tbody>
    </table>
</section>
<?php } ?>