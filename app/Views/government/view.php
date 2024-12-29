<?php if (is_array($query ?? '') && $query !== []) {
    $isHistory ??= false;
    $row = $query[0];
    ?>
<section>
    <?php if (!$isHistory) { ?>
        <h2>Summary</h2>
    <?php } ?>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if (\App\Controllers\BaseController::isLive()) { ?>
                    <th>ID</th>
                <?php } ?>
                <th>Name</th>
                <th>Level <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#governmentlevel" aria-label="Level Key" title="Level Key"><span class="keyiconfill">vpn_key</span></a></th>
                <th>Type</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <?php if (\App\Controllers\BaseController::isLive()) { ?>
                    <td><?= $row->governmentid ?></td>
                <?php } ?>
                <td><?= $row->governmentlong ?></td>
                <td><?= $row->governmentlevel ?></td>
                <td><?= $row->governmenttype ?></td>
            </tr>
        </tbody>
    </table>
</section>
<?php if ($row->textflag === 't' && !$isHistory) { ?>
    <section>
        <h2>Detail</h2>
        <table class="normal cell-border compact stripe">
            <thead>
                <tr>
                    <th>Created <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#date" aria-label="Date Key" title="Date Key"><span class="keyiconfill">vpn_key</span></a></th>
                    <?php if ($row->governmentcreationlong !== '') { ?>
                        <th>Created As</th>
                    <?php } ?>
                    <th>Boundary-Name Alteration Count</th>
                    <th>Dissolved <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#date" aria-label="Date Key" title="Date Key"><span class="keyiconfill">vpn_key</span></a></th>
                    <?php if (\App\Controllers\BaseController::isLive()) { ?>
                        <th>Mapping Complete?</th>
                    <?php } ?>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><?php if (!is_null($row->governmentcreationevent)) { ?><a href="/<?= \Config\Services::request()->getLocale() ?>/event/<?= $row->governmentcreationevent ?>/"><?= $row->governmentcreationtext ?></a><?php } ?></td>
                    <?php if ($row->governmentcreationlong !== '') { ?>
                        <td><?= $row->governmentcreationlong ?></td>
                    <?php } ?>
                    <td><?= $row->governmentaltercount ?></td>
                    <td><?php if (!is_null($row->governmentdissolutionevent)) { ?><a href="/<?= \Config\Services::request()->getLocale() ?>/event/<?= $row->governmentdissolutionevent ?>/"><?= $row->governmentdissolutiontext ?></a><?php } ?></td>
                    <?php if (\App\Controllers\BaseController::isLive()) { ?>
                        <td>
                            <form action="/<?= \Config\Services::request()->getLocale() ?>/governmentmapcomplete/" method="post">
                                <input type="hidden" name="id" value="<?= $row->governmentid ?>">
                                <select name="mapcomplete">
                                <?php if (is_array($statuses ?? '') && $statuses !== []) {
                                    foreach ($statuses as $status) { ?>
                                        <option value="<?= $status->governmentmapstatusid ?>" <?= (($status->governmentmapstatusid === $row->governmentmapstatus) ? ' selected="selected"' : '') ?>><?= $status->governmentmapstatusshort ?></option>
                                    <?php }
                                    } ?>
                                </select>
                                <button type="submit">Change</button>
                            </form>
                        </td>
                    <?php } ?>
                </tr>
            </tbody>
        </table>
    </section>
<?php }
} ?>