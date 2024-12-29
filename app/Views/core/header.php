<?php
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
    <title><?= (isset($pageTitle) ? $pageTitle . ' | ' : '') . (isset($pageTitleType) ? $pageTitleType . ' | ' : '') . $title ?> | <?= lang('Template.projectName') ?></title>
    <link rel="preload" href="/asset/font/lora-regular.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="preload" href="/asset/font/lora-semibold.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="preload" href="/asset/font/lora-italic.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="preload" href="/asset/font/lora-semibolditalic.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="preload" href="/asset/font/materialsymbolsoutlined.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="preload" href="/asset/font/frederickathegreat.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="stylesheet" href="/asset/application/css/geohistory.css" media="all">
    <?php if (\App\Controllers\BaseController::isLive()) { ?>
        <link rel="stylesheet" href="/asset/development/css/development.css" media="all">
    <?php } ?>
    <link rel="icon" href="/asset/application/image/favicon.png" type="image/png">
    <script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_jquery') : 'asset/application/dependency') ?>/jquery.min.js"></script>
    <script src="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_datatables') : 'asset/application/dependency') ?>/js/dataTables.min.js"></script>
    <link rel="stylesheet" href="/<?= (\App\Controllers\BaseController::isOnline() ? '/' . getenv('dependency_datatables') : 'asset/application/dependency') ?>/css/dataTables.dataTables.min.css">
    <script src="/asset/application/tool/table.js"></script>
</head>

<body>
    <?php if ($title === 'Welcome') { ?>
        <img src="/asset/application/image/ct001800.jpg" id="welcome" alt="Map of annexations to Los Angeles from 1916">
    <?php } ?>
    <div class="wrapper" <?= ($title === 'Welcome' ? ' id="welcomewrapper"' : '') ?>>
        <header class="headerfooter">
            <div id="headertext">
                <div id="headertitle"><a href="/<?= \Config\Services::request()->getLocale() ?>/"><?= lang('Template.projectName') ?></a></div>
                <?php if ($title !== 'Welcome') { ?>
                    <nav id="headernavigation">
                            <div id="headernavigationpart">
                                <div id="headernavigationpartpart">
                                    <div class="keyiconcontainer">
                                        <a href="/<?= \Config\Services::request()->getLocale() ?>/" aria-label="Return to Home" title="Return to Home">
                                            <span class="headericonfill">home</span>
                                        </a>
                                    </div>
                                    <div class="keyiconcontainer">
                                        <a href="/<?= \Config\Services::request()->getLocale() ?>/about/" aria-label="About" title="About">
                                            <span class="headericon">info</span>
                                        </a>
                                    </div>
                                    <div class="keyiconcontainer">
                                        <a href="/<?= \Config\Services::request()->getLocale() ?>/key/" aria-label="Key" title="Key">
                                        <span class="headericonfill">vpn_key</span>
                                        </a>
                                    </div>
                                    <div class="keyiconcontainer">
                                        <a href="/<?= \Config\Services::request()->getLocale() ?>/search/" aria-label="Search" title="Search">
                                            <span class="headericon">search</span>
                                        </a>
                                    </div>
                                    <div class="keyiconcontainer">
                                        <a href="/<?= \Config\Services::request()->getLocale() ?>/statistics/" aria-label="Statistics" title="Statistics">
                                            <span class="headericon">insert_chart</span>
                                        </a>
                                    </div>
                                    <div class="keyiconcontainer">
                                        <a href="/<?= \Config\Services::request()->getLocale() ?>/status/" aria-label="Status" title="Status">
                                            <span class="headericon">map</span>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </nav>
                <?php } ?>
            </div>
        </header>
        <main class="bodytext" <?= (isset($widthOverride) ? ' style="width: ' . $widthOverride . 'px; max-width: ' . $widthOverride . 'px;"' : '') ?>>
            <?php if ($title !== 'Welcome') { ?>
                <h1><?= $title ?></h1>
            <?php } ?>