<section>
    <?php if (!$isHistory) { ?>
        <h2>Summary</h2>
    <?php } ?>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if ($live) { ?>
                    <th>ID</th>
                <?php } ?>
                <th>Name</th>
                <th>Level <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#governmentlevel" aria-label="Level Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
                <th>Type</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <?php if ($live) { ?>
                    <td><?= $row->governmentid ?></td>
                <?php } ?>
                <td><?= $row->governmentlong ?></td>
                <td><?= $row->governmentlevel ?></td>
                <td><?= $row->governmenttype ?></td>
            </tr>
        </tbody>
    </table>
</section>
<?php if ($row->textflag == 't' and !$isHistory) { ?>
    <section>
        <h2>Detail</h2>
        <table class="normal cell-border compact stripe">
            <thead>
                <tr>
                    <th>Created <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#date" aria-label="Date Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
                    <?php if (!empty($row->governmentcreationlong)) { ?>
                        <th>Created As</th>
                    <?php } ?>
                    <th>Boundary-Name Alteration Count</th>
                    <th>Dissolved <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#date" aria-label="Date Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
                    <?php if ($live) { ?>
                        <th>Mapping Complete?</th>
                    <?php } ?>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><?php if (!empty($row->governmentcreationevent)) { ?><a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/event/<?= $row->governmentcreationevent ?>/"><?= $row->governmentcreationtext ?></a><?php } ?></td>
                    <?php if (!empty($row->governmentcreationlong)) { ?>
                        <td><?= $row->governmentcreationlong ?></td>
                    <?php } ?>
                    <td><?= $row->governmentaltercount ?></td>
                    <td><?php if (!empty($row->governmentdissolutionevent)) { ?><a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/event/<?= $row->governmentdissolutionevent ?>/"><?= $row->governmentdissolutiontext ?></a><?php } ?></td>
                    <?php if ($live) { ?>
                        <td>
                            <form action="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/governmentmapcomplete/" method="post">
                                <input type="hidden" name="id" value="<?= $row->governmentid ?>">
                                <select name="mapcomplete">
                                    <?php foreach ($statuses as $status) { ?>
                                        <option value="<?= $status->governmentmapstatusid ?>" <?= (($status->governmentmapstatusid == $row->governmentmapstatus) ? ' selected="selected"' : '') ?>><?= $status->governmentmapstatusshort ?></option>
                                    <?php } ?>
                                </select>
                                <button type="submit">Change</button>
                            </form>
                        </td>
                    <?php } ?>
                </tr>
            </tbody>
        </table>
    </section>
<?php } ?>