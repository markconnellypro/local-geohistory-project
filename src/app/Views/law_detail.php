<section>
    <h2>Summary</h2>
    <table class="normal row-border cell-border compact stripe">
        <thead>
            <tr>
                <th>Citation <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#law" aria-label="Law Key"><?= view('general_svg_icon', ['iconLabel' => 'key icon', 'iconName' => 'key', 'iconType' => 'keyicon']); ?></a></th>
                <th>Title</th>
                <th>Page Begin</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><?= $query[0]->lawsectioncitation ?></td>
                <td><?= $query[0]->lawtitle ?></td>
                <td><?= $query[0]->lawsectionpagefrom ?></td>
            </tr>
        </tbody>
    </table>
</section>