<?php

$threshold_default = 0.5;

$is_post = ($_SERVER["REQUEST_METHOD"] === "POST");
$is_get = ($_SERVER["REQUEST_METHOD"] === "GET");

$is_uploaded = $is_post;
// $is_register = ($is_post && isset($_POST["register"]));

?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>画像の白黒化</title>
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
  </style>

</head>
<body>
  <div id="content">
    <h2>白黒化したい画像をアップロード</h2>
    <form enctype="multipart/form-data" action="" method="POST"> 
      <input name="img" type="file"><br>
      閾値: <input id="threshold" name="threshold" type="number" min="0" max="1.0" step="any" class="num_input" value="<?php echo $threshold_default; ?>"><br>
      <input type="submit" value="読み込む">
      <hr>
    </form>

    <?php if($is_uploaded): ?>
    <?php 

    $thresh = (isset($_REQUEST["threshold"]))? $_REQUEST["threshold"]: $threshold_default;
    $img_path = "./files/tmpimg.bin";
    move_uploaded_file($_FILES['img']['tmp_name'], $img_path);

    $out_img_path = "./files/bk.jpg";
    // echo system("/usr/bin/convert $img_path bmp3:-");
    $cmd = "/usr/bin/convert $img_path bmp3:- | /usr/bin/mkbitmap -x -t $thresh - -o - | /usr/bin/convert - jpeg:$out_img_path";
    system($cmd);

    ?>

    <img src="<?php echo $out_img_path; ?>" alt="">

    <script>
    <?php
    if(!isset($thresh)){
      $thresh = $threshold_default;
    }
    ?>
    jQuery(function($){
      $("#threshold").val(<?php echo $thresh; ?>);
    });
    </script>

    <?php endif; ?>
  </div>
</body>
</html>
