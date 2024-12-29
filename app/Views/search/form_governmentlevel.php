<?php
$form ??= '';
$type ??= '';
?>
<label class="forselectize" for="<?= $form ?>_governmentlevel"> Level</label>
<a href="/<?= \Config\Services::request()->getLocale() ?>/key/#governmentlevel" class="forselectize" aria-label="Level Key" title="Level Key"><span class="keyiconfill">vpn_key</span></a>
<br>
<select id="<?= $form ?>_governmentlevel" name="governmentlevel" style="width: 300px;" required="required">
    <option></option>
    <?php if ($type !== 'statewide') { ?>
        <option value="Municipality">Municipality</option>
    <?php } ?>
    <option value="County">County</option>
    <option value="State">State</option>
</select>
<br><br>