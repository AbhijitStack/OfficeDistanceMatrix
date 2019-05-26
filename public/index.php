<?php

define("OFFICEDISTANCEMATRIX", "officedistancematrix");
define("ALLOWEDURLKEYS", [
    "takeInput",
    "show",
    "setDetails",
    "Analysis",
    "downloadCSV",
    "downloadCSVFile"
]);

if (isset($_REQUEST[OFFICEDISTANCEMATRIX]) && in_array($_REQUEST[OFFICEDISTANCEMATRIX], ALLOWEDURLKEYS)) {
    require_once __DIR__ . '/../app/MyURL.php';
    MyURL::$key = $_REQUEST['officedistancematrix'];
    require_once __DIR__ . '/../vendor/autoload.php';
    require_once __DIR__ . '/../app/SimpleAppUI.php';
} else {
    echo "Test URL :: Hello World!!!";
}

