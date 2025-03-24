--Start 3-17-2022 Ahsan----
CREATE TABLE dev_portal.client_review_flag(
	`post_id` VARCHAR(36) NOT NULL,
	`user_id` VARCHAR(36) NOT NULL,
	created_on timestamp NOT NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`post_id`,`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE dev_commons.forum_tags (
  `tag_id` varchar(36) NOT NULL,
  `site_id` int(11) not NULL,
  `tag_name` varchar(36) DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`tag_id`, `site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE dev_portal.client_review_tags(
	`tag_id` VARCHAR(36),
	`post_id` VARCHAR(36),
	primary key (tag_id, post_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

ALTER TABLE dev_portal.client_reviews MODIFY  source_id VARCHAR(36) NULL;
ALTER TABLE dev_portal.client_reviews MODIFY source_type ENUM ('page','product','forum') NOT NULL;
ALTER TABLE dev_portal.client_reviews ADD forum_topic TEXT;
ALTER TABLE dev_portal.client_reviews ADD last_coment_date DATETIME;
ALTER TABLE dev_portal.client_reviews ADD last_coment_by VARCHAR(36);
ALTER TABLE dev_portal.client_reviews ADD is_signaled TinyInt(1) NOT NULL DEFAULT 0;
ALTER TABLE dev_portal.client_reviews DROP COLUMN signaled_by_user;

alter table client_reactions modify source_type enum ('page','product','forum') not null;
alter table client_favorites modify source_type enum ('page','product','forum') not null;
--End 3-17-2022 Ahsan----