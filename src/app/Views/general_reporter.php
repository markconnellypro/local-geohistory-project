<?php if (is_array($query ?? '') && $query !== []) { ?>
<section>
    <h2><?= $title ?? '' ?></h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if ($hasLink ?? true) { ?>
                    <th>Detail</th>
                <?php } ?>
                <th>Citation</th>
                <th>Opinion Date</th>
                <th>Title</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <?php if ($hasLink ?? true) { ?>
                        <td><a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?? 'usa' ?>/reporter/<?= $row->adjudicationsourcecitationslug ?>/">View</a></td>
                    <?php } ?>
                    <td><?= $row->adjudicationsourcecitationvolume . ' ' . $row->sourceshort . ' ' . $row->adjudicationsourcecitationpage .
                            ($row->adjudicationsourcecitationyear != '' ? ' (' . $row->adjudicationsourcecitationyear . ')' : '') ?></td>
                    <td data-sort="<?= $row->adjudicationsourcecitationdatesort ?>"><?= $row->adjudicationsourcecitationdate ?></td>
                    <td><?= $row->adjudicationsourcecitationtitle ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>