<section>
    <h2>Recorded Document</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>Government</th>
                <th>Type</th>
                <th>Location</th>
                <th>Alternate Location</th>
                <th>Date</th>
                <th>Relationship <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventrelationship" aria-label="Relationship Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) {
                if (empty($row->recordingtype)) {
                    $row->recordingtype = $row->recordingnumbertype;
                    $row->recordinglocation = $row->recordingnumberlocation;
                    $row->recordingnumbertype = NULL;
                    $row->recordingnumberlocation = NULL;
                } ?>
                <tr>
                    <td><a href="<?= $row->government ?>"><?= $row->governmentshort ?></a></td>
                    <td><?= $row->recordingtype . ($row->hasbothtype == 't' ? '<br>' : '') . $row->recordingnumbertype ?></td>
                    <td><?= $row->recordinglocation . ($row->hasbothtype == 't' ? '<br>' : '') . $row->recordingnumberlocation ?></td>
                    <td><?= (empty($row->recordingrepositoryshort) ? '' : $row->recordingrepositoryshort .
                            (empty($row->recordingrepositoryseries) ? '' : ', series ' . $row->recordingrepositoryseries) .
                            (empty($row->recordingrepositorycontainer) ? '' : ', container ' . $row->recordingrepositorycontainer) .
                            (empty($row->recordingrepositoryitemlocation) ? '' : ', location ' . $row->recordingrepositoryitemlocation) .
                            (empty($row->recordingrepositoryitemnumber) ? '' : ', folder ' . $row->recordingrepositoryitemnumber) .
                            (empty($row->recordingrepositoryitemrange) ? '' : ', part ' . $row->recordingrepositoryitemrange)
                        ) ?></td>
                    <td data-sort="<?= $row->recordingdatesort ?>"><?= $row->recordingdate ?></td>
                    <td><?= $row->recordingeventrelationship ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>