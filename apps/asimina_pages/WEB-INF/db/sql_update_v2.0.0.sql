-- initial schema by Ali Adnan
-- START 21-01-2018 --

CREATE TABLE IF NOT EXISTS config (
  code varchar(100) NOT NULL DEFAULT '',
  val varchar(255) DEFAULT NULL,
  PRIMARY KEY (code)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO config SET code='app_version', val='1.5' ON DUPLICATE KEY UPDATE val=VALUES(val) ;

CREATE TABLE bloc_templates (
  id              int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  name            varchar(100) NOT NULL,
  site_id         int(10) UNSIGNED NOT NULL DEFAULT 0,
  custom_id       varchar(100) NOT NULL,
  description     varchar(500) NOT NULL DEFAULT '',
  template_code   mediumtext NOT NULL,
  css_code        text NOT NULL,
  js_code         text NOT NULL,

  created_ts      datetime NOT NULL,
  updated_ts      datetime NOT NULL,
  created_by      int(11) NOT NULL,
  updated_by      int(11) NOT NULL,

  PRIMARY KEY (id),
  UNIQUE INDEX uk_template_name (name)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE libraries (
  id          int(11) unsigned NOT NULL AUTO_INCREMENT,
  name        varchar(100) NOT NULL,
  site_id     int(10) UNSIGNED NOT NULL DEFAULT 0,

  created_ts  datetime NOT NULL,
  updated_ts  datetime NOT NULL,
  created_by  int(11) NOT NULL,
  updated_by  int(11) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE libraries_files (
  library_id     int(11) unsigned NOT NULL,
  file_id       int(11) unsigned NOT NULL,
  page_position enum('body','head') NOT NULL DEFAULT 'body',
  sort_order    int(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (library_id, file_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE files (
  id          int(11) unsigned NOT NULL AUTO_INCREMENT,
  file_name   varchar(100) NOT NULL,
  type        enum('css','js','fonts') NOT NULL,

  created_ts  datetime NOT NULL,
  updated_ts  datetime NOT NULL,
  created_by  int(11) NOT NULL,
  updated_by  int(11) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_files_name (file_name)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE bloc_templates_sections (
  id                  int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  bloc_template_id    int(11) UNSIGNED NOT NULL,
  name                varchar(100) NOT NULL,
  custom_id           varchar(100) NOT NULL,
  sort_order          int(11) UNSIGNED NOT NULL DEFAULT '0',
  nb_items            int(11) UNSIGNED NOT NULL DEFAULT 1 COMMENT '0 = unlimited',

  created_ts      datetime NOT NULL,
  updated_ts      datetime NOT NULL,
  created_by      int(11) NOT NULL,
  updated_by      int(11) NOT NULL,

  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE sections_fields (
  id              int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  section_id      int(11) UNSIGNED NOT NULL,
  name            varchar(100) NOT NULL,
  custom_id       varchar(100) NOT NULL,
  sort_order      int(11) UNSIGNED NOT NULL DEFAULT '0',
  nb_items        int(11) UNSIGNED NOT NULL DEFAULT 1 COMMENT '0 = unlimited',
  type            varchar(50) NOT NULL,
  value           varchar(500) NOT NULL DEFAULT '',
  default_value   varchar(500) NOT NULL DEFAULT '',
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE bloc_templates_libraries (
  bloc_template_id  int(11) UNSIGNED NOT NULL,
  library_id        int(11) UNSIGNED NOT NULL,

  PRIMARY KEY (bloc_template_id, library_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE blocs (
  id              int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  name            varchar(100) NOT NULL,
  site_id         int(10) UNSIGNED NOT NULL DEFAULT 0,
  template_id     int(11) UNSIGNED NOT NULL,

  refresh_interval int(11) NOT NULL DEFAULT '0' COMMENT 'interval in minutes, 0 = never',
  start_date      date DEFAULT NULL,
  end_date        date DEFAULT NULL,
  visible_to      enum('all','anonymous','logged') NOT NULL DEFAULT 'all',
  margin_top      int(11) NOT NULL DEFAULT 0 COMMENT 'margin in px',
  margin_bottom   int(11) NOT NULL DEFAULT 0 COMMENT 'margin in px',
  description     varchar(500) NOT NULL DEFAULT '',
  template_data   mediumtext NOT NULL,

  created_ts      datetime NOT NULL,
  updated_ts      datetime NOT NULL,
  created_by      int(11) NOT NULL,
  updated_by      int(11) NOT NULL,

  PRIMARY KEY (id),
  UNIQUE INDEX uk_template_name (name)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE pages (
  id              int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  name            varchar(100) NOT NULL,
  site_id         int(10) UNSIGNED NOT NULL DEFAULT 0,
  path            varchar(300) NOT NULL,
  langue_code     varchar(2) NOT NULL DEFAULT 'en',
  variant         enum('all','logged','anonymous') NOT NULL,
  html_file_path  varchar(1000) NOT NULL DEFAULT '' COMMENT 'relative path of the page html file',
  published_html_file_path  varchar(1000) NOT NULL DEFAULT '',
  canonical_url   varchar(500) NOT NULL,
  title           varchar(100) NOT NULL DEFAULT '',
  meta_keywords   varchar(500) NOT NULL DEFAULT '',
  meta_description varchar(500) NOT NULL DEFAULT '',
  template_id         int(11) UNSIGNED NOT NULL DEFAULT '0',

  created_ts      datetime NOT NULL,
  updated_ts      datetime NOT NULL,
  published_ts    datetime DEFAULT NULL,
  created_by      int(11) NOT NULL,
  updated_by      int(11) NOT NULL,
  published_by    int(11) DEFAULT NULL,

  to_generate     tinyint(1) NOT NULL DEFAULT '0',
  to_generate_by  int(11) DEFAULT NULL,

  to_publish      tinyint(1) NOT NULL DEFAULT '0',
  to_publish_by   int(11) DEFAULT NULL,
  to_publish_ts   datetime DEFAULT NULL,

  to_unpublish      tinyint(1) NOT NULL DEFAULT '0',
  to_unpublish_by   int(11) DEFAULT NULL,
  to_unpublish_ts   datetime DEFAULT NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uk_pages_path_variant_lang (path,variant,langue_code)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;



CREATE TABLE pages_blocs (
  page_id         int(11) UNSIGNED NOT NULL,
  bloc_id         int(11) UNSIGNED NOT NULL,
  sort_order      int(2) UNSIGNED NOT NULL,

  PRIMARY KEY (page_id, bloc_id, sort_order)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE images (
  file_name    varchar(40) NOT NULL,
  label       varchar(100) NOT NULL,

  created_ts  datetime NOT NULL,
  updated_ts  datetime NOT NULL,
  created_by  int(11) NOT NULL,
  updated_by  int(11) NOT NULL,
  PRIMARY KEY (file_name),
  KEY idx_image_label (label)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 21-01-2018 --
