-- START 10-03-2021 --
-- block system

CREATE TABLE page_templates (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  name varchar(100) NOT NULL,
  site_id int(10) unsigned NOT NULL DEFAULT 0,
  custom_id varchar(100) NOT NULL,
  description varchar(500) NOT NULL DEFAULT '',
  template_code mediumtext NOT NULL,
  is_system  tinyint(1) NULL DEFAULT 0 COMMENT '1 = system entity not to delete , selective edit',
  uuid varchar(36) NOT NULL DEFAULT UUID(),
  created_ts datetime NOT NULL,
  updated_ts datetime NOT NULL,
  created_by int(11) NOT NULL,
  updated_by int(11) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_page_template_custom_id (site_id,custom_id),
  UNIQUE KEY uk_page_template_uuid( uuid)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE page_templates_items (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  page_template_id int(11) unsigned NOT NULL,
  name varchar(100) NOT NULL,
  custom_id varchar(100) NOT NULL,
  sort_order int(2) unsigned NOT NULL DEFAULT 0,
  created_ts datetime NOT NULL,
  updated_ts datetime NOT NULL,
  created_by int(11) NOT NULL,
  updated_by int(11) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE page_templates_items_details (
  item_id int(11) unsigned NOT NULL,
  langue_id int(1) unsigned NOT NULL,
  css_classes varchar(500) NOT NULL DEFAULT '',
  css_style varchar(1000) NOT NULL DEFAULT '',
  PRIMARY KEY (item_id, langue_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE page_templates_items_blocs (
  item_id int(11) unsigned NOT NULL,
  langue_id int(1) unsigned NOT NULL,
  bloc_id int(11) unsigned NOT NULL,
  sort_order int(2) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (item_id, langue_id, bloc_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


-- creating default page template for each site

INSERT IGNORE INTO page_templates (name, site_id, custom_id, description, template_code, is_system, uuid, created_ts, updated_ts, created_by, updated_by )
SELECT 'Default template' AS name,
    sites.id AS site_id,
    'default_template' AS custom_id,
    'Default page template' AS description,
    '<!DOCTYPE html>\n<html>\n    <head>\n        \n    </head>\n    <body>\n        ${content}\n    </body>\n</html>' AS template_code,
    '1' AS is_system,
    UUID() AS uuid,
    NOW() AS created_ts,
    NOW() AS updated_ts,
    '1' AS created_by,
    '1' AS updated_by
FROM dev_portal.sites AS sites
order by sites.id;

INSERT IGNORE INTO page_templates_items(page_template_id, name, custom_id, sort_order, created_ts, updated_ts, created_by, updated_by)
SELECT t.id AS page_template_id,
    'Content' AS name,
    'content' AS custom_id,
    '0' AS sort_order,
    NOW() AS created_ts,
    NOW() AS updated_ts,
    '1' AS created_by,
    '1' AS updated_by
FROM page_templates AS t
ORDER BY t.id;

INSERT IGNORE INTO page_templates_items_details( item_id, langue_id, css_classes, css_style )
SELECT items.id AS item_id,
    l.langue_id AS langue_id,
    '' AS css_classes,
    '' AS css_style
FROM page_templates_items AS items, `language` AS l
ORDER BY items.id, l.langue_id;

INSERT INTO dev_catalog.page (name, url, parent, rang, new_tab, icon, parent_icon) VALUES ('Page templates', '/dev_pages/admin/pageTemplates.jsp', 'Templates', '800', '0', 'chevron-right', 'layout');


-- Set new default template IDs for each page corresponding to its site_id
UPDATE pages
SET template_id = (
    select id
    from page_templates
    where site_id = pages.site_id
);

