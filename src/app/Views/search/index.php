<?php
$eventTypeQuery ??= [];
$governmentIdentifierTypeQuery ??= [];
$months ??= '';
$reporterQuery ??= [];
$state ??= 'usa';
$tribunalgovernmentshortQuery ??= [];
?>
<fieldset>
    <legend>Search For:</legend>
    <div class="option_radio_indent">
        <input type="radio" name="for" id="for_event" value="event" checked="checked"><label for="for_event">Event</label><br>
        <input type="radio" name="for" id="for_government" value="government"><label for="for_government">Government</label><br>
        <input type="radio" name="for" id="for_location" value="location"><label for="for_location">Location</label><br>
        <input type="radio" name="for" id="for_law" value="law"><label for="for_law">Law</label>
    </div>
</fieldset>
<fieldset>
    <legend>Search By:</legend>
    <div id="option_event" class="option_select option_radio_indent">
        <input type="radio" name="by_event" id="by_event_government" value="government"><label for="by_event_government">Government</label><br>
    </div>
    <div id="option_government" class="option_select option_radio_indent">
        <input type="radio" name="by_government" id="by_government_government" value="government"><label for="by_government_government">Government</label><br>
        <input type="radio" name="by_government" id="by_government_statewide" value="statewide"><label for="by_government_statewide">Statewide</label><br>
        <input type="radio" name="by_government" id="by_government_identifier" value="identifier"><label for="by_government_identifier">Identifier</label>
    </div>
    <div id="option_location" class="option_select option_radio_indent">
        <input type="radio" name="by_location" id="by_location_address" value="address" checked="checked"><label for="by_location_address">Address</label><br>
        <input type="radio" name="by_location" id="by_location_point" value="point" checked="checked"><label for="by_location_point">Coordinates</label><br>
    </div>
    <div id="option_law" class="option_select option_radio_indent">
        <input type="radio" name="by_law" id="by_law_reference" value="reference" checked="checked"><label for="by_law_reference">Reference</label><br>
        <input type="radio" name="by_law" id="by_law_dateevent" value="dateevent"><label for="by_law_dateevent">Date and Event Type</label>
    </div>
</fieldset>
<fieldset>
    <legend>Search Terms:</legend>
    <div id="forms_event" class="option_select option_indent">
        <form method="post" action="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/search/event/" class="form_select" id="form_event_government">
            <?php
            echo view('search/form_government', ['form' => 'form_event_government']);
echo view('search/form_governmentparent', ['form' => 'form_event_government']);
echo view('search/form_eventtype', ['isRequired' => false, 'form' => 'form_event_government']);
echo view('search/form_year', ['form' => 'form_event_government']);
echo view('search/submit', ['type' => 'government']);
?>
        </form>
    </div>
    <div id="forms_government" class="option_select option_indent">
        <form method="post" action="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/search/government/" class="form_select" id="form_government_government">
            <?php
echo view('search/form_government', ['form' => 'form_government_government']);
echo view('search/form_governmentparent', ['form' => 'form_government_government']);
echo view('search/form_governmentlevel', ['type' => 'countymunicipality', 'form' => 'form_government_government']);
echo view('search/submit', ['type' => 'government']);
?>
        </form>
        <form method="post" action="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/search/government/" class="form_select" id="form_government_statewide">
            <?php
echo view('search/form_governmentlevel', ['type' => 'statewide', 'form' => 'form_government_statewide']);
echo view('search/submit', ['type' => 'statewide']);
?>
        </form>
        <form method="post" action="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/search/government/" class="form_select" id="form_government_identifier">
            <label class="forselectize" for="form_government_identifier_governmentidentifiertype">Identifier Source</label><br>
            <select id="form_government_identifier_governmentidentifiertype" name="governmentidentifiertype" style="width: 300px;" required="required">
            </select>
            <br>
            <label class="forselectize" for="form_government_identifier_identifier">Identifier</label><br>
            <input id="form_government_identifier_identifier" class="selectize-input forselectize stringcheck required" name="identifier" type="text" style="width: 200px;" required="required">
            <br><br>
            <?php
