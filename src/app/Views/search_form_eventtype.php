<label class="forselectize" for="<?= $form ?>_eventtype"> Event Type</label>
<a href="/<?= \Config\Services::request()->getLocale() ?>/key/#eventtype" class="forselectize" aria-label="Event Type Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicontext']); ?></a>
<br />
<select id="<?= $form ?>_eventtype" name="eventtype" style="width: 300px;" <?= ($isRequired ? ' required="required"' : '') ?>>
</select>
<br />