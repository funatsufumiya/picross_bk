<?php

require_once __DIR__ . '/../vendor/autoload.php';

use Phpml\Classification\KNearestNeighbors;
use Phpml\ModelManager;

$model_path = __DIR__ . '/data/model';

$sample = json_decode($_REQUEST['sample'], true);
$label = $_REQUEST['label'];

$samples = array($sample);
$labels = array($label);

$modelManager = new ModelManager();

$classifier = null;
try {
  $classifier = $modelManager->restoreFromFile($model_path);
} catch ( Phpml\Exception\FileException $e ) {
  $classifier = new KNearestNeighbors();
}

$classifier->train($samples, $labels);

echo "trained";

$modelManager->saveToFile($classifier, $model_path);
