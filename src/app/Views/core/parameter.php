<?php if (is_array($searchParameter ?? '') && $searchParameter !== []) { ?>
<section>
    <h2>Requested Information<?= (isset($omitColon) ? '' : ':') ?></h2>
    <div class="parameter">
        <?php foreach ($searchParameter as $parameter => $value) { ?>
            <div class="parameter-line">
                <div class="parameter-type"><?= $parameter ?>:</div>
                <div class="parameter-value"><?= $value ?></div>
            </div>
        <?php } ?>
    </div>
</section>
<?php } ?>