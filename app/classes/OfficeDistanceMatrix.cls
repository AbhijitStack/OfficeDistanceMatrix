<?php

use TeamPickr\DistanceMatrix\Licenses\StandardLicense;
use TeamPickr\DistanceMatrix\DistanceMatrix as DistanceMatrix;

//https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=000000&destinations=000000&key=

class OfficeDistanceMatrix
{
    /* @var OfficeDistanceMatrix|null $officeDistanceMatrix */
    public static $officeDistanceMatrix = null;

    /* @var bool $gInstance */
    private static $gInstance = false;

    /* @var string $apiKey */
    private $apiKey = "";

    /** @var bool $testModeStore */
    private $testModeStore = false;

    /** @var DistanceMatrix $requestObj */
    private $requestObj;

    /** @var DistanceMatrix $responseObj */
    private $responseObj;

    /**
     * OfficeDistanceMatrix constructor.
     */
    public function __construct()
    {
//        if (!self::$gInstance) {
//            echo "call getInstance()";
//            exit(0);
//        }


        if ($this->testModeStore) {
            $this->apiKey = "";
            echo "<br/>Test Mode is ON<br/><br/>";
        }
        $license = new StandardLicense($this->apiKey);
        $this->requestObj = new DistanceMatrix($license);
    }

//    /**
//     * @return OfficeDistanceMatrix|null
//     */
//    public static function getInstance()
//    {
//        self::$gInstance = true;
//        if (self::$officeDistanceMatrix === null) {
//            self::$officeDistanceMatrix = new OfficeDistanceMatrix();
//        }
//        self::$gInstance = false;
//        return self::$officeDistanceMatrix;
//    }


    /**
     * @param string[] $origins
     * @param string $destination
     *
     * @return bool
     */
    public function doRequest($origins, $destination)
    {
        try {
            $this->requestObj->avoidHighways();
            $this->requestObj->avoidTolls();
            $this->requestObj->setDepartureTime(time());
            $this->requestObj->setTrafficModel("");
            $this->requestObj->setUnits("metric");
            foreach ($origins as $origin) {
                $this->requestObj->addOrigin($origin);
                break;
            }
            $this->requestObj->addDestination($destination);
            $this->responseObj = $this->requestObj->request();
        } catch (\Exception $ex) {
            return false;
        }
        return true;
    }

    /**
     * @return string[][]
     */
    public function getResponseArr()
    {
        if ($this->testModeStore) {
            return json_decode($this->getTestResponseJson(), 1);
        }
        $responseArr = [];
        $rows = $this->responseObj->rows();
        foreach ($rows as $row) {
            /* @var \TeamPickr\DistanceMatrix\Response\Row $row */
            $rowElements = $row->elements();
            foreach ($rowElements as $rowElement) {
                /* @var  \TeamPickr\DistanceMatrix\Response\Element $rowElement */
                if ($rowElement->successful()) {
                      $responseArr[] =
                        $this->decorateResponse(
                            $rowElement->distanceText(),
                            $rowElement->distance(),
                            $rowElement->durationText(),
                            $rowElement->duration(),
                            $rowElement->durationInTrafficText(),
                            $rowElement->durationInTraffic()
                        );
                }
            }
        }

        return $responseArr;
    }

    /**
     * @param string $distance_text
     * @param string $distance_value
     * @param string $duration_text
     * @param string $duration_value
     * @param string $durationInTraffic_text
     * @param string $durationInTraffic_value
     *
     * @return array
     */
    public function decorateResponse($distance_text = '', $distance_value = '0', $duration_text = '',
                                     $duration_value = '0', $durationInTraffic_text = '', $durationInTraffic_value = '0')
    {
        return [
            "distance_text" => $distance_text,
            "distance_value" => $distance_value,
            "duration_text" => $duration_text,
            "duration_value" => $duration_value,
            "durationInTraffic_text" => $durationInTraffic_text,
            "durationInTraffic_value" => $durationInTraffic_value,
        ];
    }

    /**
     * @return string
     */
    private function getTestResponseJson()
    {
        return '[{"distance_text":"12.4 km","distance_value":12416,
        "duration_text":"39 mins","duration_value":2327},
        {"distance_text":"20.5 km","distance_value":20519,
        "duration_text":"41 mins","duration_value":2449}]';
    }
}


