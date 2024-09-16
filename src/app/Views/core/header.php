<?php
$state ??= 'usa';
$title ??= '';
?>
<!DOCTYPE html>
<html lang="<?= \Config\Services::request()->getLocale() ?>">

<head>
    <?php if (\App\Controllers\BaseController::isLive() === false && ($_ENV['analytics_google'] ?? '') !== '') { ?>
        <!-- Google tag (gtag.js) -->
        <script async src="https://www.googletagmanager.com/gtag/js?id=<?= $_ENV['analytics_google'] ?>"></script>
        <script>
            window.dataLayer = window.dataLayer || [];

            function gtag() {
                dataLayer.push(arguments);
            }
            gtag('js', new Date());

            gtag('config', '<?= $_ENV['analytics_google'] ?>');
        </script>
    <?php } ?>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta charset="UTF-8">
    <title><?= (isset($pageTitle) ? $pageTitle . ' | ' : '') . (isset($pageTitleType) ? $pageTitleType . ' | ' : '') . $title . ' | ' . ($state !== '' && $state !== 'usa' ? strtoupper($state) . ' | ' : '') ?><?= lang('Template.projectName') ?></title>
    <link rel="preload" href="/asset/font/lora-regular.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="preload" href="/asset/font/lora-semibold.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="preload" href="/asset/font/lora-italic.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="preload" href="/asset/font/lora-semibolditalic.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="preload" href="/asset/font/frederickathegreat.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="stylesheet" href="/asset/css/geohistory.css" media="all">
    <?php if (\App\Controllers\BaseController::isLive()) { ?>
        <link rel="stylesheet" href="/asset/development/css/development.css" media="all">
    <?php } ?>
    <link rel="icon" href="/asset/image/favicon.png" type="image/png">
    <script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_jquery') : 'asset/dependency') ?>/jquery.min.js"></script>
    <script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_datatables') : 'asset/dependency') ?>/js/dataTables.min.js"></script>
    <link rel="stylesheet" href="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_datatables') : 'asset/dependency') ?>/css/dataTables.dataTables.min.css">
    <script src="/asset/tool/table.js"></script>
</head>

<body>
    <?php if ($title === 'Welcome') { ?>
        <img src="/asset/image/ct001800.jpg" id="welcome" alt="Map of annexations to Los Angeles from 1916">
    <?php } ?>
    <div class="wrapper" <?= ($title === 'Welcome' ? ' id="welcomewrapper"' : '') ?>>
        <header class="headerfooter">
            <div id="headertext">
                <div id="headertitle"><a href="/<?= \Config\Services::request()->getLocale() ?>/"><?= lang('Template.projectName') ?></a></div>
                <div id="headerimagenavigation">
                    <div class="headerimageblock">
                        <?php if ($state !== '' && $state !== 'usa') { ?>
                            <a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/" aria-label="<?= strtoupper($state) ?>">
                                <?= view('core/svg_icon', ['iconLabel' => strtoupper($state) . ' map icon', 'iconName' => $state, 'iconType' => 'headericon']); ?>
                                <br><?= strtoupper($state) ?>
                            </a>
                        <?php } ?>
                    </div>
                    <nav id="headernavigation">
                        <div id="headernavigationpart">
                            <div id="headernavigationpartpart">
                                <div class="keyiconcontainer">
                                    <a href="/<?= \Config\Services::request()->getLocale() ?>/" aria-label="Return to Home">
                                        <?= view('core/svg_icon', ['iconLabel' => 'home icon', 'iconName' => 'home', 'iconType' => 'keyiconlarge']); ?>
                                    </a>
                                </div>
                                <?php if ($state !== '' && $state !== 'usa') { ?>
                                    <div class="keyiconcontainer">
                                        <a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/" aria-label="Search">
                                            <?= view('core/svg_icon', ['iconLabel' => 'magnifying glass icon', 'iconName' => 'search', 'iconType' => 'keyiconlarge']); ?>
                                        </a>
                                    </div>
                                <?php } ?>
                                <div class="keyiconcontainer">
                                    <a href="/<?= \Config\Services::request()->getLocale() ?><?= (($state !== '' && $state !== 'usa') ? '/' . $state : '') ?>/about/" aria-label="About">
                                        <?= view('core/svg_icon', ['iconLabel' => 'about icon', 'iconName' => 'about', 'iconType' => 'keyiconlarge']); ?>
                                    </a>
                                </div>
                                <div class="keyiconcontainer">
                                    <a href="/<?= \Config\Services::request()->getLocale() ?>/key/" aria-label="Key">
                                        <?= view('core/svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyiconlarge']); ?>
                                    </a>
                                </div>
                                <div class="keyiconcontainer">
                                    <a href="/<?= \Config\Services::request()->getLocale() ?><?= (($state !== '' && $state !== 'usa') ? '/' . $state : '') ?>/statistics/" aria-label="Statistics">
                                        <?= view('core/svg_icon', ['iconLabel' => 'statistics icon', 'iconName' => 'statistics', 'iconType' => 'keyiconlarge']); ?>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </nav>
                </div>
            </div>
        </header>
        <main class="bodytext" <?= (isset($widthOverride) ? ' style="width: ' . $widthOverride . 'px; max-width: ' . $widthOverride . 'px;"' : '') ?>>
            <?php if ($title !== 'Welcome') { ?>
                <h1 id="topheader"><?= $title ?></h1>
            <?php } ?>