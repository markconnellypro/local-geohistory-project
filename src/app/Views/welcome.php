<?php if (is_array($stateArray ?? '') && $stateArray !== []) { ?>
<div class="push">&nbsp;</div>
<div id="welcomecontainer">
    <div id="welcometext" class="welcomecontent">The <?= getenv('app_title_en') ?> aims to educate users and disseminate information concerning the geographic history and structure of political subdivisions and local government. Select a state to begin.</div>
    <div id="welcomestate" class="welcomecontent">
        <?php foreach ($stateArray as $s) { ?>
            <a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $s ?>/" class="bodyiconcontainer headerimageblock" aria-label="<?= strtoupper($s) ?>">
                <?= view('core/svg_icon', ['iconLabel' => strtoupper($s) . ' map icon', 'iconName' => $s, 'iconType' => 'bodyicon']); ?>
                <div style="height: auto;"><?= strtoupper($s) ?></div>
            </a>
        <?php } ?>
    </div>
</div>
<?php } ?>