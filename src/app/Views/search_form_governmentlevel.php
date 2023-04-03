<label class="forselectize" for="<?= $form ?>_governmentlevel"> Level</label>
<a href="/<?= \Config\Services::request()->getLocale() ?>/key/#governmentlevel" class="forselectize" aria-label="Level Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicontext']); ?></a>
<br />
<select id="<?= $form ?>_governmentlevel" name="governmentlevel" style="width: 300px;" required="required">
    <option></option>
    <?php if ($type !== 'statewide') { ?>
        <option value="Municipality">Municipality</option>
    <?php } ?>
    <option value="County">County</option>
    <option value="State">State</option>
</select>
<br /><br />