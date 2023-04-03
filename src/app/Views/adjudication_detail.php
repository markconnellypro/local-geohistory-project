<section>
    <h2>Tribunal</h2>
    <table class="normal row-border cell-border compact stripe">
        <thead>
            <tr>
                <th>Tribunal</th>
                <th>Current Filing Office</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><?= $row->tribunallong ?></td>
                <td><?= $row->tribunalfilingoffice ?></td>
            </tr>
        </tbody>
    </table>
</section>
<section>
    <h2>Summary</h2>
    <table class="normal row-border cell-border compact stripe">
        <thead>
            <tr>
                <th>Type</th>
                <th>No.</th>
                <th>Term</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><?= $row->adjudicationtypelong ?></td>
                <td><?= $row->adjudicationnumber ?></td>
                <td><?= $row->adjudicationterm ?></td>
            </tr>
        </tbody>
    </table>
</section>
<?php if ($row->textflag == 't') { ?>
    <section>
        <h2>Detail</h2>
        <table class="normal row-border cell-border compact stripe">
            <thead>
                <tr>
                    <th>Long Caption</th>
                    <th>Short Description</th>
                    <th>Notes</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><?= $row->adjudicationlong ?></td>
                    <td><?= $row->adjudicationshort ?></td>
                    <td><?= $row->adjudicationnotes ?></td>
                </tr>
            </tbody>
        </table>
    </section>
<?php } ?>