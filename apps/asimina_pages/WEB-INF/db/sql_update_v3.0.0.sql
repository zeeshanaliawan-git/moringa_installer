-- START DATE 9-12-2021 --
CREATE TABLE themes (
    id              int(11) unsigned NOT NULL AUTO_INCREMENT,
    uuid            varchar(36) NOT NULL DEFAULT uuid(),
    name            varchar(100) NOT NULL,
    site_id         int(10) unsigned NOT NULL DEFAULT 0,
    version         varchar(10) NOT NULL,
    asimina_version varchar(10) NOT NULL DEFAULT '1.0.0',
    description     varchar(1000) NOT NULL default '',
    status          enum ('opened', 'locked') NOT NULL DEFAULT 'opened',
    type            enum ('local', 'remote') NOT NULL DEFAULT 'local',
    is_active       tinyint(1) default 0,
    created_ts      datetime NOT NULL,
    updated_ts      datetime NOT NULL,
    created_by      int(11) NOT NULL,
    updated_by      int(11) NOT NULL,
    published_by    int(11) DEFAULT NULL,
    published_ts    datetime DEFAULT NULL,
    to_publish      tinyint(1) NOT NULL DEFAULT 0,
    to_unpublish    tinyint(1) NOT NULL DEFAULT 0,
    to_publish_by   int(11) DEFAULT NULL,
    to_unpublish_by int(11) DEFAULT NULL,
    to_publish_ts   datetime DEFAULT NULL,
    to_unpublish_ts datetime DEFAULT NULL,
    publish_status  enum('unpublished','queued','processing','published','error') NOT NULL DEFAULT 'unpublished',
    publish_log     mediumtext NOT NULL DEFAULT '',

    PRIMARY KEY (id),
    UNIQUE KEY uk_theme (id, site_id, name, version)
) ENGINE = MyISAM DEFAULT CHARSET = utf8;

INSERT INTO config
VALUES ('THEMES_FOLDER', 'themes/', '');

CREATE TABLE menu_js (
    id           int(11) unsigned NOT NULL AUTO_INCREMENT,
    uuid         varchar(36) NOT NULL DEFAULT uuid(),
    name         varchar(300) NOT NULL,
    site_id      int(10) unsigned NOT NULL DEFAULT 0,
    description  varchar(1000) NOT NULL default '',
    created_ts   datetime NOT NULL DEFAULT NOW(),
    updated_ts   datetime NOT NULL DEFAULT NOW(),
    created_by   int(11) NOT NULL,
    updated_by   int(11) NOT NULL,
    publish_status enum('unpublished','published','error') NOT NULL DEFAULT 'unpublished',
    published_by int(11) NOT NULL,
    published_ts datetime NOT NULL DEFAULT NOW(),
    publish_log mediumtext NOT NULL DEFAULT '',
    PRIMARY KEY (id)
) ENGINE = MyISAM DEFAULT CHARSET = utf8;

CREATE TABLE menu_js_details (
    menu_js_id       int(11) unsigned NOT NULL,
    langue_id        int(1) unsigned NOT NULL,
    header_bloc_id   int(11) unsigned NOT NULL DEFAULT 0,
    header_bloc_type enum ('bloc','menu') NOT NULL DEFAULT 'bloc',
    footer_bloc_id   int(11) unsigned NOT NULL DEFAULT 0,
    footer_bloc_type enum ('bloc','menu') NOT NULL DEFAULT 'bloc',
    published_json   mediumtext NOT NULL DEFAULT '{}',
    PRIMARY KEY (menu_js_id, langue_id)
) ENGINE = MyISAM DEFAULT CHARSET = utf8;

-- END DATE 9-12-2021 --

-- START DATE 29-12-2021 --

ALTER TABLE page_templates
ADD COLUMN theme_id  int(11)  UNSIGNED NOT NULL DEFAULT 0 AFTER is_system,
ADD COLUMN theme_version  varchar(10) NOT NULL DEFAULT 0 AFTER theme_id;

ALTER TABLE bloc_templates
ADD COLUMN theme_id  int(11)  UNSIGNED NOT NULL DEFAULT 0 AFTER jsonld_code,
ADD COLUMN theme_version  varchar(10) NOT NULL DEFAULT 0 AFTER theme_id;

ALTER TABLE libraries
ADD COLUMN theme_id  int(11) UNSIGNED NOT NULL DEFAULT 0 AFTER site_id,
ADD COLUMN theme_version  varchar(10) NOT NULL DEFAULT 0 AFTER theme_id;

ALTER TABLE files
ADD COLUMN theme_id  int(11) UNSIGNED NOT NULL DEFAULT 0 AFTER images_generated,
ADD COLUMN theme_version  varchar(10) NOT NULL DEFAULT 0 AFTER theme_id;

-- END DATE 29-12-2021 --

-- START DATE 30-12-2021 --
insert into dev_commons.config (code, val) values ("partoo_api_base_url", "https://api.sandbox.partoo.co/v2");

CREATE TABLE partoo_contents (
  cid int(11) unsigned NOT NULL,
  ctype enum('store','folder') not null default 'store',
  site_id int(10) unsigned not null,
  partoo_id varchar(255) default null,
  partoo_error mediumtext default null,
  rjson mediumtext default null,
  partoo_json mediumtext default null,
  created_ts timestamp not null default CURRENT_TIMESTAMP,
  updated_ts datetime default null,
  PRIMARY KEY (cid, ctype, site_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE partoo_publish (
  id int(11) unsigned auto_increment,
  cid int(11) unsigned not null,
  site_id int(10) unsigned not null,  
  ctype enum('store','folder') not null default 'store',
  status int(1) not null default 0,
  created_ts timestamp not null default CURRENT_TIMESTAMP,
  created_by int(11),
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END DATE 30-12-2021 --

-- START 05-01-2021

REPLACE INTO dev_catalog.page (name, url, parent, rang, new_tab, icon, parent_icon)
VALUES ('Themes', '/dev_pages/admin/themes.jsp', 'Developer', '810', '0', 'chevron-right', 'layout');

UPDATE dev_catalog.page  SET name = 'Templates', rang = '815'
WHERE url LIKE '%/dev_pages/admin/blocTemplates.jsp%';

UPDATE dev_catalog.page  SET rang = '820'
WHERE parent = 'Developer' AND name = 'System templates';

UPDATE dev_catalog.page  SET rang = '825'
WHERE parent = 'Developer' AND name = 'Page templates';

UPDATE dev_catalog.page  SET rang = '830'
WHERE parent = 'Developer' AND name = 'Files';

UPDATE dev_catalog.page  SET rang = '835'
WHERE parent = 'Developer' AND name = 'Libraries';

REPLACE INTO dev_catalog.page (name, url, parent, rang, new_tab, icon, parent_icon)
VALUES ('Menu js', '/dev_pages/admin/menuJs.jsp', 'Content', '311', '0', 'chevron-right', 'file-text');

-- END 05-01-2022 --

-- START 10-01-2022 --
INSERT INTO dev_commons.config VALUE("MIN_ASIMINA_VERSION", "3.0.0", "");

INSERT INTO config
VALUES ('HTTP_CONNECTION_TIMEOUT', '10000', 'used to URL connection to connect to external APIs');
-- END 10-01-2022 --

