
-- START 2019-12-20 --
CREATE  VIEW language AS select dev_catalog.language.langue_id AS langue_id,dev_catalog.language.langue AS langue,dev_catalog.language.langue_code AS langue_code,dev_catalog.language.og_local AS og_local,dev_catalog.language.direction AS direction from dev_catalog.language;

CREATE TABLE blocs_tags (
  bloc_id int(11) unsigned NOT NULL,
  tag_id varchar(100) NOT NULL,
  PRIMARY KEY (bloc_id, tag_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE pages_tags (
  page_id int(11) unsigned NOT NULL,
  tag_id varchar(100) NOT NULL,
  PRIMARY KEY (page_id, tag_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

ALTER TABLE blocs
MODIFY COLUMN start_date  varchar(20) NOT NULL DEFAULT '',
MODIFY COLUMN end_date  varchar(20) NOT NULL DEFAULT '';

UPDATE blocs SET start_date = '' WHERE start_date = '0000-00-00';
UPDATE blocs SET end_date = '' WHERE end_date = '0000-00-00';
-- END 2019-12-20 --

-- START 2020-01-06 --
ALTER TABLE bloc_templates
MODIFY COLUMN type  enum('block','feed_view','structured_content','structured_page') NOT NULL DEFAULT 'block';

ALTER TABLE pages
MODIFY COLUMN type  enum('freemarker','react','structured') NOT NULL DEFAULT 'freemarker';

CREATE TABLE structured_catalogs (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  name varchar(100) NOT NULL,
  site_id int(10) unsigned NOT NULL DEFAULT '0',
  type enum('content','page') NOT NULL DEFAULT 'content',
  template_id int(11) unsigned NOT NULL COMMENT 'catalog type',
  publish_status enum('unpublished','published') NOT NULL DEFAULT 'unpublished',
  created_ts datetime NOT NULL,
  updated_ts datetime NOT NULL,
  published_ts datetime DEFAULT NULL,
  created_by int(11) NOT NULL,
  updated_by int(11) NOT NULL,
  published_by int(11) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE structured_catalogs_published (
  id int(11) unsigned NOT NULL,
  name varchar(100) NOT NULL,
  site_id int(10) unsigned NOT NULL DEFAULT '0',
  type enum('content','page') NOT NULL DEFAULT 'content',
  template_id int(11) unsigned NOT NULL COMMENT 'catalog type',
  publish_status enum('unpublished','published') NOT NULL DEFAULT 'unpublished',
  created_ts datetime NOT NULL,
  updated_ts datetime NOT NULL,
  published_ts datetime DEFAULT NULL,
  created_by int(11) NOT NULL,
  updated_by int(11) NOT NULL,
  published_by int(11) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE structured_contents (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  catalog_id int(11) unsigned NOT NULL,
  name varchar(100) NOT NULL,
  publish_status enum('unpublished','published') NOT NULL DEFAULT 'unpublished',
  created_ts datetime NOT NULL,
  updated_ts datetime NOT NULL,
  published_ts datetime DEFAULT NULL,
  created_by int(11) NOT NULL,
  updated_by int(11) NOT NULL,
  published_by int(11) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE structured_contents_published (
  id int(11) unsigned NOT NULL,
  catalog_id int(11) unsigned NOT NULL,
  name varchar(100) NOT NULL,
  publish_status enum('unpublished','published') NOT NULL DEFAULT 'unpublished',
  created_ts datetime NOT NULL,
  updated_ts datetime NOT NULL,
  published_ts datetime DEFAULT NULL,
  created_by int(11) NOT NULL,
  updated_by int(11) NOT NULL,
  published_by int(11) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE structured_contents_details (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  content_id int(11) unsigned NOT NULL,
  langue_id int(1) unsigned NOT NULL,
  content_data text NOT NULL,
  page_id int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (id),
  UNIQUE KEY uk_item_lang (content_id,langue_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE structured_contents_details_published (
  id int(11) unsigned NOT NULL,
  content_id int(11) unsigned NOT NULL,
  langue_id int(1) unsigned NOT NULL,
  content_data text NOT NULL,
  page_id int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (id),
  UNIQUE KEY uk_item_lang (content_id,langue_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 2020-01-06 --

-- START 2020-01-28 --
-- ABJ
CREATE TABLE pages_urls (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  page_id int(11) unsigned NOT NULL,
  type enum('init') DEFAULT NULL,
  js_key varchar(100) NOT NULL,
  url varchar(2500) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
-- END 2020-01-28 --

-- START 2020-01-30 --
ALTER TABLE structured_contents
MODIFY COLUMN publish_status enum('unpublished','queued','published','error') NOT NULL DEFAULT 'unpublished';

ALTER TABLE structured_contents
ADD COLUMN to_generate tinyint(1) NOT NULL DEFAULT '0',
ADD COLUMN to_generate_by int(11) DEFAULT NULL,
ADD COLUMN to_publish tinyint(1) NOT NULL DEFAULT '0',
ADD COLUMN to_publish_by int(11) DEFAULT NULL,
ADD COLUMN to_publish_ts datetime DEFAULT NULL,
ADD COLUMN to_unpublish tinyint(1) NOT NULL DEFAULT '0',
ADD COLUMN to_unpublish_by int(11) DEFAULT NULL,
ADD COLUMN to_unpublish_ts datetime DEFAULT NULL,
ADD COLUMN publish_log mediumtext NOT NULL;

ALTER TABLE structured_contents_published
MODIFY COLUMN publish_status enum('unpublished','queued','published','error') NOT NULL DEFAULT 'unpublished';

ALTER TABLE structured_contents_published
ADD COLUMN to_generate tinyint(1) NOT NULL DEFAULT '0',
ADD COLUMN to_generate_by int(11) DEFAULT NULL,
ADD COLUMN to_publish tinyint(1) NOT NULL DEFAULT '0',
ADD COLUMN to_publish_by int(11) DEFAULT NULL,
ADD COLUMN to_publish_ts datetime DEFAULT NULL,
ADD COLUMN to_unpublish tinyint(1) NOT NULL DEFAULT '0',
ADD COLUMN to_unpublish_by int(11) DEFAULT NULL,
ADD COLUMN to_unpublish_ts datetime DEFAULT NULL,
ADD COLUMN publish_log mediumtext NOT NULL;
-- END 2020-01-30 --


-- START 2020-02-05 --

INSERT INTO config(code,val,comments) VALUES ('DYNAMIC_PAGES_COMPILER_DIRECTORY', '/home/ronaldo/pjt/dev_engines/pages/compiler/','used by dynamic pages download function');

-- END 2020-02-05 --

-- START 2020-02-21 --
DROP TABLE IF EXISTS page_libraries;

ALTER TABLE sections_fields
MODIFY COLUMN value  text NOT NULL DEFAULT '' AFTER type,
MODIFY COLUMN default_value  text NOT NULL DEFAULT '' AFTER value;

-- END 2020-02-21 --

-- START 2020-02-27 --

INSERT INTO config(code,val) VALUES ('CATALOG_DB','dev_catalog');
DELETE FROM config WHERE code = 'CATALOG_DB_NAME';

-- END 2020-02-27 --

-- START 2020-03-02

ALTER TABLE files
MODIFY COLUMN type  enum('css','js','fonts','other') NOT NULL;

-- 2MB, in bytes : 2 * 1024 * 1024 = 2097152
INSERT INTO config(code,val,comments) VALUES ('MAX_FILE_UPLOAD_SIZE', '2097152','size in bytes, must be numeric only');
-- 10MB, in bytes : 10 * 1024 * 1024 = 10485760
INSERT INTO config(code,val,comments) VALUES ('MAX_FILE_UPLOAD_SIZE_OTHER', '10485760','size in bytes, must be numeric only, used for [other] file type ');

ALTER TABLE components
ADD COLUMN thumbnail_status enum('unpublished','queued','processing','published','error') NOT NULL DEFAULT 'unpublished';

ALTER TABLE components
ADD COLUMN thumbnail_file_name varchar(100) NOT NULL DEFAULT '';

ALTER TABLE components
ADD COLUMN thumbnail_log mediumtext NOT NULL;

ALTER TABLE components
ADD COLUMN html mediumtext;


ALTER TABLE pages
ADD COLUMN get_html_status  enum('unpublished','queued','processing','published','error') NOT NULL DEFAULT 'unpublished';
ALTER TABLE pages
ADD COLUMN get_html_log mediumtext NOT NULL DEFAULT '';
ALTER TABLE pages
ADD COLUMN dynamic_html text NOT NULL DEFAULT '';

-- END 2020-03-02