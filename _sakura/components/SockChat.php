<?php
/*
 * Sock Chat extensions
 */

namespace Sakura;

class SockChat {

    // Permission indexes
    public static $_PERMS_ACCESS_INDEX  = 0;
    public static $_PERMS_RANK_INDEX    = 1;
    public static $_PERMS_TYPE_INDEX    = 2;
    public static $_PERMS_LOGS_INDEX    = 3;
    public static $_PERMS_NICK_INDEX    = 4;
    public static $_PERMS_CHANNEL_INDEX = 5;

    // Fallback permission row
    public static $_PERMS_FALLBACK = [1, 0, 0, 0, 0, 0];

    // Get all permission data
    public static function getAllPermissions() {

        // Get all data from the permissions table
        $perms = Database::fetch('sock_perms');

        // Parse permission string
        foreach($perms as $id => $perm)
            $perms[$id]['perms'] = self::decodePerms($perm['perms']);

        // Return the permission data
        return $perms;

    }

    // Get permission data for a specific rank
    public static function getRankPermissions($rid) {

        // Get data by rank id from permissions table
        $perms = Database::fetch('sock_perms', false, ['rid' => [$rid, '='], 'uid' => [0, '=']]);

        // Check if we got a row back
        if(empty($perms)) {
            $perms = [
                'rid'   => 0,
                'uid'   => 0,
                'perms' => self::$_PERMS_FALLBACK
            ];
        }

        // Parse permission string
        $perms = self::decodePerms($perms['perms']);

        // Return the permission data
        return $perms;

    }

    // Get all rank permission data
    public static function getUserPermissions($uid) {

        // Get data by user id from permissions table
        $perms = Database::fetch('sock_perms', false, ['uid' => [$uid, '='], 'rid' => [0, '=']]);

        // Check if we got a row back
        if(empty($perms)) {

            // If we didn't get the user's rank account row
            $user = Users::getUser($uid);

            // Then return the data for their rank
            return self::getRankPermissions($user['rank_main']);

        }

        // Parse permission string
        $perms = self::decodePerms($perms['perms']);

        // Return the permission data
        return $perms;

    }

    // Decode permission string
    public static function decodePerms($perms) {

        // Explode the commas
        $exploded = is_array($perms) ? $perms : explode(',', $perms);

        // "Reset" $perms
        $perms = array();

        // Put the data in the correct order
        $perms['access']    = $exploded[ self::$_PERMS_ACCESS_INDEX ];
        $perms['rank']      = $exploded[ self::$_PERMS_RANK_INDEX ];
        $perms['type']      = $exploded[ self::$_PERMS_TYPE_INDEX ];
        $perms['logs']      = $exploded[ self::$_PERMS_LOGS_INDEX ];
        $perms['nick']      = $exploded[ self::$_PERMS_NICK_INDEX ];
        $perms['channel']   = $exploded[ self::$_PERMS_CHANNEL_INDEX ];

        // Return formatted permissions array
        return $perms;

    }

    // Encode permission string
    public static function encodePerms($perms) {

        // Create array
        $encoded = array();

        // Put the data in the correct order
        $encoded[ self::$_PERMS_ACCESS_INDEX ]  = empty($perms['access'])   ? 0 : $perms['access'];
        $encoded[ self::$_PERMS_RANK_INDEX ]    = empty($perms['rank'])     ? 0 : $perms['rank'];
        $encoded[ self::$_PERMS_TYPE_INDEX ]    = empty($perms['type'])     ? 0 : $perms['type'];
        $encoded[ self::$_PERMS_LOGS_INDEX ]    = empty($perms['logs'])     ? 0 : $perms['logs'];
        $encoded[ self::$_PERMS_NICK_INDEX ]    = empty($perms['nick'])     ? 0 : $perms['nick'];
        $encoded[ self::$_PERMS_CHANNEL_INDEX ] = empty($perms['channel'])  ? 0 : $perms['channel'];

        // Implode the array
        $perms = implode(',', $encoded);

        // Return formatted permissions array
        return $perms;

    }

}
