<?php if (is_array($query ?? '') && $query !== []) {
    $hasColor ??= false;
    $hasLink ??= false;
    $title ??= '';
    ?>
<section>
    <?php if (!isset($omitTitle)) { ?>
        <h2><?= $title ?></h2>
    <?php } ?>
    <table class="normal cell-border compact<?= ($hasColor ? '' : ' stripe') ?>">
        <thead>
            <tr>
                <?php if ($hasLink) { ?>
                    <th>Detail</th>
                    <?php if (!$hasColor) { ?>
                        <th>Source</th>
                    <?php }
                    }
    if ($hasColor || !$hasLink && \App\Controllers\BaseController::isLive()) { ?>
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
                    $rowColor = ($row->citationcount > 0 ? (($row->citationeventnothandledcount > 0 || $row->sourcecitationnothandled === 't') ? 'preliminary' : 'complete') : 'incomplete');
                } else {
                    $rowColor = '';
                }
                ?>
                <tr>
                    <?php if ($hasLink) { ?>
                        <td<?= ($hasColor ? ' class="folder' . $rowColor . '"' : '') ?>><a href="/<?= \Config\Services::request()->getLocale() ?>/source/<?= $row->sourcecitationslug ?>/">View</a></td>
                            <?php if (!$hasColor) { ?>
                                <td><?= $row->sourceabbreviation ?></td>
                                <?php }
                            }
                if ($hasColor || !$hasLink && \App\Controllers\BaseController::isLive()) { ?>
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
<?php } ?>