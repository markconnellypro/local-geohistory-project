<section>
    <h2>Government Action</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if ($type !== 'source') { ?>
                    <th>Detail</th>
                <?php }
                if ($type !== 'government' or !empty($isMultiple)) { ?>
                    <th>Government</th>
                <?php } ?>
                <th>Action</th>
                <th>Date</th>
                <th>Approved</th>
                <th>Effective</th>
                <th>Location</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <?php if ($type !== 'source') { ?>
                        <td data-sort="<?= $row->governmentsourcesort ?>">
                            <?php if (!empty($row->governmentsourceslug)) { ?>
                                <a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/governmentsource/<?= $row->governmentsourceslug ?>/">View</a>
                                <?php } elseif (isset($row->eventslug)) {
                                $i = 0;
                                foreach (explode(',', str_replace(['{', '}'], '', $row->eventslug)) as $event) { ?>
                                    <?= ($i > 0 ? '<br>' : '') ?><a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/event/<?= $event ?>/">View</a>
                            <?php $i++;
                                }
                            } ?>
                        </td>
                    <?php }
                    if ($type !== 'government' or !empty($isMultiple)) { ?>
                        <td><?php echo view('general_link', ['link' => $row->government, 'text' => $row->governmentlong]); ?></td>
                    <?php } ?>
                    <td><span class="b">
                            <?= ($row->governmentsourcebody == '' ? '' : $row->governmentsourcebody . ' ') . $row->governmentsourcetype .
                                ($row->governmentsourcenumber == '' ? '' : ' ' . $row->governmentsourcenumber) .
                                ($row->governmentsourceterm == '' ? '' : ', ' . $row->governmentsourceterm) .
                                ($row->governmentsourcetitle == '' ? '</span>' : ':</span> ' . $row->governmentsourcetitle) ?>
                    </td>
                    <td data-sort="<?= $row->governmentsourcedatesort ?>"><?= $row->governmentsourcedate ?></td>
                    <td data-sort="<?= $row->governmentsourceapproveddatesort ?>">
                        <?= ($row->governmentsourceapproved == 't' ?
                            (($row->governmentsourcetype == 'Election' and $row->governmentsourceapproveddate != '') ? 'Certified ' : '') . $row->governmentsourceapproveddate : ($row->governmentsourcetype == 'Election' ? 'Rejected' : ($row->governmentsourcetype == 'Bill' ? '' : 'Veto' . ($row->governmentsourceapproveddate != '' ? ' Overridden ' . $row->governmentsourceapproveddate : 'ed')))) ?>
                    </td>
                    <td data-sort="<?= $row->governmentsourceeffectivedatesort ?>"><?= $row->governmentsourceeffectivedate ?></td>
                    <td><?=
                        $row->governmentsourcelocation .
                            ((!empty($row->governmentsourcelocation) and !empty($row->sourcecitationlocation)) ? '; ' : '') .
                            $row->sourcecitationlocation ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>