<?php if (is_array($query ?? '') && $query !== []) { ?>
<section>
    <h2>Summary</h2>
    <table class="normal cell-border compact stripe">
        <thead>
            <tr>
                <?php if (\App\Controllers\BaseController::isLive()) { ?>
                    <th>ID</th>
                <?php } ?>
                <th>Citation <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#law" aria-label="Law Key" title="Law Key"><span class="keyiconfill">vpn_key</span></a></th>
                <th>Title</th>
                <th>Page Begin</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <?php if (\App\Controllers\BaseController::isLive()) { ?>
                    <td><?= $query[0]->lawsectionid ?></td>
                <?php } ?>
                <td><?= $query[0]->lawsectioncitation ?></td>
                <td><?= $query[0]->lawtitle ?></td>
                <td><?= $query[0]->lawsectionpagefrom ?></td>
            </tr>
        </tbody>
    </table>
</section>
<?php } ?>