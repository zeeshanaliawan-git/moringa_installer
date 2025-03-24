

-- START 2019-04-09 --
ALTER TABLE images
MODIFY COLUMN file_name  varchar(100) NOT NULL FIRST ;

ALTER TABLE images
ADD COLUMN file_size  decimal(20,2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT 'file size in kB (kilo bytes)' AFTER label;

ALTER TABLE files
ADD COLUMN file_size  decimal(20,2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT 'file size in kB (kilo bytes)' AFTER type;

-- END 2019-04-09 --

-- START 2019-04-15 --
CREATE TABLE pages_meta_tags (
  page_id    	int(11) UNSIGNED NOT NULL,
  meta_name     varchar(200) NOT NULL,
  meta_content  mediumtext NOT NULL,
  PRIMARY KEY (page_id,meta_name)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 2019-04-15 --

-- START 2019-04-19 --
ALTER TABLE pages
DROP COLUMN show_header_footer,
DROP COLUMN show_smart_banner;

-- END 2019-04-19 --

-- START 2019-04-22 --

ALTER TABLE bloc_templates_sections
ADD COLUMN parent_section_id  int(11) UNSIGNED NOT NULL DEFAULT 0 AFTER bloc_template_id;

-- END 2019-04-22 --

-- START 2019-05-02 --
ALTER TABLE bloc_templates
DROP INDEX uk_template_name;

ALTER TABLE blocs
DROP INDEX uk_template_name;

ALTER TABLE pages
DROP INDEX uk_pages_path_variant_lang ,
ADD UNIQUE INDEX uk_pages_path_variant_lang (site_id, path, variant, langue_code);

-- END 2019-05-02 --


-- START 2019-05-17 --
CREATE TABLE rss_feeds (
  id              int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  name            varchar(100) NOT NULL,
  site_id         int(10) UNSIGNED NOT NULL DEFAULT '0',
  url             varchar(1500) NOT NULL,
  max_items       int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '0 = All',
  is_active       tinyint(1) NOT NULL DEFAULT '1',
  activation_type enum('auto','update','never') NOT NULL DEFAULT 'auto',

  sync_frequency  int(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'No of days',
  sync_type       enum('delete','update','duplicate') NOT NULL DEFAULT 'delete',
  last_sync_ts    datetime NOT NULL,


  ch_title        varchar(1000) NOT NULL DEFAULT '',
  ch_link         varchar(1500) NOT NULL DEFAULT '',
  ch_description  varchar(1000) NOT NULL DEFAULT '',
  ch_language     varchar(100) NOT NULL DEFAULT '',
  ch_copyright    varchar(1000) NOT NULL DEFAULT '',
  ch_category     varchar(100) NOT NULL DEFAULT '',
  ch_ttl          varchar(100) NOT NULL DEFAULT '',
  ch_pubDate      varchar(100) NOT NULL DEFAULT '',
  ch_image_url    varchar(2000) NOT NULL DEFAULT '',
  ch_image_title  varchar(100) NOT NULL DEFAULT '',
  ch_extra_params text NOT NULL COMMENT 'extra param-values stored as JSON',

  is_error        tinyint(1) NOT NULL DEFAULT '0',
  error_text      mediumtext NOT NULL,

  created_ts      datetime NOT NULL,
  updated_ts      datetime NOT NULL,
  created_by      int(11) NOT NULL,
  updated_by      int(11) NOT NULL,

  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE rss_feeds_items (
  id              int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  rss_feed_id     int(11) UNSIGNED NOT NULL,
  is_active       tinyint(1) NOT NULL DEFAULT '1',

  title           varchar(2000) NOT NULL DEFAULT '',
  link            varchar(2000) NOT NULL DEFAULT '',
  description     text NOT NULL,
  guid            varchar(2000) NOT NULL DEFAULT '',
  enclosure_url   varchar(2000) NOT NULL DEFAULT '',
  enclosure_type  varchar(100) NOT NULL DEFAULT '',
  enclosure_length varchar(100) NOT NULL DEFAULT '',
  pubDate         varchar(100) NOT NULL DEFAULT '',
  pubDate_std     datetime NOT NULL DEFAULT '2000-01-01 00:00:00',
  category        varchar(100) NOT NULL DEFAULT '',
  author          varchar(100) NOT NULL DEFAULT '',
  comments        varchar(100) NOT NULL DEFAULT '',
  source          varchar(100) NOT NULL DEFAULT '',
  source_url      varchar(2000) NOT NULL DEFAULT '',
  extra_params    text NOT NULL COMMENT 'extra param-values stored as JSON',

  created_ts      datetime NOT NULL,
  updated_ts      datetime NOT NULL,

  PRIMARY KEY (id),
  KEY idx_rss_feed_id (rss_feed_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

ALTER TABLE bloc_templates
ADD COLUMN type enum('block','feed_view') NOT NULL DEFAULT 'block' AFTER custom_id;


ALTER TABLE blocs
ADD COLUMN rss_feed_ids  varchar(1000) NOT NULL DEFAULT '' AFTER template_data,
ADD COLUMN rss_feed_sort varchar(1000) NOT NULL DEFAULT '' AFTER rss_feed_ids;


-- END 2019-05-17 --

-- START 2019-05-28 --

ALTER TABLE rss_feeds
MODIFY COLUMN sync_frequency  int(10) UNSIGNED NOT NULL DEFAULT 1 AFTER activation_type;

ALTER TABLE rss_feeds
ADD COLUMN sync_frequency_unit  enum('minute','hour','day') NOT NULL DEFAULT 'minute' AFTER sync_frequency;

-- END 2019-05-28 --


-- START 2019-08-05 --
ALTER TABLE blocs
ADD COLUMN uuid varchar(100) DEFAULT NULL AFTER template_id;

UPDATE blocs SET uuid = UUID();

ALTER TABLE blocs
MODIFY COLUMN uuid varchar(100) NOT NULL;

ALTER TABLE blocs
ADD UNIQUE INDEX uk_bloc_uuid (site_id,uuid) ;
-- END 2019-08-05 --



-- START 2019-08-21 --
ALTER TABLE files
MODIFY COLUMN file_name varchar(300) NOT NULL;

ALTER TABLE images
MODIFY COLUMN file_name varchar(300) NOT NULL;

ALTER table pages
ADD COLUMN social_title     varchar(100) NOT NULL DEFAULT '' AFTER published_by,
ADD COLUMN social_type      varchar(100) NOT NULL DEFAULT 'website' AFTER social_title,
ADD COLUMN social_description   varchar(500) NOT NULL DEFAULT '' AFTER social_type,
ADD COLUMN social_image     varchar(500) NOT NULL DEFAULT '' AFTER social_description,
ADD COLUMN social_twitter_message  varchar(500) NOT NULL DEFAULT '' AFTER social_image,
ADD COLUMN social_twitter_hashtags  varchar(500) NOT NULL DEFAULT '' AFTER social_twitter_message,
ADD COLUMN social_email_subject   varchar(100) NOT NULL DEFAULT '' AFTER social_twitter_hashtags,
ADD COLUMN social_email_popin_title varchar(100) NOT NULL DEFAULT '' AFTER social_email_subject,
ADD COLUMN social_email_message   varchar(1000) NOT NULL DEFAULT '' AFTER social_email_popin_title,
ADD COLUMN social_sms_text      varchar(500) NOT NULL DEFAULT '' AFTER social_email_message;

-- END 2019-08-21 --



-- START 2019-10-07 --
alter table dev_pages.config add comments text;

insert into dev_pages.config (code, val) values ('BASE_DIR','/home/ronaldo/tomcat/webapps/dev_pages/');
insert into dev_pages.config (code, val) values ('UPLOADS_FOLDER','uploads/');
insert into dev_pages.config (code, val) values ('EXTERNAL_LINK','/dev_pages/');
insert into dev_pages.config (code, val) values ('PROD_EXTERNAL_LINK','/dev_pages/');
insert into dev_pages.config (code, val) values ('IS_PRODUCTION_ENV','0');
insert into dev_pages.config (code, val) values ('SEMAPHORE','D004');
insert into dev_pages.config (code, val) values ('PAGES_SAVE_FOLDER','admin/pages/');
insert into dev_pages.config (code, val) values ('PAGES_PUBLISH_FOLDER','pages/');
insert into dev_pages.config (code, val) values ('SEND_REDIRECT_LINK','/dev_pages/sites/');
insert into dev_pages.config (code, val) values ('GESTION_URL','/dev_catalog/admin/gotopages.jsp');
insert into dev_pages.config (code, val) values ('MENU_IMAGES_PATH','/menu_resources/uploads/');
insert into dev_pages.config (code, val) values ('MENU_IMAGES_FOLDER','/home/ronaldo/tomcat/webapps/dev_pages/menu_resources/uploads/');
insert into dev_pages.config (code, val) values ('PORTAL_DB','dev_portal');
insert into dev_pages.config (code, val) values ('CATALOG_ROOT','/dev_catalog');
insert into dev_pages.config(code,val) values ('COMMONS_DB','dev_commons');

delete from dev_pages.config where code = 'app_version';
-- END 2019-10-07 --

-- START 2019-10-31 --
-- integration of dynamic pages

ALTER TABLE pages
ADD COLUMN type  enum('freemarker','react') NOT NULL DEFAULT 'freemarker' AFTER site_id;

ALTER TABLE pages
ADD COLUMN package_name  varchar(100) NOT NULL DEFAULT '' COMMENT 'for react pages' AFTER template_id,
ADD COLUMN class_name  varchar(100) NOT NULL DEFAULT '' COMMENT 'for react pages' AFTER package_name,
ADD COLUMN layout  enum('react-grid-layout') NOT NULL DEFAULT 'react-grid-layout' AFTER class_name;

ALTER TABLE pages
ADD COLUMN publish_status  enum('unpublished','queued','processing','published','error') NOT NULL DEFAULT 'unpublished' AFTER to_unpublish_ts,
ADD COLUMN publish_log  mediumtext NOT NULL AFTER publish_status;



CREATE TABLE page_libraries (
  page_id int(11) unsigned NOT NULL,
  library_id int(11) unsigned NOT NULL,
  PRIMARY KEY (page_id,library_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE page_items (
  id    int(11) unsigned NOT NULL AUTO_INCREMENT,
  page_id   int(11) unsigned NOT NULL,
  index_key   smallint(5) unsigned NOT NULL,
  component_id  int(11) unsigned NOT NULL,
  x_cord    smallint(5) unsigned NOT NULL,
  y_cord    smallint(5) unsigned NOT NULL,
  width     smallint(5) unsigned NOT NULL,
  height    smallint(5) unsigned NOT NULL,
  css_classes varchar(1000) NOT NULL DEFAULT '' COMMENT 'space seperated classes, for class attribute',
  css_style varchar(4000) NOT NULL DEFAULT '' COMMENT 'json object for style attribute',
  PRIMARY KEY (id),
  UNIQUE KEY page_id (page_id,index_key)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE page_item_property_values (
  page_item_id int(11) unsigned NOT NULL,
  property_id int(11) unsigned NOT NULL,
  value varchar(4000) NOT NULL,
  PRIMARY KEY (page_item_id,property_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE components (
  id      int(11) unsigned NOT NULL AUTO_INCREMENT,
  name    varchar(100) NOT NULL,
  site_id   int(10) unsigned NOT NULL DEFAULT '0',
  file_path   varchar(500) NOT NULL,
  created_ts  datetime NOT NULL,
  updated_ts  datetime NOT NULL,
  created_by  int(11) NOT NULL,
  updated_by  int(11) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE component_dependencies (
  dependant_component_id  int(11) unsigned NOT NULL,
  main_component_id     int(11) unsigned NOT NULL,
  PRIMARY KEY (dependant_component_id,main_component_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE component_packages (
  component_id int(11) unsigned NOT NULL,
  package_name varchar(100) NOT NULL,
  PRIMARY KEY (component_id,package_name)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE component_properties (
  id        int(11) unsigned NOT NULL AUTO_INCREMENT,
  component_id  int(11) unsigned NOT NULL,
  name      varchar(100) NOT NULL,
  type      enum('json','string','number','boolean') NOT NULL,
  is_required   tinyint(1) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (id),
  UNIQUE KEY uk_comp_property_name (component_id,name)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 2019-10-31 --

-- START 2019-11-07 --
CREATE TABLE component_libraries (
  component_id int(11) unsigned NOT NULL,
  library_id int(11) unsigned NOT NULL,
  PRIMARY KEY (component_id,library_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 2019-11-07 --



-- START 2019-11-12 --
ALTER TABLE component_properties
MODIFY COLUMN type  enum('json','string','number','boolean','image') NOT NULL AFTER name;

-- END 2019-11-12 --

-- START 2019-11-15 --
ALTER TABLE pages
ADD COLUMN row_height int(11) DEFAULT '50' COMMENT 'in px',
ADD COLUMN item_margin_x int(11) DEFAULT '5' COMMENT 'x margin between items in px',
ADD COLUMN item_margin_y int(11) DEFAULT '5' COMMENT 'y margin between items in px',
ADD COLUMN container_padding_x int(11) DEFAULT '5' COMMENT 'x padding inside the item container in px',
ADD COLUMN container_padding_y int(11) DEFAULT '5' COMMENT 'y padding inside the item container in px';
-- END 2019-11-15 --

-- START 2019-11-18 --
CREATE TABLE page_component_urls (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  type enum('component','item') NOT NULL,
  component_id int(11) unsigned NOT NULL COMMENT 'set for type=component , 0 for type=item',
  page_item_id int(11) unsigned NOT NULL COMMENT 'set for type=item , 0 for type=component',
  url varchar(2000) NOT NULL DEFAULT '',
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
-- END 2019-11-18 --

-- START 2019-11-19 --
-- ABJ
ALTER TABLE components
ADD COLUMN thumbnail_status enum('none','processing','error','done') NOT NULL DEFAULT 'none';

ALTER TABLE components
ADD COLUMN thumbnail_file_name varchar(100) NOT NULL DEFAULT '';

ALTER TABLE components
ADD COLUMN thumbnail_log mediumtext NOT NULL DEFAULT '';

drop view language;
create view language as select * from dev_catalog.language;
-- END 2019-11-19 --

