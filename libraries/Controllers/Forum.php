<?php
/**
 * Holds the forum pages controllers.
 * 
 * @package Sakura
 */

namespace Sakura\Controllers;

use Sakura\Config;
use Sakura\Database;
use Sakura\Forum as ForumData;
use Sakura\Perms\Forum as ForumPerms;
use Sakura\Template;
use Sakura\User;
use Sakura\Users;
use Sakura\Utils;

/**
 * Forum page controllers.
 * 
 * @package Sakura
 * @author Julian van de Groep <me@flash.moe>
 */
class Forum
{
    /**
     * Serves the forum index.
     * 
     * @return mixed HTML for the forum index.
     */
    public static function index()
    {
        // Get the global renderData
        global $renderData;
        
        // Initialise templating engine
        $template = new Template();

        // Merge index specific stuff with the global render data
        $renderData = array_merge(
            $renderData,
            [
                'forum' => (new ForumData\Forum()),
                'stats' => [
                    'userCount' => Database::count('users', ['password_algo' => ['nologin', '!='], 'rank_main' => ['1', '!=']])[0],
                    'newestUser' => User::construct(Users::getNewestUserId()),
                    'lastRegData' => date_diff(
                        date_create(date('Y-m-d', User::construct(Users::getNewestUserId())->registered)),
                        date_create(date('Y-m-d'))
                    )->format('%a'),
                    'topicCount' => Database::count('topics')[0],
                    'postCount' => Database::count('posts')[0],
                    'onlineUsers' => Users::checkAllOnline(),
                ],
            ]
        );

        // Set parse variables
        $template->setVariables($renderData);

        // Return the compiled page
        return $template->render('forum/index');
    }
}
