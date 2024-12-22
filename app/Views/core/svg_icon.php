<?php if (isset($iconLabel) && isset($iconName) && isset($iconType)) {
    $iconPath = (in_array($iconName, array_merge(['about', 'key', 'home', 'search', 'statistics'], \App\Controllers\BaseController::getProductionJurisdictions())) ? '' : 'development/') . 'image/' . $iconName;
    if (\App\Controllers\BaseController::isInternetExplorer()) { ?><img src="/asset/application/<?= $iconPath ?>.svg" class="<?= $iconType ?>" alt="<?= $iconLabel ?>"><?php } else {
        $iconSize = match ($iconType) {
            'bodyicon', 'keyicon', 'keyiconlarge' => '24 24',
            'keyicontext' => '28 28',
            default => '0 0',
        }; ?><svg viewBox="0 0 <?= $iconSize ?>" class="<?= $iconType ?>" role="img" aria-label="<?= $iconLabel ?>">
        <use xlink:href="/asset/application/<?= $iconPath ?>.svg#icon"></use>
    </svg><?php }
    } ?>
