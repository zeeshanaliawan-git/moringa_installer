alter table sites add partoo_language_id varchar(2) comment 'the language which will be used at time of calling partoo api';

insert into config(code, val, comments) values ('INTERNAL_API_URLS', '/api/;/dev_portal/api/', 'Semi colon separated list of internal api urls');

-- START 17-02-2022 Ahsan Abbas--
CREATE TABLE `client_reviews` (
  `post_id` VARCHAR(36) NOT NULL DEFAULT UUID() UNIQUE,
  `source_id` VARCHAR(36) not null,
  `source_type` ENUM ('page','product') not null,
  `post_parent_id` VARCHAR(36),
  `client_id` VARCHAR(36) not null,
  `site_id` int(10) unsigned not null,
  `type` ENUM ('comment','forum','review') NOT NULL DEFAULT 'comment',
  `category` TEXT,
  `created_dt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `rating` INT DEFAULT 0,
  `content` TEXT,
  `org_reply` TEXT,
  `org_reply_date` DATETIME,
  `org_reply_by` VARCHAR(36),
  `moderation_score` DECIMAL(6, 2),
  `sentiment_score` DECIMAL(6, 2),
  `nb_likes` INT NOT NULL DEFAULT 0,
  `nb_dislikes` INT NOT NULL DEFAULT 0,
  `is_pinned` TinyInt(1) NOT NULL DEFAULT 0,
  `signaled_by_user` VARCHAR(36),
  `is_verified` TinyInt(1) NOT NULL DEFAULT 0,
  `verification_type` VARCHAR(255),
  `verified_transection` VARCHAR(255),
  `verification_date` DATETIME,
  is_deleted TinyInt(1) NOT NULL DEFAULT 0,
PRIMARY KEY (`post_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `client_review_reactions` (
  `post_id` VARCHAR(36) not null,
  `client_id` VARCHAR(36) not null,
  `is_like` TinyInt(1)  not null,
  `created_dt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (`post_id`,`client_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `client_favorites` (
  `source_id` VARCHAR(36) not null,
  `source_type` ENUM ('page','product') not null,
  `client_id` VARCHAR(36) not null,
  `created_dt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (`source_id`, `source_type`,`client_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE `client_reactions` (
  `source_id` VARCHAR(36) not null,
  `source_type` ENUM ('page','product') not null,
  `client_id` VARCHAR(36) not null,
  `is_like` TinyInt(1) not null,
  `created_dt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (`source_id`, `source_type`,`client_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 21-02-2022 Ahsan Abbas--

