<!DOCTYPE html>
<html lang="<?= \Config\Services::request()->getLocale() ?>">

<head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta charset="UTF-8">
    <title><?= (!isset($pageTitle) ? '' : $pageTitle . ' | ') . (!isset($pageTitleType) ? '' : $pageTitleType . ' | ') . $title . ' | ' . (empty($state) ? '' : strtoupper($state) . ' | ') ?><?= lang('Template.projectName') ?></title>
    <link rel="preload" href="/asset/font/lora-regular.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="preload" href="/asset/font/lora-semibold.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="preload" href="/asset/font/lora-italic.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="preload" href="/asset/font/lora-semibolditalic.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="preload" href="/asset/font/frederickathegreat.woff2" as="font" type="font/woff2" crossorigin="anonymous">
    <link rel="stylesheet" href="/asset/css/geohistory.css" media="all">
    <?php if (ENVIRONMENT == 'development') { ?>
        <link rel="stylesheet" href="/asset/development/css/development.css" media="all">
    <?php } ?>
    <link rel="icon" href="/asset/image/favicon.png" type="image/png">
    <script src="/<?= ($online ? '/unpkg.com/jquery@3.7.1/dist' : 'asset/tool/jquery') ?>/jquery.min.js"></script>
    <script src="/<?= ($online ? '/cdn.datatables.net/1.13.6/js' : 'asset/tool/datatables') ?>/jquery.dataTables.min.js"></script>
    <link rel="stylesheet" href="/<?= ($online ? '/cdn.datatables.net/1.13.6/css' : 'asset/tool/datatables') ?>/jquery.dataTables.min.css" crossorigin="anonymous">
    <script src="/asset/tool/datatables/table.js"></script>
</head>

<body>
    <?php if ($title == 'Welcome') { ?>
        <img src="/asset/image/ct001800.jpg" id="welcome" alt="Map of annexations to Los Angeles from 1916">
    <?php } ?>
    <div class="wrapper" <?= ($title == 'Welcome' ? ' id="welcomewrapper"' : '') ?>>
        <header class="headerfooter">
            <div id="headertext">
                <div id="headertitle"><a href="/<?= \Config\Services::request()->getLocale() ?>/"><?= lang('Template.projectName') ?></a></div>
                <div id="headerimagenavigation">
                    <div class="headerimageblock">
                        <?php if (!empty($state) and $state != 'usa') { ?>
                            <a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/" aria-label="<?= strtoupper($state) ?>">
                                <?= view('general_svg_icon', ['iconLabel' => strtoupper($state) . ' map icon', 'iconName' => $state, 'iconType' => 'headericon']); ?>
                                <br><?= strtoupper($state) ?>
                            </a>
                        <?php } ?>
                    </div>
                    <nav id="headernavigation">
                        <div id="headernavigationpart">
                            <div id="headernavigationpartpart">
                                <div class="keyiconcontainer">
                                    <a href="/<?= \Config\Services::request()->getLocale() ?>/" aria-label="Return to Home">
                                        <?= view('general_svg_icon', ['iconLabel' => 'home icon', 'iconName' => 'home', 'iconType' => 'keyiconlarge']); ?>
                                    </a>
                                </div>
                                <?php if (!empty($state)) { ?>
                                    <div class="keyiconcontainer">
                                        <a href="/<?= \Config\Services::request()->getLocale() ?>/<?= $state ?>/" aria-label="Search">
                                            <?= view('general_svg_icon', ['iconLabel' => 'magnifying glass icon', 'iconName' => 'search', 'iconType' => 'keyiconlarge']); ?>
                                        </a>
                                    </div>
                                <?php } ?>
                                <div class="keyiconcontainer">
                                    <a href="/<?= \Config\Services::request()->getLocale() ?><?= ((!empty($state) and $state != 'usa') ? '/' . $state : '') ?>/about/" aria-label="About">
                                        <?= view('general_svg_icon', ['iconLabel' => 'about icon', 'iconName' => 'about', 'iconType' => 'keyiconlarge']); ?>
                                    </a>
                                </div>
                                <div class="keyiconcontainer">
                                    <a href="/<?= \Config\Services::request()->getLocale() ?>/key/" aria-label="Key">
                                        <?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyiconlarge']); ?>
                                    </a>
                                </div>
                                <div class="keyiconcontainer">
                                    <a href="/<?= \Config\Services::request()->getLocale() ?><?= ((!empty($state) and $state != 'usa') ? '/' . $state : '') ?>/statistics/" aria-label="Statistics">
                                        <?= view('general_svg_icon', ['iconLabel' => 'statistics icon', 'iconName' => 'statistics', 'iconType' => 'keyiconlarge']); ?>
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