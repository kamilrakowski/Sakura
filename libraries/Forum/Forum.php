<?php
/**
 * Holds the forum object class.
 *
 * @package Sakura
 */

namespace Sakura\Forum;

use Sakura\DB;
use Sakura\Perms;

/**
 * Used to serve forums.
 *
 * @package Sakura
 * @author Julian van de Groep <me@flash.moe>
 */
class Forum
{
    /**
     * The ID of the forum.
     *
     * @var int
     */
    public $id = 0;

    /**
     * The order of the forum.
     *
     * @var int
     */
    public $order = 0;

    /**
     * The name of the forum.
     *
     * @var string
     */
    public $name = "Forum";

    /**
     * The description of the forum.
     *
     * @var string
     */
    public $description = "";

    /**
     * The link of the forum (if the type is 2).
     * @var string
     */
    public $link = "";

    /**
     * The ID of the parent forum.
     *
     * @var int
     */
    public $category = 0;

    /**
     * The type of forum.
     *
     * @var int
     */
    public $type = 0;

    /**
     * The icon of this forum.
     *
     * @var string
     */
    public $icon = "";

    /**
     * A cached instance of the first post in this forum.
     *
     * @var Post
     */
    private $_firstPost = null;

    /**
     * A cached instance of the last post in this forum.
     *
     * @var Post
     */
    private $_lastPost = null;

    /**
     * Cached instances of the subforums.
     *
     * @var array
     */
    private $_forums = [];

    /**
     * Cached instances of the threads in this forum.
     *
     * @var array
     */
    private $_threads = [];

    /**
     * The permission container.
     *
     * @var Perms
     */
    private $_permissions;

    /**
     * Constructor.
     *
     * @param int $forumId The ID of the forum that should be constructed.
     */
    public function __construct($forumId = 0)
    {
        // Get the row from the database
        $forumRow = DB::table('forums')
            ->where('forum_id', $forumId)
            ->get();

        // Create permissions object
        $this->_permissions = new Perms(Perms::FORUM);

        // Populate the variables
        if ($forumRow) {
            $forumRow = $forumRow[0];
            $this->id = $forumRow->forum_id;
            $this->order = $forumRow->forum_order;
            $this->name = $forumRow->forum_name;
            $this->description = $forumRow->forum_desc;
            $this->link = $forumRow->forum_link;
            $this->category = $forumRow->forum_category;
            $this->type = $forumRow->forum_type;
            $this->icon = $forumRow->forum_icon;
        } elseif ($forumId != 0) {
            $this->id = -1;
        }
    }

    /**
     * Checking a permission flag.
     *
     * @param int $flag Forum permission flag.
     * @param int $user The ID of the user that is being checked.
     * @param bool $raw Whether the raw full permission flag should be returned.
     *
     * @return bool|int Either a bool indicating the permission or the full flag.
     */
    public function permission($flag, $user, $raw = false)
    {
        // Set default permission value
        $perm = 0;

        // Get the permissions of the parent forum if there is one
        if ($this->category) {
            $perm = $perm | (new Forum($this->category))->permission($flag, $user, true);
        }

        // Bitwise OR it with the permissions for this forum
        $perm = $perm | $this->_permissions->user($user, ['forum_id' => [$this->id, '=']]);

        return $raw ? $perm : $this->_permissions->check($flag, $perm);
    }

    /**
     * Gets all subforums of this forum.
     *
     * @return array Array containing forum objects.
     */
    public function forums()
    {
        // Check if _forums is populated
        if (!count($this->_forums)) {
            // Get all rows with the category id set to the forum id
            $forumRows = DB::table('forums')
                ->where('forum_category', $this->id)
                ->orderBy('forum_order')
                ->get(['forum_id']);

            // Create a storage array
            $forums = [];

            // Create new objects for each forum
            foreach ($forumRows as $forum) {
                $forums[$forum->forum_id] = new Forum($forum->forum_id);
            }

            $this->_forums = $forums;
        } else {
            $forums = $this->_forums;
        }

        // Return the forum objects
        return $forums;
    }

    /**
     * Gets the threads in this forum.
     *
     * @return array Array containing all threads.
     */
    public function threads()
    {
        // Check if _threads is populated
        if (!count($this->_threads)) {
            // Get all rows with the forum id for this forum
            $threadRows = DB::table('topics')
                ->where('forum_id', $this->id)
                ->orderBy('topic_type', 'desc')
                ->orderBy('topic_last_reply', 'desc')
                ->get(['topic_id']);

            // Create a storage array
            $threads = [];

            // Create new objects for each thread
            foreach ($threadRows as $thread) {
                $threads[$thread->topic_id] = new Thread($thread->topic_id);
            }

            $this->_threads = $threads;
        } else {
            $threads = $this->_threads;
        }

        // Return the thread objects
        return $threads;
    }

    /**
     * Gets the first post in this forum.
     *
     * @return Post The object of the first post.
     */
    public function firstPost()
    {
        // Check if _firstPost is set
        if ($this->_firstPost === null) {
            // Get the row
            $firstPost = DB::table('posts')
                ->where('forum_id', $this->id)
                ->orderBy('post_id')
                ->limit(1)
                ->get(['post_id']);

            // Create the post object
            $post = new Post(empty($firstPost) ? 0 : $firstPost[0]->post_id);

            // Assign it to a "cache" variable
            $this->_firstPost = $post;

            // Return the post object
            return $post;
        } else {
            return $this->_firstPost;
        }
    }

    /**
     * Gets the last post in this forum.
     *
     * @return Post The object of the last post.
     */
    public function lastPost()
    {
        // Check if _lastPost is set
        if ($this->_lastPost === null) {
            // Get the row
            $lastPost = DB::table('posts')
                ->where('forum_id', $this->id)
                ->orderBy('post_id', 'desc')
                ->limit(1)
                ->get(['post_id']);

            // Create the post object
            $post = new Post(empty($lastPost) ? 0 : $lastPost[0]->post_id);

            // Assign it to a "cache" variable
            $this->_lastPost = $post;

            // Return the post object
            return $post;
        } else {
            return $this->_lastPost;
        }
    }

    /**
     * Counts the amount of threads in this forum.
     *
     * @return int Number of threads in this forum.
     */
    public function threadCount()
    {
        return DB::table('topics')
            ->where('forum_id', $this->id)
            ->count();
    }

    /**
     * Counts the amount of posts in this forum.
     *
     * @return int Number of posts in this forum.
     */
    public function postCount()
    {
        return DB::table('posts')
            ->where('forum_id', $this->id)
            ->count();
    }

    /**
     * Checks if a user has read every post in the specified forum.
     *
     * @param int $user Id of the user in question.
     *
     * @return bool Indicator if read or not.
     */
    public function unread($user)
    {
        // Return false if the user id is less than 1
        if ($user < 1) {
            return false;
        }

        // Check forums
        foreach ($this->forums() as $forum) {
            if ($forum->unread($user)) {
                return true;
            }
        }

        // Check each thread
        foreach ($this->threads() as $thread) {
            if ($thread->unread($user)) {
                return true;
            }
        }

        // Return false if negative
        return false;
    }

    /**
     * Update the read status of all threads in this forum at once.
     *
     * @param int $user The id of the user in question.
     */
    public function trackUpdateAll($user)
    {
        // Iterate over every forum
        foreach ($this->forums() as $forum) {
            // Update every forum
            $forum->trackUpdateAll($user);
        }

        // Iterate over every thread
        foreach ($this->threads() as $thread) {
            // Update every thread
            $thread->trackUpdate($user);
        }
    }
}
