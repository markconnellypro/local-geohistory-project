<section>
    <?php if (!isset($omitTitle)) { ?>
        <h2><?= $title ?></h2>
    <?php } ?>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if ($hasLink) { ?>
                    <th>Detail</th>
                    <?php if (!$hasColor) { ?>
                        <th>Source</th>
                    <?php }
                }
                if ($hasColor or (!$hasLink and $live)) { ?>
                    <th>ID</th>
                <?php } ?>
                <th>Title</th>
                <th><?= ($hasColor ? 'Government References' : 'Person(s)') ?></th>
                <th>Vol.</th>
                <th>Page(s)</th>
                <th>Date 1</th>
                <th>Date 2</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) {
                if ($hasColor) {
                    $rowColor = ($row->citationcount > 0 ? (($row->citationeventnothandledcount > 0 or $row->sourcecitationnothandled == 't') ? 'preliminary' : 'complete') : 'incomplete');
                }
            ?>
                <tr>
                    <?php if ($hasLink) { ?>
                        <td<?= ($hasColor ? ' class="folder' . $rowColor . '"' : '') ?>><a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/source/<?= $row->sourcecitationslug ?>/">View</a></td>
                            <?php if (!$hasColor) { ?>
                                <td<?= ($hasColor ? ' class="folder' . $rowColor . '"' : '') ?>><?= $row->sourceabbreviation ?></td>
                                <?php }
                        }
                        if ($hasColor or (!$hasLink and $live)) { ?>
                                <td<?= ($hasColor ? ' class="folder' . $rowColor . '" data-sort="' . $rowColor . '"' : '') ?>><?= $row->sourcecitationid ?></td>
                                <?php } ?>
                                <td<?= ($hasColor ? ' class="folder' . $rowColor . '"' : '') ?>><?= $row->sourcecitationtypetitle ?></td>
                                    <td<?= ($hasColor ? ' class="folder' . $rowColor . '"' : '') ?>><?= ($hasColor ? $row->sourcecitationgovernmentreferences : $row->sourcecitationperson) ?></td>
                                        <td<?= ($hasColor ? ' class="folder' . $rowColor . '"' : '') ?>><?= $row->sourcecitationvolume ?></td>
                                            <td<?= ($hasColor ? ' class="folder' . $rowColor . '"' : '') ?>><?= $row->sourcecitationpage ?></td>
                                                <td data-sort="<?= $row->sourcecitationdatesort ?>" <?= ($hasColor ? ' class="folder' . $rowColor . '"' : '') ?>><?= $row->sourcecitationdate ?></td>
                                                <td data-sort="<?= $row->sourcecitationdaterangesort ?>" <?= ($hasColor ? ' class="folder' . $rowColor . '"' : '') ?>><?= $row->sourcecitationdaterange ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>