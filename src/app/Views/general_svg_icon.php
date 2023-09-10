<?php
$iconPath = (in_array($iconName, array_merge(['about', 'key', 'home', 'search', 'statistics'], \App\Controllers\BaseController::getProductionJurisdictions())) ? '' : 'development/') . 'image/' . $iconName;
if ($isInternetExplorer) { ?><img src="/asset/<?= $iconPath ?>.svg" class="<?= $iconType ?>" alt="<?= $iconLabel ?>" /><?php } else {
                                                                                                                        switch ($iconType) {
                                                                                                                            case 'bodyicon':
                                                                                                                            case 'headericon':
                                                                                                                                $iconSize = '128 85';
                                                                                                                                break;
                                                                                                                            case 'keyicon':
                                                                                                                            case 'keyiconlarge':
                                                                                                                                $iconSize = '24 24';
                                                                                                                                break;
                                                                                                                            case 'keyicontext':
                                                                                                                                $iconSize = '28 28';
                                                                                                                                break;
                                                                                                                            default:
                                                                                                                                $iconSize = '0 0';
                                                                                                                        } ?><svg viewBox="0 0 <?= $iconSize ?>" class="<?= $iconType ?>" role="img" aria-label="<?= $iconLabel ?>">
        <use xlink:href="/asset/<?= $iconPath ?>.svg#icon"></use>
    </svg><?php } ?>
