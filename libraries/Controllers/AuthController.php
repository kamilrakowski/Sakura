<?php
/**
 * Holds the auth controllers.
 *
 * @package Sakura
 */

namespace Sakura\Controllers;

use Sakura\Config;
use Sakura\DB;
use Sakura\Hashing;
use Sakura\Net;
use Sakura\Perms\Site;
use Sakura\Router;
use Sakura\Session;
use Sakura\Template;
use Sakura\User;
use Sakura\Users;
use Sakura\Utils;

/**
 * Authentication controllers.
 *
 * @package Sakura
 * @author Julian van de Groep <me@flash.moe>
 */
class AuthController extends Controller
{
    protected function touchRateLimit($user, $mode = 0)
    {
        DB::table('login_attempts')
            ->insert([
                'attempt_success' => $mode,
                'attempt_timestamp' => time(),
                'attempt_ip' => Net::pton(Net::IP()),
                'user_id' => $user,
            ]);
    }

    public function logout()
    {
        // Check if user is logged in
        $check = Users::checkLogin();

        if (!$check || !isset($_REQUEST['s']) || $_REQUEST['s'] != session_id()) {
            $message = 'Something happened! This probably happened because you went here without being logged in.';
            $redirect = (isset($_REQUEST['redirect']) ? $_REQUEST['redirect'] : Router::route('main.index'));

            Template::vars(['page' => ['success' => 0, 'redirect' => $redirect, 'message' => $message]]);

            return Template::render('global/information');
        }

        // Destroy the active session
        (new Session($check[0], $check[1]))->destroy();

        // Return true indicating a successful logout
        $message = 'Goodbye!';
        $redirect = Router::route('auth.login');

        Template::vars(['page' => ['success' => 1, 'redirect' => $redirect, 'message' => $message]]);

        return Template::render('global/information');
    }

    public function loginGet()
    {
        return Template::render('main/login');
    }

    public function loginPost()
    {
        // Preliminarily set login to failed
        $success = 0;
        $redirect = Router::route('auth.login');

        // Check if authentication is disallowed
        if (Config::get('lock_authentication')) {
            $message = 'Logging in is disabled for security checkups! Try again later.';
            Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

            return Template::render('global/information');
        }

        // Get request variables
        $username = isset($_REQUEST['username']) ? $_REQUEST['username'] : null;
        $password = isset($_REQUEST['password']) ? $_REQUEST['password'] : null;
        $remember = isset($_REQUEST['remember']);

        // Check if we haven't hit the rate limit
        $rates = DB::table('login_attempts')
            ->where('attempt_ip', Net::pton(Net::IP()))
            ->where('attempt_timestamp', '>', time() - 1800)
            ->where('attempt_success', '0')
            ->count();

        if ($rates > 4) {
            $message = 'Your have hit the login rate limit, try again later.';
            Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

            return Template::render('global/information');
        }

        // Get account data
        $user = User::construct(Utils::cleanString($username, true, true));

        // Check if the user that's trying to log in actually exists
        if ($user->id === 0) {
            $this->touchRateLimit($user->id);
            $message = 'The user you tried to log into does not exist.';
            Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

            return Template::render('global/information');
        }

        // Validate password
        switch ($user->passwordAlgo) {
            // Disabled
            case 'disabled':
                $this->touchRateLimit($user->id);
                $message = 'Logging into this account is disabled.';
                Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

                return Template::render('global/information');

            // Default hashing method
            default:
                if (!Hashing::validatePassword($password, [
                    $user->passwordAlgo,
                    $user->passwordIter,
                    $user->passwordSalt,
                    $user->passwordHash,
                ])) {
                    $this->touchRateLimit($user->id);
                    $message = 'The password you entered was invalid.';
                    Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

                    return Template::render('global/information');
                }
        }

        // Check if the user has the required privs to log in
        if ($user->permission(Site::DEACTIVATED)) {
            $this->touchRateLimit($user->id);
            $message = 'Your account does not have the required permissions to log in.';
            Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

            return Template::render('global/information');
        }

        // Create a new session
        $session = new Session($user->id);

        // Generate a session key
        $sessionKey = $session->create($remember);

        // User ID cookie
        setcookie(
            Config::get('cookie_prefix') . 'id',
            $user->id,
            time() + 604800,
            Config::get('cookie_path')
        );

        // Session ID cookie
        setcookie(
            Config::get('cookie_prefix') . 'session',
            $sessionKey,
            time() + 604800,
            Config::get('cookie_path')
        );

        $this->touchRateLimit($user->id, 1);

        $success = 1;
        $redirect = $user->lastOnline ? (isset($_REQUEST['redirect']) ? $_REQUEST['redirect'] : Router::route('main.index')) : Router::route('main.infopage', 'welcome');
        $message = 'Welcome' . ($user->lastOnline ? ' back' : '') . '!';

        Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

        return Template::render('global/information');
    }

