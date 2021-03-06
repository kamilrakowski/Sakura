<?php
/*
 * Sakura Authentication Page
 */

// Declare Namespace
namespace Sakura;

// Include components
require_once str_replace(basename(__DIR__), '', dirname(__FILE__)) . 'sakura.php';

// Page actions
if (isset($_REQUEST['mode'])) {
    // Continue
    $continue = true;

    // Make sure we're not in activate mode since adding a timestamp
    //  and accessing the PHP session id is kind of hard when you're in an e-mail client
    if (!isset($_REQUEST['mode']) || $_REQUEST['mode'] != 'activate') {
        // Compare time and session so we know the link isn't forged
        if (!isset($_REQUEST['time']) || $_REQUEST['time'] < time() - 1000) {
            $renderData['page'] = [

                'redirect' => $urls->format('AUTH_ACTION'),
                'message' => 'Timestamps differ too much, refresh the page and try again.',
                'success' => 0,

            ];

            // Prevent
            $continue = false;
        }

        // Match session ids for the same reason
        if (!isset($_REQUEST['session']) || $_REQUEST['session'] != session_id()) {
            $renderData['page'] = [

                'redirect' => $urls->format('AUTH_ACTION'),
                'message' => 'Invalid session, please try again.',
                'success' => 0,

            ];

            // Prevent
            $continue = false;
        }
    }

    // Login check
    if (Users::checkLogin()) {
        if (!in_array($_REQUEST['mode'], ['logout'])) {
            $continue = false;

            // Add page specific things
            $renderData['page'] = [
                'redirect' => $urls->format('SITE_HOME'),
                'message' => 'You are already authenticated. Redirecting...',
                'success' => 1,
            ];
        }
    }

    if ($continue) {
        switch ($_REQUEST['mode']) {
            case 'logout':
                // Add page specific things
                $renderData['page'] = [
                    'redirect' => Router::route('main.index'),
                    'message' => 'Wrong logout page.',
                    'success' => 0,
                ];
                break;

            case 'changepassword':
                // Attempt change
                $passforget = Users::resetPassword(
                    $_REQUEST['verk'],
                    $_REQUEST['uid'],
                    $_REQUEST['newpw'],
                    $_REQUEST['verpw']
                );

                // Array containing "human understandable" messages
                $messages = [
                    'INVALID_VERK' => 'The verification key supplied was invalid!',
                    'INVALID_CODE' => 'Invalid verification key, if you think this is an error contact the administrator.',
                    'INVALID_USER' => 'The used verification key is not designated for this user.',
                    'VERK_TOO_SHIT' => 'Your verification code is too weak, try adding some special characters.',
                    'PASS_TOO_SHIT' => 'Your password is too weak, try adding some special characters.',
                    'PASS_NOT_MATCH' => 'Passwords do not match.',
                    'SUCCESS' => 'Successfully changed your password, you may now log in.',
                ];

                // Add page specific things
                $renderData['page'] = [
                    'redirect' => (
                        $passforget[0] ?
                        $urls->format('SITE_LOGIN') :
                        $_SERVER['PHP_SELF'] . '?pw=true&uid=' . $_REQUEST['uid'] . '&verk=' . $_REQUEST['verk']
                    ),
                    'message' => $messages[$passforget[1]],
                    'success' => $passforget[0],
                ];
                break;

            // Activating accounts
            case 'activate':
                // Attempt activation
                $activate = Users::activateUser($_REQUEST['u'], true, $_REQUEST['k']);

                // Array containing "human understandable" messages
                $messages = [
                    'USER_NOT_EXIST' => 'The user you tried to activate does not exist.',
                    'USER_ALREADY_ACTIVE' => 'The user you tried to activate is already active.',
                    'INVALID_CODE' => 'Invalid activation code, if you think this is an error contact the administrator.',
                    'INVALID_USER' => 'The used activation code is not designated for this user.',
                    'SUCCESS' => 'Successfully activated your account, you may now log in.',
                ];

                // Add page specific things
                $renderData['page'] = [
                    'redirect' => $urls->format('SITE_LOGIN'),
                    'message' => $messages[$activate[1]],
                    'success' => $activate[0],
                ];
                break;

            // Resending the activation e-mail
            case 'resendactivemail':
                // Attempt send
                $resend = Users::resendActivationMail($_REQUEST['username'], $_REQUEST['email']);

                // Array containing "human understandable" messages
                $messages = [
                    'AUTH_LOCKED' => 'Authentication is currently not allowed, try again later.',
                    'USER_NOT_EXIST' => 'The user you tried to activate does not exist (confirm the username/email combination).',
                    'USER_ALREADY_ACTIVE' => 'The user you tried to activate is already active.',
                    'SUCCESS' => 'The activation e-mail has been sent to the address associated with your account.',
                ];

                // Add page specific things
                $renderData['page'] = [
                    'redirect' => $urls->format('SITE_HOME'),
                    'message' => $messages[$resend[1]],
                    'success' => $resend[0],
                ];
                break;

            // Login processing
            case 'login':
                // Add page specific things
                $renderData['page'] = [
                    'redirect' => Router::route('auth.login'),
                    'message' => 'Wrong login page.',
                    'success' => 0,
                ];
                break;

            // Registration processing
            case 'register':
                // Add page specific things
                $renderData['page'] = [
                    'redirect' => Router::route('auth.register'),
                    'message' => 'Wrong registration page.',
                    'success' => 0,
                ];
                break;

            // Unforgetting passwords
            case 'forgotpassword':
                // Attempt send
                $passforgot = Users::sendPasswordForgot($_REQUEST['username'], $_REQUEST['email']);

                // Array containing "human understandable" messages
                $messages = [
                    'AUTH_LOCKED' => 'Authentication is currently not allowed, try again later.',
                    'USER_NOT_EXIST' => 'The requested user does not exist (confirm the username/email combination).',
                    'NOT_ALLOWED' => 'Your account does not have the required permissions to change your password.',
                    'SUCCESS' => 'The password reset e-mail has been sent to the address associated with your account.',
                ];

                // Add page specific things
                $renderData['page'] = [
                    'redirect' => $urls->format('SITE_FORGOT_PASSWORD'),
                    'message' => $messages[$passforgot[1]],
                    'success' => $passforgot[0],
                ];
                break;

        }
    }

    // Print page contents or if the AJAX request is set only display the render data
    if (isset($_REQUEST['ajax'])) {
        echo $renderData['page']['message'] . '|' .
            $renderData['page']['success'] . '|' .
            $renderData['page']['redirect'];
    } else {
        Template::vars($renderData);
        echo Template::render('global/information');
    }
    exit;
}

// Add page specific things
$renderData['auth'] = [
    'redirect' => isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : $urls->format('SITE_HOME'),
];

// Check if the user is already logged in
if (Users::checkLogin()) {
    // Add page specific things
    $renderData['page'] = [
        'redirect' => $urls->format('SITE_HOME'),
        'message' => 'You are already logged in, log out to access this page.',
    ];

    Template::vars($renderData);
    echo Template::render('global/information');
    exit;
}

// If password forgot things are set display password forget thing
if (isset($_REQUEST['pw']) && $_REQUEST['pw']) {
    $renderData['auth']['changingPass'] = true;
    $renderData['auth']['userId'] = $_REQUEST['uid'];

    if (isset($_REQUEST['key'])) {
        $renderData['auth']['forgotKey'] = $_REQUEST['key'];
    }

    Template::vars($renderData);
    echo Template::render('main/forgotpassword');
    exit;
}

// Print page contents
Template::vars($renderData);
echo Template::render('main/authenticate');
