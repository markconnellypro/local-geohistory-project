<?php

$finder = (new PhpCsFixer\Finder())
    ->in(__DIR__)
    ->exclude([
        'build',
    ])
    ->notPath([
        'app/Config/Cache.php',
        'app/Config/Events.php',
        'app/Config/ForeignCharacters.php',
        'app/Config/Logger.php',
    ])
;

return (new PhpCsFixer\Config())
    ->setRules([
        '@PER-CS' => true,
        '@PHP83Migration' => true,
    ])
    ->setFinder($finder)
;