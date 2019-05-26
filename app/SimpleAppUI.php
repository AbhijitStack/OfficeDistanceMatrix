<?php

use TeamPickr\DistanceMatrix\Response\Row;
spl_autoload_register("loadClasses");

/**
 * @param string $className
 */
function loadClasses($className)
{
    require_once __DIR__ . "\classes\\{$className}.cls";
}

/**
 * @param string $name
 * @param array $viewVar
 */
function view($name, $viewVar = [])
{
    if (!ctype_alpha($name)) {
        echo "Can't view this page!";
        exit(0);
    }
    $filePath = __DIR__ . "/../resources/view/{$name}.phtml";

    if (file_exists($filePath)) {
        extract($viewVar);
        unset($viewVar);
        require_once $filePath;
    } else {
        echo "File Not Found !!!";
        exit(0);
    }
}

class SimpleAppUI
{

    public function route()
    {
        switch (MyURL::$key) {
            case 'takeInput':
                view("index");
                break;
            case 'setDetails':
                (new OfficeDistanceMatrixCtrl())->setDetails();
                break;
            case 'cron':
                (new OfficeDistanceMatrixCtrl())->runMatrix();
                break;
            case 'Analysis':
                (new OfficeDistanceMatrixCtrl())->analize();
                break;
            case 'downloadCSV':
                (new OfficeDistanceMatrixCtrl())->downloadCSV();
                break;
            case 'downloadCSVFile':
                (new OfficeDistanceMatrixCtrl())->downloadCSVFile();
                break;
            default:
                echo "File not found!!!";
                exit(0);
        }
    }
}

$simpleAppUI = new SimpleAppUI();
$simpleAppUI->route();