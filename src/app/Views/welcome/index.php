<div class="push">&nbsp;</div>
<div id="welcomecontainer">
    <div id="welcometext" class="welcomecontent">The <?= getenv('app_title_en') ?> aims to educate users and disseminate information concerning the geographic history and structure of political subdivisions and local government.</div>
    <div id="welcomestate" class="welcomecontent">
        <?php foreach ($icons as $icon) { ?>
            <a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $icon ?>/" class="bodyiconcontainer headerimageblock" aria-label="<?= ucwords($icon) ?>">
                <?= view('core/svg_icon', ['iconLabel' => $icon . ' icon', 'iconName' => $icon, 'iconType' => 'bodyicon']); ?>
                <div style="height: auto;"><?= ucwords($icon) ?></div>
            </a>
        <?php } ?>
    </div>
</div>