drop view page;
create view page as select * from dev_catalog.page;

ALTER TABLE dev_pages.bloc_templates RENAME TO dev_pages.bloc_templates_tbl;
ALTER TABLE dev_pages.bloc_templates_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_pages.bloc_templates AS SELECT * FROM bloc_templates_tbl WHERE is_deleted =0;

ALTER TABLE dev_pages.page_templates RENAME TO dev_pages.page_templates_tbl;
ALTER TABLE dev_pages.page_templates_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_pages.page_templates AS SELECT * FROM page_templates_tbl WHERE is_deleted =0;

ALTER TABLE dev_pages.files RENAME TO dev_pages.files_tbl;
ALTER TABLE dev_pages.files_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_pages.files AS SELECT * FROM files_tbl WHERE is_deleted =0;

ALTER TABLE dev_pages.libraries RENAME TO dev_pages.libraries_tbl;
ALTER TABLE dev_pages.libraries_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_pages.libraries AS SELECT * FROM libraries_tbl WHERE is_deleted =0;


-- Start 6-4-2022 --
CREATE TABLE freemarker_pages (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  uuid varchar(36) NOT NULL DEFAULT uuid(),
  name varchar(300) NOT NULL,
  site_id int(10) unsigned NOT NULL DEFAULT 0,
  folder_id int(11) unsigned NOT NULL DEFAULT 0,
  is_deleted tinyint(1) NOT NULL DEFAULT 0,
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
  publish_log mediumtext NOT NULL DEFAULT  '',
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE parent_pages_blocs (
  page_id int(11) unsigned NOT NULL,
  bloc_id int(11) unsigned NOT NULL,
  type enum('freemarker','structured') NOT NULL DEFAULT 'freemarker',
  sort_order int(2) unsigned NOT NULL,
  PRIMARY KEY (page_id,bloc_id,sort_order)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE parent_pages_forms (
  page_id int(11) unsigned NOT NULL,
  type enum('freemarker','structured') NOT NULL DEFAULT 'freemarker',
  form_id varchar(36) NOT NULL,
  sort_order int(2) unsigned NOT NULL,
  PRIMARY KEY (page_id,form_id,sort_order)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

ALTER TABLE pages ADD COLUMN parent_page_id  int(11) NOT NULL AFTER layout_data;

create table pages_blocs_v3_3_bkup as select * from pages_blocs;
create table pages_forms_v3_3_bkup as select * from pages_forms;
create table pages_v3_3_bkup as select * from pages;

-- End 6-4-2022 --

alter table sections_fields add is_bulk_modify tinyint(1) not null default 0;