<?php if (is_array($query ?? '') && $query !== []) { ?>
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
                <th>Relationship <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventrelationship" aria-label="Relationship Key" title="Relationship Key"><span class="keyiconfill">vpn_key</span></a></th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) {
                if ($row->recordingtype === '') {
                    $row->recordingtype = $row->recordingnumbertype;
                    $row->recordinglocation = $row->recordingnumberlocation;
                    $row->recordingnumbertype = null;
                    $row->recordingnumberlocation = null;
                } ?>
                <tr>
                    <td><a href="/<?= \Config\Services::request()->getLocale() ?>/government/<?= $row->government ?>/"><?= $row->governmentshort ?></a></td>
                    <td><?= $row->recordingtype . ($row->hasbothtype === 't' ? '<br>' : '') . $row->recordingnumbertype ?></td>
                    <td><?= $row->recordinglocation . ($row->hasbothtype === 't' ? '<br>' : '') . $row->recordingnumberlocation ?></td>
                    <td><?=
                        $row->recordingrepositoryshort .
                                        ($row->recordingrepositoryseries === '' ? '' : ', series ' . $row->recordingrepositoryseries) .
                                        ($row->recordingrepositorycontainer === '' ? '' : ', container ' . $row->recordingrepositorycontainer) .
                                        ($row->recordingrepositoryitemlocation === '' ? '' : ', location ' . $row->recordingrepositoryitemlocation) .
                                        ($row->recordingrepositoryitemnumber === '' ? '' : ', folder ' . $row->recordingrepositoryitemnumber) .
                                        ($row->recordingrepositoryitemrange === '' ? '' : ', part ' . $row->recordingrepositoryitemrange)
                ?></td>
                    <td data-sort="<?= $row->recordingdatesort ?>"><?= $row->recordingdate ?></td>
                    <td><?= $row->recordingeventrelationship ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<?php } ?>