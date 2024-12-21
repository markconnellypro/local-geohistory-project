<?php if (is_array($query ?? '') && $query !== []) { ?>
<section>
    <h2>Current Government</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if (\App\Controllers\BaseController::isLive() && isset($query[0]->governmentshapeid)) { ?>
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
                    <?php if (\App\Controllers\BaseController::isLive() && isset($row->governmentshapeid)) { ?>
                        <td><?= $row->governmentshapeid ?></td>
                    <?php } ?>
                    <td>
                        <?php if ($row->governmentsubmunicipality !== '') {
                            echo view('core/link', [
                                'type' => 'government',
                                'link' => $row->governmentsubmunicipality,
                                'text' => $row->governmentsubmunicipalitylong,
                            ]);
                        } ?>
                    </td>
                    <td>
                        <?php echo view('core/link', [
                            'type' => 'government',
                            'link' => $row->governmentmunicipality,
                            'text' => $row->governmentmunicipalitylong,
                        ]); ?>
                    </td>
                    <td>
                        <?php echo view('core/link', [
                            'type' => 'government',
                            'link' => $row->governmentcounty,
                            'text' => $row->governmentcountyshort,
                        ]); ?>
                    </td>
                    <td>
                        <?php echo view('core/link', [
                            'type' => 'government',
                            'link' => $row->governmentstate,
                            'text' => $row->governmentstateabbreviation,
                        ]); ?>
                    </td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>