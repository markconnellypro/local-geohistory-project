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
        <a href="/<?= \Config\Services::request()->getLocale() ?>/about/" class="welcomeiconcontainer" aria-label="About">
            <span class="welcomeicon">info</span>
            <div style="height: auto;">About</div>
        </a>
        <a href="/<?= \Config\Services::request()->getLocale() ?>/key/" class="welcomeiconcontainer" aria-label="Key">
            <span class="welcomeiconfill">vpn_key</span>
            <div style="height: auto;">Key</div>
        </a>
        <a href="/<?= \Config\Services::request()->getLocale() ?>/search/" class="welcomeiconcontainer" aria-label="Search">
            <span class="welcomeicon">search</span>
            <div style="height: auto;">Search</div>
        </a>
        <a href="/<?= \Config\Services::request()->getLocale() ?>/statistics/" class="welcomeiconcontainer" aria-label="Statistics">
            <span class="welcomeicon">insert_chart</span>
            <div style="height: auto;">Statistics</div>
        </a>
        <a href="/<?= \Config\Services::request()->getLocale() ?>/status/" class="welcomeiconcontainer" aria-label="Status">
            <span class="welcomeicon">map</span>
            <div style="height: auto;">Status</div>
        </a>
    </div>
</div>