    public function registerGet()
    {
        // Attempt to check if a user has already registered from the current IP
        $getUserIP = DB::table('users')
            ->where('register_ip', Net::pton(Net::IP()))
            ->orWhere('last_ip', Net::pton(Net::IP()))
            ->get();

        Template::vars([
            'haltRegistration' => count($getUserIP) > 1,
            'haltName' => $getUserIP[array_rand($getUserIP)]->username,
        ]);

        return Template::render('main/register');
    }

    public function registerPost()
    {
        // Preliminarily set login to failed
        $success = 0;
        $redirect = Router::route('auth.register');

        // Check if authentication is disallowed
        if (Config::get('lock_authentication') || Config::get('disable_registration')) {
            $message = 'Registration is disabled for security checkups! Try again later.';

            Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

            return Template::render('global/information');
        }

        // Check if authentication is disallowed
        if (!isset($_POST['session']) || $_POST['session'] != session_id()) {
            $message = "Your session expired, refreshing the page will most likely fix this!";

            Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

            return Template::render('global/information');
        }

        // Grab forms
        $username = isset($_POST['username']) ? $_POST['username'] : null;
        $password = isset($_POST['password']) ? $_POST['password'] : null;
        $email = isset($_POST['email']) ? $_POST['email'] : null;
        $captcha = isset($_POST['g-recaptcha-response']) ? $_POST['g-recaptcha-response'] : null;
        $terms = isset($_POST['tos']);

        // Append username and email to the redirection url
        $redirect .= "?username={$username}&email={$email}";

        // Check if the user agreed to the ToS
        if (!$terms) {
            $message = 'You are required to agree to the Terms of Service.';

            Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

            return Template::render('global/information');
        }

        // Check if we require a captcha
        if (Config::get('recaptcha')) {
            // Get secret key from the config
            $secret = Config::get('recaptcha_private');

            // Attempt to verify the captcha
            $response = Net::fetch("https://google.com/recaptcha/api/siteverify?secret={$secret}&response={$captcha}");

            // Attempt to decode as json
            if ($response) {
                $response = json_decode($response);
            }
            
            if (!$response || !$response->success) {
                $message = 'Captcha verification failed, please try again.';

                Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

                return Template::render('global/information');
            }
        }
        
        // Attempt to get account data
        $user = User::construct(Utils::cleanString($username, true, true));

        // Check if the username already exists
        if ($user && $user->id !== 0) {
            $message = "{$user->username} is already a member here! If this is you please use the password reset form instead of making a new account.";

            Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

            return Template::render('global/information');
        }

        // Username too short
        if (strlen($username) < Config::get('username_min_length')) {
            $message = 'Your name must be at least 3 characters long.';

            Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

            return Template::render('global/information');
        }

        // Username too long
        if (strlen($username) > Config::get('username_max_length')) {
            $message = 'Your name can\'t be longer than 16 characters.';

            Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

            return Template::render('global/information');
        }

        // Check if the given email address is formatted properly
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $message = 'Your e-mail address is formatted incorrectly.';

            Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

            return Template::render('global/information');
        }

        // Check the MX record of the email
        if (!Utils::checkMXRecord($email)) {
            $message = 'No valid MX-Record found on the e-mail address you supplied.';

            Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

            return Template::render('global/information');
        }

        // Check if the e-mail has already been used
        $emailCheck = DB::table('users')
            ->where('email', $email)
            ->count();
        if ($emailCheck) {
            $message = 'Someone already registered using this email!';

            Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

            return Template::render('global/information');
        }

        // Check password entropy
        if (Utils::pwdEntropy($password) < Config::get('min_entropy')) {
            $message = 'Your password is too weak, try adding some special characters.';

            Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

            return Template::render('global/information');
        }

        // Set a few variables
        $requireActive = Config::get('require_activation');
        $ranks = $requireActive ? [1] : [2];

        // Create the user
        $user = User::create($username, $password, $email, $ranks);

        // Check if we require e-mail activation
        if ($requireActive) {
            // Send activation e-mail to user
            Users::sendActivationMail($user->id);
        }

        // Return true with a specific message if needed
        $success = 1;
        $redirect = Router::route('auth.login');
        $message = $requireActive
            ? 'Your registration went through! An activation e-mail has been sent.'
            : 'Your registration went through! Welcome to ' . Config::get('sitename') . '!';

        Template::vars(['page' => ['success' => $success, 'redirect' => $redirect, 'message' => $message]]);

        return Template::render('global/information');
    }
}
