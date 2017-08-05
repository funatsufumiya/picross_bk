<?php

require_once __DIR__ . "/vendor/autoload.php";
require_once __DIR__ . "/random_word.php";

function basic_auth(){
  $user = "fu";
  $pass = "Clojure_180";
  switch (true) {
  case !isset($_SERVER['PHP_AUTH_USER'], $_SERVER['PHP_AUTH_PW']):
  case $_SERVER['PHP_AUTH_USER'] !== $user:
  case $_SERVER['PHP_AUTH_PW']   !== $pass:
    header('WWW-Authenticate: Basic realm="Enter username and password."');
    header('Content-Type: text/plain; charset=utf-8');
    die('このページを見るにはログインが必要です');
  }
}

basic_auth();
set_time_limit(0);
echo str_repeat( ' ', 10000 );

function call_api($method, $url, $data = false)
{
    $curl = curl_init();

    switch ($method)
    {
        case "POST":
            curl_setopt($curl, CURLOPT_POST, 1);

            if ($data)
                curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
            break;
        case "PUT":
            curl_setopt($curl, CURLOPT_PUT, 1);
            break;
        default:
            if ($data)
                $url = sprintf("%s?%s", $url, http_build_query($data));
    }

    // Optional Authentication:
    // curl_setopt($curl, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
    // curl_setopt($curl, CURLOPT_USERPWD, "username:password");

    curl_setopt($curl, CURLOPT_URL, $url);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);

    $result = curl_exec($curl);

    curl_close($curl);

    return $result;
}

function call_api2($method, $url, $data = false){
    $client = new \GuzzleHttp\Client();
    $res = null;
    if($method == "GET"){
      $res = $client->get($url, array(
        "query" => $data
      ));
    }else{
      $res = $client->post($url, $data);
    }
    // $body = (string) $res->getBody();
    return $res;
}

function black_image_blob($url, $thresh=0.5){
  $blob = shell_exec("curl '$url' | /usr/bin/convert - -background white -flatten bmp3:- | /usr/bin/mkbitmap -x -t $thresh - -o - | /usr/bin/convert - jpeg:-");
  return $blob;
}

function blob_jpg_to_base64($blob){
  return "data:image/jpeg;base64," . base64_encode($blob);
}

function black_image_base64($url, $thresh=0.5){
  $blob = black_image_blob($url, $thresh);
  return blob_jpg_to_base64($blob);
}

function black_image($url, $thresh=0.5){
  $blob = black_image_blob($url, $thresh);
  return blob_to_image($blob);
}

function blob_to_image($blob){
  return imagecreatefromstring($blob);
}

function image_aspect($image){
  $width = imagesx($image);
  $height = imagesy($image);
  return $height/$width;
}

function resize_image($image, $nw, $nh){
  $width = imagesx($image);
  $height = imagesy($image);
  $thumb = imagecreatetruecolor($nw, $nh);
  imagealphablending($thumb, false);
  imagesavealpha($thumb, true);
  imagecopyresampled($thumb, $image, 0, 0, 0, 0, $nw, $nh, $width, $height);
  return $thumb;
}

function image_into_bk($image, $thresh=220){
  $width = imagesx($image);
  $height = imagesy($image);
  $thumb = imagecreatetruecolor($width, $height);
  $black = imagecolorallocate($thumb, 0, 0, 0); 
  $white = imagecolorallocate($thumb, 255, 255, 255); 

  for ($y = 0; $y < $height; $y++)
  {
    for ($x = 0; $x < $width; $x++)
    {
      $rgb = imagecolorat($image, $x, $y);
      $colors = imagecolorsforindex($image, $rgb);
      $r = $colors['red'];
      $g = $colors['green'];
      $b = $colors['blue'];
      $a = $colors['alpha'];
      $val = (($r >= $thresh && $g >= $thresh && $b >= $thresh) || $a > 100)? 0: 1;
      if($val === 1){
        imagesetpixel($thumb, $x, $y, $black);
      }else{
        imagesetpixel($thumb, $x, $y, $white);
      }
    } // End for
  } // End for

  return $thumb;

}

