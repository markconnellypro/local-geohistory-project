<?php if (is_array($query ?? '') && $query !== []) { ?>
<section>
    <h2>Courses and Distances</h2>
    <p><span class="b">Note: </span>
        This is an abstract, and not a transcription, of the description, which has been made to facilitate mapping that is not of surveying or engineering quality.
        Courses and distances have been converted to decimal degrees and feet, respectively, and some corrections may have been made.
        Users are cautioned to examine the original description.
    </p>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <th>Point</th>
                <th>Thence</th>
                <th>Course</th>
                <th>Distance</th>
                <th>To</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($query as $row) { ?>
                <tr>
                    <td><?= $row->metesdescriptionline ?></td>
                    <td><?= $row->thencepoint ?></td>
                    <td class="metesdegree" data-ns="<?= $row->northsouth ?>" data-deg="<?= $row->degree ?>" data-ew="<?= $row->eastwest ?>">
                        <?= $row->northsouth . ' ' . (is_null($row->degree) ? '' : $row->degree . '&deg;') . ' ' . $row->eastwest ?></td>
                    <td class="metesfoot" data-ft="<?= $row->foot ?>"><?= (is_null($row->foot) ? '' : $row->foot . ' <span class="i">ft.</span>') ?></td>
                    <td><?= $row->topoint ?></td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>
<section>
    <h2>Change Measurement Units</h2>
    <form id="courseform">
        <span class="b">Courses&#58;&nbsp;</span>
        <input value="1" name="metesdegreetype" type="radio" checked="checked">Degrees&#59;
        <input value="2" name="metesdegreetype" type="radio">Degrees &amp; minutes&#59; or
        <input value="3" name="metesdegreetype" type="radio">Degrees, minutes, &amp; seconds.
    </form>
    <form id="distanceform">
        <span class="b">Distances&#58;&nbsp;</span>
        <input value="1" name="metesfoottype" type="radio" checked="checked">Feet&#59;
        <input value="2" name="metesfoottype" type="radio">Feet &amp; inches&#59;
        <input value="3" name="metesfoottype" type="radio">Rods&#59;
        <input value="4" name="metesfoottype" type="radio">Rods &amp; feet&#59;
        <input value="5" name="metesfoottype" type="radio">Rods, feet, &amp; inches&#59; or
        <input value="6" name="metesfoottype" type="radio">Chains.
    </form>
</section>
<script src="/asset/application/tool/metes.js"></script>
<?php } ?>