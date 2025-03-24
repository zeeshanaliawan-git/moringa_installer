
-- START 5-07-2021

CREATE TABLE sites_details  (
  site_id int(10) unsigned NOT NULL,
  langue_id int(1) unsigned NOT NULL,
  production_path varchar(300) NOT NULL DEFAULT '',
  homepage_url  varchar(2000) NOT NULL DEFAULT '',
  page_404_url  varchar(2000) NOT NULL DEFAULT '',
  default_page_template_id  int(11) unsigned NOT NULL DEFAULT '0',
  login_page_template_id    int(11) unsigned NOT NULL DEFAULT '0',
  cart_page_template_id     int(11) unsigned NOT NULL DEFAULT '0',
  funnel_page_template_id   int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (site_id, langue_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE sites_apply_to (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  site_id int(10) unsigned NOT NULL,
  apply_type enum('url','url_starting_with','drupal_pages','db_pages') NOT NULL,
  apply_to varchar(255) NOT NULL,
  replace_tags varchar(255) NOT NULL DEFAULT '',
  cache int(1) NOT NULL DEFAULT 0,
  add_gtm_script tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 5-07-2021


-- START 06-07-2021
alter table site_menus add menu_version enum('V1','V2') not null default 'V1';

insert ignore into sites_details (site_id, langue_id, production_path, homepage_url, page_404_url)  select m.site_id, l.langue_id, m.production_path, m.prod_homepage_url, m.prod_404_url from dev_prod_portal.site_menus m, dev_prod_portal.language l where l.langue_code = m.lang;

insert into sites_apply_to(site_id,apply_type,apply_to,replace_tags,cache,add_gtm_script) select distinct m.site_id,apply_type,prod_apply_to,replace_tags,cache,add_gtm_script from dev_prod_portal.site_menus m, dev_prod_portal.menu_apply_to a where m.id = a.menu_id;

delete from sites_apply_to where site_id = 0;

-- END 06-07-2021


-- START 07-07-2021

alter table cached_pages add cache_uuid varchar(36) not null default uuid();

//only required in portal config
insert into config (code, val, comments) values ('PROD_RELOAD_SINGLETONS_INTERNAL_URL','http://127.0.0.1/dev_prodportal/reloadSingletons.jsp', 'Used by engine at time of publishing the site');
-- END 07-07-2021

-- START 26-07-2021 --
alter table sites_details add login_page_url varchar(500);

insert into config (code, val, comments) values ('payment_return_jsp','/cart/recap.jsp', 'configure this for your shop');

insert into config (code, val, comments) values ('ESHOP_FRAUD_JSP','/cart/default_error_fraud.jsp', 'configure this for your shop');
insert into config (code, val, comments) values ('ESHOP_SERVER_ERROR_JSP','/cart/default_error_server.jsp', 'configure this for your shop');
-- END 26-07-2021 --

-- START 10-08-2021 --
-- later fix in case there are invalid empty production_path column in sites_details

UPDATE sites_details sd
JOIN sites s ON s.id = sd.site_id
JOIN language l ON l.langue_id = sd.langue_id
SET sd.production_path = REGEXP_REPLACE(LOWER(s.name),'[^a-z0-9]','-')
WHERE TRIM(sd.production_path) = '';

-- END 10-08-2021 --
