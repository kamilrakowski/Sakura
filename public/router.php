<?php
/*
 * Sakura Router
 */

// Declare Namespace
namespace Sakura;

// Include components
require_once str_replace(basename(__DIR__), '', dirname(__FILE__)) . 'sakura.php';

if (!Config::local('dev', 'show_changelog') || !Config::local('dev', 'show_errors')) {
    exit;
}

Router::setBasePath('/router.php');

// Handle requests
echo Router::handle($_SERVER['REQUEST_METHOD'], $_SERVER['REQUEST_URI']);