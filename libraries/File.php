<?php
/**
 * Holds the file server.
 *
 * @package Sakura
 */

namespace Sakura;

use finfo;

/**
 * Used for storing files served through Sakura.
 *
 * @package Sakura
 * @author Julian van de Groep <me@flash.moe>
 */
class File
{
    /**
     * ID of the file.
     * @var int
     */
    public $id = 0;

    /**
     * User instance of the user that uploaded this file.
     *
     * @var User
     */
    public $user = null;

    /**
     * Data of the file.
     *
     * @var string
     */
    public $data = null;

    /**
     * Original filename of the file.
     *
     * @var string
     */
    public $name = null;

    /**
     * Mime type of the file.
     *
     * @var string
     */
    public $mime = null;

    /**
     * The UNIX timestamp of when this file was created.
     *
     * @var int
     */
    public $time = 0;

    /**
     * The UNIX timestamp of when this file should automatically remove itself (currently unused).
     *
     * @var int
     */
    public $expire = 0;

    /**
     * Create a new file.
     *
     * @param string $data Contents of the file.
     * @param string $name Name of the file.
     * @param User $user User instance of the user creating this file.
     * @param int $expire UNIX timestamp of when this file should automatically remove itself.
     *
     * @return File The created file instance for the file.
     */
    public static function create($data, $name, User $user, $expire = 0)
    {
        // Get the mimetype
        $mime = (new finfo(FILEINFO_MIME_TYPE))->buffer($data);

        // Insert it into the database
        $id = DB::table('uploads')
            ->insertGetId([
                'user_id' => $user->id,
                'file_data' => $data,
                'file_name' => $name,
                'file_mime' => $mime,
                'file_time' => time(),
                'file_expire' => $expire,
            ]);

        // Return a new File object
        return new File($id);
    }

    /**
     * Constructor.
     *
     * @param int $fileId ID of the file that should be constructed.
     */
    public function __construct($fileId)
    {
        // Attempt to get the database row
        $fileRow = DB::table('uploads')
            ->where('file_id', $fileId)
            ->get();

        // If anything was returned populate the variables
        if ($fileRow) {
            $fileRow = $fileRow[0];
            $this->id = $fileRow->file_id;
            $this->user = User::construct($fileRow->user_id);
            $this->data = $fileRow->file_data;
            $this->name = $fileRow->file_name;
            $this->mime = $fileRow->file_mime;
            $this->time = $fileRow->file_time;
            $this->expire = $fileRow->file_expire;
        }
    }

    /**
     * Delete this file from the database.
     */
    public function delete()
    {
        DB::table('uploads')
            ->where('file_id', $this->id)
            ->delete();
    }
}
