<?php
$includeBase ??= true;
?>
<section>
    <h2>Map</h2>
    <?php if (isset($includeDisclaimer)) { ?>
        <p><span class="b">Note: </span>
            This map shows the approximate area of the description, and is not of surveying or engineering quality.
            Users are cautioned to examine the original description.
        </p>
    <?php } elseif (isset($eventIsMapped) && !$eventIsMapped) { ?>
        <p><span class="b">Note: </span>
            Mapping of this event is incomplete.
        </p>
    <?php } ?>
    <?= ((\App\Controllers\BaseController::isLive() && $includeBase) ? '<div style="width: 40%; float: right;">Coordinates:&nbsp;<div id="coord" style="float: right;"></div></div>' : '') ?>
    <div id="map">
    </div>
    <input type="hidden" name="idholder" id="idholder" value="-100">
</section>