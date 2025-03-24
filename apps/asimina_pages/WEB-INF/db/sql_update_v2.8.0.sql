-- START 07-04-2021 --
ALTER TABLE pages
ADD COLUMN uuid varchar(36) not null default uuid() AFTER id;

ALTER TABLE structured_catalogs
ADD COLUMN uuid varchar(36) not null default uuid() AFTER id;

ALTER TABLE structured_catalogs_published
ADD COLUMN uuid varchar(36) AFTER id;

-- END 07-04-2021 --


-- START 08-04-2021 --
-- system templates
ALTER TABLE bloc_templates
ADD COLUMN is_system TINYINT(1) DEFAULT '0' AFTER js_code;


ALTER TABLE bloc_templates_sections
ADD COLUMN is_system TINYINT(1) DEFAULT '0' AFTER nb_items;

ALTER TABLE sections_fields
ADD COLUMN is_system TINYINT(1) DEFAULT '0' AFTER placeholder;

ALTER TABLE bloc_templates
MODIFY COLUMN type enum('block','feed_view','structured_content','structured_page','menu') NOT NULL DEFAULT 'block';

INSERT INTO dev_catalog.page (name, url, parent, rang, new_tab, icon, parent_icon)
VALUES ('System templates', '/dev_pages/admin/systemTemplates.jsp', 'Templates', '800', '0', 'chevron-right', 'layout');

UPDATE dev_catalog.page SET parent = 'Developer' WHERE parent = 'Templates';

INSERT INTO dev_catalog.page (name, url, parent, rang, new_tab, icon, parent_icon)
VALUES ('Menus (beta)', '/dev_pages/admin/menus.jsp', 'Developer', '802', '0', 'chevron-right', 'layout');

CREATE TABLE dev_portal.menus (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  uuid varchar(36) NOT NULL DEFAULT uuid(),
  name varchar(300) NOT NULL,
  site_id int(10) unsigned NOT NULL DEFAULT 0,
  template_id int(11) unsigned NOT NULL,
  langue_id int(1) unsigned NOT NULL,
  production_path varchar(300) NOT NULL,
  variant enum('all','logged','anonymous') NOT NULL,
  template_data mediumtext NOT NULL,

  homepage_url varchar(2000) NOT NULL DEFAULT '',
  page_404_url varchar(2000) NOT NULL DEFAULT '',
  favicon varchar(300) NOT NULL DEFAULT '',
  favicon_alt varchar(300) NOT NULL DEFAULT '',

  created_ts datetime NOT NULL,
  updated_ts datetime NOT NULL,
  published_ts datetime DEFAULT NULL,
  created_by int(11) NOT NULL,
  updated_by int(11) NOT NULL,
  published_by int(11) DEFAULT NULL,

  to_generate tinyint(1) NOT NULL DEFAULT 0,
  to_generate_by int(11) DEFAULT NULL,
  to_publish tinyint(1) NOT NULL DEFAULT 0,
  to_publish_by int(11) DEFAULT NULL,
  to_publish_ts datetime DEFAULT NULL,
  to_unpublish tinyint(1) NOT NULL DEFAULT 0,
  to_unpublish_by int(11) DEFAULT NULL,
  to_unpublish_ts datetime DEFAULT NULL,
  publish_status enum('unpublished','queued','processing','published','error') NOT NULL DEFAULT 'unpublished',
  publish_log mediumtext NOT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE dev_portal.menus_apply_to (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  menu_id int(11) unsigned NOT NULL,
  apply_type enum('url','url_starting_with','drupal_pages','db_pages') NOT NULL,
  apply_to varchar(255) NOT NULL,
  replace_tags varchar(255) NOT NULL DEFAULT '',
  prod_apply_to varchar(255) NOT NULL DEFAULT '',
  cache int(1) NOT NULL DEFAULT 0,
  cache_refresh_interval int(11) NOT NULL DEFAULT 0,
  cache_refresh_on varchar(5) DEFAULT NULL,
  add_gtm_script tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE VIEW menus AS
SELECT * FROM dev_portal.menus;

CREATE VIEW menus_apply_to AS
SELECT * FROM dev_portal.menus_apply_to;

ALTER TABLE page_templates_items_blocs
ADD COLUMN type enum('bloc','menu') NULL DEFAULT 'bloc' AFTER bloc_id;

ALTER TABLE page_templates_items_blocs
DROP PRIMARY KEY,
ADD PRIMARY KEY (item_id, langue_id, bloc_id, type);

INSERT INTO dev_commons.config(code,val,comments) VALUES ('MENU_APP_URL', '/dev_menu/','');

INSERT INTO dev_commons.config(code,val,comments) VALUES ('PROD_PORTAL_DB', 'dev_prod_portal','');


-- END 08-04-2021 --