<?php

date_default_timezone_set("Asia/kolkata");

class MyURL
{
    /* @var string $key */
    public static $key;

    /* @var string $baseURL */
    public static $baseURL = "http://localhost/IntacctOffice/public";

    /**
     * @param string $url
     *
     * @return string
     */
    public static function generate($url)
    {
        return self::$baseURL . "/?" . OFFICEDISTANCEMATRIX . "=" . $url;
    }

    /**
     * @return string
     */
    public static function getKeyName()
    {
        return OFFICEDISTANCEMATRIX;
    }
}