<?php
/*
 * Sakura FAQ Page
 */

// Declare Namespace
namespace Sakura;

// Include components
require_once str_replace(basename(__DIR__), '', dirname(__FILE__)) . 'sakura.php';

// Add page specific things
$renderData['page'] = [
    'title' => 'Frequently Asked Questions',
    'questions' => Main::getFaqData(),
];

// Initialise templating engine
$template = new Template();

// Change templating engine
$template->setTemplate($templateName);

// Set parse variables
$template->setVariables($renderData);

// Print page contents
echo $template->render('main/faq');
