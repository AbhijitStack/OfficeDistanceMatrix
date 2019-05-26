<?php


require_once __DIR__ . '/../app/MyURL.php';;
require_once __DIR__ . '/../vendor/autoload.php';


class Cron{

    /**
     * Cron constructor.
     * @param string $officedistancematrix
     */
    public function __construct($officedistancematrix)
    {
        MyURL::$key = $officedistancematrix;
    }

    public function execute(){
        require_once __DIR__ . '/../app/SimpleAppUI.php';
    }

}

(new Cron('cron'))->execute();