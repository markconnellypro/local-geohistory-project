<?php

declare(strict_types=1);

use Rector\Config\RectorConfig;
use Rector\TypeDeclaration\Rector\ClassMethod\AddVoidReturnTypeWhereNoReturnRector;
use Rector\Php81\Rector\FuncCall\NullToStrictStringFuncCallArgRector;

return RectorConfig::configure()
    ->withPaths([
        __DIR__ . '/app',
    ])
    ->withPhpSets(php84: true)
    ->withPreparedSets(deadCode: true, codeQuality: true)
    ->withRules([
        AddVoidReturnTypeWhereNoReturnRector::class,
    ])
    ->withSkip([
        NullToStrictStringFuncCallArgRector::class,
    ]);