echo view('search/submit', ['type' => 'identifier']);
?>
        </form>
    </div>
    <div id="forms_location" class="option_select option_indent">
        <form method="post" action="/<?= \Config\Services::request()->getLocale() ?>/address/" class="form_select" id="form_location_address">
            <label for="form_location_address_address" class="forselectize">Address</label><br>
            <input id="form_location_address_address" class="selectize-input forselectize stringcheck required" name="address" type="text" style="width: 300px;" required="required"><br>
            <br>
            <?php
echo view('search/submit', ['type' => 'address']);
?>
        </form>
        <form method="post" action="/<?= \Config\Services::request()->getLocale() ?>/point/" class="form_select" id="form_location_point">
            <label for="form_location_point_y" class="forselectize">Latitude</label><br>
            <input id="form_location_point_y" class="selectize-input forselectize stringcheck required" name="y" type="number" min="-180" max="180" step="any" style="width: 150px;" required="required"><br>
            <label for="form_location_point_x" class="forselectize">Longitude</label><br>
            <input id="form_location_point_x" class="selectize-input forselectize stringcheck required" name="x" type="number" min="-90" max="90" step="any" style="width: 150px;" required="required"><br>
            <br>
            <?php
echo view('search/submit', ['type' => 'point']);
?>
        </form>
    </div>
    <div id="forms_law" class="option_select option_indent">
        <form method="post" action="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/search/law/" class="form_select" id="form_law_reference">
            <label for="form_law_reference_yearvolume" class="forselectize">Year/Volume</label><br>
            <input id="form_law_reference_yearvolume" class="selectize-input required stringcheck forselectize" name="yearvolume" type="text" required="required" style="width: 100px;">
            <br>
            <label for="form_law_reference_page" class="forselectize">Page</label><br>
            <input id="form_law_reference_page" class="selectize-input forselectize" name="page" type="number" style="width: 100px;">
            <br>
            <label for="form_law_reference_numberchapter" class="forselectize">Number/Chapter</label><br>
            <input id="form_law_reference_numberchapter" class="selectize-input forselectize" name="numberchapter" type="number" style="width: 100px;">
            <br><br>
            <?php
echo view('search/submit', ['type' => 'reference']);
?>
        </form>
        <form method="post" action="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/search/law/" class="form_select" id="form_law_dateevent">
            <label for="form_law_dateevent_date" class="forselectize">Date</label><br>
            <input id="form_law_dateevent_date" class="selectize-input required stringcheck forselectize" name="date" type="date" required="required" pattern="\d{4}-\d{2}-\d{2}" title="Date should be formatted as YYYY-MM-DD." style="width: 150px;">
            <br>
            <?php
echo view('search/form_eventtype', ['isRequired' => true, 'form' => 'form_law_dateevent']);
?>
            <br>
            <?php
echo view('search/submit', ['type' => 'dateEvent']);
?>
        </form>
    </div>
