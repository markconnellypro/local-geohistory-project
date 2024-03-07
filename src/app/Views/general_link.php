<?php

$link ??= '';
$text ??= '';
if ($link === '' || $text === '') {
    echo $text;
} else {
    echo '<a href="' . $link . '">' . $text . '</a>';
}
