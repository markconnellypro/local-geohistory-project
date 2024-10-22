<?php

$link ??= '';
$text ??= '';
$type ??= '';
if ($link === '' || $text === '') {
    echo $text;
} else {
    echo '<a href="' .
        ($type !== '' ? '/' . \Config\Services::request()->getLocale() . '/' . $type . '/' : '') .
        $link . ($type !== '' ? '/' : '') . '">' . $text . '</a>';
}
