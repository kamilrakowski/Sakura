-- Adminer 4.2.0 MySQL dump

SET NAMES utf8mb4;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

CREATE DATABASE `sakura-development` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_bin */;
USE `sakura-development`;

DROP TABLE IF EXISTS `sakura_actioncodes`;
CREATE TABLE `sakura_actioncodes` (
  `id` bigint(255) NOT NULL AUTO_INCREMENT COMMENT 'Automatically generated ID by MySQL for management.',
  `action` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Action identifier so the backend knows what to do.',
  `userid` bigint(255) NOT NULL COMMENT 'ID of the user that would be affected by this action',
  `actkey` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'The URL key for using this code.',
  `instruction` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Things the backend should do upon using this code',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_apikeys`;
CREATE TABLE `sakura_apikeys` (
  `id` bigint(128) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Automatically generated ID by MySQL for management.',
  `owner` bigint(128) unsigned NOT NULL COMMENT 'ID of user that owns this API key.',
  `apikey` varchar(32) COLLATE utf8_bin NOT NULL COMMENT 'The API key.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_bans`;
CREATE TABLE `sakura_bans` (
  `id` bigint(128) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Automatically generated ID by MySQL for management.',
  `uid` bigint(128) unsigned NOT NULL COMMENT 'ID of user that was banned, 0 for just an IP ban.',
  `ip` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'IP to disallow access to the site.',
  `type` tinyint(1) unsigned NOT NULL COMMENT 'The type of ban that should be enforced.',
  `timestamp` int(16) unsigned NOT NULL COMMENT 'Timestamp when the user was banned.',
  `bannedtill` int(16) unsigned NOT NULL COMMENT 'Timestamp when the user should regain access to the site.',
  `modid` bigint(128) unsigned NOT NULL COMMENT 'ID of moderator that banned this user,',
  `modip` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'IP of moderator that banned this user.',
  `reason` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT 'Reason given for the ban.',
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`),
  CONSTRAINT `sakura_bans_ibfk_1` FOREIGN KEY (`uid`) REFERENCES `sakura_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_bbcodes`;
CREATE TABLE `sakura_bbcodes` (
  `id` int(64) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Automatically generated ID by MySQL for management.',
  `regex` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Regular expression string for the BBCode.',
  `replace` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'What to replace it with.',
  `description` varchar(512) COLLATE utf8_bin NOT NULL COMMENT 'Description of what this does.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_config`;
CREATE TABLE `sakura_config` (
  `config_name` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Array key for configuration value',
  `config_value` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'The value, obviously.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_faq`;
CREATE TABLE `sakura_faq` (
  `id` bigint(128) unsigned NOT NULL AUTO_INCREMENT COMMENT 'MySQL Generated ID used for sorting.',
  `short` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Used for linking directly to a question.',
  `question` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'The question.',
  `answer` text COLLATE utf8_bin NOT NULL COMMENT 'The answer.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_forums`;
CREATE TABLE `sakura_forums` (
  `forum_id` bigint(255) unsigned NOT NULL AUTO_INCREMENT COMMENT 'MySQL Generated ID used for sorting.',
  `forum_name` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Display name of the forum.',
  `forum_desc` text COLLATE utf8_bin NOT NULL COMMENT 'Description of the forum.',
  `forum_link` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'If set forum will display as a link.',
  `forum_category` bigint(255) unsigned NOT NULL DEFAULT '0' COMMENT 'ID of the category this forum falls under.',
  `forum_type` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT 'Forum type, 0 for regular board, 1 for category and 2 for link.',
  `forum_posts` bigint(128) unsigned NOT NULL DEFAULT '0' COMMENT 'Post count of the forum',
  `forum_topics` bigint(255) unsigned NOT NULL DEFAULT '0' COMMENT 'Topic count of the forum.',
  `forum_last_post_id` bigint(255) unsigned NOT NULL DEFAULT '0' COMMENT 'ID of last post in forum.',
  `forum_last_poster_id` bigint(255) unsigned NOT NULL DEFAULT '0' COMMENT 'ID of last poster in forum.',
  `forum_icon` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Display icon for the forum.',
  PRIMARY KEY (`forum_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_friends`;
CREATE TABLE `sakura_friends` (
  `uid` bigint(255) unsigned NOT NULL COMMENT 'ID of the user that added the friend.',
  `fid` bigint(255) unsigned NOT NULL COMMENT 'ID of the user that was added as a friend.',
  `timestamp` int(11) unsigned NOT NULL COMMENT 'Timestamp of action.',
  KEY `uid` (`uid`),
  KEY `fid` (`fid`),
  CONSTRAINT `sakura_friends_ibfk_2` FOREIGN KEY (`fid`) REFERENCES `sakura_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sakura_friends_ibfk_1` FOREIGN KEY (`uid`) REFERENCES `sakura_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_infopages`;
CREATE TABLE `sakura_infopages` (
  `shorthand` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Name used for calling this page up in the /r/URL',
  `pagetitle` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Title displayed on the top of the page',
  `content` text COLLATE utf8_bin NOT NULL COMMENT 'Content of the page'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_logs`;
CREATE TABLE `sakura_logs` (
  `id` bigint(255) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Automatically generated ID by MySQL for management.',
  `uid` bigint(255) unsigned NOT NULL COMMENT 'User ID of user that took this action.',
  `action` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Action identifier.',
  `attribs` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Optional attributes, vsprintf() style.',
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`),
  CONSTRAINT `sakura_logs_ibfk_1` FOREIGN KEY (`uid`) REFERENCES `sakura_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_logtypes`;
CREATE TABLE `sakura_logtypes` (
  `id` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Identifier of action (has to match things in the logs table).',
  `string` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'String to format using vsprintf and the attributes in the logs table.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_messages`;
CREATE TABLE `sakura_messages` (
  `id` bigint(128) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Automatically generated ID by MySQL for management.',
  `from_user` bigint(255) unsigned NOT NULL COMMENT 'ID of the user that sent this message.',
  `to_user` bigint(255) unsigned NOT NULL COMMENT 'ID of user that should receive this message.',
  `read` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'IDs of users who read this message.',
  `deleted` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Indicator if one of the parties deleted the message, if it is already 1 the script will remove this row.',
  `timestamp` int(11) unsigned NOT NULL COMMENT 'Timestamp of the time this message was sent',
  `subject` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Title of the message',
  `content` text COLLATE utf8_bin NOT NULL COMMENT 'Contents of the message.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_news`;
CREATE TABLE `sakura_news` (
  `id` bigint(128) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Automatically generated ID by MySQL for management.',
  `uid` bigint(128) unsigned NOT NULL COMMENT 'ID of user who posted this news message.',
  `date` int(64) unsigned NOT NULL COMMENT 'News post timestamp.',
  `title` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Title of the post.',
  `content` text COLLATE utf8_bin NOT NULL COMMENT 'Contents of the post',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_notifications`;
CREATE TABLE `sakura_notifications` (
  `id` bigint(255) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Automatically generated ID by MySQL for management.',
  `uid` bigint(255) unsigned NOT NULL DEFAULT '0' COMMENT 'User ID this notification is intended for.',
  `timestamp` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Timestamp when this notification was created.',
  `notif_read` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'Toggle for unread and read.',
  `notif_sound` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'Toggle if a sound should be played upon receiving the notification.',
  `notif_title` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Title displayed on the notification.',
  `notif_text` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Text displayed.',
  `notif_link` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT 'Link (empty for no link).',
  `notif_img` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Image path, prefix with font: to use a font class instead of an image.',
  `notif_timeout` int(16) unsigned NOT NULL DEFAULT '0' COMMENT 'How long the notification should stay on screen in milliseconds, 0 for forever.',
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`),
  CONSTRAINT `sakura_notifications_ibfk_1` FOREIGN KEY (`uid`) REFERENCES `sakura_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_permissions`;
CREATE TABLE `sakura_permissions` (
  `rid` bigint(128) unsigned NOT NULL DEFAULT '0' COMMENT 'ID of the rank this permissions set is used for.',
  `uid` bigint(255) unsigned NOT NULL DEFAULT '0' COMMENT 'ID of the user this permissions set is used for.',
  `siteperms` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '000000000000000000000000000' COMMENT 'Site permissions.',
  `manageperms` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '0' COMMENT 'Site management permissions',
  `forumperms` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '0' COMMENT 'Forum permissions.',
  `rankinherit` varchar(4) COLLATE utf8_bin NOT NULL DEFAULT '000' COMMENT 'Rank inheritance, only used when user specific.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_posts`;
CREATE TABLE `sakura_posts` (
  `post_id` bigint(255) unsigned NOT NULL AUTO_INCREMENT COMMENT 'MySQL Generated ID used for sorting.',
  `topic_id` bigint(255) unsigned NOT NULL DEFAULT '0' COMMENT 'ID of topic this post is a part of.',
  `forum_id` bigint(255) unsigned NOT NULL DEFAULT '0' COMMENT 'ID of forum this was posted in.',
  `poster_id` bigint(255) unsigned NOT NULL DEFAULT '0' COMMENT 'ID of poster of this post.',
  `poster_ip` varchar(40) COLLATE utf8_bin NOT NULL COMMENT 'IP of poster.',
  `post_time` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Time this post was made.',
  `parse_mode` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'Switch the type of parser that''s used.',
  `enable_sig` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT 'Toggle if signature should be shown.',
  `post_subject` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Subject of the post.',
  `post_text` text COLLATE utf8_bin NOT NULL COMMENT 'Contents of the post.',
  `post_edit_time` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Time this post was last edited.',
  `post_edit_reason` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT 'Reason this was edited.',
  `post_edit_user` int(255) unsigned NOT NULL DEFAULT '0' COMMENT 'ID of user that edited.',
  PRIMARY KEY (`post_id`),
  KEY `topic_id` (`topic_id`),
  KEY `forum_id` (`forum_id`),
  KEY `poster_id` (`poster_id`),
  CONSTRAINT `sakura_posts_ibfk_3` FOREIGN KEY (`poster_id`) REFERENCES `sakura_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sakura_posts_ibfk_1` FOREIGN KEY (`topic_id`) REFERENCES `sakura_topics` (`topic_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sakura_posts_ibfk_2` FOREIGN KEY (`forum_id`) REFERENCES `sakura_forums` (`forum_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_premium`;
CREATE TABLE `sakura_premium` (
  `uid` bigint(255) unsigned NOT NULL COMMENT 'ID of the user that purchased Tenshi.',
  `startdate` int(11) unsigned NOT NULL COMMENT 'Timestamp of first purchase.',
  `expiredate` int(11) unsigned NOT NULL COMMENT 'Expiration timestamp.',
  UNIQUE KEY `uid` (`uid`),
  CONSTRAINT `sakura_premium_ibfk_1` FOREIGN KEY (`uid`) REFERENCES `sakura_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

INSERT INTO `sakura_premium` (`uid`, `startdate`, `expiredate`) VALUES
(2, 1435756632, 1441012632),
(18,  1435760007, 1443644007)
ON DUPLICATE KEY UPDATE `uid` = VALUES(`uid`), `startdate` = VALUES(`startdate`), `expiredate` = VALUES(`expiredate`);

DROP TABLE IF EXISTS `sakura_profilefields`;
CREATE TABLE `sakura_profilefields` (
  `id` int(64) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID used for ordering on the userpage.',
  `name` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Name of the field.',
  `formtype` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Type attribute in the input element.',
  `islink` tinyint(1) unsigned NOT NULL COMMENT 'Set if this value should be put in a href.',
  `linkformat` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'If the form is a link how should it be formatted? {{ VAL }} gets replace with the value.',
  `description` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Description of the field displayed in the control panel.',
  `additional` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Undocumented JSON array containing special options if needed (probably only going to be used for the YouTube field).',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_ranks`;
CREATE TABLE `sakura_ranks` (
  `id` bigint(128) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Automatically generated ID by MySQL for management.',
  `name` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Display name of the rank.',
  `multi` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'Can the rank name have an s at the end?',
  `colour` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Colour used for the username of a member of this rank.',
  `description` text COLLATE utf8_bin NOT NULL COMMENT 'A description of what a user of this rank can do/is supposed to do.',
  `title` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Default user title if user has none set.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_regcodes`;
CREATE TABLE `sakura_regcodes` (
  `id` bigint(255) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Automatically generated ID by MySQL for management.',
  `code` varchar(32) COLLATE utf8_bin NOT NULL COMMENT 'Randomly generated registration key.',
  `created_by` bigint(255) unsigned NOT NULL COMMENT 'ID of user who generated this code.',
  `used_by` bigint(255) unsigned NOT NULL COMMENT 'ID of user who used this code.',
  `key_used` tinyint(1) unsigned NOT NULL COMMENT 'Boolean for setting this key as used.',
  PRIMARY KEY (`id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `sakura_regcodes_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `sakura_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_reports`;
CREATE TABLE `sakura_reports` (
  `id` bigint(255) unsigned NOT NULL AUTO_INCREMENT COMMENT 'MySQL Generated ID used for sorting.',
  `type` int(32) unsigned NOT NULL COMMENT 'Report type, entirely handled on the script side.',
  `issuer` bigint(255) unsigned NOT NULL COMMENT 'ID of the person who issued this report.',
  `subject` bigint(255) unsigned NOT NULL COMMENT 'ID pointing out what was reported (a more accurate description isn''t possible due to the type column).',
  `title` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'A quick description of this report.',
  `description` text COLLATE utf8_bin NOT NULL COMMENT 'And a detailed description.',
  `reviewed` bigint(255) unsigned NOT NULL DEFAULT '0' COMMENT 'ID of the moderator that reviewed this report.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_sessions`;
CREATE TABLE `sakura_sessions` (
  `id` bigint(255) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Automatically generated ID by MySQL for management. ',
  `userip` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'IP of the user this session is spawned for.',
  `useragent` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT 'User agent of the user this session is spawned for.',
  `userid` bigint(255) unsigned NOT NULL COMMENT 'ID of the user this session is spawned for. ',
  `skey` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Session key, allow direct access to the user''s account. ',
  `started` int(16) unsigned NOT NULL COMMENT 'The timestamp for when the session was started. ',
  `expire` int(16) unsigned NOT NULL COMMENT 'The timestamp for when this session should end, -1 for permanent. ',
  `remember` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'If set to 1 session will be extended each time a page is loaded.',
  PRIMARY KEY (`id`),
  KEY `userid` (`userid`),
  CONSTRAINT `sakura_sessions_ibfk_1` FOREIGN KEY (`userid`) REFERENCES `sakura_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_sock_perms`;
CREATE TABLE `sakura_sock_perms` (
  `rid` bigint(128) unsigned NOT NULL DEFAULT '0' COMMENT 'ID of rank that this permission counts for (set to 0 if user).',
  `uid` bigint(255) unsigned NOT NULL DEFAULT '0' COMMENT 'ID of the user this permission counts for (set to 0 if rank).',
  `perms` varchar(128) COLLATE utf8_bin NOT NULL DEFAULT '1,0,0,0,0,0' COMMENT 'Permission data (has access, in-chat rank, user type, log access, nick access, channel creation)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_topics`;
CREATE TABLE `sakura_topics` (
  `topic_id` bigint(255) unsigned NOT NULL AUTO_INCREMENT COMMENT 'MySQL Generated ID used for sorting.',
  `forum_id` bigint(255) unsigned NOT NULL DEFAULT '0' COMMENT 'ID of forum this topic was created in.',
  `topic_hidden` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'Boolean to set the topic as hidden.',
  `topic_title` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Title of the topic.',
  `topic_time` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Timestamp when the topic was created.',
  `topic_time_limit` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'After how long a topic should be locked.',
  `topic_last_reply` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Last time a post was posted in this topic.',
  `topic_views` bigint(64) unsigned NOT NULL DEFAULT '0' COMMENT 'Amount of times the topic has been viewed.',
  `topic_replies` bigint(128) unsigned NOT NULL DEFAULT '0' COMMENT 'Amount of replies the topic has.',
  `topic_status` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'Status of topic.',
  `topic_status_change` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Date the topic status was changed (used for deletion cooldown as well).',
  `topic_type` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'Type of the topic.',
  `topic_first_post_id` bigint(255) unsigned DEFAULT NULL COMMENT 'ID of first post made in this topic.',
  `topic_first_poster_id` bigint(255) unsigned DEFAULT NULL COMMENT 'User ID of person who made the first post.',
  `topic_last_post_id` bigint(255) unsigned DEFAULT NULL COMMENT 'ID of last post made in this topic.',
  `topic_last_poster_id` bigint(255) unsigned DEFAULT NULL COMMENT 'User ID of person who made the last post.',
  PRIMARY KEY (`topic_id`),
  KEY `forum_id` (`forum_id`),
  KEY `topic_first_poster_id` (`topic_first_poster_id`),
  KEY `topic_last_poster_id` (`topic_last_poster_id`),
  CONSTRAINT `sakura_topics_ibfk_1` FOREIGN KEY (`forum_id`) REFERENCES `sakura_forums` (`forum_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_users`;
CREATE TABLE `sakura_users` (
  `id` bigint(255) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Automatically generated ID by MySQL for management. ',
  `username` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Username set at registration.',
  `username_clean` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'A more cleaned up version of the username for backend usage.',
  `password_hash` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Hashing algo used for the password hash.',
  `password_salt` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Salt used for the password hash.',
  `password_algo` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Algorithm used for the password hash.',
  `password_iter` int(16) unsigned NOT NULL COMMENT 'Password hash iterations.',
  `password_chan` int(16) unsigned NOT NULL COMMENT 'Last time the user changed their password.',
  `password_new` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT 'Field with array containing new password data beit that they requested a password change.',
  `email` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'E-mail of the user for password restoring etc.',
  `rank_main` mediumint(4) unsigned NOT NULL DEFAULT '0' COMMENT 'Main rank of the user.',
  `ranks` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '[0]' COMMENT 'Array containing the ranks the user is part of.',
  `name_colour` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT 'Additional name colour, when empty colour defaults to group colour.',
  `register_ip` varchar(16) COLLATE utf8_bin NOT NULL COMMENT 'IP used for the creation of this account.',
  `last_ip` varchar(16) COLLATE utf8_bin NOT NULL COMMENT 'Last IP that was used to log into this account.',
  `usertitle` varchar(64) COLLATE utf8_bin DEFAULT NULL COMMENT 'Custom user title of the user, when empty reverts to their derault group name.',
  `regdate` int(16) unsigned NOT NULL DEFAULT '0' COMMENT 'Timestamp of account creation.',
  `lastdate` int(16) unsigned NOT NULL DEFAULT '0' COMMENT 'Last time anything was done on this account.',
  `lastunamechange` int(16) unsigned NOT NULL DEFAULT '0' COMMENT 'Last username change.',
  `birthday` varchar(16) COLLATE utf8_bin DEFAULT NULL COMMENT 'Birthdate of the user.',
  `country` varchar(4) COLLATE utf8_bin NOT NULL COMMENT 'Contains ISO 3166 country code of user''s registration location.',
  `userData` varchar(512) COLLATE utf8_bin NOT NULL DEFAULT '[]' COMMENT 'All additional profile data.',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username_clean` (`username_clean`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sakura_warnings`;
CREATE TABLE `sakura_warnings` (
  `id` bigint(255) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Automatically generated ID by MySQL for management.',
  `uid` bigint(255) unsigned NOT NULL COMMENT 'ID of user that was warned.',
  `iid` bigint(255) unsigned NOT NULL COMMENT 'ID of the user that issued the warning.',
  `issued` int(16) unsigned NOT NULL COMMENT 'Timestamp of the date the warning was issued.',
  `expire` int(16) unsigned NOT NULL COMMENT 'Timstamp when the warning should expire, 0 for a permanent warning.',
  `reason` varchar(512) COLLATE utf8_bin DEFAULT NULL COMMENT 'Reason for the warning.',
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`),
  KEY `iid` (`iid`),
  CONSTRAINT `sakura_warnings_ibfk_2` FOREIGN KEY (`iid`) REFERENCES `sakura_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sakura_warnings_ibfk_1` FOREIGN KEY (`uid`) REFERENCES `sakura_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `sock_banned_users`;
CREATE TABLE `sock_banned_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip` varchar(50) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `username` varchar(256) DEFAULT NULL,
  `expiration` bigint(20) NOT NULL DEFAULT '-1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `sock_channels`;
CREATE TABLE `sock_channels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chname` varchar(256) NOT NULL,
  `pwd` varchar(512) DEFAULT NULL,
  `priv` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`chname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `sock_logs`;
CREATE TABLE `sock_logs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `epoch` int(11) DEFAULT NULL,
  `userid` int(11) NOT NULL,
  `username` varchar(256) NOT NULL,
  `color` varchar(24) NOT NULL,
  `channel` varchar(1024) NOT NULL,
  `chrank` int(11) NOT NULL,
  `message` longtext NOT NULL,
  `flags` varchar(10) NOT NULL DEFAULT '10010',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `sock_online_users`;
CREATE TABLE `sock_online_users` (
  `userid` int(11) NOT NULL,
  `username` varchar(256) NOT NULL,
  `color` varchar(16) NOT NULL,
  `perms` varchar(512) NOT NULL,
  UNIQUE KEY `userid` (`userid`,`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


-- 2015-07-01 14:42:04
