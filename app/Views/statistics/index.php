<?php
$eventTypeQuery ??= [];
$jurisdictions ??= [];
?>
<form method="post" action="/<?= \Config\Services::request()->getLocale() ?>/statistics/report/">
    <fieldset>
        <legend>Metric:</legend>
        <div class="option_radio_indent">
            <input type="radio" name="for" id="for_created" value="created" checked="checked"><label for="for_created">Created Municipalities</label><br>
            <input type="radio" name="for" id="for_dissolved" value="dissolved"><label for="for_dissolved">Dissolved Municipalities</label><br>
            <input type="radio" name="for" id="for_net" value="net"><label for="for_net">Net Created-Dissolved Municipalities</label><br>
            <input type="radio" name="for" id="for_eventtype" value="eventtype"><label for="for_eventtype">Events by Event Type</label><br>
            <?php if (\App\Controllers\BaseController::isLive()) { ?>
                <input type="radio" name="for" id="for_mapped_incorporated_review" value="mapped_incorporated_review"><label for="for_mapped_incorporated_review">Reviewed Incorporated Municipalities</label><br>
                <input type="radio" name="for" id="for_mapped_incorporated" value="mapped_incorporated"><label for="for_mapped_incorporated">Mapped Incorporated Municipalities</label><br>
                <input type="radio" name="for" id="for_mapped_total_review" value="mapped_total_review"><label for="for_mapped_total_review">Reviewed Total Municipalities</label><br>
                <input type="radio" name="for" id="for_mapped_total" value="mapped_total"><label for="for_mapped_total">Mapped Total Municipalities</label>
            <?php } ?>
        </div>
    </fieldset>
        <input type="hidden" name="by" value="historic">
    <fieldset>
        <legend>Filters:</legend>
        <div class="option_indent">
            <div class="option_select">
                <?php
                echo view('search/form_eventtype', ['isRequired' => false, 'form' => '']);
?>
            </div>
            <label class="forselectize" for="governmentjurisdiction">Jurisdiction</label><br>
            <select name="governmentjurisdiction" class="forselectize" style="width: 300px;">
            </select>
            <div style="margin-top: -10px;">
                <label class="forselectize" for="from">Year(s)</label><br>
                <input id="from" class="selectize-input" name="from" type="number" step="1" style="width: 100px;">
                <label for="to">&ndash;</label>
                <input id="to" class="selectize-input" name="to" type="number" step="1" min="0" style="width: 100px;">
            </div>
            <br>
            <button class="submitbutton" type="submit">Search</button>
        </div>
    </fieldset>
</form>
<script>
    var eventTypeList = <?= json_encode($eventTypeQuery); ?>;
    var jurisdictionList = <?= json_encode($jurisdictions); ?>;

    $(function() {
        $('input[type=radio][name=for]').change(function() {
            if ($(this).val() == 'eventtype') {
                $('.option_select').css('display', 'inherit');
                $('#_eventtype').attr('required', 'required');
            } else {
                $('.option_select').css('display', 'none');
                $('#_eventtype').removeAttr('required');
            }
        });

        var forValue = $('input[type=radio][name=for]').val();
        $('input[type=radio][name=for][value=' + forValue + ']').trigger('click');

        $('select[name=eventtype]').selectize({
            selectOnTab: true,
            closeAfterSelect: true,
            highlight: false,
            options: eventTypeList,
            valueField: 'eventtypeshort',
            labelField: 'eventtypeshort',
            searchField: 'eventtypeshort'
        });

        $('select[name=governmentjurisdiction]').selectize({
            selectOnTab: true,
            closeAfterSelect: true,
            highlight: false,
            options: jurisdictionList,
            valueField: 'governmentabbreviation',
            labelField: 'governmentshort',
            searchField: 'governmentshort'
        });
    });
</script>