<?php
/*
 * Sakura Authentication Page
 */

// Declare Namespace
namespace Sakura;

// Include components
require_once str_replace(basename(__DIR__), '', dirname(__FILE__)) .'_sakura/sakura.php';

// Page actions
if(
    isset($_REQUEST['mode'])
) {

    // Continue
    $continue = true;

    // Make sure we're not in activate mode since adding a timestamp and accessing the PHP session id is kind of hard when you're in an e-mail client
    if(!isset($_REQUEST['mode']) || $_REQUEST['mode'] != 'activate') {

        // Compare time and session so we know the link isn't forged
        if($_REQUEST['time'] < time() - 1000) {

            $renderData['page'] = [
                'title'     => 'Action failed',
                'redirect'  => '/authenticate',
                'message'   => 'Timestamps differ too much, please try again.'
            ];

            // Prevent
            $continue = false;

        }

        // Match session ids for the same reason
        if(!isset($_REQUEST['session']) || $_REQUEST['session'] != session_id()) {

            $renderData['page'] = [
                'title'     => 'Action failed',
                'redirect'  => '/authenticate',
                'message'   => 'Session IDs do not match.'
            ];

            // Prevent
            $continue = false;

        }

    }

    // Login check
    if(Users::checkLogin()) {

        if($_REQUEST['mode'] != 'logout')
            $continue = false;

    }

    if($continue) {
        switch($_REQUEST['mode']) {

            case 'logout':

                // Attempt logout
                $logout = Users::logout();

                // Add page specific data
                $renderData['page'] = [
                    'title'     => 'Logout',
                    'redirect'  => ($logout ? $_REQUEST['redirect'] : '/authenticate'),
                    'message'   => $logout ? 'You are now logged out.' : 'Logout failed.'
                ];

                break;

            // Activating accounts
            case 'activate':

                // Attempt activation
                $activate = Users::activateUser($_REQUEST['u'], true, $_REQUEST['k']);

                // Array containing "human understandable" messages
                $messages = [
                    'USER_NOT_EXIST'        => 'The user you tried to activate does not exist.',
                    'USER_ALREADY_ACTIVE'   => 'The user you tried to activate is already active.',
                    'INVALID_CODE'          => 'Invalid activation code, if you think this is an error contact the administrator.',
                    'INVALID_USER'          => 'The used registration code is not designated for this user.',
                    'SUCCESS'               => 'Successfully activated your account, you may now log in.'
                ];

                // Add page specific things
                $renderData['page'] = [
                    'title'     => 'Activate account',
                    'redirect'  => '/authenticate',
                    'message'   => $messages[$activate[1]]
                ];

                break;

            // Resending the activation e-mail
            case 'resendactivemail':
                
                break;

            // Login processing
            case 'login':

                // Attempt login
                $login = Users::login($_REQUEST['username'], $_REQUEST['password'], isset($_REQUEST['remember']));

                // Array containing "human understandable" messages
                $messages = [
                    'USER_NOT_EXIST'        => 'The user you tried to log into does not exist.',
                    'INCORRECT_PASSWORD'    => 'The password you entered was invalid.',
                    'DEACTIVATED'           => 'Your account is deactivated.',
                    'NO_LOGIN'              => 'Logging into this account is disabled.',
                    'LEGACY_SUCCESS'        => 'Login successful! Taking you to the password changing page...',
                    'LOGIN_SUCESS'          => 'Login successful!'
                ];

                // Add page specific things
                $renderData['page'] = [
                    'title'     => 'Login',
                    'redirect'  => ($login[0] ? $_REQUEST['redirect'] : '/authenticate'),
                    'message'   => $messages[$login[1]]
                ];

                break;

            // Registration processing
            case 'register':

                // Attempt registration
                $register = Users::register(
                    $_REQUEST['username'],
                    $_REQUEST['password'],
                    $_REQUEST['confirmpassword'],
                    $_REQUEST['email'],
                    isset($_REQUEST['tos']),
                    (
                        Configuration::getConfig('recaptcha') ?
                        $_REQUEST['g-recaptcha-response'] :
                        null
                    ),
                    (
                        Configuration::getConfig('require_registration_code') ?
                        $_REQUEST['registercode'] :
                        null
                    )
                );

                // Array containing "human understandable" messages
                $messages = [
                    'DISABLED'          => 'Registration is currently disabled.',
                    'INVALID_REG_KEY'   => 'The given registration code was invalid.',
                    'TOS'               => 'You are required to agree to the Terms of Service.',
                    'CAPTCHA_FAIL'      => 'Captcha verification failed, please try again.',
                    'USER_EXISTS'       => 'A user with this username already exists, if you lost your password try using the Lost Password form.',
                    'NAME_TOO_SHORT'    => 'Your name must be at least 3 characters long.',
                    'NAME_TOO_LONG'     => 'Your name can\'t be longer than 16 characters.',
                    'PASS_TOO_SHORT'    => 'Your password is too short, it must be at least 8 characters.',
                    'PASS_TOO_LONG'     => 'A password longer than 256 characters? Seriously?',
                    'PASS_NOT_MATCH'    => 'Passwords do not match.',
                    'INVALID_EMAIL'     => 'Your e-mail address is formatted incorrectly.',
                    'INVALID_MX'        => 'No valid MX-Record found on the e-mail address you supplied.',
                    'EMAILSENT'         => 'Your registration went through! An activation e-mail has been sent.',
                    'SUCCESS'           => 'Your registration went through! Welcome to '. Configuration::getConfig('sitename') .'!'
                ];

                // Add page specific things
                $renderData['page'] = [
                    'title'     => 'Register on Flashii',
                    'redirect'  => ($register[0] ? '/' : '/authenticate'),
                    'message'   => $messages[$register[1]]
                ];

                break;

            // Unforgetting passwords
            case 'forgotpassword':

                // Add page specific things
                $renderData['page'] = [
                    'title'     => 'Forgot Password',
                    'redirect'  => $_SERVER['PHP_SELF'],
                    'message'   => 'what'
                ];

                break;

        }
    }

    // Print page contents or if the AJAX request is set only display the render data
    print   isset($_REQUEST['ajax']) ?
            (
                $renderData['page']['title']
                . ':'
                . $renderData['page']['message']
                . ':'
                . $renderData['page']['redirect']
            ) :
            Templates::render('errors/information.tpl', $renderData);
    exit;

}

// Add page specific things
$renderData['page'] = [
    'title' => 'Login to Flashii'
];
$renderData['auth'] = [
    'redirect' => (
        isset($_REQUEST['chat']) ?
        Configuration::getLocalConfig('urls', 'chat') :
        (
            isset($_SERVER['HTTP_REFERER']) ?
            $_SERVER['HTTP_REFERER'] :
            Configuration::getLocalConfig('urls', 'main')
        )
    ),
    'blockRegister' => [
        'do' => false
    ]
];

// Check if a user has already registered from the current IP address
if(count($regUserIP = Users::getUsersByIP(Main::getRemoteIP()))) {

    $renderData['auth']['blockRegister'] = [
        'do'        => true,
        'username'  => $regUserIP[array_rand($regUserIP)]['username']
    ];

}

// Print page contents
print Templates::render('main/authenticate.tpl', $renderData);
