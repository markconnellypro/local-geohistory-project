<?php
$icons ??= [];
$mastodon = $_ENV['mastodon'] ?? '';
$welcome ??= '';
?>
<?php if ($mastodon !== '') { ?>
<link rel="me" href="<?= $mastodon ?>" />
<?php } ?>
<div class="push">&nbsp;</div>
<div id="welcomecontainer">
    <div id="welcometext" class="welcomecontent"><?= $welcome ?></div>
    <div id="welcomestate" class="welcomecontent">
        <?php foreach ($icons as $icon) { ?>
            <a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $icon ?>/" class="bodyiconcontainer headerimageblock" aria-label="<?= ucwords($icon) ?>">
                <?= view('core/svg_icon', ['iconLabel' => $icon . ' icon', 'iconName' => $icon, 'iconType' => 'bodyicon']); ?>
                <div style="height: auto;"><?= ucwords($icon) ?></div>
            </a>
        <?php } ?>
    </div>
</div>