<?php if (is_array($query ?? '') && $query !== []) { ?>
    var affectedgovernmenttype = <?= json_encode($query); ?>;
<?php }
