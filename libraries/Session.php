<?php
/**
 * Holds the session handler.
 *
 * @package Sakura
 */

namespace Sakura;

/**
 * User session handler.
 *
 * @package Sakura
 * @author Julian van de Groep <me@flash.moe>
 */
class Session
{
    /**
     * The ID of the user this session is from.
     *
     * @var int
     */
    public $userId = 0;

    /**
     * The ID of the session.
     *
     * @var string
     */
    public $sessionId = "";

    /**
     * Constructor.
     *
     * @param int $userId The ID of the user.
     * @param int $sessionId The active session ID.
     */
    public function __construct($userId, $sessionId = null)
    {
        // Set the supposed session data
        $this->userId = $userId;
        $this->sessionId = $sessionId;

        // Check if a PHP session was already started and if not start one
        if (session_status() != PHP_SESSION_ACTIVE) {
            session_start();
        }
    }

    /**
     * Destroy the active session.
     */
    public function destroy()
    {
        // Invalidate the session key
        DB::table('sessions')
            ->where('session_key', $this->sessionId)
            ->where('user_id', $this->userId)
            ->delete();

        // Unset userId and sessionId
        unset($this->userId);
        unset($this->sessionId);

        // Destroy the session
        if (session_status() == PHP_SESSION_ACTIVE) {
            session_destroy();
        }
    }

    /**
     * Destroy all sessions from this user.
     */
    public function destroyAll()
    {
        // Delete all database entries with this user in it
        DB::table('sessions')
            ->where('user_id', $this->userId)
            ->delete();

        // Destroy this session to finish it off
        $this->destroy();
    }

    /**
     * Create a new session.
     *
     * @param boolean $permanent Is this a permanent session?
     *
     * @return string The session key.
     */
    public function create($permanent)
    {
        // Generate session key
        $session = hash('sha256', $this->userId . base64_encode('sakura' . mt_rand(0, 99999999)) . time());

        // Insert the session into the database
        DB::table('sessions')
            ->insert([
                'user_id' => $this->userId,
                'user_ip' => Net::pton(Net::IP()),
                'user_agent' => Utils::cleanString(isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : 'No user agent header.'),
                'session_key' => $session,
                'session_start' => time(),
                'session_expire' => time() + 604800,
                'session_remember' => $permanent ? '1' : '0',
            ]);

        // Return the session key
        return $session;
    }

    /**
     * Validate the session.
     *
     * @return int Success indicator; 0 = false, 1 = active, 2 = permanent.
     */
    public function validate()
    {
        // Get session from database
        $session = DB::table('sessions')
            ->where('user_id', $this->userId)
            ->where('session_key', $this->sessionId)
            ->get();

        // Check if we actually got something in return
        if (!$session) {
            return 0;
        }

        // Check if the session expired
        if ($session[0]->session_expire < time()) {
            // ...and return false
            return 0;
        }

        // IP Check
        $ipCheck = false; // Forced disabled due to incompatibility with the Net class. -- Config::get('session_check');

        // Origin checking
        if ($ipCheck) {
            // Split both IPs up
            $sessionIP = explode('.', $session[0]->user_ip);
            $userIP = explode('.', Net::IP());

            // Take 1 off the ipCheck variable so it's equal to the array keys
            $ipCheck = $ipCheck - 1;

            // Check if the user's IP is similar to the session's registered IP
            switch ($ipCheck) {
                // 000.xxx.xxx.xxx
                case 3:
                    if ($userIP[3] !== $sessionIP[3]) {
                        return 0;
                    }

                // xxx.000.xxx.xxx
                case 2:
                case 3:
                    if ($userIP[2] !== $sessionIP[2]) {
                        return 0;
                    }

                // xxx.xxx.000.xxx
                case 1:
                case 2:
                case 3:
                    if ($userIP[1] !== $sessionIP[1]) {
                        return 0;
                    }

                // xxx.xxx.xxx.000
                case 0:
                case 1:
                case 2:
                case 3:
                    if ($userIP[0] !== $sessionIP[0]) {
                        return 0;
                    }
            }
        }

        // If the remember flag is set extend the session time
        if ($session[0]->session_remember) {
            DB::table('sessions')
                ->where('session_id', $session[0]->session_id)
                ->update(['session_expire' => time() + 604800]);
        }

        // Return 2 if the remember flag is set and return 1 if not
        return $session[0]->session_remember ? 2 : 1;
    }
}
