<?php

use Rewritevendor\Teampickr\Element;

class OfficeDistanceMatrixCtrl
{
    public function setDetails()
    {
        $origins = explode("\n", $_POST['origins']);

        foreach ($origins as &$o) {
            $o = trim($o);
        }

        $destination = trim($_POST['destination']);
        $label = $_POST['label'];
        if (!ctype_alpha($label)) {
            echo "Only aplha. allowed!!!";
            exit(0);
        }
        $content = [
            "label" => $label,
            "destination" => $destination,
            "origins" => $origins
        ];
        file_put_contents("../storage/request/{$label}.json", json_encode($content));
    }

    public function runMatrix()
    {
        $maxApiCall = 10;
        foreach (glob("../storage/request/*.json", GLOB_BRACE) as $jsonFile) {
            $fileContent = file_get_contents($jsonFile);
            $content = json_decode($fileContent);
            $dmdObj = new OfficeDistanceMatrix();
            if (!$dmdObj->doRequest($content->origins, $content->destination)) {
                continue;
            }
            $responseArr = $dmdObj->getResponseArr();
            $dateStr = date("D-d-M@h_i_s_a");
            $label = $content->label . "#~#" . $dateStr . ".csv";
            $file = fopen("../storage/response/{$label}", "w");
            $test = 0;
            foreach ($responseArr as $line) {
                fputcsv($file, $line);
                $test++;
            }
            $stat = fstat($file);
            if (($stat['size'] - 1) > 1) {
                ftruncate($file, $stat['size'] - 1);
            }
            fclose($file);
            $maxApiCall--;
            if ($maxApiCall == 0) {
                break;
            }
        }

    }

    public function analize()
    {

        $dmdObj = new OfficeDistanceMatrix();

        $response = [];
        $viewVar = [];
        foreach (glob("../storage/response/*.csv", GLOB_BRACE) as $csvFile) {
            $file = fopen($csvFile, "r");
            $tempArr = explode("/", $csvFile);
            $label = explode("#~#", end($tempArr))[0];
            $totalCount = 0;
            $allDistanceValue = 0;
            $allDurationValue = 0;
            $allTrafficDurationValue = 0;
            while (!feof($file)) {
                $fileContent = (fgetcsv($file));
                $r = $dmdObj->decorateResponse(
                    $fileContent[0], $fileContent[1], $fileContent[2],
                    $fileContent[3], $fileContent[4], $fileContent[5]);
                $allDistanceValue += $r["distance_value"];
                $allDurationValue += $r["duration_value"];
                $allTrafficDurationValue += $r["durationInTraffic_value"];
                $response[$label][] = $r;
                $totalCount++;
            }
            fclose($file);
            $viewVar[$label]['averageDistanceValue'] = ceil(($allDistanceValue / $totalCount) / 1000) . " km";
            $minutes = ($allDurationValue / $totalCount);
            $viewVar[$label]['averageDurationValue'] = floor($minutes / 60) . ':' . (ceil($minutes - floor($minutes / 60) * 60)) . " min";
            $minutes = ($allTrafficDurationValue / $totalCount);
            $viewVar[$label]['averageTrafficDurationValue'] = floor($minutes / 60) . ':' . (ceil($minutes - floor($minutes / 60) * 60)) . " min";

        }
        view("analysis", ["data" => $viewVar]);
    }

    public function downloadCSV()
    {
        $csvFileNames = [];
        foreach (glob("../storage/response/*.csv", GLOB_BRACE) as $csvFile) {
            $tempArr = explode("/", $csvFile);
            $csvFileNames[] = end($tempArr);
        }
        view("download", ["csvNames" => $csvFileNames]);
    }

    public function downloadCSVFile()
    {
        $code = $_POST['code'];
        $csvFile = $_POST['csvFile'];
        $pattern = '/^[a-z]+#~#[a-z]{3}-[0-9]{1,2}-[a-z]{3}@[0-9_]{5,8}_[a-z]{2}.csv$/i';
        if ($code === "akumar9111" && preg_match($pattern, $csvFile)) {
            $csvFile = "../storage/response/{$csvFile}";
            if (file_exists($csvFile)) {
                echo "ok";
                header('Content-Description: File Transfer');
                header('Content-Type: application/octet-stream');
                header('Content-Disposition: attachment; filename=' . basename($csvFile));
                header('Content-Transfer-Encoding: binary');
                header('Expires: 0');
                header('Cache-Control: must-revalidate');
                header('Pragma: public');
                header('Content-Length: ' . filesize($csvFile));
                ob_clean();
                flush();
                readfile($csvFile);
                exit;
            }

        }
        echo "Unable to download CSV.";
        exit(0);
    }

}