function image_to_array($image){
  $matrix = array();
  $width = imagesx($image);
  $height = imagesy($image);

  // get flatten array
  for ($y = 0; $y < $height; $y++)
  {
    for ($x = 0; $x < $width; $x++)
    {
      $rgb = imagecolorat($image, $x, $y);
      $colors = imagecolorsforindex($image, $rgb);
      $r = $colors['red'];
      $val = ($r == 0)? 1: 0;
      $matrix[] = $val;
    } // End for
  } // End for
  
  return $matrix;
}

function image_to_base64($image){
  ob_start();
  imagepng($image);
  $blob = ob_get_contents();
  ob_end_clean();
  return "data:image/png;base64," . base64_encode($blob);
}

function image_resize_bk_base64($image, $w, $h){
  $img = resize_image($image, $w, $h);
  $img_bk = image_into_bk($img);
  imagedestroy($img);
  return image_to_base64($img_bk);
}

function image_resize_bk($image, $w, $h){
  $img = resize_image($image, $w, $h);
  $img_bk = image_into_bk($img);
  imagedestroy($img);
  return $img_bk;
}

// =========================

$pixabay_api = "https://pixabay.com/api/";
$api_key = "3690984-cd232e93b678c3bb97ff9789f";
$word = (isset($_REQUEST['q']))? $_REQUEST['q']: random_word();

$res = call_api2("GET", $pixabay_api, array(
  "key" => $api_key,
  "image_type" => ( (isset($_REQUEST['type']))? $_REQUEST['type']: "vector" ),
  "q" => $word
));

$content_type = $res->getHeader("Content-Type")[0];
if($content_type != "application/json"){
  exit;
}
$json = $res->getBody();
$list = json_decode($json,true);
$total_hits = $list["totalHits"];

$use_ai = (isset($_REQUEST['ai']));
$ai = null;

