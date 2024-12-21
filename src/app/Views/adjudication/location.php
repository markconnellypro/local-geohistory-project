<?php if (is_array($query ?? '') && $query !== []) { ?>
<section>
    <h2>Location References</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>Type</th>
                <th>Location</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <td><?= $row->adjudicationlocationtypelong . ' ' . $row->adjudicationlocationtypetype .
                            ($row->tribunallong !== '' ? ' <span class="i"><span class="b">(Tribunal: </span>' . $row->tribunallong .
                                '<span class="b">; Current Filing Office: </span>' . $row->tribunalfilingoffice . '<span class="b">)</span></span>' : '') ?></td>
                    <td><?= ($row->adjudicationlocationpage === 'electronic' ? 'electronic' : ($row->adjudicationlocationtypearchiveseries !== '' ? $row->adjudicationlocationtypearchivetype . ' archives series ' . $row->adjudicationlocationtypearchiveseries . ', ' : '') .
                            ($row->adjudicationlocationtypevolumetype === 'Volume' ? 'v.' : strtolower($row->adjudicationlocationtypevolumetype)) . ' ' . $row->adjudicationlocationvolume . ', ' .
                            ($row->adjudicationlocationtypepagetype === 'Page' ? 'p.' : strtolower($row->adjudicationlocationtypepagetype)) . ' ' . $row->adjudicationlocationpage) ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>