</fieldset>
<script>
    var eventTypeList = <?= json_encode($eventTypeQuery); ?>;
    var governmentIdentifierTypeList = <?= json_encode($governmentIdentifierTypeQuery); ?>;
    var monthList = <?= json_encode($months); ?>;
    var reporterList = <?= json_encode($reporterQuery); ?>;
    var tribunalGovernmentShortList = <?= json_encode($tribunalgovernmentshortQuery); ?>;

    $(function() {

        $('input[type=radio][name=for]').change(function() {
            $('.option_select').css('display', 'none');
            $('#option_' + $(this).val()).css('display', 'inherit');
            $('#forms_' + $(this).val()).css('display', 'inherit');
        });

        $('input[type=radio][name^=by]').change(function() {
            $('#forms' + $(this).attr('name').substring(2) + ' .form_select').css('display', 'none');
            $('#form' + $(this).attr('name').substring(2) + '_' + $(this).val()).css('display', 'inherit');
        });

        var forValue = $('input[type=radio][name=for]').val();
        var byValue;

        $(['law', 'adjudication', 'location', 'government', 'event']).each(function(i, v) {
            byValue = $('input[type=radio][name=by_' + v + ']').val();
            $('input[type=radio][name=by_' + v + '][value=' + byValue + ']').trigger('click');
        });

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

        var xhr;
        var select_government = [];
        var $select_government = [];
        var select_governmentparent = [];
        var $select_governmentparent = [];

        $('select[name=government]').each(function(i) {
            $select_government[i] = $(this).selectize({
                selectOnTab: true,
                closeAfterSelect: true,
                highlight: false,
                setFirstOptionActive: true,
                options: [],
                valueField: 'governmentshort',
                labelField: 'governmentshort',
                searchField: ['governmentsearch', 'governmentshort'],
                sortField: [{
                    field: 'governmentshort',
                    direction: 'asc'
                }, {
                    field: '$score'
                }],
                load: function(query, callback) {
                    if (!query.length) {
                        return callback();
                    }
                    $.ajax({
                        url: '/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/lookup/government/' + query.toLowerCase() + '/',
                        dataType: 'json',
                        success: function(results) {
                            callback(results);
                        },
                        error: function() {
                            callback();
                        }
                    });
                },
                onChange: function(value) {
                    if (!value.length) {
                        return;
                    }
                    select_governmentparent[i].clearOptions();
                    select_governmentparent[i].load(function(callback) {
                        xhr && xhr.abort();
                        xhr = $.ajax({
                            url: '/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/lookup/governmentparent/' + encodeURIComponent(value.toLowerCase()) + '/',
                            dataType: 'json',
                            success: function(results) {
                                callback(results);
                            },
                            error: function() {
                                callback();
                            }
                        })
                    });
                }
            });

            matchParent = $('select[name=governmentparent]')[i];

            $select_governmentparent[i] = $(matchParent).selectize({
                selectOnTab: true,
                closeAfterSelect: true,
                highlight: false,
                setFirstOptionActive: true,
                valueField: 'governmentshort',
                labelField: 'governmentshort',
                searchField: ['governmentsearch', 'governmentshort'],
                sortField: [{
                    field: 'governmentshort',
                    direction: 'asc'
                }, {
                    field: '$score'
                }]
            });

            select_governmentparent[i] = $select_governmentparent[i][0].selectize;
            select_government[i] = $select_government[i][0].selectize;

        });

        $('select[name=governmentlevel]').selectize({
            selectOnTab: true,
            closeAfterSelect: true,
            highlight: false
        });

        $('select[name=governmentidentifiertype]').selectize({
            selectOnTab: true,
            closeAfterSelect: true,
            highlight: false,
            options: governmentIdentifierTypeList,
            valueField: 'governmentidentifiertypeshort',
            labelField: 'governmentidentifiertypeshort',
            searchField: 'governmentidentifiertypeshort'
        });

        $('select[name=tribunalgovernment]').selectize({
            selectOnTab: true,
            closeAfterSelect: true,
            highlight: false,
            options: tribunalGovernmentShortList,
            valueField: 'governmentshort',
            labelField: 'governmentshort',
            searchField: 'governmentshort'
        });

        $('select[name=reporter]').selectize({
            selectOnTab: true,
            closeAfterSelect: true,
            highlight: false,
            options: reporterList,
            valueField: 'sourceshort',
            labelField: 'sourceshort',
            searchField: 'sourceshort'
        });

        $('select[name=month]').selectize({
            selectOnTab: true,
            closeAfterSelect: true,
            highlight: false,
            options: monthList,
            valueField: 'monthNumber',
            labelField: 'monthName',
            searchField: ['monthName']
        });

        $('.stringcheck').change(function() {
            if ($(this).val() === '') {
                $(this).addClass('required');
            } else {
                $(this).removeClass('required');
            }
        });

    });
</script>