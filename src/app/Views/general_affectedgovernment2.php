<section>
    <?php if ($isComplete) { ?>
        <h2>Affected Government</h2>
    <?php } ?>
    <table class="normal row-border cell-border compact stripe wrap">
        <thead>
            <tr>
                <?php if ($includeDate) { ?>
                    <th>Detail</th>
                    <th>Date <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#date" aria-label="Date Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a>
                    </th>
                <?php } elseif ($live and $isComplete) { ?>
                    <th>Map<br />Link</th>
                    <?php }
                foreach ($affectedGovernment['types'] as $fromTo => $levels) {
                    foreach ($levels as $levelOrder => $level) { ?>
                        <th><?= ucfirst($fromTo) . '<br />' . str_replace(' ', '<br />', $level) ?></th>
                <?php  }
                } ?>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($affectedGovernment['rows'] as $id => $row) { ?>
                <tr>
                    <?php if ($includeDate) { ?>
                        <td data-sort="<?= $row->eventorder ?>"><?php echo view('general_link', ['link' => (empty($row->eventslug) ? '' : "/" . \Config\Services::request()->getLocale() . "/" . $state . "/event/" . $row->eventslug . "/"), 'text' => (empty($row->eventslug) ? 'Missing' : 'View')]) ?></td>
                        <td data-sort="<?= $row->eventsortdate ?>"><?= (empty($row->eventeffective) ? $row->eventrange : $row->eventeffective) ?></td>
                    <?php } elseif ($live and $isComplete) { ?>
                        <td>

                            <?php foreach ($affectedGovernment['linkTypes'] as $fromTo => $levels) {
                                foreach ($levels as $levelOrder => $level) {
                                    if (isset($row->{ucfirst($fromTo) . ' ' . $level . ' Long'})) { ?>
                                        <?php echo view('general_link', ['link' => str_replace('government', 'governmentmap', $row->{ucfirst($fromTo) . ' ' . $level . ' Link'}) . $id . "/", 'text' => ucfirst($fromTo)]) ?><br />
                            <?php
                                    }
                                }
                            } ?>
                        </td>
                        <?php }
                    foreach ($affectedGovernment['types'] as $fromTo => $levels) {
                        foreach ($levels as $levelOrder => $level) { ?>
                            <td>
                                <?php if (isset($row->{ucfirst($fromTo) . ' ' . $level . ' Long'})) { ?>
                                    <?php echo view('general_link', ['link' => $row->{ucfirst($fromTo) . ' ' . $level . ' Link'}, 'text' => $row->{ucfirst($fromTo) . ' ' . $level . ' Long'}]) ?>
                                    <br /><span class="i"><?= $row->{ucfirst($fromTo) . ' ' . $level . ' Affected'} ?> <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#affectedtype" aria-label="Affected Type Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicontext']); ?></a></span>
                                <?php } ?>
                            </td>
                    <?php }
                    } ?>
                </tr>
            <?php } ?>
        </tbody>
    </table>
</section>