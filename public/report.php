<?php
/*
 * Sakura Reporting
 */

// Declare Namespace
namespace Sakura;

// Include components
require_once str_replace(basename(__DIR__), '', dirname(__FILE__)) .'_sakura/sakura.php';

print Templates::render('main/report.tpl', $renderData);