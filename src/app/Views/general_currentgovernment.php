<section>
    <h2>Current Government</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if ($live and isset($query[0]->governmentshapeid)) { ?>
                    <th>ID</th>
                <?php } ?>
                <th>Sub-Municipality</th>
                <th>Municipality</th>
                <th>County</th>
                <th>State</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <?php if ($live and isset($row->governmentshapeid)) { ?>
                        <td><?= $row->governmentshapeid ?></td>
                    <?php } ?>
                    <td>
                        <?php if (!empty($row->governmentsubmunicipality)) {
                            echo view('general_link', ['link' => $row->governmentsubmunicipality, 'text' => $row->governmentsubmunicipalitylong]);
                        } ?>
                    </td>
                    <td>
                        <?php echo view('general_link', ['link' => $row->governmentmunicipality, 'text' => $row->governmentmunicipalitylong]) ?>
                    </td>
                    <td>
                        <?php echo view('general_link', ['link' => $row->governmentcounty, 'text' => $row->governmentcountyshort]) ?>
                    </td>
                    <td>
                        <?php echo view('general_link', ['link' => $row->governmentstate, 'text' => $row->governmentstateabbreviation]) ?>
                    </td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>