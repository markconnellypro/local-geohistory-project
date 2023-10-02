<form method="post" action="/<?= \Config\Services::request()->getLocale() ?>/<?= $state . (empty($state) ? '' : '/') ?>statistics/report/">
    <fieldset>
        <legend>Metric:</legend>
        <div class="option_radio_indent">
            <input type="radio" name="for" id="for_created" value="created" checked="checked"><label for="for_created">Created Municipalities</label><br>
            <input type="radio" name="for" id="for_dissolved" value="dissolved"><label for="for_dissolved">Dissolved Municipalities</label><br>
            <input type="radio" name="for" id="for_net" value="net"><label for="for_net">Net Created-Dissolved Municipalities</label><br>
            <input type="radio" name="for" id="for_eventtype" value="eventtype"><label for="for_eventtype">Events by Event Type</label><br>
            <?php if ($live) { ?>
                <input type="radio" name="for" id="for_mapped_incorporated_review" value="mapped_incorporated_review"><label for="for_mapped_incorporated_review">Reviewed Incorporated Municipalities</label><br>
                <input type="radio" name="for" id="for_mapped_incorporated" value="mapped_incorporated"><label for="for_mapped_incorporated">Mapped Incorporated Municipalities</label><br>
                <input type="radio" name="for" id="for_mapped_total_review" value="mapped_total_review"><label for="for_mapped_total_review">Reviewed Total Municipalities</label><br>
                <input type="radio" name="for" id="for_mapped_total" value="mapped_total"><label for="for_mapped_total">Mapped Total Municipalities</label>
            <?php } ?>
        </div>
    </fieldset>
    <?php if (0 == 1) { ?>
        <fieldset>
            <legend>Group By:</legend>
            <div class="option_radio_indent">
                <input type="radio" name="by" id="by_current" value="current" checked="checked"><label for="by_current">Current Jurisdictions</label><br>
                <input type="radio" name="by" id="by_historic" value="historic"><label for="by_historic">Historic Jurisdictions</label>
            </div>
        </fieldset>
    <?php } else { ?>
        <input type="hidden" name="by" value="historic">
    <?php } ?>
    <fieldset>
        <legend>Filters:</legend>
        <div class="option_indent">
            <div class="option_select">
                <?php
                echo view('search_form_eventtype', ['isRequired' => false, 'form' => '']);
                ?>
            </div>
            <label class="forselectize" for="from">Year(s)</label><br>
            <input id="from" class="selectize-input" name="from" type="number" step="1" style="width: 100px;">
            <label for="to">&ndash;</label>
            <input id="to" class="selectize-input" name="to" type="number" step="1" min="0" style="width: 100px;">
            <br><br>
            <button class="submitbutton" type="submit">Search</button>
        </div>
    </fieldset>
</form>
<script>
    var eventTypeList = <?= json_encode($eventTypeQuery); ?>;

    $(function() {

        $('input[type=radio][name=for]').change(function() {
            if ($(this).val() == 'eventtype') {
                $('.option_select').css('display', 'inherit');
                $('select').attr('required', 'required');
            } else {
                $('.option_select').css('display', 'none');
                $('select').removeAttr('required');
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

    });
</script>