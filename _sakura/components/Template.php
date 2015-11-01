<?php
/*
 * Template engine wrapper
 */

namespace Sakura;

use Twig_Environment;
use Twig_Extension_StringLoader;
use Twig_Loader_Filesystem;

/**
 * Class Template
 * @package Sakura
 */
class Template
{
    // Engine container, template folder name, options and template variables
    private $vars = [];
    private $template;
    private $templateName;
    private $templateOptions;
    private $fallback;
    private $fallbackName;
    private $fallbackOptions;

    // Initialise templating engine and data
    public function __construct()
    {
        // Set template to default
        $this->setTemplate(Configuration::getConfig('site_style'));

        // Set a fallback
        $this->setFallback(Configuration::getConfig('site_style'));
    }

    // Set a template name
    public function setTemplate($name)
    {
        // Assign config path to a variable so we don't have to type it out twice
        $confPath = ROOT . '_sakura/templates/' . $name . '/template.ini';

        // Check if the configuration file exists
        if (!file_exists($confPath)) {
            trigger_error('Template configuration does not exist', E_USER_ERROR);
        }

        // Parse and store the configuration
        $this->templateOptions = parse_ini_file($confPath, true);

        // Make sure we're not using a manage template for the main site or the other way around
        if (defined('SAKURA_MANAGE') && (bool) $this->templateOptions['manage']['mode'] != (bool) SAKURA_MANAGE) {
            trigger_error('Incorrect template type', E_USER_ERROR);
        }

        // Set variables
        $this->templateName = $name;

        // Reinitialise
        $this->initTemplate();
    }

    // Initialise main template engine
    public function initTemplate()
    {
        // Initialise Twig Filesystem Loader
        $twigLoader = new Twig_Loader_Filesystem(ROOT . '_sakura/templates/' . $this->templateName);

        // Environment variable
        $twigEnv = [];

        // Enable caching
        if (Configuration::getConfig('enable_tpl_cache')) {
            $twigEnv['cache'] = ROOT . 'cache';
        }

        // And now actually initialise the templating engine
        $this->template = new Twig_Environment($twigLoader, $twigEnv);

        // Load String template loader
        $this->template->addExtension(new Twig_Extension_StringLoader());
    }

    // Set a fallback
    private function setFallback($name)
    {
        // Assign config path to a variable so we don't have to type it out twice
        $confPath = ROOT . '_sakura/templates/' . $name . '/template.ini';

        // Check if the configuration file exists
        if (!file_exists($confPath)) {
            trigger_error('Template configuration does not exist', E_USER_ERROR);
        }

        // Parse and store the configuration
        $this->fallbackOptions = parse_ini_file($confPath, true);

        // Make sure we're not using a manage template for the main site or the other way around
        if (defined('SAKURA_MANAGE') && (bool) $this->fallbackOptions['manage']['mode'] != (bool) SAKURA_MANAGE) {
            trigger_error('Incorrect template type', E_USER_ERROR);
        }

        // Set variables
        $this->fallbackName = $name;

        // Reinitialise
        $this->initFallback();
    }

    // Initialise main fallback engine
    public function initFallback()
    {
        // Initialise Twig Filesystem Loader
        $twigLoader = new Twig_Loader_Filesystem(ROOT . '_sakura/templates/' . $this->fallbackName);

        // Environment variable
        $twigEnv = [];

        // Enable caching
        if (Configuration::getConfig('enable_tpl_cache')) {
            $twigEnv['cache'] = ROOT . 'cache';
        }

        // And now actually initialise the templating engine
        $this->fallback = new Twig_Environment($twigLoader, $twigEnv);

        // Load String template loader
        $this->fallback->addExtension(new Twig_Extension_StringLoader());
    }

    // Set variables
    public function setVariables($vars)
    {
        $this->vars = array_merge($this->vars, $vars);
    }

    // Render a template
    public function render($file)
    {
        try {
            return $this->template->render($file, $this->vars);
        } catch (\Exception $e) {
            try {
                return $this->fallback->render($file, $this->vars);
            } catch (\Exception $e) {
                trigger_error($e->getMessage(), E_USER_ERROR);
            }
        }
    }
}
