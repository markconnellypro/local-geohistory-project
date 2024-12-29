<?php
$affectedGovernment ??= ['linkTypes' => [], 'rows' => [], 'types' => []];
$includeDate ??= false;
$isComplete ??= true;
?>
<section>
    <?php if ($isComplete) { ?>
        <h2>Affected Government</h2>
    <?php } ?>
    <table class="normal cell-border compact stripe wrap">
        <thead>
            <tr>
                <?php if ($includeDate) { ?>
                    <th>Detail</th>
                    <th>Date <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#date" aria-label="Date Key" title="Date Key"><span class="keyiconfill">vpn_key</span></a>
                    </th>
                <?php } elseif (\App\Controllers\BaseController::isLive() && $isComplete) { ?>
                    <th>Map<br>Link</th>
                    <?php }
                foreach ($affectedGovernment['types'] as $fromTo => $levels) {
                    foreach ($levels as $level) { ?>
                        <th><?= ucfirst($fromTo) . '<br>' . str_replace(' ', '<br>', $level) ?></th>
                <?php  }
                } ?>
            </tr>
        </thead>
        <tbody>
            <?php if (is_array($affectedGovernment['rows'] ?? '') && $affectedGovernment['rows'] !== []) {
                foreach ($affectedGovernment['rows'] as $id => $row) { ?>
                <tr>
                    <?php if ($includeDate) { ?>
                        <td data-sort="<?= $row->eventsort ?>"><?php echo view('core/link', [
                            'type' => 'event',
                            'link' => $row->eventslug,
                            'text' => ($row->eventslug  === '' ? 'Missing' : 'View'),
                        ]) ?></td>
                        <td data-sort="<?= $row->eventsort ?>"><?= $row->eventeffective ?></td>
                    <?php } elseif (\App\Controllers\BaseController::isLive() && $isComplete) { ?>
                        <td>

                            <?php if (is_array($affectedGovernment['linkTypes'] ?? '') && $affectedGovernment['linkTypes'] !== []) {
                                foreach ($affectedGovernment['linkTypes'] as $fromTo => $levels) {
                                    foreach ($levels as $level) {
                                        if (isset($row->{ucfirst($fromTo) . ' ' . $level . ' Long'})) { ?>
                                        <?php echo view('core/link', [
                                            'type' => 'governmentmap',
                                            'link' => $row->{ucfirst($fromTo) . ' ' . $level . ' Link'} . '/' . $id,
                                            'text' => ucfirst($fromTo),
                                        ]) ?><br>
                            <?php
                                        }
                                    }
                                }
                            } ?>
                        </td>
                        <?php }
                    if (is_array($affectedGovernment['types'] ?? '') && $affectedGovernment['types'] !== []) {
                        foreach ($affectedGovernment['types'] as $fromTo => $levels) {
                            foreach ($levels as $level) { ?>
                            <td>
                                <?php if (isset($row->{ucfirst($fromTo) . ' ' . $level . ' Long'})) { ?>
                                    <?php echo view('core/link', [
                                        'type' => 'government',
                                        'link' => $row->{ucfirst($fromTo) . ' ' . $level . ' Link'},
                                        'text' => $row->{ucfirst($fromTo) . ' ' . $level . ' Long'},
                                    ]) ?>
                                    <br><span class="i"><?= $row->{ucfirst($fromTo) . ' ' . $level . ' Affected'} ?> <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#affectedtype" aria-label="Affected Type Key" title="Affected Type Key"><span class="keyiconfill">vpn_key</span></a></span>
                                <?php } ?>
                            </td>
                    <?php }
                            }
                    } ?>
                </tr>
            <?php }
                } ?>
        </tbody>
    </table>
</section>