if( $use_ai ){
  $model_path = __DIR__ . '/ai/data/model';
  $modelManager = new Phpml\ModelManager();
  $ai = $modelManager->restoreFromFile($model_path);
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Pixabayから問題を生成</title>
  <meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
  <link rel="stylesheet" href="https://unpkg.com/purecss@0.6.2/build/pure-min.css" integrity="sha384-UQiGfs9ICog+LwheBSRCt1o5cbyKIHbwjWscjemyBMT9YCUMZffs6UqUTd0hObXD" crossorigin="anonymous">
  <script src="https://use.fontawesome.com/319d485afb.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore-min.js"></script>
  <script src="https://code.jquery.com/jquery-2.2.4.min.js"></script>

  <style>
  body {
    -webkit-text-size-adjust: 100%;
    margin: 1rem;
  }

  .dot_img {
    width: 100px;
    border: 1px solid gray;
    image-rendering: optimizeSpeed;             /* STOP SMOOTHING, GIVE ME SPEED  */
    image-rendering: -moz-crisp-edges;          /* Firefox                        */
    image-rendering: -o-crisp-edges;            /* Opera                          */
    image-rendering: -webkit-optimize-contrast; /* Chrome (and eventually Safari) */
    image-rendering: pixelated; /* Chrome */
    image-rendering: optimize-contrast;         /* CSS3 Proposed                  */
    -ms-interpolation-mode: nearest-neighbor;   /* IE8+ */
  }

  .match_rate {
    display: inline-block;
    width: 100%;
    background: #e0e0e0;
    color: white;
    padding-left: 10px;
  }

  .rate_5 {
    background: red;
  }

  .rate_3 {
    background: orange;
  }

  </style>

</head>
<body>
<?php

if($total_hits == 0){
  echo $word."<br>";
  echo "hits = 0";
  ?></body></html><?php
  exit;
}

echo $word."<br>";
echo $total_hits."<br>";

$hits = $list["hits"];

$count = 0;
foreach($hits as $v){
  if($count >= 20) break;

  $preview_url = $v["previewURL"];
  // $blob = black_image_blob($preview_url);
  // $base64 = blob_jpg_to_base64($blob);
  // $base64 = black_image_base64($preview_url, 0.5);
  $img = black_image($preview_url, 0.5);
  $img_30_bk = image_resize_bk($img, 30, 30);
  $img_30_bk_array = image_to_array($img_30_bk);

  if( $use_ai ) {
    $match_rate = intval($ai->predict( $img_30_bk_array ));
    if($match_rate < 3){
      continue;
    }

    if($match_rate == 5){
      echo "<span class=\"match_rate rate_5\">★★★</span>";
    }else if($match_rate == 3){
      echo "<span class=\"match_rate rate_3\">★</span>";
    }
  }

  echo "<div style='white-space: nowrap; margin-bottom: 20px;'>";
  echo "<img src='$preview_url'/>";


  $img_dark = black_image($preview_url, 0.7);
  $img_bright = black_image($preview_url, 0.3);
  $img_base64 = image_to_base64($img);
  $r = image_aspect($img);
  // $img_15 = resize_image($img, 15, 15);
  // $img_15_base64 = image_to_base64($img_15);
  // $img_15_bk_base64 = image_to_base64($img_15_bk);
  $img_10_bk_base64 = image_resize_bk_base64($img, 10, 10);
  $img_15_bk_base64 = image_resize_bk_base64($img, 15, 15);
  $img_20_bk_base64 = image_resize_bk_base64($img, 20, 20);
  $img_25_bk_base64 = image_resize_bk_base64($img, 25, 25);
  $img_30_bk_base64 = image_resize_bk_base64($img, 30, 30);

  echo "<img src='$img_base64'/>";
  echo "<img src='".image_to_base64($img_dark)."'/>";
  echo "<img src='".image_to_base64($img_bright)."'/>";
  echo "<br>";
  // echo "<img class='dot_img' src='$img_15_base64'/>";
  echo "<img class='dot_img' data-size='10x10' src='$img_10_bk_base64'/>";
  echo "<img class='dot_img' data-size='15x15' src='$img_15_bk_base64'/>";
  echo "<img class='dot_img' data-size='20x20' src='$img_20_bk_base64'/>";
  echo "<img class='dot_img' data-size='25x25' src='$img_25_bk_base64'/>";
  echo "<img class='dot_img' data-size='30x30' src='$img_30_bk_base64'/>";

  echo "<br>";
  for($i=10; $i<=30; $i+=5){
    $base64 = image_resize_bk_base64($img, $i, intval($i*$r));
    echo "<img class='dot_img img_normal' data-size='".$i."x".(intval($i*$r))."' src='$base64'/>";
  }

  echo "<br>";
  for($i=15; $i<=30; $i+=5){
    $base64 = image_resize_bk_base64($img_dark, $i, intval($i*$r));
    echo "<img class='dot_img img_dark' data-size='".$i."x".(intval($i*$r))."' src='$base64'/>";
  }

  echo "<br>";
  for($i=15; $i<=30; $i+=5){
    $base64 = image_resize_bk_base64($img_bright, $i, intval($i*$r));
    echo "<img class='dot_img img_bright' data-size='".$i."x".(intval($i*$r))."' src='$base64'/>";
  }

  echo "<br>";
  echo "</div>";

  @ob_flush();
  @flush();

  $count++;
}

// echo "<hr>";
echo '<div style="width:100%; height:10px; background:#ff0000;"></div>';

// echo "<pre>";
// print_r($hits);
// echo "</pre>";

// echo "<pre>";
// echo($json);
// echo "</pre>";

?>
</body>
</html>
